/**
 * PFC-API-Connector (SKL-154) — Config-Driven HTTP Integration
 *
 * Generic, config-driven HTTP connector for external API sources.
 * Handles auth, polling, rate-limiting, retry with backoff, and caching.
 * New API sources require only a config file — no code changes.
 *
 * @version 0.1.0
 * @classification SKILL_STANDALONE
 * @cascadeTier PFC
 * @epic Epic 90 F90.1
 */

class PfcApiConnector {
  constructor(config) {
    this.config = config;
    this.endpoint = config.endpoint;
    this.authMethod = config.authMethod;
    this.authParamName = config.authParamName;
    this.secretRef = config.secretRef;
    this.pollingIntervalSec = config.pollingIntervalSec || 300;
    this.rateLimitPerMin = config.rateLimitPerMin || 10;
    this.retryPolicy = config.retryPolicy || { maxRetries: 3, backoffMs: 2000 };
    this.responseMapping = config.responseMapping || {};

    // State
    this._apiKey = null;
    this._pollTimer = null;
    this._requestCount = 0;
    this._requestWindowStart = Date.now();
    this._cache = null;
    this._cacheTimestamp = null;
    this._listeners = [];
    this._totalCreditsUsed = 0;
  }

  /**
   * Set API key (from environment or manual input)
   */
  setApiKey(key) {
    this._apiKey = key;
  }

  /**
   * Check if API key is configured
   */
  hasApiKey() {
    return !!this._apiKey;
  }

  /**
   * Build request URL with auth
   */
  _buildUrl(params = {}) {
    const url = new URL(this.endpoint);

    if (this.authMethod === 'query-param') {
      url.searchParams.set(this.authParamName, this._apiKey);
    }

    Object.entries(params).forEach(([k, v]) => {
      url.searchParams.set(k, v);
    });

    return url.toString();
  }

  /**
   * Build request headers with auth
   */
  _buildHeaders() {
    const headers = { 'Accept': 'application/json' };

    if (this.authMethod === 'header') {
      headers[this.authParamName] = this._apiKey;
    } else if (this.authMethod === 'bearer') {
      headers['Authorization'] = `Bearer ${this._apiKey}`;
    }

    return headers;
  }

  /**
   * Rate limit check — returns true if request is allowed
   */
  _checkRateLimit() {
    const now = Date.now();
    const windowMs = 60000;

    if (now - this._requestWindowStart > windowMs) {
      this._requestCount = 0;
      this._requestWindowStart = now;
    }

    if (this._requestCount >= this.rateLimitPerMin) {
      console.warn(`[PFC-API-Connector] Rate limit reached (${this.rateLimitPerMin}/min). Waiting.`);
      return false;
    }

    this._requestCount++;
    return true;
  }

  /**
   * Fetch with retry and backoff
   */
  async fetch(params = {}) {
    if (!this._apiKey) {
      return { success: false, error: 'NO_API_KEY', message: `Set API key via setApiKey() or env ${this.secretRef}` };
    }

    if (!this._checkRateLimit()) {
      return { success: false, error: 'RATE_LIMITED', message: `Max ${this.rateLimitPerMin} requests/min` };
    }

    const url = this._buildUrl(params);
    const headers = this._buildHeaders();

    let lastError = null;
    for (let attempt = 0; attempt <= this.retryPolicy.maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          const delay = this.retryPolicy.backoffMs * Math.pow(2, attempt - 1);
          console.log(`[PFC-API-Connector] Retry ${attempt}/${this.retryPolicy.maxRetries} after ${delay}ms`);
          await new Promise(r => setTimeout(r, delay));
        }

        const response = await fetch(url, { headers, signal: AbortSignal.timeout(10000) });

        if (!response.ok) {
          lastError = `HTTP ${response.status}: ${response.statusText}`;
          if (response.status === 401 || response.status === 403) {
            return { success: false, error: 'AUTH_FAILED', message: lastError, status: response.status };
          }
          if (response.status === 429) {
            continue; // retry on rate limit from server
          }
          continue;
        }

        const data = await response.json();

        const result = {
          success: true,
          data: data,
          fetchedAt: new Date().toISOString(),
          source: this.config['@id'] || this.config.displayName || 'unknown',
          status: response.status,
          attempt: attempt + 1
        };

        // Cache
        this._cache = result;
        this._cacheTimestamp = Date.now();
        this._totalCreditsUsed++;

        // Notify listeners
        this._listeners.forEach(fn => fn(result));

        return result;

      } catch (err) {
        lastError = err.message || String(err);
        if (err.name === 'AbortError') lastError = 'Request timeout (10s)';
      }
    }

    return { success: false, error: 'FETCH_FAILED', message: lastError, attempts: this.retryPolicy.maxRetries + 1 };
  }

  /**
   * Get cached response (if fresh enough)
   */
  getCached(maxAgeMs) {
    if (!this._cache || !this._cacheTimestamp) return null;
    const age = Date.now() - this._cacheTimestamp;
    if (maxAgeMs && age > maxAgeMs) return null;
    return { ...this._cache, fromCache: true, cacheAgeMs: age };
  }

  /**
   * Start polling at configured interval
   */
  startPolling(params = {}, onResult) {
    if (this._pollTimer) this.stopPolling();

    if (onResult) this._listeners.push(onResult);

    console.log(`[PFC-API-Connector] Polling started: every ${this.pollingIntervalSec}s`);

    // Immediate first fetch
    this.fetch(params);

    this._pollTimer = setInterval(() => {
      this.fetch(params);
    }, this.pollingIntervalSec * 1000);
  }

  /**
   * Stop polling
   */
  stopPolling() {
    if (this._pollTimer) {
      clearInterval(this._pollTimer);
      this._pollTimer = null;
      console.log('[PFC-API-Connector] Polling stopped');
    }
  }

  /**
   * Add listener for fetch results
   */
  onResult(fn) {
    this._listeners.push(fn);
  }

  /**
   * Get connector status
   */
  getStatus() {
    return {
      configured: this.hasApiKey(),
      polling: !!this._pollTimer,
      pollingIntervalSec: this.pollingIntervalSec,
      totalRequests: this._totalCreditsUsed,
      rateLimitRemaining: this.rateLimitPerMin - this._requestCount,
      lastFetchAt: this._cacheTimestamp ? new Date(this._cacheTimestamp).toISOString() : null,
      source: this.config.displayName
    };
  }

  /**
   * Generate raw-response.jsonld envelope
   */
  toJsonLd(fetchResult) {
    return {
      '@context': { 'api': 'https://oaa-ontology.org/v6/api-connector/' },
      '@type': 'api:RawResponse',
      data: fetchResult.data,
      fetchedAt: fetchResult.fetchedAt,
      source: fetchResult.source,
      status: fetchResult.status,
      creditsUsed: this._totalCreditsUsed
    };
  }
}

// Export for ES module or global
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { PfcApiConnector };
} else if (typeof window !== 'undefined') {
  window.PfcApiConnector = PfcApiConnector;
}

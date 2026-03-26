/**
 * W4M-LSC-AIS-Adapter (SKL-155) — Vessel Tracking Data Transform
 *
 * Maps Datalastic/VesselFinder AIS API responses to the LSC tracker data model.
 * Container-level: MMSI lookup, position, SOG, ETA, destination.
 *
 * @version 0.1.0
 * @classification SKILL_STANDALONE
 * @cascadeTier PFI (W4M-WWG)
 * @epic Epic 90 F90.2
 */

class W4mLscAisAdapter {
  /**
   * @param {Object} containerMmsiMap - { containerId: { mmsi, carrier, vessel, product, type, sp } }
   * @param {string} source - 'datalastic' | 'vesselfinder'
   */
  constructor(containerMmsiMap, source = 'datalastic') {
    this.containerMap = containerMmsiMap;
    this.source = source;
    this._mmsiToContainer = {};

    // Build reverse lookup: MMSI -> containerId
    Object.entries(containerMmsiMap).forEach(([containerId, info]) => {
      if (info.mmsi) {
        this._mmsiToContainer[String(info.mmsi)] = containerId;
      }
    });
  }

  /**
   * Transform raw API response to tracker-update.jsonld
   * @param {Object} rawResponse - output from PfcApiConnector.fetch()
   * @returns {Object} tracker-update.jsonld
   */
  transform(rawResponse) {
    if (!rawResponse || !rawResponse.success || !rawResponse.data) {
      return {
        '@type': 'lsc:FleetUpdate',
        containers: [],
        fetchedAt: new Date().toISOString(),
        source: this.source,
        error: rawResponse?.error || 'NO_DATA'
      };
    }

    const vessels = this._extractVessels(rawResponse.data);
    const containers = [];

    vessels.forEach(vessel => {
      const mmsi = String(vessel.mmsi);
      const containerId = this._mmsiToContainer[mmsi];

      if (!containerId) return; // vessel not in our fleet

      const containerInfo = this.containerMap[containerId];
      const mapped = this._mapVessel(vessel, containerId, containerInfo);
      containers.push(mapped);
    });

    return {
      '@context': { 'lsc': 'https://oaa-ontology.org/v6/lsc/' },
      '@type': 'lsc:FleetUpdate',
      containers: containers,
      fetchedAt: rawResponse.fetchedAt || new Date().toISOString(),
      source: this.source,
      vesselsInResponse: vessels.length,
      containersMatched: containers.length,
      containersUnmatched: Object.keys(this.containerMap).length - containers.length
    };
  }

  /**
   * Extract vessel array from API response (source-specific)
   */
  _extractVessels(data) {
    if (this.source === 'datalastic') {
      // Datalastic: { data: { ... } } for single or { data: [ ... ] } for bulk
      if (Array.isArray(data.data)) return data.data;
      if (data.data && typeof data.data === 'object') return [data.data];
      if (Array.isArray(data)) return data;
      return [];
    }

    if (this.source === 'vesselfinder') {
      // VesselFinder: { AIS: [ ... ] }
      if (Array.isArray(data.AIS)) return data.AIS;
      return [];
    }

    // Generic fallback
    if (Array.isArray(data)) return data;
    if (data.data && Array.isArray(data.data)) return data.data;
    return [];
  }

  /**
   * Map a single vessel record to tracker container format
   */
  _mapVessel(vessel, containerId, containerInfo) {
    const lat = this._getField(vessel, ['lat', 'LATITUDE', 'latitude']);
    const lon = this._getField(vessel, ['lon', 'LONGITUDE', 'longitude']);
    const speed = this._getField(vessel, ['speed', 'SPEED', 'sog']);
    const heading = this._getField(vessel, ['course', 'HEADING', 'heading', 'cog']);
    const destination = this._getField(vessel, ['destination', 'DESTINATION']);
    const eta = this._getField(vessel, ['eta', 'ETA']);
    const navStatus = this._getField(vessel, ['navigation_status', 'NAVSTAT', 'nav_status']);
    const vesselName = this._getField(vessel, ['name', 'SHIPNAME', 'vessel_name']);
    const lastUpdate = this._getField(vessel, ['last_position_epoch', 'TIMESTAMP', 'timestamp']);

    // Determine status from nav status
    const status = this._deriveStatus(navStatus, speed);

    // Calculate position age
    let positionAgeMinutes = null;
    if (lastUpdate) {
      const updateTime = typeof lastUpdate === 'number'
        ? lastUpdate * 1000 // epoch seconds -> ms
        : new Date(lastUpdate).getTime();
      positionAgeMinutes = Math.round((Date.now() - updateTime) / 60000);
    }

    return {
      id: containerId,
      carrier: containerInfo.carrier,
      vessel: vesselName || containerInfo.vessel,
      product: containerInfo.product,
      type: containerInfo.type,
      sp: containerInfo.sp,
      lat: parseFloat(lat) || null,
      lon: parseFloat(lon) || null,
      sog: parseFloat(speed) || 0,
      heading: parseFloat(heading) || null,
      destination: destination || null,
      etaRaw: eta || null,
      etaRevised: this._parseEta(eta),
      status: status,
      navStatus: navStatus,
      positionAgeMinutes: positionAgeMinutes,
      source: this.source,
      live: true
    };
  }

  /**
   * Get field value trying multiple key names (source-agnostic)
   */
  _getField(obj, keys) {
    for (const key of keys) {
      if (obj[key] !== undefined && obj[key] !== null && obj[key] !== '') {
        return obj[key];
      }
    }
    return null;
  }

  /**
   * Derive container status from AIS nav status
   */
  _deriveStatus(navStatus, speed) {
    if (!navStatus) return speed > 0.5 ? 'At Sea' : 'Booked';

    const ns = String(navStatus).toLowerCase();
    if (ns.includes('moor') || ns.includes('anchor')) return 'Port Approach';
    if (ns.includes('under way') || ns === '0') return 'At Sea';
    if (ns.includes('not under command') || ns === '2') return 'At Sea — ALERT';
    if (speed && parseFloat(speed) > 0.5) return 'At Sea';
    return 'At Sea';
  }

  /**
   * Parse ETA string to ISO date
   */
  _parseEta(eta) {
    if (!eta) return null;
    try {
      // Datalastic: "2026-03-26T08:00:00" or epoch
      if (typeof eta === 'number') return new Date(eta * 1000).toISOString().substring(0, 10);
      const d = new Date(eta);
      if (!isNaN(d.getTime())) return d.toISOString().substring(0, 10);
    } catch (e) { /* ignore */ }
    return String(eta);
  }

  /**
   * Get list of containers with no MMSI match in the response
   */
  getUnmatchedContainers(fleetUpdate) {
    const matchedIds = new Set(fleetUpdate.containers.map(c => c.id));
    return Object.keys(this.containerMap).filter(id => !matchedIds.has(id));
  }
}

// Container-to-MMSI lookup table for W4M-WWG fleet (12 containers)
// MMSI numbers are illustrative — replace with real MMSIs when Datalastic trial key available
const WWG_CONTAINER_MMSI_MAP = {
  'MRKU4821073': { mmsi: 219018228, carrier: 'Maersk', vessel: 'MV Maersk Hobart', product: 'Frozen Beef BMB', type: 'frozen', sp: -18 },
  'MRKU7734901': { mmsi: 219018229, carrier: 'Maersk', vessel: 'MV Sealand Michigan', product: 'Chilled Lamb', type: 'chilled', sp: 2 },
  'TCKU8820445': { mmsi: 228388700, carrier: 'CMA CGM', vessel: 'MV CMA CGM Liberté', product: 'Frozen Lamb', type: 'frozen', sp: -20 },
  'HLXU9901234': { mmsi: 218302000, carrier: 'Hapag-Lloyd', vessel: 'MV Hapag San Francisco', product: 'Chilled Beef Premium', type: 'chilled', sp: 1 },
  'MSCU5512087': { mmsi: 353136000, carrier: 'MSC', vessel: 'MV MSC Beatrice', product: 'Frozen Beef Whole Muscle', type: 'frozen', sp: -18 },
  'OOLU6634128': { mmsi: 477328100, carrier: 'OOCL', vessel: 'MV OOCL London', product: 'Fresh Lamb CA', type: 'fresh', sp: 0 },
  'MSDU3310092': { mmsi: 353137000, carrier: 'MSC', vessel: 'MV MSC Aurora', product: 'Frozen Beef Chuck', type: 'frozen', sp: -18 },
  'CMAU7712034': { mmsi: 228389700, carrier: 'CMA CGM', vessel: 'MV CMA CGM Roussillon', product: 'Frozen Lamb Trim', type: 'frozen', sp: -20 },
  'HASU4490012': { mmsi: 218303000, carrier: 'Hapag-Lloyd', vessel: 'MV Hamburg Express', product: 'Chilled Beef Striploin', type: 'chilled', sp: 1 },
  'MRKU3319021': { mmsi: 219018228, carrier: 'Maersk', vessel: 'MV Maersk Hobart', product: 'Frozen Beef Ribeye', type: 'frozen', sp: -18 },
  'EVRU8821100': { mmsi: 416394000, carrier: 'Evergreen', vessel: 'MV Ever Summit', product: 'Chilled Lamb Rack', type: 'chilled', sp: 2 },
  'COSU6678234': { mmsi: 477875100, carrier: 'COSCO', vessel: 'MV COSCO Pride', product: 'Frozen Beef Mixed', type: 'frozen', sp: -18 }
};

// Export
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { W4mLscAisAdapter, WWG_CONTAINER_MMSI_MAP };
} else if (typeof window !== 'undefined') {
  window.W4mLscAisAdapter = W4mLscAisAdapter;
  window.WWG_CONTAINER_MMSI_MAP = WWG_CONTAINER_MMSI_MAP;
}

# PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0

> **Product Code:** PFC-ARCH
> **Doc Type:** BRIEF (Briefing / Decision Record)
> **Version:** 1.0.0
> **Status:** For Decision
> **Date:** 2026-03-26
> **Epic:** Epic 65 (#1106) — PFC-ARCH-DSY
> **Related:** W4M-WWG LSC Demos, MeatTrackAI Fleet Intelligence Tracker

---

## 1. Problem Statement

Automate external API integration — starting with Datalastic AIS vessel tracking for the MeatTrackAI Fleet Intelligence Tracker — in a way that is generalisable across future PFI instances and API sources.

The current `lsc-shipping-tracker.html` runs entirely on simulated data. Production use requires live AIS vessel positions, and future iterations will need port congestion, weather, and market data feeds. The question is: what is the correct skill architecture to support this using the PFC skill builder and decision tree?

---

## 2. Dtree Evaluation

### 2.1 HG-01: Autonomy Assessment

**Question:** Does this require autonomous reasoning beyond predefined instructions?

| Criterion | Weight | Score | Rationale |
|-----------|--------|-------|-----------|
| C0: Ambiguity / novel inputs | 3 | 6 | API schemas vary but are well-documented; some interpretation needed for mapping response fields to tracker data model |
| C1: Decisions with incomplete info | 3 | 5 | Must handle API failures, rate limits, partial data — but fallback logic is deterministic |
| C2: State across interactions | 2 | 7 | Polling state, credential management, ETA revision history, cache invalidation |
| C3: Coordinates other capabilities | 2 | 4 | Calls one API, transforms, writes — does not orchestrate sub-agents |

**Calculation:**

```
Weighted sum:  (6 x 3) + (5 x 3) + (7 x 2) + (4 x 2) = 18 + 15 + 14 + 8 = 55
Max possible:  (3 + 3 + 2 + 2) x 10 = 100
Normalised:    55 / 100 x 10 = 5.5
```

**Outcome:** 5.5 → **PARTIAL** (threshold: 4.0–6.9) → route to **HG-03**

Not fully autonomous (API integration is largely schema-mapped), but not trivial either. State management and error handling elevate it beyond simple scripting.

---

### 2.2 HG-03: Bundling Requirement

**Question:** Does this need multiple extension types (skills + MCP + commands) bundled together?

| Criterion | Weight | Score | Rationale |
|-----------|--------|-------|-----------|
| Multiple skills needed | 2 | 3 | Single concern: fetch, transform, emit |
| MCP integrations | 3 | 2 | No MCP needed — direct HTTP via fetch/curl |
| Slash commands | 2 | 3 | One invocation: `/pfc-api-connector` |
| Role-specific workflow | 3 | 3 | General-purpose, not role-bound |

**Calculation:**

```
Weighted sum:  (3 x 2) + (2 x 3) + (3 x 2) + (3 x 3) = 6 + 6 + 6 + 9 = 27
Max possible:  (2 + 3 + 2 + 3) x 10 = 100
Normalised:    27 / 100 x 10 = 2.7
```

**Outcome:** 2.7 → **FAIL** (threshold: <4.0) → terminal recommendation: **`SKILL_STANDALONE`**

No bundling required. This is a single-concern skill — fetch, transform, emit.

---

### 2.3 Dtree Path Summary

```
HG-01 (Autonomy)         5.5 PARTIAL
  |
  v
HG-03 (Bundling)          2.7 FAIL
  |
  v
Terminal: SKILL_STANDALONE
```

---

### 2.4 Classification Rationale

API integration is:

- **Deterministic** — schema mapping, not reasoning
- **Single-concern** — fetch, transform, emit
- **Repeatable** — same pattern for Datalastic, VesselFinder, MarineTraffic, or any future API
- **No orchestration** — no sub-agents or parallel workflows
- **Config-driven** — new API sources require config, not code

`SKILL_STANDALONE` is the correct classification. The effort profile is 1–3 days per skill, with no plugin packaging or MCP overhead.

---

## 3. Proposed Skill Architecture

### 3.1 Two-Skill Pattern: Generic Connector + Domain Adapter

```
SKL-154: pfc-api-connector            (SKILL_STANDALONE, PFC tier)
  |
  |  Generic: auth, polling, rate-limit, retry, cache, error handling
  |  Config-driven: endpoint URL, auth method, polling interval,
  |                 response mapping
  |
  +-- Consumed by domain-specific adapter skills:
      |
      SKL-155: w4m-lsc-ais-adapter    (SKILL_STANDALONE, PFI tier, W4M-WWG)
          |
          |  Maps Datalastic/VesselFinder response to tracker data model
          |  Container-level: MMSI lookup, position, SOG, ETA, temp
          |  Emits: JSONLD conforming to tracker schema
```

**Future adapters (same pattern, no changes to connector):**

```
SKL-xxx: w4m-lsc-port-adapter         (port congestion APIs)
SKL-xxx: w4m-lsc-weather-adapter      (weather / storm APIs)
SKL-xxx: baiv-market-adapter          (BAIV market data APIs)
SKL-xxx: airl-cloud-metrics-adapter   (AIRL Azure metrics APIs)
```

### 3.2 Why Two Skills, Not One

| Concern | pfc-api-connector (SKL-154) | w4m-lsc-ais-adapter (SKL-155) |
|---------|---------------------------|-------------------------------|
| **Scope** | HTTP mechanics | Domain semantics |
| **Reuse** | Any PFI, any API | W4M-WWG AIS only |
| **Changes when** | Auth protocols evolve | Datalastic schema changes |
| **Cascade tier** | PFC (universal) | PFI (instance-specific) |
| **Owner** | PFC | W4M-WWG |

Separating transport from transform means adding a new API source = new adapter config + mapping, zero changes to the connector.

---

## 4. Skill Chain Data Flow

```
                    pfc-api-connector (SKL-154)
                    ==========================
                    Generic HTTP integration

  Config Input                              Output
  ============                              ======
  api-config.jsonld                         raw-response.jsonld
  {                                         {
    endpoint: "https://api.datalastic        @type: "api:RawResponse",
               .com/api/v0/vessel",           data: [...vessel positions...],
    auth: {                                   fetchedAt: "2026-03-26T12:00Z",
      method: "query-param",                  source: "datalastic",
      paramName: "api-key",                   status: 200,
      secretRef: "DATALASTIC_KEY"             creditsUsed: 12
    },                                      }
    polling: {
      intervalSec: 300,
      retryOnFail: 3
    },
    params: {
      mmsi: "${container.mmsiList}"
    },
    rateLimit: { maxPerMin: 10 }
  }
        |
        v
                    w4m-lsc-ais-adapter (SKL-155)
                    ============================
                    Domain-specific transform

  raw-response.jsonld                       tracker-update.jsonld
  {                                         {
    data: [                                   @type: "lsc:FleetUpdate",
      { mmsi: 123456789,                      containers: [
        lat: -15.23, lon: 45.67,                { id: "MRKU4821073",
        speed: 14.8, heading: 310,                lat: -15.23,
        destination: "GBTIL",                     lon: 45.67,
        eta: "2026-02-21T08:00" }                 sog: 14.8,
    ]                                             status: "At Sea",
  }                                               etaRevised: "2026-02-21",
                                                  temp: -17.8,
        |                                         delay: 8 }
        v                                       ]
                                              }
              lsc-shipping-tracker.html
              =========================
              Renders updated positions on map,
              refreshes stats, alerts, charts
```

---

## 5. Config-Driven Design

The `pfc-api-connector` skill is **config-driven**, not code-driven. Each API integration is defined by an `api-config.jsonld` file. Adding a new API source = new config file, no code changes to the connector skill.

### 5.1 Datalastic Config (First Integration)

```jsonld
{
  "@context": {
    "api": "https://oaa-ontology.org/v6/api-connector/"
  },
  "@type": "api:IntegrationConfig",
  "@id": "pf:api:datalastic-ais",
  "displayName": "Datalastic AIS Vessel Tracking",
  "endpoint": "https://api.datalastic.com/api/v0/vessel",
  "authMethod": "query-param",
  "authParamName": "api-key",
  "secretRef": "DATALASTIC_API_KEY",
  "pollingIntervalSec": 300,
  "rateLimitPerMin": 10,
  "retryPolicy": {
    "maxRetries": 3,
    "backoffMs": 2000
  },
  "responseMapping": {
    "vessels": "$.data[*]",
    "lat": "$.latitude",
    "lon": "$.longitude",
    "speed": "$.speed",
    "heading": "$.heading",
    "eta": "$.eta",
    "destination": "$.destination"
  },
  "owningPfi": "W4M-WWG",
  "cascadeTier": "PFI"
}
```

### 5.2 VesselFinder Config (Future Integration)

```jsonld
{
  "@type": "api:IntegrationConfig",
  "@id": "pf:api:vesselfinder-ais",
  "displayName": "VesselFinder AIS Positions",
  "endpoint": "https://api.vesselfinder.com/vessels",
  "authMethod": "query-param",
  "authParamName": "userkey",
  "secretRef": "VESSELFINDER_API_KEY",
  "pollingIntervalSec": 600,
  "rateLimitPerMin": 5,
  "retryPolicy": {
    "maxRetries": 2,
    "backoffMs": 5000
  },
  "responseMapping": {
    "vessels": "$.AIS[*]",
    "lat": "$.LAT",
    "lon": "$.LON",
    "speed": "$.SPEED",
    "heading": "$.HEADING",
    "eta": "$.ETA",
    "destination": "$.DESTINATION"
  },
  "notes": "Satellite AIS = 10 credits per position (mid-ocean vessels)",
  "owningPfi": "W4M-WWG",
  "cascadeTier": "PFI"
}
```

---

## 6. Cascade Distribution

### 6.1 Tier Assignment

| Skill | Cascade Tier | Owned By | Distributed To |
|-------|-------------|----------|---------------|
| `pfc-api-connector` (SKL-154) | **PFC** | PFC (universal) | All PFI instances via `pfc-release.yml` |
| `w4m-lsc-ais-adapter` (SKL-155) | **PFI** | W4M-WWG | W4M-WWG dev/test/prod only |

### 6.2 Cascade Flow

```
Azlan-EA-AAA (PFC Hub)
  |
  |  pfc-release.yml (tag: pfc-vN.N.N)
  |  Distributes: pfc-api-connector (SKL-154)
  |  Filter: ALL PFI instances (PFC tier = universal)
  |
  +---> pfi-w4m-wwg-dev     pfc-core/skills/pfc-api-connector/
  +---> pfi-baiv-aiv-dev     pfc-core/skills/pfc-api-connector/
  +---> pfi-airl-caf-aza-dev pfc-core/skills/pfc-api-connector/
  +---> (all other PFIs)

pfi-w4m-wwg-dev (PFI Instance)
  |
  |  Instance-specific skill (NOT distributed via hub)
  |  Lives in: instance-data/skills/w4m-lsc-ais-adapter/
  |
  |  promote.yml (dev -> test -> prod)
  |
  +---> pfi-w4m-wwg-test
  +---> pfi-w4m-wwg-prod
```

This follows the established cascade pattern:

- **PFC-generic** skills (connector) flow to all PFIs automatically
- **PFI-instance-specific** skills (adapter) stay within the owning PFI's triad
- Future PFIs (BAIV, AIRL) build their own adapters consuming the same `pfc-api-connector`
- The cascade is PFC-PFI generalised, never designed for a single PFI instance

---

## 7. URG Intake Path

Both skills follow the standard 3-stage URG intake pipeline (PE-ONT ProcessPath v1.0.0):

### 7.1 Stage 1: Candidate (dev)

| Step | Action | Artefact |
|------|--------|----------|
| 1 | Create skill directory in `azlan-github-workflow/skills/pfc-api-connector/` | Directory |
| 2 | Author `SKILL.md` with PFC frontmatter conventions | SKILL.md |
| 3 | Map to PE-ONT process type (JP-PE-001) | PE binding |
| 4 | Create `registry-entry-v0.1.0.jsonld` with `intakeStatus: "candidate"` | Registry entry |
| 5 | Add to `skills-register-index.json` with `status: "candidate"` | Index update |
| 6 | Record Dtree classification (this document) | Decision record |

**Gate G1: Candidate Classification**
- HG-01 score 5.5 >= 3.5 threshold: **PASS**
- Dtree classification complete: **SKILL_STANDALONE**
- Cascade tier assigned: **PFC** (connector), **PFI** (adapter)
- RACI skeleton: Owner = PFC (connector), W4M-WWG (adapter)

### 7.2 Stage 2: Evaluate (test)

| Step | Action | Gate |
|------|--------|------|
| 7 | Functional review vs PFC quality gates (G1–G5) | G2: Quality pass |
| 8 | PE-functional enhancements — PFC conventions, ontology bindings | G2: PE-ONT bound |
| 9 | RRR-RACI assignment — R/A/C/I roles | G2: RACI matrix |
| 10 | Test in W4M-WWG dev triad with Datalastic trial key | G2: Triad test pass |

**Gate G2: Schema Compliance**
- `pfc-tracker-validate` returns 0 schema errors
- Metadata completeness >= 90% of mandatory fields
- Deduplication confirmed (no overlap with existing skills)

### 7.3 Stage 3: Adopt (prod)

| Step | Action | Gate |
|------|--------|------|
| 11 | Update `intakeStatus` to `"adopted"`, bump version to `1.0.0` | G3 |
| 12 | Promote via `pfc-release.yml` to PFI prod triads | G3: CI/CD |
| 13 | Visible in skills register and OAA visualiser | G3: Registry |

**Gate G3: Adoption Confirmation**
- CI `pfc-tracker-validate.yml` PASS
- Skill visible in registry visualiser
- Epic body updated with skill registration

---

## 8. Registry Entries (Proposed)

### 8.1 SKL-154: pfc-api-connector

```json
{
  "entryId": "Entry-SKL-154",
  "skillName": "pfc-api-connector",
  "displayName": "PFC-API-Connector: Config-Driven HTTP Integration",
  "classification": "SKILL_STANDALONE",
  "version": "0.1.0",
  "status": "candidate",
  "category": "foundation",
  "sourceType": "pfc-native",
  "owningPfi": "PFC",
  "intakeStatus": "candidate",
  "cascadeTier": "PFC",
  "owningOntology": "PE-ONT",
  "dtreeClassification": {
    "autonomy": 5.5,
    "orchestration": "none",
    "bundling": 2.7,
    "recommendation": "SKILL_STANDALONE"
  },
  "gateOutcomes": {
    "G1": { "gate": "Candidate Classification", "result": "PASS",
            "evidence": "HG-01: 5.5 PARTIAL, HG-03: 2.7 FAIL -> SKILL_STANDALONE" },
    "G2": { "gate": "Schema Compliance", "result": "PENDING" },
    "G3": { "gate": "Adoption Confirmation", "result": "PENDING" }
  }
}
```

### 8.2 SKL-155: w4m-lsc-ais-adapter

```json
{
  "entryId": "Entry-SKL-155",
  "skillName": "w4m-lsc-ais-adapter",
  "displayName": "W4M-LSC-AIS-Adapter: Vessel Tracking Data Transform",
  "classification": "SKILL_STANDALONE",
  "version": "0.1.0",
  "status": "candidate",
  "category": "execution",
  "sourceType": "pfc-native",
  "owningPfi": "W4M-WWG",
  "intakeStatus": "candidate",
  "cascadeTier": "PFI",
  "owningOntology": "PE-ONT",
  "dtreeClassification": {
    "autonomy": 3.8,
    "orchestration": "none",
    "bundling": 2.0,
    "recommendation": "SKILL_STANDALONE"
  },
  "gateOutcomes": {
    "G1": { "gate": "Candidate Classification", "result": "PASS",
            "evidence": "Schema-mapped transform, no reasoning required" },
    "G2": { "gate": "Schema Compliance", "result": "PENDING" },
    "G3": { "gate": "Adoption Confirmation", "result": "PENDING" }
  }
}
```

---

## 9. Supported API Sources

The config-driven architecture supports these API sources without code changes:

| API Source | Auth Method | Polling | Credits Model | Status |
|-----------|-------------|---------|---------------|--------|
| **Datalastic** | Query param (`api-key`) | 300s | Per successful return | First target |
| **VesselFinder** | Query param (`userkey`) | 600s | 1 terrestrial / 10 satellite | Future |
| **MarineTraffic** | API key header | 600s | Enterprise / credit-based | Future (enterprise) |
| **Port congestion** | Varies | 3600s | Subscription | Future |
| **Weather (met office)** | API key header | 1800s | Free tier available | Future |

---

## 10. Reuse Across PFI Instances

| PFI Instance | Adapter Skill | API Source | Use Case |
|---|---|---|---|
| **W4M-WWG** | `w4m-lsc-ais-adapter` | Datalastic / VesselFinder | AIS vessel positions for meat shipping |
| **W4M-WWG** | `w4m-lsc-port-adapter` (future) | MarineTraffic | Port congestion overlay |
| **W4M-WWG** | `w4m-lsc-weather-adapter` (future) | Met Office / Open-Meteo | Storm diversion alerts |
| **BAIV** | `baiv-market-adapter` (future) | Market data APIs | Antiques market pricing |
| **AIRL** | `airl-cloud-metrics-adapter` (future) | Azure Monitor API | Cloud infrastructure metrics |

All adapters consume the same `pfc-api-connector` (SKL-154). The connector handles HTTP mechanics; each adapter handles domain-specific schema mapping.

---

## 11. Decision Summary

| Decision | Outcome |
|----------|---------|
| **Dtree path** | HG-01 (5.5 PARTIAL) → HG-03 (2.7 FAIL) → `SKILL_STANDALONE` |
| **Architecture** | Two-skill pattern: generic connector + domain adapter |
| **Connector tier** | PFC (universal, all PFIs) |
| **Adapter tier** | PFI (instance-specific, W4M-WWG first) |
| **Config model** | JSONLD config per API source, no code changes for new sources |
| **URG intake** | Standard 3-stage: Candidate → Evaluate → Adopt (G1/G2/G3) |
| **First integration** | Datalastic AIS vessel tracking (trial key available) |
| **Effort** | 1–3 days per skill (SKILL_STANDALONE effort profile) |

---

## 12. Next Steps

1. Scaffold `SKILL.md` files for SKL-154 and SKL-155 in `azlan-github-workflow/skills/`
2. Register as candidates in `skills-register-index.json`
3. Write `api-config.jsonld` for Datalastic as the first integration config
4. Implement connector skill with polling, retry, and cache logic
5. Implement AIS adapter with Datalastic response mapping to tracker data model
6. Test in W4M-WWG dev triad with Datalastic trial key
7. Update `lsc-shipping-tracker.html` to accept live data via adapter output
8. Implement PDF shipping status & risk/impact report generation (F90.7)
9. Auto-generate RAID log from tracker data for governance reporting

---

## 13. Document Cross-References

| Document | Location | Relationship |
|----------|----------|-------------|
| Epic Plan (7 features, 48 stories, RAID log) | PBS/STRATEGY/PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md | F90.1/F90.2 skill stories, F90.7 PDF reporting, requirements register, RAID log |
| Microsoft VE/QVF Strategy Brief | PBS/STRATEGY/PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md | Macro context, VP-RRR analysis, QVF financial model, Kano classification |
| Fleet Intelligence Tracker Doc | PBS/LSC-DEMOS/LSC-DEMO-DOC-MeatTrackAI-Fleet-Intelligence-Tracker-v1.0.0.md | Tracker architecture, data model, scenario engine |
| Live Demo (GitHub Pages) | PBS/LSC-DEMOS/lsc-shipping-tracker.html | Interactive simulation tracker |

---

*Decision record generated from Dtree evaluation using PFC Skill Builder (decision-tree.js v1.0.0, skill-builder.js v1.0.0). URG intake governed by PE-ONT v4.2.0 ProcessPath. Cross-referenced to Epic 90 plan (7 features, 48 stories) and RAID log (RAID-ONT, GRC-Series).*

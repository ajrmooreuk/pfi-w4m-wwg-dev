# PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0

> **Product Code:** PFC-ARCH
> **Doc Type:** PLAN (Epic Plan & Cross-Reference)
> **Version:** 1.0.0
> **Status:** For Decision
> **Date:** 2026-03-26
> **Parent Epic:** Epic 45 (#634) — PFI-WWG-SUPPLY (CLOSED — instance data complete)
> **Depends On:** Epic 65 (#1106) — PFC-ARCH-DSY App Skeleton, Epic 77 (#1204) — URG Consolidated

---

## 1. Purpose

This document defines the epic, feature, and story plan for operationalising the W4M-WWG LSC (Logistics & Supply Chain) integration — moving from the completed ontology instance data (Epic 45) and demo trackers (LSC-DEMOS) through to live API-connected, App Skeleton-rendered, skill-governed production dashboards.

It cross-references all related skills, issues, UI/UX components, and App Skeleton artefacts.

---

## 2. Epic Lineage

```
Epic 34 (#518) — Platform Strategy [CLOSED]
  |
  +-- Epic 45 (#634) — PFI-WWG-SUPPLY [CLOSED]
  |     |  VP+RRR instances, LSC-ONT 4 corridors, OFM-ONT,
  |     |  KPI/BSC, 12-panel dashboard, composed graph spec
  |     |
  |     +-- Epic 44 (#631) — WWG Design System [OPEN, P0 Backlog]
  |           Token re-extraction, DS-ONT v2.2.0, triad population
  |
  +-- Epic 65 (#1106) — App Skeleton Skill Chain [90% COMPLETE]
  |     7-phase pipeline (SKL-113 to SKL-121), PfcShell,
  |     responsive breakpoints, navigation history
  |
  +-- Epic 77 (#1204) — URG Consolidated [IN PROGRESS]
  |     Skill intake (G1/G2/G3), PE-ONT merge, registry
  |
  +-- Epic 88 (#1338) — gstack Skills Integration [SCOPED]
  |     /browse, /retro, doc-drift, OWASP review
  |
  +-- *** NEW: Epic 90 — W4M-WWG-LSC Live Integration ***
        API connector + AIS adapter skills (SKL-154/155),
        App Skeleton LSC components, Microsoft integration,
        live dashboard deployment
```

---

## 3. Proposed Epic 90: W4M-WWG-LSC Live Integration

### 3.1 Epic Summary

**Title:** W4M-WWG-LSC — Live API Integration, App Skeleton Components & Microsoft Deployment

**Objective:** Deliver production-ready, API-connected logistics intelligence dashboards for W4M-WWG, governed by PFC skills, rendered via App Skeleton, and deployed within the Microsoft ecosystem.

**Scope:**
- API integration skills (SKL-154, SKL-155) — Dtree-evaluated, URG-intake-governed
- App Skeleton LSC components — new PfcPanel types for shipping/logistics
- Microsoft environment integration — Teams, Outlook, SharePoint embedding
- Live data pipeline — Datalastic AIS → tracker → dashboard
- VE/QVF value realisation metrics
- PDF shipping status, risk assessment, impact assessment, and RAID log reports

---

### 3.2 Features & Stories

#### F90.1 — API Connector Skill (SKL-154: pfc-api-connector)

**Cascade Tier:** PFC (universal)
**Dtree:** HG-01: 5.5 PARTIAL → HG-03: 2.7 FAIL → SKILL_STANDALONE
**Cross-ref:** PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0.md

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.1.1 | Scaffold SKILL.md and registry-entry for pfc-api-connector | SKILL.md with PFC frontmatter, registry-entry-v0.1.0.jsonld, Dtree classification recorded |
| S90.1.2 | Implement config-driven HTTP fetch with auth, retry, rate-limit | api-config.jsonld consumed, 3 retry with backoff, rate-limit respected, raw-response.jsonld emitted |
| S90.1.3 | Add polling scheduler with configurable interval | intervalSec from config, pause/resume, credit tracking |
| S90.1.4 | Register in skills-register-index.json as candidate | Entry-SKL-154, intakeStatus: "candidate", G1 PASS |
| S90.1.5 | URG intake G2: schema compliance validation | pfc-tracker-validate returns 0 errors, metadata >= 90% |
| S90.1.6 | URG intake G3: adoption confirmation | CI pass, visible in visualiser, intakeStatus: "adopted" |

---

#### F90.2 — AIS Adapter Skill (SKL-155: w4m-lsc-ais-adapter)

**Cascade Tier:** PFI (W4M-WWG)
**Dtree:** HG-01: 3.8 FAIL → HG-04: 7.3 PASS → SKILL_STANDALONE
**Cross-ref:** PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0.md

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.2.1 | Scaffold SKILL.md for w4m-lsc-ais-adapter | PFI-tier skill, W4M-WWG owned, PE-ONT bound |
| S90.2.2 | Implement Datalastic response mapping | $.data[*] → tracker-update.jsonld, lat/lon/speed/heading/eta/destination mapped |
| S90.2.3 | Implement VesselFinder response mapping | Alternative API source, satellite AIS credit awareness |
| S90.2.4 | Write api-config.jsonld for Datalastic | First integration config, query-param auth, 300s polling |
| S90.2.5 | Write api-config.jsonld for VesselFinder | Second integration config, 600s polling, credit model documented |
| S90.2.6 | Container-to-MMSI lookup table | 12 containers mapped to vessel MMSI numbers, extensible |
| S90.2.7 | URG intake (G1→G2→G3) | Full 3-stage intake, W4M-WWG triad test pass |

---

#### F90.3 — App Skeleton LSC Components

**Cascade Tier:** PFC (reusable) + PFI (instance-specific configuration)
**Cross-ref:** Epic 65 (#1106) F65.4 PFC Wrapper Components

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.3.1 | PfcVesselMap — SVG route map component | Configurable waypoints, vessel dots with trails, risk zone overlays, click-to-select, fullscreen toggle |
| S90.3.2 | PfcVoyageTimeline — milestone event list | Milestone dots (done/active/pending/alert), date labels, expandable notes |
| S90.3.3 | PfcFleetSnapshot — 4-metric summary cards | Active/Delayed/Alerts/Arrived counters, colour-coded, real-time update |
| S90.3.4 | PfcContainerCard — container list item | ID, carrier, ETA, product type tag, delay badge, temp breach indicator |
| S90.3.5 | PfcReeferChart — temperature vs set-point canvas | Supply air temp line, set-point reference, breach highlighting, responsive resize |
| S90.3.6 | PfcETAChart — ETA revision history canvas | Delay accumulation area chart, colour-coded severity |
| S90.3.7 | PfcSimulationPlayback — date scrubber and controls | Play/pause, step +/-1/7 days, speed 1x/3x/7x, slider with progress fill |
| S90.3.8 | PfcAlertPanel — risk event feed | Severity-coded cards (CRITICAL/HIGH/MEDIUM/LOW), container + global alerts |
| S90.3.9 | PfcStatusBar — day-block heatmap | Per-day colour blocks, click-to-jump, current-day highlight |
| S90.3.10 | Register all LSC components in DS-ONT component catalogue | Component tokens, zone allocations, responsive breakpoint rules |

**Component → Zone Mapping (DS-ONT):**

```
Z-WWG-301  PfcVesselMap          Dashboard zone (strategic)
Z-WWG-302  PfcVoyageTimeline     Dashboard zone (strategic)
Z-WWG-303  PfcFleetSnapshot      Dashboard zone (strategic)
Z-WWG-101  PfcContainerCard      Management zone (operational)
Z-WWG-102  PfcReeferChart        Management zone (operational)
Z-WWG-103  PfcETAChart           Management zone (operational)
Z-WWG-104  PfcSimulationPlayback Management zone (operational)
Z-WWG-105  PfcAlertPanel         Management zone (operational)
Z-WWG-106  PfcStatusBar          Management zone (operational)
```

---

#### F90.4 — Live Dashboard Deployment

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.4.1 | Integrate pfc-api-connector with lsc-shipping-tracker.html | Live data toggle: simulation mode (default) / live mode (API key set) |
| S90.4.2 | GitHub Pages deployment (light theme) | Auto-deploy via pages.yml, accessible at ajrmooreuk.github.io URL |
| S90.4.3 | App Skeleton version of tracker (TS-React) | Skeleton-loaded, DS-ONT tokens applied, responsive breakpoints |
| S90.4.4 | Fullscreen panel toggle on all cards | Expand button per panel, ESC to close, re-render charts on resize |
| S90.4.5 | Cold-chain shelf-life calculator | ETA x departure temp x product type → remaining shelf life |
| S90.4.6 | BTOM/IPAFFS compliance status overlay | Gov.uk IPAFFS pre-notification status per container |

---

#### F90.5 — Microsoft Environment Integration

**Cross-ref:** PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.5.1 | Teams tab embedding — fleet dashboard | Tracker embeddable as Teams tab via iframe, SSO-aware |
| S90.5.2 | Outlook actionable notifications | Delay/alert emails with actionable cards (View Container, Acknowledge) |
| S90.5.3 | SharePoint dashboard page | Tracker embedded in SharePoint site, org-wide visibility |
| S90.5.4 | Power Automate flow — ETA shift alerts | Trigger when ETA shifts > 24hrs, notify stakeholder distribution list |
| S90.5.5 | Excel export — fleet status snapshot | One-click export of current fleet state to .xlsx |
| S90.5.6 | PowerBI connector (future) | tracker-update.jsonld as PowerBI data source |

---

#### F90.6 — VE/QVF Value Realisation Metrics

**Cross-ref:** VP-ONT ↔ RRR-ONT alignment convention (JP-VP-RRR-001)

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.6.1 | VP instance for W4M-WWG LSC live integration | vp:Problem (blind spots), vp:Solution (live AIS), vp:Benefit (reduced spoilage) |
| S90.6.2 | QVF financial model — spoilage reduction | Baseline spoilage cost, projected reduction with live tracking, ROI |
| S90.6.3 | QVF financial model — demurrage avoidance | Port delay cost baseline vs early-warning benefit |
| S90.6.4 | KPI dashboard — LSC operational metrics | 6 KPIs: ETA accuracy, temp compliance, alert response time, spoilage rate, demurrage cost, shelf-life utilisation |
| S90.6.5 | BSC integration — 4-perspective scorecard | Financial (margin), Customer (OTIF), Process (alert latency), Learning (scenario coverage) |

---

#### F90.7 — PDF Shipping Status & Risk/Impact Assessment Report

**Cascade Tier:** PFI (W4M-WWG) — reusable pattern for other PFI instances
**Cross-ref:** LSC-ONT scenarios, OFM-ONT margin impacts, KPI-ONT metrics, RAID-ONT (GRC-Series)

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.7.1 | Fleet Status PDF — point-in-time snapshot | Generate branded PDF of current fleet state: all 12 containers, status, ETA, delay, temp, route. Includes SVG map render and fleet snapshot stats |
| S90.7.2 | Container Detail PDF — single container deep-dive | Per-container report: voyage timeline, temperature chart, ETA revision chart, alert history, compliance status. Exportable from container detail panel |
| S90.7.3 | Risk Assessment section — geopolitical & operational | Active risk events table (severity, zone, duration, affected containers). LSC-ONT scenario cross-reference. Cascade effect chains (delay → storage → spoilage → customer breach) |
| S90.7.4 | Impact Assessment section — financial & operational | QVF-derived cost impact per delay event: spoilage (product type x days x temp), demurrage (£/day x overstay), customer penalty (SLA breach), insurance exposure. OFM-ONT margin impact waterfall |
| S90.7.5 | RAID Log — per-voyage risks, assumptions, issues, dependencies | Auto-generated from tracker data: Risks (active risk events + temp breaches), Assumptions (route holds, carrier commitments), Issues (current delays, AIS gaps), Dependencies (BTOM clearance, warehouse slots, customer windows) |
| S90.7.6 | Requirements Traceability — VP/RRR alignment in PDF | Requirements table linking vp:Solution → rrr:Requirement, current status (met/at-risk/breached), evidence reference |
| S90.7.7 | Scheduled PDF generation — daily/weekly fleet report | Power Automate trigger: daily 06:00 fleet status PDF to distribution list. Weekly Friday 17:00 risk summary PDF to management |
| S90.7.8 | PDF branding — DS-ONT token application | WWG brand tokens applied (Pink/Magenta header, Royal Blue accents, Jura typeface). PFC logo + W4M-WWG instance branding. Consistent with App Skeleton DS-ONT cascade |

**PDF Report Structure:**

```
+--------------------------------------------------+
|  HEADER: W4M-WWG Fleet Intelligence Report       |
|  Date: 2026-03-26  |  Period: Jan-Mar 2026       |
|  Report Type: [Fleet Status / Container Detail]   |
+--------------------------------------------------+
|                                                    |
|  1. EXECUTIVE SUMMARY                             |
|     Fleet snapshot (active/delayed/alerts/arrived) |
|     Key risks and financial exposure               |
|                                                    |
|  2. FLEET STATUS                                   |
|     SVG route map (rendered to PNG for PDF)        |
|     Container status table (all 12)                |
|     ETA variance summary                          |
|                                                    |
|  3. RISK ASSESSMENT                                |
|     3.1 Active Geopolitical Risks                  |
|         (Red Sea, Hormuz, weather, port strikes)   |
|     3.2 Container-Level Risks                      |
|         (temp breaches, AIS gaps, route changes)   |
|     3.3 Cascade Effect Analysis                    |
|         (delay → storage → spoilage → customer)   |
|                                                    |
|  4. IMPACT ASSESSMENT                              |
|     4.1 Financial Impact Summary                   |
|         (spoilage, demurrage, penalty, insurance)  |
|     4.2 Per-Container Cost Waterfall               |
|     4.3 Margin Impact vs Baseline                  |
|                                                    |
|  5. RAID LOG                                       |
|     5.1 Risks (R)                                  |
|     5.2 Assumptions (A)                            |
|     5.3 Issues (I)                                 |
|     5.4 Dependencies (D)                           |
|                                                    |
|  6. REQUIREMENTS TRACEABILITY                      |
|     VP-RRR alignment table                         |
|     Requirement status (met/at-risk/breached)      |
|                                                    |
|  7. APPENDIX                                       |
|     Temperature charts per container               |
|     ETA revision histories                         |
|     Compliance gate status                         |
|                                                    |
+--------------------------------------------------+
|  FOOTER: Confidential | Generated by MeatTrackAI  |
|  Page X of Y | Report ID: RPT-WWG-2026-0326-001   |
+--------------------------------------------------+
```

---

#### F90.8 — Interactive Legend Filtering

**Cascade Tier:** PFC (reusable pattern for any dashboard)
**Status:** COMPLETE — implemented in lsc-shipping-tracker.html

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.8.1 | Clickable legend bar with event type filters | Legend items: At Sea, Delayed, Alert, Arrived, Booked. Click to filter. Click again to deselect. "Clear filter" link to reset |
| S90.8.2 | Live container counts per legend category | Each legend item shows count of matching containers for current date. Updates on date change |
| S90.8.3 | Container list filtering | Non-matching containers dimmed (opacity 0.2, non-interactive). Matching containers fully visible and clickable |
| S90.8.4 | Map vessel filtering | Non-matching vessel dots dimmed (opacity 0.15). Matching vessels at full opacity with glow effects |
| S90.8.5 | Filter state persistence across date changes | Active filter maintained when stepping through dates. Counts update but filter category persists |

---

#### F90.9 — Colour-Coded Risk Assessment Bands

**Cascade Tier:** PFI (W4M-WWG) — reusable pattern
**Cross-ref:** QVF-ONT financial impact, LSC-ONT scenarios, RAID-ONT (GRC-Series)
**Status:** COMPLETE — implemented in lsc-shipping-tracker.html

| Story | Title | Acceptance Criteria |
|-------|-------|---------------------|
| S90.9.1 | Risk assessment panel — appears on legend filter activation | Panel slides in below legend bar when any filter is active. Shows risk bands for matching containers sorted by severity (CRITICAL → LOW) |
| S90.9.2 | Colour-coded severity bands | CRITICAL (red), HIGH (amber), MEDIUM (yellow), LOW (green). Each band shows severity label, risk score (1–10), container ID, carrier, product |
| S90.9.3 | Point-and-click expand — issues and reasoning | Click any risk band to expand: (1) risk factors list, (2) QVF financial impact grid, (3) assessment reasoning with explanatory text |
| S90.9.4 | QVF financial impact per container | Spoilage cost (product type x days x temp), demurrage (£/day x overstay), customer penalty (SLA breach). Total impact. Calculated from tracker data |
| S90.9.5 | Assessment reasoning — natural language explanation | Per-risk-factor reasoning: why this score, what the operational impact is, what evidence supports the assessment. References LSC-ONT scenarios and cascade effects |
| S90.9.6 | Geopolitical risk overlay | Active global risk events (RISK_EVENTS) factored into per-container score. Severity inherited from event when container is in affected zone |
| S90.9.7 | Risk band fullscreen toggle | Expand button on risk panel header. Fullscreen view shows all risk bands with full detail expanded |

---

### 3.3.0 QVF Risk Assessment — Capability Analysis

**Question:** Can existing QVF skills (SKL-101–106) perform LSC risk assessment calculations, or are LSC-specific additions needed?

**Answer:** The existing QVF skills are **cyber-domain-specific** (DALE, insurance premiums, NIST/ISO compliance ROI). They cannot directly calculate LSC risk assessments. However, the **QVF calculation pattern is reusable** — the framework (baseline cost, risk reduction, ROI) transfers directly. What is needed:

| QVF Component | Cyber (Existing SKL-101–106) | LSC (New — Needed) |
|---|---|---|
| **Risk quantification** | DALE (Annual Loss Expectancy) | Spoilage probability x product value x temperature deviation |
| **Cost baseline** | Breach cost (NIST/Ponemon data) | Spoilage + demurrage + penalty baseline (per container type) |
| **Mitigation value** | Security control effectiveness | Early-warning detection time x re-routing/re-allocation success rate |
| **Insurance impact** | Cyber insurance premium reduction | Cargo insurance claim approval rate improvement (45% → 85%) |
| **ROI calculation** | (Risk reduction - investment) / investment | (Avoided spoilage + demurrage + penalty - API cost) / API cost |

**Proposed new QVF-LSC skills (candidate for URG intake):**

| SKL-# | Skill Name | Calculation | Input | Output |
|-------|-----------|------------|-------|--------|
| SKL-156 | `pfc-qvf-lsc-spoilage` | Spoilage risk = P(delay > threshold) x product_value x temp_sensitivity_factor | Container type, set point, current temp, delay days, product value | Spoilage cost estimate (£) + probability band |
| SKL-157 | `pfc-qvf-lsc-demurrage` | Demurrage cost = delay_days x daily_rate x (1 + cold_storage_premium) | Delay days, port daily rate, storage type | Demurrage cost estimate (£) |
| SKL-158 | `pfc-qvf-lsc-impact` | Total impact = spoilage + demurrage + penalty + insurance_exposure - mitigation_value | All above + SLA penalty schedule, insurance terms | Net financial impact (£) + ROI of tracking |

**Dtree classification (preliminary):** All three → `SKILL_STANDALONE` (same pattern as SKL-101–106, deterministic calculation, no orchestration).

**Implementation note:** The current `renderRiskAssessment()` function in the tracker already implements a simplified version of these calculations inline. The skills formalise and generalise the calculation models for reuse across PFI instances and for PDF report generation (F90.7).

---

### 3.3 Dependency Map

```
Epic 45 (CLOSED)                    Epic 65 (90%)
LSC-ONT, OFM-ONT,                  App Skeleton pipeline,
VP/RRR/KPI instances               PfcShell, responsive,
12-panel dashboard                  navigation, components
        |                                   |
        +------- Epic 90 (NEW) ------------+
        |        W4M-WWG-LSC Live          |
        |                                   |
Epic 44 (P0)                        Epic 77 (IN PROGRESS)
WWG Design System                   URG Consolidated
DS-ONT token extraction             Skill intake G1/G2/G3
Brand palette application           PE-ONT merge
        |                                   |
        +------- F90.3 Components ---------+
        |        (need DS tokens            |
        |         + URG registration)       |
        |                                   |
Epic 88 (SCOPED)                    Dtree Review
gstack /browse /qa                  SKL-154, SKL-155
Browser QA for tracker              SKILL_STANDALONE
        |                                   |
        +------- F90.4 Deployment ---------+
                 (QA via /browse,
                  skills via URG)
```

---

### 3.4 Skills Cross-Reference

| SKL-# | Skill Name | Classification | Tier | Epic | Feature | Status |
|-------|-----------|---------------|------|------|---------|--------|
| SKL-113 | pfc-ds-extract | SKILL_STANDALONE | PFC | E65 | F65.7 | Adopted |
| SKL-114 | pfc-skeleton-compose | SKILL_STANDALONE | PFC | E65 | F65.8 | Adopted |
| SKL-115 | pfc-zone-allocator | SKILL_STANDALONE | PFC | E49 | F49.5 | Adopted |
| SKL-116 | pfc-nav-generator | SKILL_STANDALONE | PFC | E65 | F65.9 | Adopted |
| SKL-117 | pfc-token-resolver | SKILL_STANDALONE | PFC | E65 | F65.10 | Adopted |
| SKL-118 | pfc-component-scaffold | SKILL_STANDALONE | PFC | E65 | F65.11 | Adopted |
| SKL-119 | pfc-view-register | SKILL_STANDALONE | PFC | E65 | F65.12 | Adopted |
| SKL-121 | pfc-app-skeleton-pipeline | AGENT_ORCHESTRATOR | PFC | E65 | F65.13 | Adopted |
| **SKL-154** | **pfc-api-connector** | **SKILL_STANDALONE** | **PFC** | **E90** | **F90.1** | **Candidate** |
| **SKL-155** | **w4m-lsc-ais-adapter** | **SKILL_STANDALONE** | **PFI** | **E90** | **F90.2** | **Candidate** |
| **SKL-156** | **pfc-qvf-lsc-spoilage** | **SKILL_STANDALONE** | **PFC** | **E90** | **F90.9** | **Candidate** |
| **SKL-157** | **pfc-qvf-lsc-demurrage** | **SKILL_STANDALONE** | **PFC** | **E90** | **F90.9** | **Candidate** |
| **SKL-158** | **pfc-qvf-lsc-impact** | **SKILL_STANDALONE** | **PFC** | **E90** | **F90.9** | **Candidate** |

---

### 3.5 App Skeleton Component Cross-Reference

| Component | DS-ONT Zone | Epic 65 Dependency | Epic 90 Feature | Skeleton Phase |
|-----------|------------|-------------------|-----------------|----------------|
| PfcVesselMap | Z-WWG-301 | F65.4 (wrapper) | F90.3 S90.3.1 | COMPONENT-SCAFFOLD |
| PfcVoyageTimeline | Z-WWG-302 | F65.4 (wrapper) | F90.3 S90.3.2 | COMPONENT-SCAFFOLD |
| PfcFleetSnapshot | Z-WWG-303 | F65.4 (wrapper) | F90.3 S90.3.3 | COMPONENT-SCAFFOLD |
| PfcContainerCard | Z-WWG-101 | F65.16 (responsive) | F90.3 S90.3.4 | COMPONENT-SCAFFOLD |
| PfcReeferChart | Z-WWG-102 | F65.4 (wrapper) | F90.3 S90.3.5 | COMPONENT-SCAFFOLD |
| PfcETAChart | Z-WWG-103 | F65.4 (wrapper) | F90.3 S90.3.6 | COMPONENT-SCAFFOLD |
| PfcSimulationPlayback | Z-WWG-104 | F65.19 (nav history) | F90.3 S90.3.7 | COMPONENT-SCAFFOLD |
| PfcAlertPanel | Z-WWG-105 | F65.21 (fullscreen) | F90.3 S90.3.8 | COMPONENT-SCAFFOLD |
| PfcStatusBar | Z-WWG-106 | F65.16 (responsive) | F90.3 S90.3.9 | COMPONENT-SCAFFOLD |
| PfcShell (existing) | — | F65.18 (complete) | F90.4 S90.4.3 | VIEW-REGISTER |

---

### 3.6 Ontology Cross-Reference

| Ontology | Version | Role in Epic 90 | Instance Data |
|----------|---------|-----------------|---------------|
| LSC-ONT | v1.2.0 | Supply chain corridors, compliance gates, scenarios | 4 corridor files (AU/NZ/IS/IE → UK) |
| OFM-ONT | v1.0.0 | Customer orders, stock allocation, fulfilment | 82 entities (5 orders, 18 lines, 12 allocations) |
| VP-ONT | v1.2.3 | Value proposition for live integration | F90.6 S90.6.1 (new instance) |
| RRR-ONT | v3.0.0 | Risk/Requirement/Result alignment | JP-VP-RRR-001 join pattern |
| KPI-ONT | v2.0.0 | Operational metrics | F90.6 S90.6.4 (6 LSC KPIs) |
| BSC-ONT | v1.0.0 | Balanced scorecard perspectives | F90.6 S90.6.5 (4 perspectives) |
| DS-ONT | v3.1.0 | Component tokens, brand palette | F90.3 S90.3.10 (component catalogue) |
| PE-ONT | v4.2.0 | Skill governance, ProcessPath | SKL-154/155 intake path |
| EMC-ONT | v5.0.0 | Instance composition, scope rules | W4M-WWG InstanceConfiguration |

---

### 3.7 UI/UX Cross-Reference

| UI Element | Source | Target | Notes |
|-----------|--------|--------|-------|
| 12-panel logistics dashboard | Epic 45 (HTML standalone) | Epic 90 F90.4 S90.4.3 (App Skeleton) | Replatform from standalone to skeleton-rendered |
| lsc-shipping-tracker.html | LSC-DEMOS (simulation) | Epic 90 F90.4 S90.4.1 (live toggle) | Add live/sim mode switch |
| MeatTrackAI Fleet Intelligence | LSC-DEMOS/MeatTrackAI/ | Reference implementation | React-style multi-tab (reference, not target) |
| Fullscreen panel toggle | Epic 90 F90.4 S90.4.4 | All panels | Already implemented in tracker, formalise as PfcPanel feature |
| WWG brand tokens | Epic 44 (#631) DS-ONT | Epic 90 F90.3 S90.3.10 | Pink/Magenta primary, Royal Blue secondary, Jura typeface |
| Responsive breakpoints | Epic 65 F65.16–F65.18 | All LSC components | Mobile (1-col), Tablet (2-col), Desktop (3-4 col) |

---

### 3.8 Demo & Presentation Assets

| Asset | Location | Purpose |
|-------|----------|---------|
| lsc-shipping-tracker.html | PBS/LSC-DEMOS/ | Interactive simulation (light theme, GitHub Pages hosted) |
| MeatTrackAI_Fleet_Intelligence_3Month.html | PBS/LSC-DEMOS/MeatTrackAI/ | Full fleet dashboard variant |
| MeatTrackAI_Microsoft_Demo.html | PBS/LSC-DEMOS/MeatTrackAI/ | Microsoft environment integration demo |
| MeatTrackAI_Google_Workspace_Simulation.html | PBS/LSC-DEMOS/MeatTrackAI/ | Google Workspace integration demo |
| MeatTrackAI_Microsoft_Presentation.pptx | PBS/LSC-DEMOS/MeatTrackAI/ | Stakeholder presentation deck |
| LSC-DEMO-DOC-MeatTrackAI-Fleet-Intelligence-Tracker-v1.0.0.md | PBS/LSC-DEMOS/ | Technical documentation |
| PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0.md | PBS/STRATEGY/ | Dtree review for SKL-154/155 |

---

## 4. Issue Creation Plan

### 4.1 Epic Issue

**Epic 90:** W4M-WWG-LSC — Live API Integration, App Skeleton Components & Microsoft Deployment

**Labels:** `type:epic`, `pfi:w4m-wwg`, `product:lsc`

### 4.2 Feature Issues

| Issue | Title | Labels |
|-------|-------|--------|
| F90.1 | API Connector Skill (SKL-154: pfc-api-connector) | `type:feature`, `skill:standalone` |
| F90.2 | AIS Adapter Skill (SKL-155: w4m-lsc-ais-adapter) | `type:feature`, `skill:standalone` |
| F90.3 | App Skeleton LSC Components (9 new components) | `type:feature`, `component:skeleton` |
| F90.4 | Live Dashboard Deployment | `type:feature`, `deploy:pages` |
| F90.5 | Microsoft Environment Integration | `type:feature`, `platform:microsoft` |
| F90.6 | VE/QVF Value Realisation Metrics | `type:feature`, `ve:qvf` |
| F90.7 | PDF Shipping Status & Risk/Impact Assessment Report | `type:feature`, `report:pdf` |
| F90.8 | Interactive Legend Filtering | `type:feature`, `ux:filter` |
| F90.9 | Colour-Coded Risk Assessment Bands | `type:feature`, `risk:assessment` |

### 4.3 Story Issues

60 stories across 9 features (S90.1.1–S90.9.7) as detailed in section 3.2.

---

## 5. Delivery Sequence

```
Phase 1: Skills & Foundation (F90.1, F90.2)
  |  Scaffold skills, implement connector + adapter
  |  URG intake: Candidate → Evaluate
  |  Depends: Epic 77 URG intake path
  |
Phase 2: Components & Dashboard (F90.3, F90.4)
  |  Build App Skeleton LSC components
  |  Integrate live data toggle
  |  Deploy to GitHub Pages
  |  Depends: Epic 65 F65.4 wrapper components, Epic 44 DS tokens
  |
Phase 3: Microsoft, Value & Reporting (F90.5, F90.6, F90.7)
  |  Teams/Outlook/SharePoint embedding
  |  VP/QVF/KPI instances, BSC integration
  |  PDF shipping status & risk/impact reports
  |  RAID log auto-generation from tracker data
  |  Scheduled PDF distribution via Power Automate
  |  Depends: Phase 2 complete
  |
Phase 4: Adoption (cross-epic)
     URG intake G3: skills adopted
     PFI triad promotion (dev → test → prod)
     Live API key provisioned
```

---

## 6. Cross-Reference Index

| Document | Location | Relationship |
|----------|----------|-------------|
| API Integration Dtree Review | PBS/STRATEGY/PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0.md | SKL-154/155 classification |
| Fleet Intelligence Tracker Doc | PBS/LSC-DEMOS/LSC-DEMO-DOC-MeatTrackAI-Fleet-Intelligence-Tracker-v1.0.0.md | Tracker architecture |
| W4M-WWG Microsoft VE/QVF Strategy | PBS/STRATEGY/PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md | Strategic brief |
| Epic 45 (#634) | Azlan-EA-AAA hub | LSC/OFM/VP/RRR instance data (CLOSED) |
| Epic 65 (#1106) | Azlan-EA-AAA hub | App Skeleton pipeline |
| Epic 44 (#631) | Azlan-EA-AAA hub | WWG Design System |
| Epic 77 (#1204) | Azlan-EA-AAA hub | URG skill intake |

---

## 7. Requirements Register

### 7.1 Functional Requirements

| REQ-ID | Requirement | Source (VP) | RRR Alignment | Feature | Priority | Status |
|--------|------------|-------------|---------------|---------|----------|--------|
| REQ-001 | System shall display real-time vessel positions updated every 5 minutes | vp:Solution S1 | rrr:Requirement (live AIS tracking) | F90.1, F90.2 | Must Have | Candidate |
| REQ-002 | System shall monitor reefer temperature against set-point and alert on deviation > 0.5C | vp:Solution S2 | rrr:Requirement (cold-chain monitoring) | F90.3 S90.3.5 | Must Have | Candidate |
| REQ-003 | System shall track and display ETA revision history with delay accumulation | vp:Solution S3 | rrr:Requirement (ETA management) | F90.3 S90.3.6 | Must Have | Candidate |
| REQ-004 | System shall integrate IPAFFS/BTOM compliance status per container | vp:Solution S4 | rrr:Requirement (regulatory compliance) | F90.4 S90.4.6 | Should Have | Planned |
| REQ-005 | System shall quantify financial impact per delay event (spoilage, demurrage, penalty) | vp:Solution S5 | rrr:Requirement (financial visibility) | F90.6 S90.6.2, S90.6.3 | Should Have | Planned |
| REQ-006 | System shall provide pre-modelled geopolitical disruption scenarios with cascade effects | vp:Solution S6 | rrr:Requirement (scenario planning) | F90.3 S90.3.8 | Should Have | In Progress (6 scenarios in LSC-ONT) |
| REQ-007 | Dashboard shall be embeddable as Microsoft Teams tab with SSO | vp:Solution (Microsoft) | rrr:Requirement (enterprise deployment) | F90.5 S90.5.1 | Should Have | Planned |
| REQ-008 | System shall send Outlook actionable notifications on ETA shift > 24hrs or temp breach | vp:Solution (Microsoft) | rrr:Requirement (automated alerting) | F90.5 S90.5.2 | Should Have | Planned |
| REQ-009 | System shall generate branded PDF fleet status report on demand and on schedule | vp:Solution (reporting) | rrr:Requirement (stakeholder reporting) | F90.7 S90.7.1, S90.7.7 | Must Have | Planned |
| REQ-010 | PDF report shall include risk assessment with geopolitical and container-level risks | vp:Solution (risk visibility) | rrr:Requirement (risk management) | F90.7 S90.7.3 | Must Have | Planned |
| REQ-011 | PDF report shall include financial impact assessment with cost waterfall per container | vp:Solution (financial case) | rrr:Requirement (impact quantification) | F90.7 S90.7.4 | Must Have | Planned |
| REQ-012 | PDF report shall include auto-generated RAID log from tracker data | vp:Solution (governance) | rrr:Requirement (RAID governance) | F90.7 S90.7.5 | Must Have | Planned |
| REQ-013 | System shall support config-driven API source switching (Datalastic ↔ VesselFinder) | Architecture | rrr:Requirement (resilience) | F90.1, F90.2 | Must Have | Candidate |
| REQ-014 | PDF report shall include requirements traceability (VP-RRR alignment status) | Governance | rrr:Requirement (traceability) | F90.7 S90.7.6 | Should Have | Planned |
| REQ-015 | All panels shall support fullscreen expand/close toggle | UX | rrr:Requirement (usability) | F90.4 S90.4.4 | Must Have | Complete |
| REQ-016 | System shall export fleet status to Excel (.xlsx) on demand | vp:Solution (Microsoft) | rrr:Requirement (data portability) | F90.5 S90.5.5 | Could Have | Planned |

### 7.2 Non-Functional Requirements

| REQ-ID | Requirement | Category | Feature | Priority |
|--------|------------|----------|---------|----------|
| NFR-001 | API polling shall not exceed rate limits (configurable per source) | Performance | F90.1 | Must Have |
| NFR-002 | Dashboard shall render within 2 seconds on desktop, 4 seconds on mobile | Performance | F90.4 | Must Have |
| NFR-003 | PDF generation shall complete within 10 seconds per report | Performance | F90.7 | Should Have |
| NFR-004 | System shall gracefully degrade to simulation mode if API unavailable | Resilience | F90.1, F90.4 | Must Have |
| NFR-005 | All API credentials shall be stored as environment secrets, never in source | Security | F90.1 | Must Have |
| NFR-006 | Dashboard shall be responsive across mobile/tablet/desktop breakpoints | Usability | F90.3, F90.4 | Must Have |
| NFR-007 | PDF report shall conform to W4M-WWG DS-ONT brand tokens | Branding | F90.7 | Should Have |
| NFR-008 | System shall support 12+ concurrent containers without performance degradation | Scalability | F90.3 | Must Have |

---

## 8. RAID Log

### 8.1 Risks (R)

| RAID-ID | Risk | Likelihood | Impact | Severity | Mitigation | Owner | Feature |
|---------|------|-----------|--------|----------|-----------|-------|---------|
| R-001 | Datalastic API discontinued or pricing changes materially | Low | High | HIGH | Config-driven design enables source switch to VesselFinder in < 1 day. api-config.jsonld pattern isolates transport from transform | PFC | F90.1 |
| R-002 | AIS satellite coverage gaps for mid-ocean AU→UK vessels | Medium | Medium | MEDIUM | VesselFinder satellite tier (10 credits/position). Position age displayed in UI. Fallback to carrier portal for confirmation | W4M-WWG | F90.2 |
| R-003 | Red Sea disruption extends beyond simulation period (post-Mar 2026) | High | High | CRITICAL | 6 pre-modelled scenarios in LSC-ONT. Scenario engine extensible. Cape of Good Hope route as permanent alternative | W4M-WWG | F90.3 |
| R-004 | Reefer temperature data not available via AIS (requires IoT/carrier API) | Medium | High | HIGH | Phase 1 uses simulated temp data. Future: carrier reefer API integration as additional adapter skill (same SKL-154 pattern) | W4M-WWG | F90.2 |
| R-005 | Microsoft Teams embedding blocked by customer tenant policies | Medium | Medium | MEDIUM | SharePoint page as alternative. GitHub Pages hosted version always available as fallback. PDF reports as offline alternative | W4M-WWG | F90.5 |
| R-006 | UK BTOM enforcement changes (tighter or relaxed) | Medium | Medium | MEDIUM | Compliance overlay is modular (F90.4 S90.4.6). Rules configurable. Relaxation reduces value of compliance feature but core tracking remains valuable | W4M-WWG | F90.4 |
| R-007 | PDF generation performance with large fleet (50+ containers) | Low | Medium | LOW | Pagination. Server-side generation for large fleets. Client-side adequate for 12-container demo | W4M-WWG | F90.7 |
| R-008 | Geopolitical normalisation reduces perceived urgency | Low | Medium | LOW | Platform value extends beyond geopolitics — operational efficiency, compliance, financial visibility remain compelling. Kano: Must-Be features retain value regardless | W4M-WWG | F90.6 |
| R-009 | Competitor (project44, FourKites) enters mid-market with Microsoft integration | Medium | High | HIGH | First-mover advantage. Domain-specific (meat/seafood) moat. QVF financial overlay as differentiator. Config-driven cost advantage | W4M-WWG | F90.5 |
| R-010 | Epic 65 F65.4 (PFC Wrapper Components) delayed, blocking App Skeleton version | Medium | High | HIGH | HTML standalone version (lsc-shipping-tracker.html) remains functional and demo-ready. GitHub Pages deployment independent of App Skeleton | PFC | F90.3, F90.4 |

### 8.2 Assumptions (A)

| RAID-ID | Assumption | Confidence | Impact if Wrong | Feature |
|---------|-----------|-----------|----------------|---------|
| A-001 | Datalastic API trial key available for development and testing | High | Development blocked — switch to VesselFinder trial | F90.1, F90.2 |
| A-002 | Target customers operate Microsoft 365 (Teams, Outlook, SharePoint) | High (95%+ UK mid-market) | Reduce Microsoft integration priority, focus on standalone dashboard | F90.5 |
| A-003 | AIS vessel position data is sufficient for importer decision-making (vs container-level GPS) | High | Container-level tracking requires carrier API partnerships — significantly more complex | F90.2 |
| A-004 | 5-minute polling interval is adequate for operational decisions | High | Increase polling frequency (higher API cost) or add webhook support | F90.1 |
| A-005 | 12 containers is representative demo scale; production will handle 50–500 | Medium | Performance testing needed for larger fleets. Pagination for PDF reports | F90.4, F90.7 |
| A-006 | Epic 44 (WWG Design System) will deliver DS-ONT tokens before F90.3 App Skeleton components | Medium | Use PFC default tokens. Apply WWG brand tokens as override when available | F90.3 |
| A-007 | UK BTOM pre-notification API (IPAFFS) is accessible for integration | Medium | Manual compliance status entry as fallback. Gov.uk API documentation review needed | F90.4 |
| A-008 | PDF generation can use client-side HTML-to-PDF (jsPDF/html2canvas) for 12-container scale | High | Server-side Puppeteer/Playwright if client-side insufficient for larger fleets | F90.7 |

### 8.3 Issues (I)

| RAID-ID | Issue | Status | Impact | Resolution | Feature |
|---------|-------|--------|--------|-----------|---------|
| I-001 | PROMOTION_PAT secrets not set on W4M-WWG triad repos | OPEN | Blocks dev→test→prod promotion pipeline | Manual admin action required to set PAT secrets | All |
| I-002 | Epic 44 (#631) WWG Design System in P0 Backlog — not actively in progress | OPEN | F90.3 components will use PFC default tokens until DS-ONT re-extraction complete | Proceed with PFC defaults, apply brand override post-Epic 44 | F90.3 |
| I-003 | S45.2.x — 4 LSC corridor files not yet merged into unified instance | DEFERRED | Dashboard must query 4 separate files instead of 1. Performance acceptable at current scale | Deferred pending EMC composition engine (F19.2) | F90.3 |
| I-004 | No CLAUDE.md in pfi-w4m-wwg-dev repo | OPEN | Agent context incomplete for automated workflows | S40.28.2 (#976) — create CLAUDE.md | All |
| I-005 | Reefer temperature data not available from AIS API — AIS provides vessel position only | KNOWN LIMITATION | Temperature monitoring in Phase 1 uses simulated/set-point data. Live temp requires carrier IoT API | Carrier API adapter skill (future) | F90.2, F90.7 |

### 8.4 Dependencies (D)

| RAID-ID | Dependency | Type | Dependent Feature | Providing Feature/Epic | Status |
|---------|-----------|------|------------------|----------------------|--------|
| D-001 | Epic 65 F65.4 — PFC Wrapper Components | Technical | F90.3 (App Skeleton LSC components) | Epic 65 (#1106) | 3/7 complete |
| D-002 | Epic 77 — URG Skill Intake Path | Process | F90.1, F90.2 (skill registration) | Epic 77 (#1204) | In Progress |
| D-003 | Epic 44 — WWG Design System tokens | Visual | F90.3 S90.3.10, F90.7 S90.7.8 (branding) | Epic 44 (#631) | P0 Backlog |
| D-004 | Datalastic API trial key provisioning | External | F90.1, F90.2 (live data) | External vendor | Not started |
| D-005 | Microsoft Graph API access (tenant) | External | F90.5 (Teams/Outlook/SharePoint) | Customer tenant admin | Not started |
| D-006 | IPAFFS/Gov.uk API documentation review | External | F90.4 S90.4.6 (compliance overlay) | UK Government | Not started |
| D-007 | PFI triad PAT secrets | Infrastructure | All (promotion pipeline) | Admin action | OPEN (I-001) |
| D-008 | Power Automate licence (customer tenant) | External | F90.5 S90.5.4, F90.7 S90.7.7 (scheduled flows) | Customer M365 licence | Assumed available (E3/E5) |

---

## 9. RAID Summary Matrix

```
                HIGH Impact               LOW Impact
              +-------------------------+-------------------------+
 HIGH         |  R-003 Red Sea extends  |  R-006 BTOM changes     |
 Likelihood   |  R-009 Competitor entry |  R-008 Geo normalise    |
              |  R-010 E65 F65.4 delay  |                         |
              +-------------------------+-------------------------+
 LOW          |  R-001 API discontinue  |  R-007 PDF performance  |
 Likelihood   |  R-004 Reefer data gap  |                         |
              |  R-005 Teams tenant     |                         |
              +-------------------------+-------------------------+

 Critical Path Dependencies: D-001 (E65 wrappers) → D-003 (DS tokens) → D-002 (URG intake)
 External Dependencies:      D-004 (Datalastic key) → D-005 (MS Graph) → D-006 (IPAFFS)
 Blockers:                   I-001 (PAT secrets), I-004 (CLAUDE.md)
```

---

*Plan generated from Dtree evaluation (decision-tree.js v1.0.0), Epic 45 deliverables, Epic 65 component framework, and PFC-PFI cascade architecture. RAID log aligned to RAID-ONT (GRC-Series). Requirements traced to VP-ONT ↔ RRR-ONT alignment convention (JP-VP-RRR-001).*

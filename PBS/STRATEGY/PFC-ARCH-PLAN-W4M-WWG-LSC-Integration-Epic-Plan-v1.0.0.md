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

### 4.3 Story Issues

33 stories across 6 features (S90.1.1–S90.6.5) as detailed in section 3.2.

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
Phase 3: Microsoft & Value (F90.5, F90.6)
  |  Teams/Outlook/SharePoint embedding
  |  VP/QVF/KPI instances
  |  BSC integration
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

*Plan generated from Dtree evaluation (decision-tree.js v1.0.0), Epic 45 deliverables, Epic 65 component framework, and PFC-PFI cascade architecture.*

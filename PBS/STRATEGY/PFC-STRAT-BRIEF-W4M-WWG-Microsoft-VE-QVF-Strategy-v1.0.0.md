# PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0

> **Product Code:** PFC-STRAT
> **Doc Type:** BRIEF (Strategy Briefing)
> **Version:** 1.0.0
> **Status:** For Decision
> **Date:** 2026-03-26
> **PFI Instance:** W4M-WWG (World Wide Gourmet)
> **Cross-ref:** PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md, PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0.md

---

## 1. Executive Summary

W4M-WWG (World Wide Gourmet) operates as a UK specialist food importer across four inbound supply corridors — Australia, New Zealand, Iceland, and Ireland — managing frozen, chilled, and fresh meat and seafood shipments into UK distribution.

This strategy brief positions the W4M-WWG logistics intelligence solution within the **Microsoft enterprise ecosystem** (Teams, Outlook, SharePoint, Power Platform, Azure) and evaluates it through the **VE (Value Engineering) and QVF (Quantified Value Framework)** lens — quantifying value for both the **customer** (UK importers, distributors, retailers) and the **internal exporter/importer operation**, while accounting for escalating global geopolitical risk, economic volatility, and the operational imperative for supply chain agility.

---

## 2. Macro Context: Why Now

### 2.1 Geopolitical Risk Escalation

The global shipping environment has entered a structurally higher-risk regime. The simulation scenarios built into the MeatTrackAI tracker are not hypothetical — they reflect events that have occurred or are plausible within the current geopolitical landscape:

| Risk Vector | Current Status | Impact on AU/NZ → UK Corridor |
|------------|---------------|-------------------------------|
| **Red Sea / Houthi disruption** | Ongoing since late 2023. Maersk, MSC, CMA CGM intermittently suspending Suez transits | +7–10 days transit via Cape of Good Hope. $1M+ per vessel in additional fuel. 15–20% reefer capacity reduction on Cape route |
| **Strait of Hormuz tension** | IRGC exercises, US-Iran escalation cycles | AIS blackout zones. Vessels held at Jebel Ali. Insurance premium surges (300%+ in Lloyd's war-risk market) |
| **Ukraine/Black Sea corridor** | Grain corridor instability. NATO escalation risk | Indirect: global shipping capacity reallocation. Container availability squeeze in Indian Ocean |
| **South China Sea / Taiwan Strait** | PLA exercises, US FONOPS, Philippines tensions | Malacca Strait contingency planning. AU/NZ carriers assessing alternative routing |
| **Suez Canal politicisation** | Egyptian toll increases (15% Jan 2024). Climate-driven low-water events | Cost pass-through to shippers. Transit delay variability increasing |
| **UK border regime (BTOM)** | Border Target Operating Model phased enforcement | Documentary checks causing 24–36hr delays at Tilbury/Southampton BCP. Pre-notification window extended to 72hrs |

**Net effect:** Transit time variability has increased from +/-2 days (2019) to +/-10 days (2026). The cost of a "surprise" has risen proportionally — a single reefer container of premium Australian beef arriving 7 days late can trigger £15K–£40K in spoilage, demurrage, and customer penalty costs.

### 2.2 Economic Pressures

| Factor | Trend | Impact |
|--------|-------|--------|
| **Bunker fuel costs** | Volatile (VLSFO $550–$750/mt range) | Carriers imposing slow-steaming without notice. ETA +5–7 days. No advance warning to importers |
| **Container rates** | Spot rates 3–5x above 2019 baseline on AU/NZ → EU routes | Margin compression for importers. Need to optimise every shipment |
| **UK cold storage capacity** | Near saturation (92–96% utilisation nationally) | No buffer for delayed arrivals. Overflow = temporary storage at £800–£1,200/day/container |
| **Sterling volatility** | GBP/AUD oscillating 1.85–1.98 (2025-2026) | Procurement cost uncertainty. Need real-time margin recalculation |
| **Insurance premiums** | War-risk premiums 10–15x above 2022 baseline for Red Sea transit | Route choice now has direct insurance cost impact |

### 2.3 Regulatory Tightening

| Regulation | Requirement | Consequence of Non-Compliance |
|-----------|-------------|-------------------------------|
| **UK BTOM** (Border Target Operating Model) | Pre-notification via IPAFFS 72hrs before arrival. Documentary checks at BCP. Physical checks (risk-based) | Shipment held at port. £500–£2,000 per inspection delay. Perishable goods at risk |
| **DAFF** (AU Department of Agriculture) | Export permit, health certificate, cold-chain documentation | Shipment rejected at origin. 2–4 week remediation |
| **EU Deforestation Regulation** | Due diligence on beef supply chain (applies to UK via retained EU law alignment) | Market access restriction. Reputational damage |
| **HMRC Tariff Codes** | Correct commodity codes for preferential rates under UK-AU FTA | Overpayment of duty (3–12% on meat products) or customs penalty |

### 2.4 The Agility Imperative

In this environment, the traditional model of **weekly spreadsheet tracking + email chains + phone calls to freight forwarders** is structurally inadequate. The information arrives too late, in too many formats, from too many sources, with no integrated view of risk, cost, or customer impact.

**What is needed:**
- **Real-time visibility** — vessel position, ETA revision, reefer temperature, compliance status
- **Predictive intelligence** — scenario modelling, cascade effect analysis, shelf-life projection
- **Automated alerting** — stakeholder notification within minutes, not days
- **Integrated decision support** — financial impact quantification alongside operational status
- **Microsoft-native delivery** — embedded in the tools the business already uses (Teams, Outlook, SharePoint)

---

## 3. Value Engineering Analysis

### 3.1 VP-ONT Instance: W4M-WWG LSC Live Integration

Following the VP-ONT ↔ RRR-ONT alignment convention (JP-VP-RRR-001):

#### Problems (vp:Problem → rrr:Risk)

| ID | Problem | Risk (RRR) | Severity |
|----|---------|------------|----------|
| P1 | **Blind spots on vessel position** — importers don't know where shipments are until carrier sends manual update (often 48–72hrs delayed) | Spoilage from undetected delay. Customer SLA breach | CRITICAL |
| P2 | **No temperature visibility in transit** — reefer temperature data only available at discharge. By then, damage is done | Cold-chain breach undetected. Insurance claim rejected (no evidence of monitoring) | HIGH |
| P3 | **Manual ETA management** — ETA tracked in spreadsheets, updated by email. No revision history. No impact analysis | Warehouse capacity misallocation. Customer delivery window missed | HIGH |
| P4 | **Fragmented compliance workflow** — IPAFFS, DAFF, HMRC in separate systems. No integrated pre-arrival view | BTOM inspection delay. Goods held at port. Perishable degradation | MEDIUM |
| P5 | **No financial impact quantification** — operations team sees delays but can't quantify cost impact in real-time | Margin erosion invisible until month-end P&L. No data for insurance claims | MEDIUM |
| P6 | **Geopolitical risk response is reactive** — route changes discovered after the fact. No scenario planning | Competitive disadvantage vs importers with better intelligence | HIGH |

#### Solutions (vp:Solution → rrr:Requirement)

| ID | Solution | Requirement (RRR) | Skill |
|----|----------|-------------------|-------|
| S1 | **Live AIS vessel tracking** via Datalastic/VesselFinder API, updated every 5 minutes | API connector skill (SKL-154) + AIS adapter (SKL-155) | pfc-api-connector, w4m-lsc-ais-adapter |
| S2 | **Reefer temperature monitoring** with set-point deviation alerting | PfcReeferChart component, threshold alert logic | App Skeleton F90.3 |
| S3 | **Automated ETA revision tracking** with historical revision chart and cascade impact analysis | PfcETAChart, delay accumulation model, OFM cross-reference | App Skeleton F90.3 |
| S4 | **Integrated compliance dashboard** — IPAFFS pre-notification status, BTOM documentary check readiness | Compliance overlay (F90.4 S90.4.6), Gov.uk API | Future skill |
| S5 | **QVF financial impact engine** — real-time cost quantification per delay event (spoilage, demurrage, penalty, insurance) | QVF LSC model (F90.6), KPI dashboard | pfc-qvf-lsc (future SKL) |
| S6 | **Geopolitical scenario engine** — pre-modelled disruption scenarios with cascade effect chains | LSC-ONT scenario instances (6 pre-modelled), PfcAlertPanel | Existing instance data |

#### Benefits (vp:Benefit → rrr:Result)

| ID | Benefit | Result (RRR) | Quantification |
|----|---------|-------------|----------------|
| B1 | **Reduced spoilage** — early detection of delay + temp breach enables proactive re-routing or re-allocation | Spoilage rate reduction 30–50% | £120K–£400K/year (based on 200 containers/year, 5% baseline spoilage, £12K–£40K per incident) |
| B2 | **Demurrage avoidance** — early ETA revision enables warehouse slot re-booking | Demurrage cost reduction 40–60% | £60K–£150K/year (based on £500–£1,200/day per late container, 3–5 day average overstay) |
| B3 | **Customer SLA compliance** — proactive notification enables delivery window renegotiation | OTIF (On Time In Full) improvement from 78% to 92%+ | Customer retention value: £200K–£500K/year (contract renewal probability uplift) |
| B4 | **Insurance claim success** — continuous monitoring evidence supports cargo claims | Claim approval rate improvement from 45% to 85%+ | £50K–£150K/year (improved recovery on legitimate claims) |
| B5 | **Margin visibility** — real-time cost impact enables informed procurement decisions | Gross margin improvement 2–4 percentage points | £100K–£300K/year on £5M–£10M import volume |
| B6 | **Competitive advantage** — intelligence-led importing vs reactive competitors | Market positioning as technology-forward importer | Strategic: customer acquisition, premium pricing justification |

---

### 3.2 QVF Financial Model

#### 3.2.1 Customer Value (UK Importer — External)

**Scenario: Mid-size UK meat importer, 200 containers/year, £5M–£10M annual import value**

| Value Driver | Annual Baseline Cost | Projected Reduction | Annual Saving |
|-------------|---------------------|--------------------|--------------|
| Spoilage (cold-chain failure + delay) | £400K–£800K | 30–50% | £120K–£400K |
| Demurrage & detention | £150K–£300K | 40–60% | £60K–£180K |
| Customer penalties (SLA breach) | £100K–£250K | 50–70% | £50K–£175K |
| Insurance claim recovery gap | £80K–£200K | 40%+ improvement | £32K–£80K |
| Manual tracking labour | £60K–£120K (1.5–3 FTE) | 60–80% automation | £36K–£96K |
| **Total annual saving** | | | **£298K–£931K** |

| Investment | Cost |
|-----------|------|
| Datalastic API (Starter plan) | £2,400/year |
| Platform licence (SaaS model, future) | £12K–£24K/year |
| Implementation (one-time) | £5K–£15K |
| **Total annual cost** | **£14K–£26K** |

| Metric | Value |
|--------|-------|
| **Net annual value** | £272K–£905K |
| **ROI** | 1,146%–3,481% |
| **Payback** | < 1 month |

#### 3.2.2 Internal Value (W4M-WWG — Exporter/Importer Operation)

| Value Driver | Mechanism | Annual Impact |
|-------------|-----------|--------------|
| **Operational efficiency** | Automated tracking replaces 2 FTE manual monitoring | £80K–£120K saved |
| **Decision speed** | Real-time vs 48–72hr delayed information | Unmeasured but strategic (faster re-routing, re-allocation) |
| **Product IP** | Reusable platform capability for other PFI instances | Amortised development cost across BAIV, AIRL, future PFIs |
| **Market validation** | Demo-ready product for investor/customer conversations | De-risks fundraising, accelerates sales cycle |
| **Skill portfolio** | SKL-154/155 contribute to PFC skill register (153 → 155) | Platform maturity signal |

#### 3.2.3 Kano Classification

| Feature | Kano Category | Rationale |
|---------|--------------|-----------|
| Live vessel position | **Must-Be** | Table stakes for modern logistics intelligence. Absence = unacceptable |
| ETA revision tracking | **Performance** | More accuracy = more satisfaction. Linear relationship |
| Temperature monitoring | **Must-Be** | Regulatory and insurance requirement. Non-negotiable |
| Geopolitical scenario engine | **Attractive** | Unexpected delight. Competitors don't offer pre-modelled disruption analysis |
| QVF financial impact | **Attractive** | Most competitors show operational data, not financial impact |
| Microsoft Teams embedding | **Performance** | Convenience scales with usage. More integration = more value |
| Simulation playback | **Attractive** | Training and audit capability. Not expected but highly valued |
| Cold-chain shelf-life calculator | **Performance** | Directly actionable. More precision = more value |

---

## 4. Microsoft Environment Strategy

### 4.1 Why Microsoft

W4M-WWG's target customer base (UK food importers, distributors, retailers) overwhelmingly operates within the Microsoft ecosystem:

- **95%+ of UK mid-market businesses** use Microsoft 365 (Teams, Outlook, SharePoint)
- **Operations teams live in Outlook and Teams** — not in standalone dashboards
- **Decision-makers consume data in Excel and PowerBI** — not in custom UIs
- **IT departments approve Microsoft-integrated tools faster** — SSO, compliance, data residency

Delivering logistics intelligence inside the Microsoft environment eliminates the adoption barrier of "yet another dashboard to check."

### 4.2 Integration Architecture

```
                    Data Layer
                    ==========
    Datalastic AIS API          VesselFinder API
    (vessel positions)          (satellite AIS)
            |                         |
            v                         v
    pfc-api-connector (SKL-154)
    Config-driven HTTP integration
            |
            v
    w4m-lsc-ais-adapter (SKL-155)
    Domain-specific transform
            |
            v
                    Presentation Layer
                    ==================
    +--------------------------------------------------+
    |              Microsoft 365 Environment            |
    |                                                    |
    |  +-- Teams Tab --------------------------------+  |
    |  |   Fleet Intelligence Dashboard              |  |
    |  |   (iframe embed, SSO-aware)                 |  |
    |  |   Real-time map, container list, alerts     |  |
    |  +--------------------------------------------+  |
    |                                                    |
    |  +-- Outlook Actionable Messages ---------------+ |
    |  |   ETA shift > 24hrs → notification card      | |
    |  |   Temp breach → CRITICAL alert card          | |
    |  |   Buttons: View Container | Acknowledge      | |
    |  +--------------------------------------------+  |
    |                                                    |
    |  +-- SharePoint Dashboard Page ----------------+  |
    |  |   Org-wide fleet visibility                  |  |
    |  |   Embedded tracker + KPI summary             |  |
    |  +--------------------------------------------+  |
    |                                                    |
    |  +-- Power Automate Flows --------------------+  |
    |  |   ETA shift trigger → email DL              |  |
    |  |   Temp breach trigger → Teams channel alert  |  |
    |  |   Daily fleet summary → SharePoint list      |  |
    |  +--------------------------------------------+  |
    |                                                    |
    |  +-- Excel / PowerBI --------------------------+  |
    |  |   One-click fleet status export (.xlsx)      |  |
    |  |   PowerBI connector (tracker-update.jsonld)  |  |
    |  |   Historical voyage analysis                 |  |
    |  +--------------------------------------------+  |
    +--------------------------------------------------+
```

### 4.3 Microsoft Integration Phases

| Phase | Capability | Complexity | Dependency |
|-------|-----------|-----------|------------|
| **Phase 1** | GitHub Pages hosted dashboard (current) | Low | None — already deployed |
| **Phase 2** | Teams tab + Outlook notifications | Medium | Microsoft Graph API, Adaptive Cards |
| **Phase 3** | SharePoint page + Power Automate flows | Medium | SharePoint Framework (SPFx), Power Automate connectors |
| **Phase 4** | PowerBI connector + Excel export | Medium-High | PowerBI REST API, custom connector certification |

### 4.4 Security & Compliance (Microsoft Environment)

| Requirement | Approach |
|-------------|----------|
| **Authentication** | Azure AD / Entra ID SSO. No separate credentials |
| **Data residency** | API data processed in UK region. No PII in vessel tracking data |
| **Tenant isolation** | Per-customer deployment. No shared tenancy |
| **Audit trail** | All API calls logged. ETA revision history immutable |
| **GDPR** | No personal data in vessel tracking. Customer contact data in Outlook governed by existing DPA |

---

## 5. Competitive Positioning

### 5.1 Landscape

| Competitor | Strength | Weakness | W4M-WWG Differentiation |
|-----------|----------|----------|------------------------|
| **MarineTraffic** | Large AIS network, port intelligence | Generic — not food/cold-chain specific. No financial impact. No Microsoft integration | Domain-specific (meat/seafood), QVF financial overlay, Microsoft-native |
| **project44** | Enterprise supply chain visibility | Expensive ($50K+/year). Complex implementation. Overkill for mid-market | Right-sized for mid-market importers. Config-driven, not custom-built |
| **FourKites** | Real-time visibility, carrier integrations | US-focused. Limited UK BTOM/IPAFFS awareness | UK-specific compliance (BTOM, IPAFFS, DAFF). 4-corridor AU/NZ/IS/IE model |
| **Carrier portals** (Maersk, MSC) | Direct carrier data | Fragmented — one portal per carrier. No cross-carrier view | Unified view across all carriers. 12 containers, 6 carriers, single dashboard |
| **Spreadsheets + email** | Familiar, no licence cost | No real-time data. Manual errors. No alerts. No scenario planning | Automated, real-time, intelligent, Microsoft-integrated |

### 5.2 Unique Value Proposition

**For UK meat and seafood importers** who manage 50–500 containers per year across multiple carriers and corridors, **W4M-WWG LSC Intelligence** provides **real-time vessel tracking, cold-chain monitoring, and financial impact quantification** delivered inside Microsoft Teams and Outlook — unlike carrier portals that show fragmented data, or enterprise platforms that cost £50K+/year and take months to implement.

---

## 6. Benefits Realisation Framework

### 6.1 Customer Benefits Realisation

| Benefit | Measure | Baseline | Target | Timeframe |
|---------|---------|----------|--------|-----------|
| Spoilage reduction | Spoilage incidents per quarter | 12–15 | 6–8 | 6 months |
| Demurrage avoidance | Demurrage days per quarter | 45–60 | 18–25 | 3 months |
| OTIF improvement | On Time In Full % | 78% | 92%+ | 6 months |
| Alert response time | Time from event to stakeholder notification | 48–72 hrs | < 15 mins | Immediate |
| Manual tracking labour | FTE on manual vessel tracking | 1.5–3 FTE | 0.3–0.5 FTE | 3 months |
| Insurance claim recovery | Claim approval rate | 45% | 85%+ | 12 months |
| ETA accuracy | ETA prediction accuracy (within 24hrs) | 55% | 88%+ | 6 months |

### 6.2 Internal Benefits Realisation

| Benefit | Measure | Baseline | Target | Timeframe |
|---------|---------|----------|--------|-----------|
| Platform skill count | Skills in register | 153 | 155+ | Immediate |
| PFI cascade reuse | PFI instances consuming pfc-api-connector | 0 | 3+ (W4M, BAIV, AIRL) | 6 months |
| Demo readiness | Interactive demos available for customer/investor | 3 (simulation only) | 6+ (live + simulation) | 3 months |
| Product-market validation | Customer conversations using live demo | 0 | 5+ | 3 months |
| Revenue pipeline | Pipeline value from LSC intelligence product | £0 | £100K–£500K | 12 months |

### 6.3 BSC (Balanced Scorecard) Integration

| Perspective | KPI | Target | VP Alignment |
|------------|-----|--------|-------------|
| **Financial** | Gross margin improvement | +2–4 pp | B5 (margin visibility) |
| **Customer** | OTIF delivery performance | 92%+ | B3 (SLA compliance) |
| **Process** | Alert-to-action latency | < 15 mins | B1 (spoilage reduction) |
| **Learning** | Scenario coverage (pre-modelled disruptions) | 6 active scenarios | B6 (competitive advantage) |

---

## 7. Risk Assessment

### 7.1 Delivery Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Datalastic API discontinuation | Low | High | VesselFinder as configured alternative. Config-driven design enables source switch in < 1 day |
| AIS coverage gaps (mid-ocean satellite) | Medium | Medium | Satellite AIS via VesselFinder (10 credits/position). Budget for satellite tier |
| Microsoft Graph API changes | Low | Medium | Adaptive Cards versioning. SPFx framework backward-compatible |
| Customer adoption resistance | Medium | High | Deploy in existing Microsoft tools (Teams/Outlook). Zero new UIs to learn |
| Data accuracy (AIS position lag) | Medium | Low | Position age displayed. Polling interval configurable. Fallback to carrier portal for confirmation |

### 7.2 Strategic Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Competitor enters mid-market with Microsoft integration | Medium | High | First-mover advantage. Domain-specific (meat/seafood) moat. QVF financial overlay as differentiator |
| UK BTOM enforcement relaxed | Low | Medium | Dashboard value extends beyond compliance (operational intelligence) |
| Geopolitical risk normalisation (Suez reopens permanently) | Low | Low | Scenario engine remains valuable for other disruptions. Weather, port strikes, disease outbreaks |
| Cold-chain technology shift (IoT-direct monitoring) | Medium | Medium | Architecture supports IoT data source as additional adapter skill (same pfc-api-connector pattern) |

---

## 8. Strategic Recommendations

1. **Proceed with Epic 90** — the macro environment demands supply chain intelligence. The VE/QVF analysis shows compelling ROI (>1,000%) for target customers.

2. **Prioritise Microsoft Teams embedding** (F90.5 S90.5.1) as the highest-impact integration. Operations teams live in Teams — meeting them there eliminates adoption friction.

3. **Lead with the simulation tracker for sales** — the interactive demo (GitHub Pages) is immediately available for customer conversations. Live API integration follows as the paid product.

4. **Build the generic connector first** (SKL-154) — PFC-tier reuse across BAIV, AIRL, and future PFIs justifies the investment. The connector is the platform play; the adapter is the product play.

5. **Quantify value in every customer conversation** using the QVF model. Don't sell features — sell £300K–£900K/year in avoided cost. The financial case is the differentiator.

6. **Register VP instance** (F90.6 S90.6.1) immediately to formalise the value proposition in the ontology. This enables consistent messaging across demos, investor materials, and customer proposals.

7. **Deploy PDF reporting early** (F90.7) — branded fleet status and risk/impact PDFs are the highest-value sales artefact. Customers who receive a professional PDF risk assessment during a demo conversation convert faster than those shown a dashboard alone. The RAID log auto-generation (S90.7.5) and requirements traceability (S90.7.6) add governance credibility for enterprise buyers.

8. **Use the QVF financial impact section in PDFs** (S90.7.4) as the closing argument in every customer proposal — spoilage cost waterfall, demurrage avoidance, and margin impact quantified per container. Board-ready evidence, not operational data.

---

## 9. Epic 90 Feature Summary

| Feature | Title | Stories | Phase |
|---------|-------|---------|-------|
| F90.1 | API Connector Skill (SKL-154) | 6 | Phase 1 |
| F90.2 | AIS Adapter Skill (SKL-155) | 7 | Phase 1 |
| F90.3 | App Skeleton LSC Components | 10 | Phase 2 |
| F90.4 | Live Dashboard Deployment | 6 | Phase 2 |
| F90.5 | Microsoft Environment Integration | 6 | Phase 3 |
| F90.6 | VE/QVF Value Realisation Metrics | 5 | Phase 3 |
| F90.7 | PDF Shipping Status & Risk/Impact Assessment | 8 | Phase 3 |
| F90.8 | Interactive Legend Filtering | 5 | Phase 2 |
| F90.9 | Colour-Coded Risk Assessment Bands + QVF-LSC | 7 | Phase 2 |
| **Total** | | **60** | |

Full feature/story detail, requirements register, and RAID log in the Epic Plan document.

---

## 10. Document Cross-References

| Document | Location | Relationship |
|----------|----------|-------------|
| Epic Plan & Cross-Reference | PBS/STRATEGY/PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md | Epic 90: 7 features, 48 stories, requirements register, RAID log |
| API Integration Dtree Review | PBS/STRATEGY/PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0.md | SKL-154/155 Dtree classification |
| Fleet Intelligence Tracker Doc | PBS/LSC-DEMOS/LSC-DEMO-DOC-MeatTrackAI-Fleet-Intelligence-Tracker-v1.0.0.md | Tracker architecture, data model, scenario engine |
| lsc-shipping-tracker.html | PBS/LSC-DEMOS/lsc-shipping-tracker.html | Live demo (GitHub Pages) |
| MeatTrackAI Documentation | PBS/LSC-DEMOS/MeatTrackAI/MeatTrackAI-Documentation.md | AIS API setup, trade lanes, carriers |
| MeatTrackAI Microsoft Demo | PBS/LSC-DEMOS/MeatTrackAI/MeatTrackAI_Microsoft_Demo.html | Microsoft environment integration demo |
| MeatTrackAI Presentation | PBS/LSC-DEMOS/MeatTrackAI/MeatTrackAI_Microsoft_Presentation.pptx | Stakeholder presentation deck |

---

*Strategy brief authored using VSOM → OKR → VP → QVF → PMF → EFS lineage chain. VP-ONT ↔ RRR-ONT alignment convention (JP-VP-RRR-001). Kano classification applied to feature prioritisation. QVF financial model based on mid-market UK meat importer profile (200 containers/year, £5M–£10M import volume).*

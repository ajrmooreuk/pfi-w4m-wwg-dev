# DISCUSSION: FairSlice — Proposals Overview & Open Decisions

## FairSlice One-Page Proposal, VSOM Cascade & Commercial Model

| Field | Value |
|---|---|
| **Date** | 2026-03-04 |
| **Version** | 1.0.0 |
| **Status** | PROPOSAL — For Review & Discussion |
| **Classification** | CONFIDENTIAL — Strategic Planning Asset |
| **Parent** | Epic 34: PF-Core Graph-Based Agentic Platform Strategy (#518) |
| **Tracking** | Epic 50 (#754), Epic 51 (#754) |
| **Lead Document** | [BRIEFING-FairSlice-Strategy-Implementation-Proposals.md](BRIEFING-FairSlice-Strategy-Implementation-Proposals.md) |
| **VP-RRR Convention** | Maintained throughout — Problem=Risk, Solution=Requirement, Benefit=Result |

---

## 1. The One-Page Proposal

### What Is FairSlice?

FairSlice is the **economic layer** of PF-Core. It automates how value (equity, revenue, commissions) flows between everyone who contributes to a venture -- builders, salespeople, module creators, and channel partners.

### Why Now?

Three forces are converging:

1. **BAIV is approaching 100 clients** (OBJ-F1). Partner conversations are already happening. Without a formal model, early deals will set ad-hoc precedents that are expensive to unpick later.
2. **Epic 34 has two unresolved BSC objectives** -- OBJ-SH2 (10+ partners with digital contracts) and OBJ-F4 (GBP 100K partner revenue). Neither has an implementation path today.
3. **The JSONB Graph PoC (F34.5) and FairSlice schema are the same thing.** Building FairSlice IS building the graph storage layer -- we get two deliverables for one effort.

### How Does It Work?

```
REVENUE EVENT (e.g. GBP 5,000 enterprise deal)
  |
  v
WATERFALL ENGINE (7 priority steps)
  1. Platform Fee       -->  PF-Core         (5% = GBP 250)
  2. Affiliate Payout   -->  Referrer         (10% of fee = GBP 25)
  3. Agency Retainer    -->  Managing Agency   (5% = GBP 250)
  4. Architect Royalty   -->  Module Creator    (license fee = GBP 100)
  5. OpEx Recovery      -->  Operating costs   (GBP 0)
  6. Tax Reserve        -->  HMRC reserve      (GBP 0)
  7. Dividend Pool      -->  Pie Members       (by ownership % = GBP 4,375)
```

Every step is governed by a **smart contract** (ontology-driven business logic, not blockchain). An **AI Judge** (Claude) verifies contribution claims before slices are allocated. The whole thing runs through the same quasi-OO cascade as every other PFC artifact.

### Four Personas, Four Incentives

| Who | What They Do | What They Get | Platform Win |
|-----|-------------|---------------|-------------|
| **Builder** | Ships code, content, assets | 2x Slice multiplier (equity) | Automated credit, no spreadsheets |
| **Rainmaker** | Closes deals, brings revenue | Cash/equity commission | Dynamic payout on cash availability |
| **Architect** | Creates reusable smart contracts | Royalty per install | License IP to multiple ventures |
| **Partner** | Agency manages pies; Affiliate refers | Management fee / referral % | Channel velocity at scale |

### Three Revenue Loops

| Loop | Who Pays | For What | Revenue Type |
|------|---------|----------|-------------|
| **Inner (SaaS)** | Founders, startups | Platform subscription, equity automation | Recurring MRR |
| **Middle (Marketplace)** | Pies (startups) | Smart contract licenses, architect royalties | Transaction fees |
| **Outer (Channel)** | Agencies bring volume | Management fees, referral commissions | Partner-originated |

### What's Already Done

- FAIRSLICE-ONT v1.0.0 -- 9 entities, 19 relationships, 8/8 OAA gates (Orchestration series)
- PARTNER-ONT v1.0.0 -- 6 entities, 10 relationships, 8/8 OAA gates (Foundation series, closes Epic 34 gap)
- Registry updated to v10.7.0 (52 ontologies)
- Schema convergence map proving FairSlice tables = F34.5 JSONB patterns
- Epic briefing with full BSC cascade

### What's Not Done (Decisions Needed)

| Decision | Options | Impact |
|----------|---------|--------|
| **Build sequence** | FairSlice first (standalone SaaS) vs. embedded in BAIV vs. pure PFC capability | Determines first revenue path |
| **Smart contracts -- real or modelled?** | Full Stripe Connect split payments vs. ledger-only (manual payouts) | Scope and compliance burden |
| **AI Judge scope** | Claims verification only vs. dispute resolution vs. contract generation | Agent cost model |
| **Partner tier thresholds** | Bronze 1-5 clients, Silver 6-15, Gold 16-30, Platinum 31+ (proposed) | Channel economics |
| **Equity vs. cash split** | Builder-heavy (equity) vs. Rainmaker-heavy (cash) vs. configurable per pie | Incentive design |

---

## 2. VSOM -- FairSlice Strategy

### 2.1 Vision

> **Every contributor to a PF-Core venture receives a fair, transparent, automatically calculated share of the value they create -- governed by the same ontology cascade that powers the entire platform.**

### 2.2 Strategies

| # | Strategy | Aligns To | Focus |
|---|----------|-----------|-------|
| **FS-S1** | Waterfall-First Revenue Engine | Epic 34 S1 (Graph-First) | Revenue events flow through priority-ordered rules. All distributions are graph-traversable, auditable, reconcilable. |
| **FS-S2** | Contribution-Based Equity | Epic 34 S2 (VE-Driven) | Every slice traces to a verified claim. Ownership is dynamic and earned, not static cap table entries. |
| **FS-S3** | AI-Verified Claims | Epic 34 S3 (Agentic) | Claude Judge evaluates claims against smart contract rules. Three-tier cost model keeps per-claim cost under $0.05. |
| **FS-S4** | Channel Economics at Scale | Epic 34 S4 (Instance Customisation) | Partners/agencies/affiliates inherit PFC base rules, override per PFI, customise per pie. Quasi-OO cascade. |
| **FS-S5** | Smart Contract Marketplace | Epic 34 S6 (Integration) | Architects publish reusable validation logic. Pies subscribe. Unified Registry treats contracts as artifacts. |

### 2.3 Objectives (BSC, 5 Perspectives)

**Financial**

| ID | Objective | Target | Traces To |
|----|-----------|--------|-----------|
| OBJ-FS-F1 | Platform fee revenue (SaaS loop) | GBP 50K ARR | Epic 34 OBJ-F2 |
| OBJ-FS-F2 | Partner-originated revenue (channel loop) | GBP 100K/year | Epic 34 OBJ-F4 |
| OBJ-FS-F3 | Marketplace revenue (architect loop) | GBP 25K ARR | New |

**Customer**

| ID | Objective | Target | Traces To |
|----|-----------|--------|-----------|
| OBJ-FS-C1 | Pie creation to first distribution | < 7 days | Epic 34 OBJ-C3 |
| OBJ-FS-C2 | Contributor fairness NPS | >= 65 | Epic 34 OBJ-C2 |
| OBJ-FS-C3 | Claim auto-verification rate | 80%+ | New |

**Internal Process**

| ID | Objective | Target | Traces To |
|----|-----------|--------|-----------|
| OBJ-FS-IP1 | Waterfall execution latency | < 500ms | Epic 34 OBJ-IP3 |
| OBJ-FS-IP2 | Audit trail coverage on distributions | 100% | Epic 34 OBJ-IP1 |
| OBJ-FS-IP3 | AI Judge cost per claim | < $0.05 avg | Epic 34 OBJ-IP5 |

**Learning & Growth**

| ID | Objective | Target | Traces To |
|----|-----------|--------|-----------|
| OBJ-FS-LG1 | Ontologies in registry (DONE) | FAIRSLICE + PARTNER | Epic 34 OBJ-LG1 |
| OBJ-FS-LG2 | Reusable smart contracts published | 5+ in marketplace | New |

**Stakeholder**

| ID | Objective | Target | Traces To |
|----|-----------|--------|-----------|
| OBJ-FS-SH1 | Partners with digital contract governance | 10+ | Epic 34 OBJ-SH2 |
| OBJ-FS-SH2 | Channel Velocity (Pies/Agency/Month) | > 1.5 | New -- PMF signal |

### 2.4 Key Metrics

| Type | Metric | Target | Why It Matters |
|------|--------|--------|---------------|
| Leading | Active Pies | 50+ | Predicts platform fee revenue |
| Leading | Channel Velocity | > 1.5 | PMF signal for partner programme |
| Leading | Smart Contract Installs/Month | 20+ | Predicts marketplace revenue |
| Lagging | Platform Fee ARR | GBP 50K | Confirms SaaS model works |
| Lagging | Partner-Originated Revenue | GBP 100K/yr | Confirms channel model works |
| Lagging | Contributor NPS | >= 65 | Confirms fairness perception |

### 2.5 Cause-Effect Chain (Primary)

```
[LEARNING: Ontologies + Smart Contracts in Registry]
    |
    v
[PROCESS: Waterfall < 500ms, 100% audit, AI Judge < $0.05/claim]
    |
    v
[CUSTOMER: Pie setup < 7 days, 80% auto-verified, NPS >= 65]
    |
    v
[STAKEHOLDER: 10+ partners, Channel Velocity > 1.5]
    |
    v
[FINANCIAL: GBP 50K SaaS + GBP 100K Channel + GBP 25K Marketplace = GBP 175K ARR]
```

---

## 3. Value Proposition (VP-RRR Aligned)

### 3.1 For Founders / Startup Teams (Pie Members)

| VP Element | Statement |
|-----------|-----------|
| **Customer Segment** | Early-stage founders and startup teams (2-10 people) splitting equity and revenue |
| **Problem** (= Risk) | Equity conversations are awkward, manual, and deferred. Spreadsheet cap tables go stale. Revenue splits are negotiated ad-hoc under pressure. Contributors feel under-rewarded and leave. |
| **Solution** (= Requirement) | FairSlice: create a pie, add members with roles and multipliers, submit contribution claims verified by AI, and watch ownership percentages update in real-time. When revenue arrives, the waterfall distributes automatically. |
| **Benefit** (= Result) | Transparent, auditable, always-current ownership. No more awkward conversations. Contributors see their share growing as they contribute. Revenue flows fairly on day one, not "when we get round to it." |
| **Unique Differentiator** | Ontology-governed smart contracts (not blockchain). Same governance cascade as the entire PF-Core platform. AI Judge for claim verification. Three-tier cost model keeps it affordable. |
| **Key Metric** | Pie creation to first distribution < 7 days. Contributor NPS >= 65. |

### 3.2 For Agencies / Channel Partners

| VP Element | Statement |
|-----------|-----------|
| **Customer Segment** | Marketing agencies, consultancies, accelerators managing multiple client ventures |
| **Problem** (= Risk) | Referral attribution is lost in email threads. Management fees are invoiced manually. No visibility across client portfolios. Commission disputes damage relationships. |
| **Solution** (= Requirement) | Partner programme with tiered commission rules, immutable referral attribution, agency dashboard with cross-pie visibility, and automated commission aggregation with payout approval workflow. |
| **Benefit** (= Result) | Predictable recurring revenue per managed pie. Cross-client visibility from a single dashboard. Immutable attribution means no disputes. Tiered programme rewards growth. |
| **Unique Differentiator** | Agency as "super-admin" across client pies. Management fee contracts inject automatically into the waterfall. Partner tier progression (Bronze to Platinum) with increasing benefits. |
| **Key Metric** | Channel Velocity > 1.5 Pies/Agency/Month. Partner-originated revenue GBP 100K/year. |

### 3.3 For Architects / Module Creators

| VP Element | Statement |
|-----------|-----------|
| **Customer Segment** | Domain experts who package business logic (validation rules, commission triggers, verification prompts) as reusable smart contracts |
| **Problem** (= Risk) | Expertise is trapped in one-off implementations. No mechanism to monetise reusable patterns. IP contribution is unrecognised. |
| **Solution** (= Requirement) | Smart Contract Registry: publish versioned business logic with licensing terms (cash, equity, or free). Pies subscribe with one-click install. Royalty step auto-injected into waterfall. |
| **Benefit** (= Result) | Passive income from every pie that uses your contract. Version-controlled, immutable-after-publish. Reputation grows with install count. |
| **Unique Differentiator** | Smart contracts are Unified Registry artifacts -- same quasi-OO cascade, same governance, same promotion pipeline as ontologies. |
| **Key Metric** | 5+ reusable contracts published. 20+ installs/month. GBP 25K marketplace ARR. |

---

## 4. Discussion Points

These are the open questions to shape the next phase:

### 4.1 Sequencing -- What Do We Build First?

| Option | Pros | Cons |
|--------|------|------|
| **A: FairSlice as standalone SaaS** | Fastest to market. Own brand. Direct revenue validation. | Separate from PFC ecosystem. Harder to converge later. |
| **B: FairSlice embedded in BAIV** | Immediate customer base (approaching 100). Real revenue to test waterfall. | Couples FairSlice lifecycle to BAIV. May not generalise cleanly. |
| **C: FairSlice as pure PFC capability** | Maximum reuse across all PFIs. Clean quasi-OO cascade from day one. | Slower to first revenue. Needs at least one PFI to validate. |
| **D: Hybrid -- PFC capability, BAIV first customer** | Best of B and C. PFC owns the ontology; BAIV provides the proving ground. | Marginally more upfront design work. |

**Recommendation:** Option D. The ontologies are already in PFC (done). BAIV provides the first real waterfall. Other PFIs inherit.

### 4.2 Scope -- MVP vs. Full Vision

| Scope | What's Included | What's Deferred |
|-------|----------------|-----------------|
| **MVP (Phase 1-2)** | Pies, members, slices, claims, waterfall, basic AI Judge | Smart contract marketplace, Stripe Connect, partner programme |
| **Growth (Phase 3)** | Smart contract registry, partner/agency engine | Multi-jurisdiction compliance, advanced dispute resolution |
| **Scale (Phase 4)** | Stripe Connect split payments, E2E BAIV worked example | Blockchain bridge, external audit integration |

### 4.3 Commercial Model -- What Do We Charge?

| Revenue Stream | Proposed Model | Notes |
|---------------|---------------|-------|
| Platform fee | 5% of revenue through waterfall OR flat monthly subscription | % aligns incentives but has compliance implications |
| Smart contract license | Per-install fee set by architect (marketplace take: 20%) | Marketplace commission funds curation |
| Agency management | Monthly per-pie retainer (agency sets price, platform takes 5%) | Low take-rate to attract agencies early |
| Affiliate referral | 10% of platform fee for 12 months (attribution window) | Standard SaaS affiliate model |

### 4.4 Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| FCA regulation on equity distribution | Medium | High | Legal review before launch. Start with revenue-only (no equity tokenisation). |
| AI Judge makes wrong call on a claim | Medium | Medium | Human appeal process. Audit trail. Three-tier escalation (Local to Haiku to Sonnet to Human). |
| Partner channel cannibalises direct sales | Low | Medium | Attribution window limits. Direct sales excluded from partner commission. |
| Smart contract IP disputes | Low | High | Immutable-after-publish. Version history. Clear licensing terms at point of publish. |
| Schema convergence breaks F34.5 PoC | Low | High | Convergence map already validated. Same resolve_cascaded_config() pattern. |

---

## 5. Suggested Next Steps

Depending on discussion outcomes:

1. **Agree sequencing** (Option A/B/C/D) and scope tier (MVP/Growth/Scale)
2. **Validate commercial model** with 2-3 existing BAIV partner conversations
3. **Legal checkpoint** on equity distribution (FCA) and platform fee model
4. **Build Phase 1** -- Supabase schema + slice engine + basic waterfall
5. **BAIV worked example** -- real pie with real revenue event through real waterfall

---

*This is a discussion document. All numbers, thresholds, and commercial terms are proposals for review, not commitments.*

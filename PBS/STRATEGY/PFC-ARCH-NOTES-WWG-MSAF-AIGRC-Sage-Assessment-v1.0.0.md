# PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0

| Field | Value |
|---|---|
| **Document** | PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0 |
| **Product Code** | PFC-ARCH |
| **Type** | Architecture Notes (NOTES) |
| **Status** | For Discussion |
| **PFI** | W4M-WWG |
| **Date** | 2026-04-05 |
| **Related** | Epic 15 (#75 pfc-dev), Epic 16 (#77 pfc-dev), Epic 90 (#39 WWG), Epic 91 (#51 WWG) |

---

## 1. Purpose

Honest assessment of whether Microsoft Agent Framework (Epic 15) and Microsoft AI GRC Agent Governance Toolkit (Epic 16) create real value for W4M-WWG — given that WWG's business reality is **Sage 200 + LSC corridors (AU/NZ/IS/IE) + MeatTrackAI platform**.

This is a strategy-as-code business sense check. VE-QVF at the centre. Does it fit? Does it matter? Does it create real value? Or is it technology looking for a problem?

---

## 2. W4M-WWG Current Reality

### What Exists

| Asset | Status | Reference |
|---|---|---|
| **pfi-w4m-wwg-dev** repo | Active, scaffolded, CLAUDE.md, promotion pipeline | [Repo](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev) |
| **Epic 2 (#30)** | Foundation — SaaS platform, VSOM cascade, adaptive SA | Open |
| **Epic 90 (#39)** | Live API integration — 11 features, API connector (SKL-154), AIS adapter (SKL-155), App Skeleton components | Open, planned |
| **Epic 91 (#51)** | **Sage 200 + AI augmentation** — 8 features, 52 stories, 4 phases, MCP Server (SKL-160/161), Power Automate, Claude+Sage, Power BI | Open, planned |
| **Strategy docs** | 6 in PBS/STRATEGY — inc. Microsoft VE-QVF Strategy, Sage 200 Self-Hosted Notes, LSC Integration Plan | Committed |
| **Product** | MeatTrackAI — LSC platform, 4 corridors (AU/NZ/IS/IE) | Pre-MVP |
| **ERP** | **Sage 200** (confirmed in Epic 91) | Production (client system) |
| **Ontology instances** | Empty (.gitkeep) — no instances promoted yet | Not started |

### What Epic 91 Already Plans (Sage 200 Integration)

| Phase | Scope | Skills |
|---|---|---|
| **Phase 1** | Sage 200 MCP Server + API client. Entity mapping to corridors | SKL-160 pfc-erp-connector, SKL-161 w4m-sage200-adapter |
| **Phase 2** | Power Automate flows: Tracker→Sage events (discharge, demurrage, spoilage, SLA breach, BTOM clearance). Sage→MS365 alerting | Power Automate |
| **Phase 3** | AI-augmented financial ops: Claude + Sage. SOP enforcement | Claude agents |
| **Phase 4** | Power BI dashboards. Landed cost engine. Month-end reconciliation | Power BI, Sage API |

### Sage 200 API Reality (Honest)

| Capability | Sage 200 API | Notes |
|---|---|---|
| Purchase orders | ✅ Full lifecycle via REST | `/purchase_orders` endpoint |
| Sales orders | ✅ Full lifecycle via REST | `/sales_orders` endpoint |
| Stock items | ✅ With warehouse locations | `/stock_items` |
| Stock transactions | ✅ Goods in/out movements | `/stock_transactions` |
| Invoicing | ✅ Sales + purchase invoices | Well-covered |
| Contacts/suppliers | ✅ Full CRUD | `/contacts`, `/customers`, `/suppliers` |
| Multi-currency | ⚡ Partially exposed | Sage 200 Professional has good multi-currency |
| **GRN (Goods Receipt)** | ⚠️ **Partial** | Linked to PO but API coverage incomplete — may need SDK or direct DB |
| **Dispatch notes** | ⚠️ **Partial** | SO→dispatch→invoice flow exists in app but API coverage is partial |
| **Customs/duty** | ❌ **Not native** | Basic — customs data in custom fields or separate systems. Not Sage X3 |
| **Warehousing (WMS)** | ⚠️ **Basic** | Warehouse locations yes, bin-level management no |
| **Webhooks** | ⚠️ **Limited** | Basic event subscription — not all entities, not reliable for mission-critical |
| **Rate limits** | ⚡ ~15 req/5s | Adequate for batch, tight for real-time |

**The Sage 200 API gap for WWG logistics**: GRN, dispatch notes, and customs are the three operations most critical to LSC corridor management — and they're the three weakest in the API. This is the real integration challenge, not agent orchestration patterns.

---

## 3. VE-QVF Business Sense Check

### 3.1 The Fundamental Question

> Does W4M-WWG need MS Agent Framework graph workflows and AI GRC agent governance toolkits — or does it need Sage 200 data flowing reliably into MeatTrackAI?

**Answer: Sage data first. Everything else is secondary.**

### 3.2 Kano Analysis — Brutally Honest

```
                    Satisfaction
                         ↑
                         |
                         |     ● AI GRC trust cascade (Indifferent)
                         |    ● MS AF graph workflows (Premature Delighter)
                         |   ● MS AF durable SOPs (Future Performance)
                         |
    ─────────────────────┼──────────────────────────────→ Fulfilment
                         |
           Sage 200 data │
           flowing into  │
           MeatTrackAI ● │  ← MUST-HAVE (absent = no product)
                         |
           Epic 91 Ph1 ● │  ← MUST-HAVE (MCP Server + API client)
                         |
           Power Auto  ● │  ← PERFORMANCE (event flows, alerting)
                         |
```

| Category | What | Why | WWG Phase |
|---|---|---|---|
| **Must-have** | Sage 200 MCP Server (SKL-160/161) + API client with corridor entity mapping | **No Sage data = no product.** MeatTrackAI without Sage is a dashboard with no data | Epic 91 Phase 1 |
| **Must-have** | App Skeleton LSC components (Epic 90) with live API data | UI showing real corridor data from Sage — this is the visible product | Epic 90 |
| **Performance** | Power Automate event flows (discharge, demurrage, SLA breach) | Automates manual Sage→notification workflows. Linear value. Each flow saves time | Epic 91 Phase 2 |
| **Performance** | Claude + Sage financial ops (month-end, reconciliation) | AI augmenting real financial workflows with real Sage data | Epic 91 Phase 3 |
| **Performance** | Power BI dashboards + landed cost engine | Business intelligence on real operational data | Epic 91 Phase 4 |
| **Future Performance** | MS AF durable tasks for SOP execution | Valuable AFTER SOPs are defined and Sage data flows. Premature without Phase 1–3 | Post-Epic 91 |
| **Premature Delighter** | MS AF graph workflow DAGs for logistics chains | Impressive architecture but WWG needs working Sage integration, not orchestration patterns | Post-Epic 91 |
| **Premature Delighter** | MS AF declarative agents from ontology | WWG ontology instances are empty (.gitkeep). No ontology = nothing to declare from | Post-ontology promotion |
| **Indifferent (now)** | AI GRC agent governance, trust scoring, OWASP agentic | Governance of what? WWG has zero deployed agents. Govern after you have something to govern | Post-deployment |
| **Indifferent (now)** | AgentMesh zero-trust identity for WWG agents | WWG agents don't exist yet. Identity for non-existent agents is overhead | Post-deployment |

### 3.3 VP-ONT — Does It Create Real Value?

**VP1: MS Agent Framework for WWG**

- `vp:Problem` → `rrr:Risk`: WWG SOPs are manual/documented. No durable execution framework.
- `vp:Solution` → `rrr:Requirement`: MS AF provides durable tasks, graph workflows, declarative agents.
- `vp:Benefit` → `rrr:Result`: SOPs become executable, checkpointed, auditable.
- **BUSINESS SENSE CHECK**: ⚠️ **Conditional value.** MS AF creates genuine value for SOP execution — BUT only after:
  1. Sage 200 data is flowing (Epic 91 Phase 1)
  2. SOPs are defined against real data patterns (Epic 91 Phase 3)
  3. Power Automate event flows prove the trigger patterns (Epic 91 Phase 2)
  
  Without these prerequisites, MS AF for WWG is architecture without foundation.

**VP2: AI GRC Agent Governance for WWG**

- `vp:Problem` → `rrr:Risk`: WWG agents have no runtime governance.
- `vp:Solution` → `rrr:Requirement`: Agent Governance Toolkit provides policy enforcement, identity, audit.
- `vp:Benefit` → `rrr:Result`: Governed agent operations across corridors.
- **BUSINESS SENSE CHECK**: ❌ **No value today.** WWG has zero deployed agents. Epic 91 Phase 3 is the first Claude+Sage agent work. Governance is Phase 5+ concern. Premature adoption = overhead with no return.

**VP3: Sage 200 Integration (Already Planned)**

- `vp:Problem` → `rrr:Risk`: MeatTrackAI has no live financial/operational data.
- `vp:Solution` → `rrr:Requirement`: Sage 200 MCP Server + API client + Power Automate flows.
- `vp:Benefit` → `rrr:Result`: Live corridor data, automated event flows, AI-augmented ops.
- **BUSINESS SENSE CHECK**: ✅ **Essential value.** This is the product. Everything else depends on this.

### 3.4 The Sage 200 Integration Gap That Actually Matters

The real architectural challenge for WWG isn't "how do we orchestrate agents" — it's:

| Gap | Impact | What Fixes It |
|---|---|---|
| **GRN (Goods Receipt) API partial** | Can't automate goods-in for LSC corridors | SKL-161 w4m-sage200-adapter must handle GRN via Sage 200 SDK or direct DB as fallback |
| **Dispatch notes API partial** | Can't automate outbound logistics confirmation | Same adapter — SDK/DB fallback for dispatch workflow |
| **No native customs/duty** | AU/NZ/IS/IE corridors have different customs regimes — Sage 200 doesn't model this | Custom data model in MeatTrackAI (Cosmos DB or Supabase), sync financial summary back to Sage |
| **Limited webhooks** | Can't reliably trigger on Sage events | Polling pattern via Azure Functions on schedule, or Power Automate as middleware |
| **Rate limits (~15 req/5s)** | Bulk operations (month-end, corridor-wide sync) may throttle | Batch operations, off-peak scheduling, queue-based processing |

**These are the problems to solve.** MS AF and AI GRC don't help with any of them.

---

## 4. Where MS AF and AI GRC DO Create Future Value for WWG

### 4.1 MS Agent Framework — Conditional Value (Epic 91 Phase 3+)

| MS AF Capability | WWG Application | Prerequisites | Phase |
|---|---|---|---|
| **Durable tasks + checkpointing** | SOP execution that must complete (discharge, BTOM clearance) — checkpoint per step, resume on failure | Sage 200 data flowing, SOPs defined, Power Automate event patterns proven | Post-Phase 3 |
| **Human-in-the-loop** | Customs clearance decisions, quality hold/release, spoilage sign-off | SOP workflows operational, decision points identified from real operations | Post-Phase 3 |
| **Graph workflows** | Corridor logistics chain as DAG: procurement → QC → warehousing → dispatch → customs → delivery | Full corridor data model in MeatTrackAI, Sage 200 entities mapped | Post-Phase 4 |
| **Declarative agents** | SOP per corridor as YAML config — AU has different rules than IE | Ontology instances promoted (currently empty), corridor-specific rules documented | Post-ontology |
| **Azure Functions hosting** | Event-driven triggers: Sage status change → SOP agent activation | Power Automate event patterns proven first (Phase 2) | Post-Phase 2 |

### 4.2 AI GRC Agent Governance — Deferred Value (Post-Deployment)

| AI GRC Capability | WWG Application | Prerequisites | Phase |
|---|---|---|---|
| **Agent OS policy** | SOP agents constrained to corridor scope — AU agent can't touch NZ data | Agents exist and are deployed | Post-deployment |
| **UACL audit** | SOP execution evidence for corridor compliance | Agents executing SOPs with real data | Post-deployment |
| **Trust scoring** | Client-facing agents (if MeatTrackAI exposes agent features to clients) | Product-market fit proven, client access model defined | Post-PMF |

### 4.3 Honest Timeline Positioning

```
Epic 91 Phase 1     Epic 91 Phase 2     Epic 91 Phase 3     Epic 91 Phase 4     MS AF / AI GRC
(Sage MCP +         (Power Automate     (Claude + Sage      (Power BI +         (Agent
 API client)         event flows)        AI-augmented ops)   landed cost)        orchestration +
                                                                                 governance)
     │                    │                    │                    │                    │
     ▼                    ▼                    ▼                    ▼                    ▼
   MUST-HAVE          PERFORMANCE          PERFORMANCE          PERFORMANCE          FUTURE
   ─────────────────────────────────────────────────────────────────────────────────────→
   "No Sage =          "Saves time"        "Claude helps"      "Dashboards"        "SOPs become
    no product"                             with Sage data"                          durable agents"
```

**MS AF and AI GRC are Phase 5+ considerations for WWG.** They sit after the entire Epic 91 delivery. Governance comes after there's something to govern.

---

## 5. Specific Sage 200 × MS AF × AI GRC Integration Points (Future Architecture)

When WWG reaches Phase 3+ and MS AF/AI GRC become relevant, the integration architecture would look like:

```
┌────────────────────────────────────────────────────────────────┐
│ W4M-WWG — Future Agent Architecture                            │
│                                                                │
│  ┌──────────────┐                                              │
│  │ Sage 200     │◄─── SKL-160/161 (MCP Server + Adapter)       │
│  │ (ERP)        │     ↕ REST API + SDK fallback for GRN/dispatch│
│  └──────┬───────┘                                              │
│         │                                                      │
│         ▼                                                      │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────┐   │
│  │ Power Auto   │──→│ Azure        │──→│ MS AF Agent      │   │
│  │ (event       │   │ Functions    │   │ (durable SOP     │   │
│  │  triggers)   │   │ (processing) │   │  execution)      │   │
│  └──────────────┘   └──────────────┘   └────────┬─────────┘   │
│                                                  │             │
│                                        ┌─────────┴─────────┐  │
│                                        │ Agent OS          │  │
│                                        │ (policy, identity,│  │
│                                        │  audit — AI GRC)  │  │
│                                        └─────────┬─────────┘  │
│                                                  │             │
│                                        ┌─────────┴─────────┐  │
│                                        │ MeatTrackAI       │  │
│                                        │ (App Skeleton UI) │  │
│                                        └───────────────────┘  │
│                                                                │
│  Claude via Azure AI Foundry — intelligence layer throughout   │
└────────────────────────────────────────────────��───────────────┘
```

### Critical Integration Point: Sage 200 MCP Server as Foundation

The SKL-160 `pfc-erp-connector` and SKL-161 `w4m-sage200-adapter` from Epic 91 Phase 1 are the **prerequisite for everything**:

- MS AF agents need Sage data as tool inputs → MCP Server provides it
- AI GRC needs to govern agent actions on Sage data → agents must exist first
- Power Automate triggers need Sage events → MCP Server or polling provides them
- Claude + Sage ops (Phase 3) need reliable API access → adapter handles Sage 200 API gaps

**Without SKL-160/161 working, nothing else in this architecture functions.**

### Where MS AF Adds Genuine Value Over Power Automate Alone

| Dimension | Power Automate (Epic 91 Phase 2) | MS AF (Future) | Real Delta |
|---|---|---|---|
| **SOP execution** | Linear flow: trigger → action → action | Graph DAG with branching, checkpointing, HITL | Complex SOPs with exception paths — only matters for non-trivial SOPs |
| **Failure handling** | Retry + error notification | Checkpoint + resume from last good state | Matters for multi-step corridored operations (AU customs ≠ IE customs) |
| **Claude integration** | Power Automate AI Builder (limited) | Full Claude agent with tools, context, reasoning | Matters for Phase 3 AI-augmented ops — Claude needs agent context, not just API calls |
| **Multi-corridor** | Separate flows per corridor | Declarative agent config per corridor (same engine, different rules) | Matters at scale — 4 corridors × N SOPs = flow sprawl in Power Automate |

**Honest assessment**: Power Automate handles Phase 2 event flows well. MS AF becomes genuinely valuable when:
1. SOPs have exception branches (not just linear flows)
2. Claude needs sustained context across SOP steps (not just one-shot API calls)
3. Corridor count × SOP count creates flow management burden in Power Automate
4. Checkpoint/resume is a business requirement (regulatory, contractual)

---

## 6. Kano Summary — What Actually Matters for WWG

| Priority | What | Kano | Epic | Status |
|---|---|---|---|---|
| **1** | Sage 200 MCP Server + API client + corridor mapping | Must-have | 91 Phase 1 | Planned |
| **2** | App Skeleton LSC components with live data | Must-have | 90 | Planned |
| **3** | Power Automate event flows (discharge, demurrage, SLA, BTOM) | Performance | 91 Phase 2 | Planned |
| **4** | Claude + Sage AI-augmented financial ops | Performance | 91 Phase 3 | Planned |
| **5** | Power BI dashboards + landed cost engine | Performance | 91 Phase 4 | Planned |
| **6** | Ontology instances promoted to WWG | Enabler | Epic 2 | Not started |
| **7** | MS AF durable SOPs with checkpointing + HITL | Future Performance | Post-91 | **Assess after Phase 3** |
| **8** | MS AF declarative agents per corridor | Future Delighter | Post-91 | **Assess after ontology promotion** |
| **9** | AI GRC agent governance for deployed agents | Future Performance | Post-deployment | **Assess after agents exist** |

**Items 1–6 are the real work. Items 7–9 are genuine future value but premature to implement or even deeply plan until the foundation is live.**

---

## 7. Recommendations

### 7.1 Do Now
- **Continue Epic 91 Phase 1** as the critical path. SKL-160/161 is the foundation for everything
- **Sage 200 API gap analysis** for GRN and dispatch notes — determine SDK vs direct DB vs custom workaround. This is the real technical risk, not agent orchestration

### 7.2 Do When Phase 2 Completes
- **Evaluate Power Automate flow sprawl** — if 4 corridors × N event types creates management burden, MS AF declarative patterns become relevant
- **Test MS AF anthropic provider** with Sage data (QW-1 from quick wins) — low effort, proves compatibility

### 7.3 Do When Phase 3 Completes
- **Evaluate MS AF durable tasks** for Claude + Sage SOP workflows that need checkpointing
- **Compare** MS AF agent execution vs Power Automate AI Builder for sustained Claude context

### 7.4 Do After Deployment
- **Agent OS policy enforcement** for deployed Claude + Sage agents
- **UACL audit integration** for SOP execution evidence
- **Trust scoring** if MeatTrackAI exposes agent features to external users

### 7.5 Do NOT Do
- Adopt MS AF or AI GRC for WWG before Epic 91 Phase 1 is live
- Plan agent governance for agents that don't exist
- Build graph workflow DAGs for SOPs that aren't defined against real data
- Promote ontology instances before the data model is proven with Sage 200

---

## 8. Cross-References

| Reference | Relationship |
|---|---|
| [Epic 90 (#39 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/39) | Live API integration — App Skeleton LSC components |
| [Epic 91 (#51 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/51) | Sage 200 + AI augmentation — the actual integration epic |
| [Epic 15 (#75 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/75) | MS Agent Framework — conditional future value for WWG |
| [Epic 16 (#77 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/77) | AI GRC Agent Governance — deferred value for WWG |
| [PFC-ARCH-NOTES-Sage-200-Self-Hosted-Integrations-v1.0.0.md](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-NOTES-Sage-200-Self-Hosted-Integrations-v1.0.0.md) | Existing Sage 200 integration notes |
| [PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md) | Existing Microsoft VE-QVF strategy |

# PFC-ARCH-PLAN-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0

| Field | Value |
|---|---|
| **Document** | PFC-ARCH-PLAN-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0 |
| **Product Code** | PFC-ARCH |
| **Type** | Architecture Plan (PLAN) |
| **Status** | For Discussion |
| **PFI** | W4M-WWG |
| **Date** | 2026-04-05 |
| **Companion** | PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0 (see for full analysis) |
| **Related** | Epic 15 (#75 pfc-dev), Epic 16 (#77 pfc-dev), Epic 90 (#39 WWG), Epic 91 (#51 WWG) |

---

## 1. Plan Purpose

Phased assessment plan for integrating Microsoft Agent Framework (Epic 15) and AI GRC Agent Governance Toolkit (Epic 16) into W4M-WWG's Sage 200-based MeatTrackAI logistics platform — **gated by Epic 91 progress, not by technology enthusiasm**.

### Governing Principle

> **Strategy-as-code demands business sense.** Every assessment gate asks: does this create value that W4M-WWG's customers care about, or is it architectural elegance for its own sake?

---

## 2. VE-QVF Assessment Gates

Each phase below has a **Proceed/Defer/Drop** gate with explicit criteria. No phase starts until its gate passes.

### Gate Framework

| Gate Type | Question | Pass Criteria |
|---|---|---|
| **FIT** | Does this solve a problem W4M-WWG actually has today? | Problem is documented in Epic 90/91 or observed in live operations |
| **MATTER** | Would the absence of this capability block or degrade the product? | Measurable impact on corridor operations, SOP execution, or client value |
| **VALUE** | Does the benefit justify the adoption cost (learning, integration, maintenance)? | Net positive when compared to existing/simpler alternatives (Power Automate, direct API) |
| **ADVANTAGE** | Does this create competitive differentiation for MeatTrackAI? | Capability that competitors don't have or can't easily replicate |

---

## 3. Phased Assessment Plan

### Phase 0: Foundation Validation (Epic 91 Phase 1 — MUST COMPLETE FIRST)

**This is not an MS AF / AI GRC phase. This is the prerequisite.**

| # | Action | Deliverable | Gate |
|---|---|---|---|
| 0.1 | Deliver SKL-160 `pfc-erp-connector` + SKL-161 `w4m-sage200-adapter` | Working Sage 200 MCP Server with corridor entity mapping | **Epic 91 Phase 1 completion** |
| 0.2 | Validate Sage 200 API coverage for WWG operations | Gap report: GRN, dispatch notes, customs — API vs SDK vs DB fallback per entity | **Sage API gap documented** |
| 0.3 | Deliver App Skeleton LSC components with live Sage data | MeatTrackAI showing real corridor data from Sage 200 | **Epic 90 MVP** |

**Gate 0 → Phase 1:** Sage 200 data is flowing into MeatTrackAI. SKL-160/161 are operational. Sage API gaps are documented with fallback strategies in place.

**If Gate 0 does not pass:** Nothing below proceeds. All MS AF / AI GRC assessment work is deferred.

---

### Phase 1: Power Automate Event Pattern Validation (Epic 91 Phase 2)

**Still not MS AF. This validates the event patterns that MS AF would later orchestrate.**

| # | Action | Deliverable | VE-QVF Check |
|---|---|---|---|
| 1.1 | Deliver Power Automate event flows (discharge, demurrage, spoilage, SLA breach, BTOM clearance) | Working event→action flows per corridor | **FIT**: ✅ Documented in Epic 91 |
| 1.2 | Measure flow complexity — how many flows × corridors? Is management burden emerging? | Flow inventory + complexity assessment | **MATTER**: Does flow sprawl actually occur? |
| 1.3 | Document decision points that are currently human-manual | HITL decision inventory per SOP | **VALUE**: Identifies where durable tasks (MS AF) would actually help |
| 1.4 | Document exception paths — what happens when SOP steps fail? | Exception path map per corridor | **VALUE**: Identifies where graph DAGs (MS AF) would actually help |

**Gate 1 → Phase 2:** Event patterns are proven. Flow complexity, HITL decision points, and exception paths are documented from real operations, not hypothetical.

**Kano check at Gate 1:**

| Finding | Implication |
|---|---|
| Flow count manageable, few exceptions | Power Automate sufficient. MS AF = Indifferent. **DEFER** MS AF |
| Flow sprawl emerging, exception paths complex | MS AF graph workflows + durable tasks = Performance. **PROCEED** to Phase 2 |
| Human decisions are blocking SOP completion | MS AF HITL = Performance. **PROCEED** to Phase 2 |

---

### Phase 2: MS Agent Framework Compatibility Proof (Conditional — only if Gate 1 passes with PROCEED)

**First MS AF contact. Minimal scope. Prove it works with Claude + Sage data.**

| # | Action | Deliverable | VE-QVF Check |
|---|---|---|---|
| 2.1 | `pip install agent-framework-anthropic --pre` + run hello-world with Claude | Claude + MS AF confirmed working | **FIT**: ✅ Technical prerequisite |
| 2.2 | Build one Sage 200 tool (read stock levels via SKL-161 adapter) as MS AF agent tool | Claude agent that queries Sage 200 stock via MeatTrackAI MCP Server | **FIT**: ✅ Proves Sage↔MS AF↔Claude chain |
| 2.3 | Run `checkpoint-hitl-resume` sample with WWG SOP scenario | One real SOP (simplest — e.g. goods receipt) as durable task with HITL gate at QC | **MATTER**: Does durable execution change the SOP quality? |
| 2.4 | Compare: MS AF durable SOP vs Power Automate flow for same SOP | Side-by-side comparison document | **VALUE**: Is the delta worth the adoption cost? |

**Gate 2 → Phase 3:** MS AF demonstrably improves SOP execution quality (resilience, auditability, HITL) compared to Power Automate alone — for at least one real WWG SOP with real Sage data.

**Kano check at Gate 2:**

| Finding | Implication |
|---|---|
| Durable SOP marginally better than Power Automate | MS AF = Indifferent for WWG. **DEFER** — Power Automate covers the need |
| Checkpoint/resume prevents real data loss or SOP restart | MS AF = Performance. **PROCEED** to Phase 3 |
| HITL integration transforms customs/QC decision quality | MS AF = Performance. **PROCEED** to Phase 3 |
| Declarative agent per corridor eliminates flow duplication | MS AF = Delighter. **PROCEED** to Phase 3 |

---

### Phase 3: Claude + Sage AI-Augmented Operations (Epic 91 Phase 3 + MS AF)

**MS AF as execution chassis for Claude + Sage agent workflows.**

| # | Action | Deliverable | VE-QVF Check |
|---|---|---|---|
| 3.1 | Refactor Epic 91 Phase 3 AI-augmented ops to use MS AF as execution layer | Claude + Sage financial ops running as MS AF durable agent workflows | **VALUE**: Better resilience + auditability for AI-augmented ops |
| 3.2 | Declarative agent config per corridor (AU, NZ, IS, IE) | 4 YAML configs sharing same workflow engine, different rules/thresholds | **ADVANTAGE**: Corridor scaling without flow duplication |
| 3.3 | OpenTelemetry tracing on Claude + Sage agent operations | Audit trail per AI-assisted financial decision | **MATTER**: Creates compliance evidence as byproduct |
| 3.4 | Test failure scenarios: agent fails mid-SOP with Sage 200 write in progress | Checkpoint/rollback behaviour documented | **VALUE**: Prevents half-written Sage data on failure |

**Gate 3 → Phase 4:** Claude + Sage agent workflows running reliably on MS AF with evidence of improved resilience, auditability, and corridor scalability over Power Automate alone.

---

### Phase 4: AI GRC Agent Governance (Post-Deployment — only when agents exist)

**First AI GRC contact. Conditional on deployed agents from Phase 3.**

| # | Action | Deliverable | VE-QVF Check |
|---|---|---|---|
| 4.1 | `pip install agent-os-kernel` + define one OPA/Rego policy for corridor scope | Agent policy: AU corridor agent can only access AU Sage data | **FIT**: Corridor data isolation is a real business requirement |
| 4.2 | AgentMesh identity for WWG agents | Agent identity verifiable — which agent made which Sage 200 change | **MATTER**: Audit requirement — who/what changed financial data? |
| 4.3 | UACL-ONT integration with Agent OS audit | SOP execution evidence chain: UACL hash-chain + OTel traces | **VALUE**: Compliance evidence as byproduct, not separate effort |
| 4.4 | Test: MeatTrackAI external agent (client-facing) with trust scoring | Client-facing agent at Standard trust (600) vs internal agent at Trusted (800) | **ADVANTAGE**: Multi-tenant agent governance — client agents sandboxed |

**Gate 4 → Production:** Agent governance proven for deployed WWG agents. Trust cascade operational.

**Kano check at Gate 4:**

| Finding | Implication |
|---|---|
| Corridor data isolation valuable for multi-client | AI GRC = Performance. **ADOPT** for agent governance |
| Audit evidence valuable for client compliance reporting | AI GRC = Performance. **ADOPT** for audit |
| Trust scoring enables client-facing agents | AI GRC = Delighter. **ADOPT** — competitive differentiation |
| Governance adds overhead without measurable benefit | AI GRC = Indifferent for WWG. **DROP** — not worth the cost |

---

## 4. Decision Points Summary

```
Epic 91 Ph1                          Epic 91 Ph2                    Phase 2                    Phase 3               Phase 4
(Sage 200                            (Power Auto                    (MS AF                     (Claude+Sage           (AI GRC
 MCP Server)                          event flows)                  compat proof)               on MS AF)             governance)
     │                                    │                             │                          │                     │
     ▼                                    ▼                             ▼                          ▼                     ▼
  GATE 0 ─────────────────────────→ GATE 1 ──── PROCEED? ────→ GATE 2 ─── PROCEED? ──→ GATE 3 ─── PROCEED? ──→ GATE 4
  "Sage data    flows?"              "Flow sprawl?        "MS AF better than     "AI agents      "Governance
                                      Exceptions?           Power Automate?"      reliable?"       adds value?"
                                      HITL needed?"
                                           │                        │                                   │
                                        DEFER ─→ Stay on       DEFER ─→ Stay on                    DROP ─→ No
                                        Power Automate          Power Automate                      governance
                                        (perfectly fine)        (perfectly fine)                     overhead
```

---

## 5. What NOT To Plan

| Don't | Why | Instead |
|---|---|---|
| Don't plan MS AF graph workflows for WWG SOPs now | SOPs aren't defined against real Sage data yet | Define SOPs in Epic 91 Phase 3 with real data patterns first |
| Don't plan declarative agents from ontology | WWG ontology instances are empty (.gitkeep) | Promote ontology instances after Sage data model is proven |
| Don't plan AI GRC trust cascade for WWG | Zero deployed agents to govern | Assess governance after Phase 3 agents are operational |
| Don't plan Azure Functions deployment for WWG agents | Infrastructure decisions are premature without operational agents | Use local execution for Phase 2 proof, Azure for Phase 3 if MS AF adopted |
| Don't plan A2A cross-PFI communication from WWG | WWG is pre-MVP. Cross-PFI = post-product-market-fit | Focus on single-PFI value first |

---

## 6. Sage 200 Technical Risk Items (The Actual Work)

These are more important than MS AF / AI GRC planning:

| Risk | Impact | Mitigation | Owner |
|---|---|---|---|
| **GRN API partial** | Can't automate goods receipt for corridors | SKL-161 adapter: test Sage 200 REST for GRN → if gap, evaluate Sage 200 SDK (.NET) or direct DB read | Epic 91 Phase 1 |
| **Dispatch notes API partial** | Can't automate outbound confirmation | Same as GRN — test REST, fallback to SDK/DB | Epic 91 Phase 1 |
| **No native customs/duty** | AU/NZ/IS/IE have different customs regimes | Custom data model in MeatTrackAI DB, financial summary syncs back to Sage | Epic 91 Phase 1 |
| **Webhook unreliability** | Can't trigger on Sage events in real-time | Polling via Azure Functions on schedule (every 5 min), or Power Automate as middleware. Accept near-real-time, not real-time | Epic 91 Phase 2 |
| **Rate limits (15 req/5s)** | Bulk corridor operations may throttle | Queue-based processing, off-peak scheduling, batch reads | Epic 91 Phase 1 |
| **Sage 200 hosted vs on-prem** | API endpoint differs. On-prem may need VPN/ExpressRoute | Confirm deployment model with WWG client. If on-prem, plan network connectivity | **Immediate** |

---

## 7. Cross-References

| Reference | Relationship |
|---|---|
| [PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0.md) | Companion analysis document |
| [Epic 90 (#39 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/39) | Live API integration — App Skeleton LSC components |
| [Epic 91 (#51 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/51) | Sage 200 + AI augmentation — the critical path |
| [Epic 15 (#75 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/75) | MS Agent Framework strategic review |
| [Epic 16 (#77 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/77) | AI GRC Agent Governance strategic review |
| [PFC-ARCH-NOTES-Sage-200-Self-Hosted-Integrations-v1.0.0.md](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-NOTES-Sage-200-Self-Hosted-Integrations-v1.0.0.md) | Existing Sage 200 notes |
| [PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md) | Existing Microsoft VE-QVF strategy |
| [PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md) | Existing LSC integration plan |

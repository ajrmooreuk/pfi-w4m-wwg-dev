# PFC-ARCH-NOTES-WWG-Interim-Value-Plays-v1.0.0

| Field | Value |
|---|---|
| **Document** | PFC-ARCH-NOTES-WWG-Interim-Value-Plays-v1.0.0 |
| **Product Code** | PFC-ARCH |
| **Type** | Architecture Notes (NOTES) |
| **Status** | For Discussion |
| **PFI** | W4M-WWG |
| **Date** | 2026-04-05 |
| **Context** | Addendum to PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0 — interim value within Sage 200 constraints |

---

## 1. The Reframe

The previous assessment positioned MS AF and AI GRC as Phase 5+ for WWG. That's correct for **wholesale adoption**. But there are smart interim plays that extract value from MS AF, AI GRC, and Claude capabilities **by working WITH the Sage 200 constraints**, not waiting for them to disappear.

> **Principle: Sage 200 API gaps are not just blockers — they're the first use cases for Claude agent value.**

Sage 200 can't do GRN properly via API. Sage 200 can't do customs. Sage 200 webhooks are unreliable. Instead of building SDK workarounds or database-level hacks, Claude agents can bridge these gaps intelligently.

---

## 2. Six Interim Value Plays

### Play 1: Claude as Sage 200 API Gap Bridge (Epic 91 Phase 1 Enhancement)

**The constraint:** Sage 200 REST API has partial coverage for GRN (goods receipt) and dispatch notes — the two operations most critical to LSC corridor management.

**The smart move:** Instead of building Sage 200 SDK (.NET) or direct DB workarounds, use Claude via the MCP Server as an **intelligent inference layer** that reconstructs what the API doesn't directly expose.

| Operation | Sage 200 API Gap | Claude Bridge |
|---|---|---|
| **Goods Receipt (GRN)** | No dedicated GRN endpoint. Stock transactions exist but aren't linked to PO receipt workflow | Claude agent reads: PO (confirmed) + stock transaction (goods-in type) + supplier invoice (matched). **Infers** GRN: which PO lines were received, quantities, dates, variances. Writes GRN record to MeatTrackAI |
| **Dispatch Notes** | SO→dispatch→invoice flow exists in Sage app but API only partially exposes dispatch | Claude agent reads: SO (allocated) + stock transaction (goods-out type) + carrier data. **Generates** dispatch record with line-level detail. Financial posting stays in Sage |
| **Customs Intelligence** | Not in Sage 200 at all | Claude agent owns customs entirely in MeatTrackAI. Per-corridor rules (AU/NZ/IS/IE). Financial duty/tariff summary syncs back to Sage as journal entries |

**VE-QVF check:**
- **FIT**: ✅ Solves documented Sage API gaps in Epic 91
- **MATTER**: ✅ Without GRN/dispatch, corridor tracking is incomplete
- **VALUE**: ✅ Claude inference vs Sage SDK development — faster, more flexible, lower maintenance
- **ADVANTAGE**: ✅ Intelligent gap-bridging is a capability, not a workaround. Competitors building Sage SDK integrations get brittle connectors. Claude agents adapt when Sage data shapes change

**Kano**: Performance — directly improves data completeness without waiting for Sage API improvements.

**What's needed**: SKL-160/161 MCP Server operational (Phase 1 prerequisite), Claude API key, agent tool definitions for Sage read operations. No MS AF runtime required — Claude Code or basic agent script is sufficient.

**MS AF enhancement (optional)**: If using MS AF, the GRN inference becomes a durable task with checkpoint. If Claude is mid-inference and the Sage API rate-limits, checkpoint → retry → resume. Without MS AF, it's a script that retries or fails.

---

### Play 2: Customs as MeatTrackAI-Native Intelligence (Parallel to Epic 91 Phase 1)

**The constraint:** Sage 200 has no native customs/duty handling. AU/NZ/IS/IE all have different regimes. Waiting for Sage X3 upgrade is not realistic.

**The smart move:** Don't fight Sage. Build customs intelligence as a **MeatTrackAI-native capability** owned by Claude agents, with financial summaries posted back to Sage.

```
┌────────────────────────────────────────────────┐
│ Customs Intelligence (MeatTrackAI-native)      │
│                                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ AU Rules │  │ NZ Rules │  │ IS Rules │ ... │
│  │ (YAML)   │  │ (YAML)   │  │ (YAML)   │     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       └──────────────┼──────────────┘           │
│                      ▼                          │
│         ┌────────────────────┐                  │
│         │ Claude Agent       │                  │
│         │ (customs reasoning │                  │
│         │  + tariff lookup   │                  │
│         │  + duty calc)      │                  │
│         └─────────┬──────────┘                  │
│                   │                             │
│          ┌────────┴────────┐                    │
│          │ MeatTrackAI DB  │                    │
│          │ (customs records)│                    │
│          └────────┬────────┘                    │
│                   │                             │
│          ┌────────┴────────┐                    │
│          │ Sage 200 sync   │                    │
│          │ (journal entry: │                    │
│          │  duty/tariff    │                    │
│          │  financial      │                    │
│          │  summary only)  │                    │
│          └─────────────────┘                    │
└────────────────────────────────────────────────┘
```

**This IS the MS AF declarative agent use case** — but scoped to customs only:
- 4 corridor YAML configs (AU, NZ, IS, IE) with different tariff codes, duty rates, documentation requirements
- Same Claude agent engine, different rules per corridor
- `pip install agent-framework-anthropic --pre` + declarative workflow sample = running prototype

**VE-QVF check:**
- **FIT**: ✅ Customs is a WWG must-have that Sage 200 can't provide
- **MATTER**: ✅ International corridors without customs intelligence is a gap competitors won't have
- **VALUE**: ✅ Building customs as MeatTrackAI-native is permanent value, not a workaround
- **ADVANTAGE**: ✅ Customs intelligence that adapts per corridor via config, not code — scales to new corridors without development

**Kano**: Must-have (customs capability) delivered as a Delighter (intelligent, per-corridor, adaptive).

---

### Play 3: UACL Audit on the MCP Server Layer (Epic 91 Phase 1 — Day One)

**The constraint:** AI GRC agent governance seems premature — no deployed agents to govern.

**The reframe:** The SKL-160/161 MCP Server IS the first agent-facing component. Every Sage 200 API call through it is a governable action. Audit the integration layer from day one.

| What | How | Value |
|---|---|---|
| Every Sage 200 read via MCP Server | UACL hash-chained audit record: who requested, what entity, when, from which corridor context | **Financial data access audit trail from day one** |
| Every Sage 200 write via MCP Server | UACL record + before/after snapshot | **Change evidence for financial data — compliance requirement** |
| MCP Server tool calls | Agent OS policy (lightweight): allowed entity types per corridor, read-only vs read-write per role | **Data access governance on the integration layer, not the agent layer** |

**This doesn't require deployed agents.** Even Claude Code calling the MCP Server generates audit records. The UACL skills (pfc-uacl-record, pfc-uacl-verify, pfc-uacl-boundary-check) are already shipped from Epic 97.

**VE-QVF check:**
- **FIT**: ✅ Financial data access audit is a real requirement for any ERP integration
- **MATTER**: ✅ "Who accessed what financial data and when" is a compliance question clients will ask
- **VALUE**: ✅ UACL is already shipped. Minimal integration effort to wrap MCP Server calls
- **ADVANTAGE**: ✅ Audit-by-design from day one, not bolted on after an incident

**Kano**: Must-have (audit) that's invisible until someone asks for it — then it's the difference between "we have evidence" and "we don't know".

---

### Play 4: SOP-as-Config Before SOP-as-Execution (Parallel — Low Effort)

**The constraint:** MS AF SOP execution needs Phase 3 Claude+Sage ops. Can't run durable SOPs without the data pipeline.

**The smart move:** Define SOPs as structured YAML configs NOW, even before they execute. The value is in the structure, not the execution.

| Current State | Interim State | Future State |
|---|---|---|
| SOPs as Word docs or team knowledge | SOPs as YAML declarative agent configs (versioned, per-corridor) | SOPs executed as MS AF durable workflows |
| Can't verify SOP was followed | SOP definition is auditable, diff-able, reviewable | SOP execution is checkpointed, auditable, resumable |
| New corridor = write new document | New corridor = new YAML variant | New corridor = deploy new config |

**What this looks like:**

```yaml
# sop-goods-receipt-au.yaml
name: "Goods Receipt — AU Corridor"
version: "1.0.0"
corridor: "AU"
steps:
  - id: verify_po
    agent: claude
    tool: sage200_read_purchase_order
    input: "{{po_number}}"
    validation: "PO status must be 'On Order' or 'Part Received'"

  - id: check_stock_movement
    agent: claude
    tool: sage200_read_stock_transactions
    input: "{{po_number}}"
    validation: "Goods-in transaction exists matching PO lines"

  - id: quality_check
    type: human_in_the_loop
    prompt: "QC hold/release decision for {{po_number}}"
    options: ["release", "hold", "reject"]
    timeout: "4h"
    escalation: "ops_manager"

  - id: generate_grn
    agent: claude
    tool: meattrack_write_grn
    input:
      po: "{{po_number}}"
      stock_movements: "{{check_stock_movement.result}}"
      qc_decision: "{{quality_check.result}}"

  - id: sage_financial_sync
    agent: claude
    tool: sage200_post_journal
    input: "Duty/tariff journal for {{po_number}} per AU customs rules"
    condition: "{{quality_check.result}} == 'release'"
```

**This YAML is human-readable, version-controllable, and will execute on MS AF when the time comes.** But even before execution, it:
- Documents SOPs precisely (replaces ambiguous Word docs)
- Enables review/approval via PR (SOP change = code review)
- Identifies exactly which Sage 200 API endpoints each SOP needs (feeds Sage API gap analysis)
- Defines HITL gates explicitly (who decides, timeout, escalation)
- Is per-corridor diffable (AU vs NZ = diff the YAML)

**VE-QVF check:**
- **FIT**: ✅ SOPs need to be documented regardless — this is a better format
- **MATTER**: ✅ Structured SOPs reveal API requirements, HITL gates, and corridor differences before build
- **VALUE**: ✅ Low effort (writing YAML, not building systems). High preparedness for MS AF execution
- **ADVANTAGE**: ⚡ Moderate — structured SOPs are better than Word docs but not yet a product differentiator

**Kano**: Performance — better SOP definition reduces Phase 3 implementation risk.

---

### Play 5: Power Automate + Claude Hybrid (Epic 91 Phase 2 Enhancement)

**The constraint:** Power Automate handles simple trigger→action flows. Claude needs sustained context for intelligent operations. They're different tools.

**The smart move:** Use both. Power Automate is the event bus. Claude is the brain.

```
┌──────────────────────────────────────────────────┐
│ Hybrid Pattern                                   │
│                                                  │
│  Sage 200 ──poll──→ Power Automate               │
│                        │                         │
│                    ┌───┴───────────────────┐      │
│                    │ Simple events:        │      │
│                    │ notification, logging │      │
│                    │ → PA handles directly │      │
│                    └───────────────────────┘      │
│                        │                         │
│                    ┌───┴───────────────────┐      │
│                    │ Complex events:       │      │
│                    │ SLA breach, spoilage, │      │
│                    │ BTOM clearance        │      │
│                    │ → PA triggers Claude  │      │
│                    │   agent (HTTP call)   │      │
│                    └───────────────────────┘      │
│                        │                         │
│                        ▼                         │
│               Claude Agent (Azure Function       │
│               or local endpoint)                 │
│               - Reads Sage context via MCP       │
│               - Reasons about the event          │
│               - Recommends action                │
│               - Posts back to Sage/MeatTrackAI   │
└──────────────────────────────────────────────────┘
```

**Phase 2 scope**: Simple events stay in Power Automate. Complex events route to Claude. This introduces Claude agent value in Phase 2, not Phase 3 — earlier than originally planned.

**The MS AF angle**: When MS AF is adopted later, the Claude agent endpoint becomes a full MS AF durable workflow. The Power Automate trigger stays the same — only the downstream processing upgrades. Clean migration path.

**VE-QVF check:**
- **FIT**: ✅ Complex events (SLA breach, spoilage) need reasoning, not just notification
- **MATTER**: ✅ SLA breach with context ("this corridor has had 3 breaches this month, supplier X is pattern") is more valuable than a bare alert
- **VALUE**: ✅ Power Automate does what it's good at (triggers). Claude does what it's good at (reasoning). Neither is forced into the other's role
- **ADVANTAGE**: ✅ Intelligent event response vs dumb notification — client-visible quality difference

**Kano**: Performance → approaching Delighter when Claude's contextual reasoning surfaces patterns humans miss.

---

### Play 6: Corridor Ontology Instances from Sage Data (Parallel — Fills the .gitkeep Gap)

**The constraint:** WWG ontology instances are empty (.gitkeep). No instances promoted. Can't build ontology-driven features without instances.

**The smart move:** Generate ontology instances FROM Sage 200 entity data. Don't manually author what the data already knows.

| Sage 200 Entity | Ontology Target | Instance |
|---|---|---|
| Suppliers (AU corridor) | ORG-ONT | `org:supplier-au-*` entities with Sage ID cross-reference |
| Products (meat categories) | FUNC-ONT domain taxonomy | `func:product-category-*` per corridor |
| Warehouses | FUNC-ONT location taxonomy | `func:warehouse-*` with corridor assignment |
| Customer accounts | ORG-ONT | `org:client-*` per corridor |
| Corridor structure | PFI instance config | `pfi:corridor-au`, `pfi:corridor-nz`, etc. |

**Claude generates these from Sage 200 data via MCP Server.** One-time seed + periodic sync. This fills the .gitkeep gap with real, data-derived instances — not manually authored placeholders.

**VE-QVF check:**
- **FIT**: ✅ Ontology instances are needed for any ontology-driven feature
- **MATTER**: ⚡ Moderate — instances enable future features but aren't directly client-visible
- **VALUE**: ✅ Auto-generation from Sage data vs manual authoring — dramatically lower effort
- **ADVANTAGE**: ⚡ Moderate — ontology-driven corridor management is architectural preparation

**Kano**: Enabler — invisible but makes everything ontology-driven possible.

---

## 3. Interim Value Timeline — Revised

```
Epic 91 Phase 1                  Phase 1+Plays              Epic 91 Phase 2+Plays
(Sage MCP Server)                (Parallel interim value)    (Event flows + Claude hybrid)
     │                                │                          │
     ├─ SKL-160/161 operational      ├─ Play 1: Claude GRN/     ├─ Play 5: PA+Claude hybrid
     │                               │  dispatch inference       │  for complex events
     │                               ├─ Play 2: Customs as      │
     │                               │  MeatTrackAI-native      ├─ Epic 91 Phase 3 starts
     │                               ├─ Play 3: UACL on MCP     │  with better foundation
     │                               │  Server (day one audit)  │
     │                               ├─ Play 4: SOP YAML        │
     │                               │  configs (documentation) │
     │                               ├─ Play 6: Ontology        │
     │                               │  instances from Sage      │
     │                               │                          │
     ▼                               ▼                          ▼
  FOUNDATION                    INTERIM VALUE                ENHANCED VALUE
  "Sage data flows"             "Claude bridges gaps,        "Intelligent event
                                 customs is native,           response, SOP
                                 audit from day one,          configs ready for
                                 SOPs structured,             MS AF execution"
                                 ontology seeded"
```

---

## 4. What Changes in the Assessment

| Previous Position | Revised Position | Why |
|---|---|---|
| MS AF = Phase 5+ for WWG | MS AF declarative agents = **Phase 1+ for customs** (Play 2). MS AF durable tasks = Phase 3+ | Customs is Sage-absent, not Sage-deferred. MS AF fills a real gap now |
| AI GRC = post-deployment | UACL audit on MCP Server = **Phase 1 day one** (Play 3). Agent OS policy = Phase 3+ | The integration layer IS the first governable component |
| Claude agents = Phase 3 | Claude GRN/dispatch inference = **Phase 1+** (Play 1). Claude event reasoning = **Phase 2** (Play 5) | Claude adds value wherever Sage API falls short — that's Phase 1 |
| Ontology instances = "not started" | Ontology instances seeded from Sage data = **Phase 1+** (Play 6) | The data to generate instances exists in Sage. Don't author manually |
| SOPs = "define in Phase 3" | SOP YAML configs = **Phase 1+ parallel** (Play 4) | Structure before execution. Reveals requirements before build |

---

## 5. Cross-References

| Reference | Relationship |
|---|---|
| [PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0.md) | Parent assessment — this addendum revises the timeline |
| [PFC-ARCH-PLAN-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-PLAN-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0.md) | Gated plan — Plays 1-6 insert into Phase 0-1 gates |
| [Epic 91 (#51 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/51) | Sage 200 integration epic — Plays enhance Phase 1-2 |
| [Epic 90 (#39 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/39) | Live API integration — Play 1 feeds corridor data completeness |
| [Epic 15 (#75 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/75) | MS Agent Framework — Play 2 is first concrete use case |
| [Epic 16 (#77 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/77) | AI GRC — Play 3 is first concrete use case |

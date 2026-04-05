# PFC-ARCH-NOTES-WWG-Interim-Value-Plays-v1.1.0

| Field | Value |
|---|---|
| **Document** | PFC-ARCH-NOTES-WWG-Interim-Value-Plays-v1.1.0 |
| **Product Code** | PFC-ARCH |
| **Type** | Architecture Notes (NOTES) |
| **Status** | For Discussion |
| **PFI** | W4M-WWG |
| **Date** | 2026-04-05 |
| **Version** | v1.1.0 — corrected: operations and LSC work from Sage downloads, API is parallel track |
| **Context** | Addendum to PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0 |

---

## 1. The Correction

v1.0.0 treated Sage 200 API gaps as blockers that Claude agents needed to "bridge" with inference. That's overthinking it.

**Reality: Operations and LSC already work from Sage 200 data downloads (CSV, Excel exports).** This is how the business runs today. The API integration is a parallel engineering track — important, but NOT a prerequisite for Claude agent value.

> **Sage downloads = immediate data. Sage API = parallel improvement. Don't conflate them.**

This means Claude + MS AF + AI GRC value can land **immediately** on exported Sage data, while the API work (SKL-160/161 MCP Server, GRN/dispatch gaps, webhooks) proceeds independently.

---

## 2. Two Parallel Tracks

```
TRACK A: Operations & LSC Value (NOW)          TRACK B: Sage API Integration (PARALLEL)
─────────────────────────────────────           ────────────────────────────────────────
Sage 200 CSV/Excel exports                      SKL-160 pfc-erp-connector
  → Claude processes downloaded data            SKL-161 w4m-sage200-adapter
  → MeatTrackAI populated from exports          Sage 200 REST API coverage testing
  → SOP analysis on real data                   GRN/dispatch API gap workarounds
  → Customs intelligence per corridor           Webhook/polling patterns
  → Corridor analytics & anomaly detection      Power Automate event flows
  → Ontology instances seeded from exports      Live real-time sync
                                                
VALUE: Immediate                                VALUE: When ready
BLOCKER: None — data exists today               BLOCKER: API gaps, SDK evaluation
```

**Track A doesn't wait for Track B.** Track B makes Track A better (live data, real-time, write-back) — but Track A delivers value from day one on data that's already available.

---

## 3. Revised Interim Value Plays (Download-First)

### Play 1: Claude on Sage Exports — Corridor Intelligence (NOW)

**What exists:** Sage 200 data can be exported as CSV/Excel — POs, SOs, invoices, stock, contacts, bank transactions. WWG operations already work from these exports.

**What Claude adds:**

| Input (Sage Export) | Claude Analysis | Output |
|---|---|---|
| PO export (CSV) | Cross-corridor PO analysis — spend by corridor, supplier concentration, lead time patterns | Corridor procurement intelligence dashboard data |
| SO + Invoice export | Revenue by corridor, payment patterns, overdue analysis, margin by product/corridor | Financial corridor performance |
| Stock export | Stock levels vs demand patterns, slow-moving lines, reorder triggers per corridor | Inventory intelligence with corridor context |
| Supplier contacts | Supplier risk scoring — concentration, geography, payment history | Supply chain risk per corridor |
| Bank transactions | Cash flow patterns, FX exposure by corridor (AU$/NZ$/ISK/EUR), reconciliation assistance | Multi-currency treasury view |

**How:**
- Export CSVs from Sage 200 (manual or scheduled report)
- Claude agent reads CSVs, analyses, generates corridor intelligence
- Results populate MeatTrackAI dashboard components (Epic 90)

**MS AF angle:** Declarative agent config per analysis type. Schedule-driven (weekly export → process → dashboard refresh). Doesn't need durable tasks — batch processing of static exports is simple.

**VE-QVF:**
- **FIT**: ✅ Operations already works from exports. Claude adds intelligence on top
- **MATTER**: ✅ Corridor analytics is MeatTrackAI's core product value
- **VALUE**: ✅ Zero API dependency. Data exists. Claude reads it. Done
- **ADVANTAGE**: ✅ Intelligent corridor analytics vs spreadsheet reports — product differentiator
- **Kano**: Performance → Delighter (patterns humans miss in spreadsheets)

---

### Play 2: Customs Intelligence from Export Data (NOW)

Unchanged from v1.0.0 but simpler — customs rules apply to export data, not API calls.

| Input | Claude Process | Output |
|---|---|---|
| PO export with product codes | Claude applies AU/NZ/IS/IE tariff rules per product line | Duty/tariff estimate per PO per corridor |
| SO export with destination | Claude identifies customs documentation requirements | Required customs docs per shipment |
| Historical customs outcomes (if captured) | Pattern analysis — rejections, delays, duty adjustments | Corridor-specific customs risk profile |

Per-corridor YAML rules (AU, NZ, IS, IE) — same declarative agent pattern. Works on CSV input today, works on live API input later. No architecture change when Track B delivers.

**Kano**: Must-have capability delivered from day one, not waiting for Sage API.

---

### Play 3: UACL Audit on Exports + MCP Server (Layered)

**Immediate (Track A):** UACL audit record when Claude processes a Sage export — who uploaded what file, what analysis was run, what outputs generated. Lightweight but establishes audit chain from the start.

**When Track B delivers:** UACL audit on every MCP Server API call — full transaction-level audit. The audit chain is continuous from export-era through to live-API-era.

**Kano**: Enabler — invisible but creates continuous audit history from day one.

---

### Play 4: SOP-as-Config from Real Operations (NOW)

SOPs defined as structured YAML based on how operations actually works today with Sage exports:

```yaml
# sop-goods-receipt-au.yaml
name: "Goods Receipt — AU Corridor"
version: "1.0.0"
corridor: "AU"
trigger: "PO export shows status change to 'Part Received' or 'Complete'"
data_source: "sage_export_csv"  # → changes to "sage_api" when Track B delivers
steps:
  - id: match_po_to_stock
    description: "Match PO lines to stock movement entries in export"
    input: ["po_export.csv", "stock_export.csv"]
    
  - id: quality_check
    type: human_in_the_loop
    prompt: "QC decision for received goods"
    options: ["release", "hold", "reject"]
    
  - id: customs_assessment
    agent: claude
    rules: "customs-rules-au.yaml"
    input: "{{match_po_to_stock.result}}"
    
  - id: record_in_meattrack
    target: "meattrack_db"
    data: "GRN record with QC + customs data"
    
  - id: sage_financial_note
    description: "Manual: post duty/tariff journal in Sage"  # → automated when Track B delivers
```

**Key:** `data_source: "sage_export_csv"` changes to `data_source: "sage_api"` when Track B delivers. Same SOP, same structure, same logic. Only the data source changes.

**Kano**: Performance — structured SOPs now, executable SOPs later. Same YAML both times.

---

### Play 5: Power Automate + Claude Hybrid (Track B Phase 2 — unchanged)

Still depends on Track B (Sage API/polling). But when it arrives, the Claude agents from Track A already exist and understand the data patterns from months of processing exports. They're smarter on day one of live data than they would be starting cold.

---

### Play 6: Ontology Instances from Sage Exports (NOW)

Generate ontology instances from Sage export data — same as v1.0.0 but doesn't need the MCP Server:

| Sage Export | Ontology Target |
|---|---|
| Supplier list CSV | `org:supplier-au-*`, `org:supplier-nz-*` etc. |
| Product catalogue CSV | `func:product-category-*` per corridor |
| Warehouse list | `func:warehouse-*` with corridor assignment |
| Customer list CSV | `org:client-*` per corridor |

Claude reads CSVs, generates ontology instance files, commits to repo. Fills the .gitkeep gap with real data-derived instances.

**Kano**: Enabler — seeds the ontology layer from data that exists today.

---

## 4. Revised Timeline

```
NOW (Track A)                    PARALLEL (Track B)              CONVERGENCE
─────────────                    ──────────────────              ───────────
Claude on Sage exports:          SKL-160/161 MCP Server dev     Track A agents switch from
• Corridor intelligence          • Sage 200 REST API testing      CSV input to API input
• Customs per corridor           • GRN/dispatch gap analysis    • Same agents, same logic
• SOP YAML from real ops         • Webhook/polling patterns     • data_source changes
• UACL on export processing      • Power Automate flows         • Write-back to Sage enabled
• Ontology instances seeded      • Azure Functions hosting      • Real-time replaces batch
                                                                
DELIVERS: Weeks                  DELIVERS: Per Epic 91 phases   DELIVERS: When Track B ready
BLOCKS ON: Nothing               BLOCKS ON: Sage API gaps       BLOCKS ON: Track B completion
```

**The critical insight:** Track A agents learn the data, learn the patterns, learn the corridor differences, learn the SOP structures — all from real export data. When Track B delivers live API access, those agents don't start from scratch. They upgrade from batch to real-time. The intelligence is already built.

---

## 5. What This Changes

| Previous Position | Corrected Position |
|---|---|
| Sage MCP Server (Phase 1) must complete before Claude value | Claude value from **day one** on Sage exports. MCP Server improves it, doesn't enable it |
| GRN/dispatch API gaps block corridor tracking | Corridor tracking from **export data** immediately. API enriches with real-time + write-back |
| MS AF declarative agents need live API data | Declarative agents work on **CSV input** with same YAML config. `data_source` field changes later |
| Ontology instances can't be generated without API | Ontology instances generated from **export CSVs**. Same data, different delivery mechanism |
| Phase 1 → Phase 2 → Phase 3 → Phase 4 → MS AF | Track A (export-based value) + Track B (API engineering) **in parallel**. MS AF enters when it helps, not when API is complete |

---

## 6. Cross-References

| Reference | Relationship |
|---|---|
| [PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-NOTES-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0.md) | Parent assessment |
| [PFC-ARCH-PLAN-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-PLAN-WWG-MSAF-AIGRC-Sage-Assessment-v1.0.0.md) | Gated plan — Track A plays insert before all gates |
| [Epic 90 (#39 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/39) | LSC components — Track A feeds dashboard data from exports |
| [Epic 91 (#51 WWG)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/51) | Sage integration — Track B. Runs in parallel, not as prerequisite |
| [Epic 15 (#75 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/75) | MS Agent Framework — declarative agents usable on CSV data today |
| [Epic 16 (#77 pfc-dev)](https://github.com/ajrmooreuk/pfc-dev/issues/77) | AI GRC — UACL audit on export processing from day one |

# PFC-ARCH-NOTES-Sage-200-Self-Hosted-Integrations-v1.0.0

> **Product Code:** PFC-ARCH
> **Doc Type:** NOTES (Architecture Technical Notes)
> **Version:** 1.0.0
> **Status:** For Decision
> **Date:** 2026-03-27
> **PFI Instance:** W4M-WWG (World Wide Gourmet)
> **Epic Ref:** Epic 91 (W4M-WWG) — AI & LSC-SOP-OFM AI Augmented Solution with Sage 200 & MS365 Integration
> **Cross-ref:** PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md, PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md, F90.11 (#50)
> **Cascade Target:** PFI-W4M-WWG → `PBS/STRATEGY/`

---

## 1. Purpose

This architecture note defines the integration approach for **Sage 200 (self-hosted)** with the W4M-WWG logistics intelligence platform, augmented by **Claude AI agentic capabilities** and embedded within the **Microsoft 365 ecosystem**.

The note addresses four integration dimensions:

1. **Sage 200 API & MCP Server** — programmatic access to accounting, stock, and order fulfilment data
2. **Microsoft 365 Integration** — Power Automate, Teams, Outlook, SharePoint, Power BI
3. **Claude AI Agentic Layer** — MCP-connected agent for intelligent financial operations
4. **Security & RBAC** — layered access control for AI-to-ERP interactions

This builds on the data flow architecture defined in **F90.11** (#50) — Accounting & Stock Order Fulfilment Data Flow Back — and extends it with a concrete Sage 200 implementation path and AI augmentation strategy.

---

## 2. Context: Why Sage 200 Self-Hosted

W4M-WWG's target mid-market UK meat importers typically run **Sage 200 Professional** (self-hosted, on-premises SQL Server). This is the dominant ERP in UK mid-market food distribution:

| Factor | Relevance |
|--------|-----------|
| **Market share** | Sage 200 is the most common mid-market ERP in UK food/distribution (estimated 35–45% of businesses with 50–500 employees) |
| **Self-hosted** | On-premises SQL Server deployment. No cloud API gateway. Requires network-local or VPN access |
| **Modules in use** | Nominal Ledger, Sales Ledger, Purchase Ledger, Stock Control, Project Accounting |
| **Integration surface** | REST API (version-dependent), .NET SDK, ODBC/SQL Server direct |
| **Existing automation** | Typically minimal — manual CSV imports, email-based workflows |

The opportunity is to connect the MeatTrackAI logistics intelligence directly to Sage 200, enabling:
- **Automated accounting entries** from tracker events (demurrage, spoilage, penalties)
- **Real-time stock visibility** correlated with vessel position and ETA
- **Landed cost calculation** from freight + duty + handling + delay costs
- **AI-augmented financial operations** via Claude agent with controlled Sage access

---

## 3. Sage 200 Integration Architecture

### 3.1 Integration Surface

Sage 200 self-hosted provides three access layers:

| Layer | Protocol | Capabilities | Constraints |
|-------|----------|-------------|-------------|
| **REST API** | HTTPS (OAuth2 / API key) | Sales, Purchase, Stock, Nominal, Projects | Version-dependent maturity. Professional edition required for full API |
| **.NET SDK** | In-process (.NET Framework) | Full business logic layer. Custom fields, workflows | Requires deployment on Sage server. Windows-only |
| **SQL Server** | ODBC / TDS | Direct table access. All data visible | Read-only recommended. Schema undocumented. Risk of bypassing business rules |

**Recommended approach:** REST API as primary, SQL Server as read-only fallback for reporting queries not exposed via API.

### 3.2 MCP Server Design

A thin **Model Context Protocol (MCP) server** wraps the Sage 200 REST API, exposing 5 coarse-grained tools to the Claude agent. This follows the PFC MCP architecture principle of token-efficient design (~2,500–4,000 token overhead).

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────┐
│ Claude Agent │────▶│  MCP Server      │────▶│  Sage 200    │
│ (Anthropic)  │     │  (Stdio plugin)  │     │  REST API    │
└──────────────┘     │                  │     │  + SQL Server│
                     │  5 tools:        │     └──────────────┘
                     │  query_financials│
                     │  lookup_entity   │
                     │  list_transactions│
                     │  stock_check     │
                     │  create_transaction│
                     └──────────────────┘
```

#### Tool Definitions

| Tool | Purpose | Access Mode |
|------|---------|-------------|
| `sage_query_financials` | Trial balance, aged debtors/creditors, nominal activity. Date range + cost centre filtering | Read |
| `sage_lookup_entity` | Customer, supplier, product, project, nominal account lookup by code/name/search | Read |
| `sage_list_transactions` | Sales/purchase invoices, credit notes, payments, receipts, journals. Filter by entity, date, status | Read |
| `sage_stock_check` | Stock levels, warehouse allocation, reorder status. Product group and warehouse filtering | Read |
| `sage_create_transaction` | Create invoice, credit note, journal, payment. **dry_run: true by default**. Requires explicit user confirmation | Write (gated) |

#### Transport Model

**StdioServerTransport** (plugin model) — consistent with existing PFC MCP patterns (Discord, FakeChat). The server starts/stops with the Claude session.

```typescript
// server.ts — simplified structure
import { Server } from '@modelcontextprotocol/sdk/server/index.js'
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'

const mcp = new Server(
  { name: 'sage200', version: '1.0.0' },
  { capabilities: { tools: {} } }
)

// Register 5 tools, connect via stdio
await mcp.connect(new StdioServerTransport())
```

#### Sage 200 API Client

The client handles:
- **Authentication** — token acquisition and refresh (OAuth2 or API key depending on Sage version)
- **Pagination** — Sage API returns paged results for large datasets
- **Retry with backoff** — network resilience for on-prem connectivity
- **Rate limiting** — max 50 API calls/minute (configurable)
- **Audit logging** — append-only JSON log of all API interactions

### 3.3 Network Topology

Since Sage 200 is self-hosted (on-premises), the MCP server needs network access:

```
┌─────────────────────────────────┐
│  Client Network (On-Premises)    │
│                                  │
│  ┌──────────┐  ┌──────────────┐ │
│  │ Sage 200 │  │ MCP Server   │ │
│  │ Server   │──│ (same LAN)   │ │
│  │ SQL Svr  │  │              │ │
│  └──────────┘  └──────┬───────┘ │
│                       │          │
└───────────────────────┼──────────┘
                        │ VPN / Azure Hybrid Connection
                        │
              ┌─────────▼──────────┐
              │  Claude Agent      │
              │  (Anthropic Cloud) │
              └────────────────────┘
```

**Options:**
1. **MCP server on client LAN** — simplest. Direct access to Sage. Claude connects via secure tunnel
2. **Azure Hybrid Connection** — Azure-managed relay. No inbound firewall rules needed
3. **VPN tunnel** — IPSec/WireGuard from cloud to client network
4. **Azure Function middleware** — hosted in Azure, connects to Sage via Express Route or VPN

**Recommendation:** Option 1 (LAN-hosted MCP) for PoC. Option 2 (Azure Hybrid) for production multi-tenant.

---

## 4. Microsoft 365 Integration Layer

### 4.1 Architecture

The Microsoft integration extends the existing Epic 90 F90.5/F90.10 architecture to include Sage 200 data flows:

```
┌────────────────────────────────────────────────────────┐
│                Microsoft 365 Environment                │
│                                                         │
│  ┌── Power Automate ─────────────────────────────────┐ │
│  │                                                    │ │
│  │  Flow 1: Sage → Tracker Reconciliation             │ │
│  │    Trigger: Container discharged (tracker event)   │ │
│  │    Action: Create Sage goods receipt (PO match)    │ │
│  │    Action: Update stock levels                     │ │
│  │    Action: Post Teams notification                 │ │
│  │                                                    │ │
│  │  Flow 2: Tracker → Sage Cost Accruals              │ │
│  │    Trigger: Demurrage/spoilage event               │ │
│  │    Action: Create Sage journal entry               │ │
│  │    Action: Update corridor cost centre             │ │
│  │    Action: Email finance team with cost breakdown  │ │
│  │                                                    │ │
│  │  Flow 3: Sage → Power BI Refresh                   │ │
│  │    Trigger: Monthly schedule (1st of month)        │ │
│  │    Action: Extract Sage trial balance via API      │ │
│  │    Action: Upload to SharePoint                    │ │
│  │    Action: Refresh Power BI dataset                │ │
│  │                                                    │ │
│  │  Flow 4: Overdue Invoice Alerting                  │ │
│  │    Trigger: Daily schedule (09:00)                 │ │
│  │    Action: Query Sage aged debtors                 │ │
│  │    Action: Filter > threshold                      │ │
│  │    Action: Post Teams channel alert                │ │
│  │    Action: If > 60 days → email credit controller  │ │
│  │                                                    │ │
│  │  Flow 5: Purchase Order Approval                   │ │
│  │    Trigger: PO value > £5,000 (Sage webhook/poll)  │ │
│  │    Action: Teams Approval → manager                │ │
│  │    Action: If approved → authorise PO in Sage      │ │
│  │    Action: If rejected → reject + notify requester │ │
│  └────────────────────────────────────────────────────┘ │
│                                                         │
│  ┌── Teams / Outlook ────────────────────────────────┐ │
│  │  Fleet Intelligence Tab (iframe — existing)        │ │
│  │  + Financial Impact Cards (Adaptive Cards)         │ │
│  │    "Container AUS-007 discharged — landed cost     │ │
│  │     £12,847 vs budget £11,200 (+£1,647 demurrage)"│ │
│  │  + Sage Quick Actions                              │ │
│  │    [View in Sage] [Approve PO] [Query Stock]       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                         │
│  ┌── Power BI ───────────────────────────────────────┐ │
│  │  Corridor P&L Dashboard                            │ │
│  │    Source: Sage nominal + tracker delay costs       │ │
│  │  Landed Cost Trending                              │ │
│  │    Source: Sage purchase invoices + freight + duty  │ │
│  │  Customer Profitability                            │ │
│  │    Source: Sage sales + tracker OTIF metrics        │ │
│  └────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

### 4.2 On-Premises Data Gateway

**Required** for Power Automate ↔ Sage 200 connectivity:

- Install **Microsoft On-Premises Data Gateway** on a server with access to both Sage SQL Server and Sage REST API
- Gateway provides secure relay — no inbound firewall rules needed
- Power Automate flows use the gateway as a connector data source
- Supports SQL connector (for direct queries) and HTTP connector (for Sage REST API)

### 4.3 Integration Phases

| Phase | Capability | Dependency | Epic 91 Features |
|-------|-----------|------------|------------------|
| **Phase 1** | MCP server + read-only Sage access | Sage API credentials, network access | F91.1, F91.2 |
| **Phase 2** | Power Automate flows (tracker → Sage) | On-Premises Data Gateway | F91.3, F91.4 |
| **Phase 3** | AI-augmented financial ops (Claude + Sage) | MCP server deployed, RBAC configured | F91.5, F91.6 |
| **Phase 4** | Power BI dashboards + landed cost engine | Sage + tracker data in SharePoint/SQL | F91.7, F91.8 |

---

## 5. AI Augmentation Strategy

### 5.1 Claude Agent Use Cases

The Claude agent, connected to Sage via MCP, enables **conversational financial operations**:

| Use Case | Example Interaction | Sage Tools Used |
|----------|-------------------|-----------------|
| **Financial inquiry** | "What's our aged debtors position for AU corridor customers?" | `sage_query_financials` (aged debtors) + `sage_lookup_entity` (customer filter) |
| **Cost investigation** | "Why did container AUS-007 cost £1,647 over budget?" | `sage_list_transactions` (PO lines) + tracker delay data |
| **Stock planning** | "Do we have enough NZ lamb in Southampton to cover next week's orders?" | `sage_stock_check` (warehouse: Southampton, product group: NZ lamb) |
| **Invoice generation** | "Create a sales invoice for Morrison's — 200 cases NZ lamb shoulder at £18.50/case" | `sage_create_transaction` (dry_run first, then confirmed) |
| **Month-end support** | "Generate the corridor P&L summary for March — AU, NZ, IS, IE corridors" | `sage_query_financials` (nominal activity by cost centre) |
| **Landed cost analysis** | "What's the average landed cost per kilo for AU beef this quarter vs last?" | `sage_list_transactions` (purchase invoices) + tracker freight data |

### 5.2 SOP Augmentation (Standard Operating Procedures)

The AI agent automates and enforces SOPs that are currently manual:

| SOP | Current Process | AI-Augmented Process |
|-----|----------------|---------------------|
| **Container arrival** | Manual: check discharge, email warehouse, update spreadsheet, create Sage GRN | Automated: tracker detects discharge → agent creates Sage goods receipt → notifies warehouse via Teams → updates stock |
| **Demurrage accrual** | Manual: freight forwarder sends invoice → accounts manually create journal | Automated: tracker detects overstay → agent calculates cost → creates Sage journal (dry_run) → sends for approval via Teams |
| **Spoilage write-off** | Manual: quality team reports → accounts create credit note and write-off | Automated: tracker detects temp breach → agent prepares Sage write-off + insurance claim evidence → routes for approval |
| **Monthly reconciliation** | Manual: 2–3 days of spreadsheet work to reconcile tracker data with Sage | Automated: agent queries Sage transactions → cross-references tracker events → generates reconciliation report → flags discrepancies |
| **Customer SLA breach** | Manual: discovered at month-end when compiling KPIs | Automated: tracker detects OTIF breach → agent queries customer SLA terms → calculates penalty → creates Sage provision → alerts account manager |

### 5.3 OFM Integration (Order Fulfilment Management)

The agent bridges **OFM-ONT** (82 entities in W4M-WWG instance) with Sage 200:

| OFM Entity | Sage Object | Agent Action |
|-----------|-------------|-------------|
| `SalesOrder` | Sales Order Header/Line | Sync order status, delivery promise dates |
| `StockAllocation` | Stock Record / Warehouse | Check availability, reserve stock on ETA confirmation |
| `DeliveryWindow` | Despatch Note | Trigger despatch when BTOM cleared + stock available |
| `MarginImpact` | Nominal Journals | Post delay cost journals, recalculate margin per order |
| `CustomerChangeScenario` | Credit Note / Amendment | Process date push-back, quantity reduction, spec change |
| `LandedCost` | Purchase Invoice + Journals | Aggregate freight + duty + handling + demurrage + inspection |

---

## 6. Security & RBAC Model

### 6.1 Layered Security Architecture

```
┌─────────────────────────────────────────────────────┐
│  Layer 1: Claude Agent — Tool-level gating           │
│  • dry_run: true by default on all writes            │
│  • User confirmation required before posting          │
│  • Conversation audit trail                           │
├─────────────────────────────────────────────────────┤
│  Layer 2: MCP Server — Application-level controls    │
│  • Read-only mode flag (env var)                     │
│  • Transaction value ceiling (configurable)          │
│  • Allowlisted nominal codes only                    │
│  • Rate limiting (max 50 API calls/min)              │
│  • Audit log (JSON append-only)                      │
├─────────────────────────────────────────────────────┤
│  Layer 3: Sage 200 API — System-level controls       │
│  • Dedicated API user with restricted role            │
│  • Read-only on Nominal Ledger, Payroll, VAT         │
│  • Write limited to: SI, PI, CN, Journals            │
│  • No access to: bank recon, year-end, payroll       │
│  • IP allowlist (MCP server IP only)                 │
├─────────────────────────────────────────────────────┤
│  Layer 4: Network — Infrastructure controls          │
│  • Sage API on internal network only                 │
│  • MCP server ↔ Sage via LAN or VPN                  │
│  • TLS everywhere                                    │
│  • No direct internet exposure of Sage               │
└─────────────────────────────────────────────────────┘
```

### 6.2 RBAC Matrix

| Capability | Agent (Read) | Agent (Write) | Human Approval | Blocked |
|---|---|---|---|---|
| Query trial balance / aged reports | Yes | — | — | — |
| List invoices / transactions | Yes | — | — | — |
| Customer / supplier lookup | Yes | — | — | — |
| Stock level check | Yes | — | — | — |
| Create sales invoice | — | dry_run | Yes (confirm) | — |
| Create purchase invoice | — | dry_run | Yes (confirm) | — |
| Post journal | — | dry_run | Yes (confirm) | — |
| Create credit note | — | dry_run | Yes (confirm) | — |
| Modify nominal structure | — | — | — | Blocked |
| Bank reconciliation | — | — | — | Blocked |
| Payroll access | — | — | — | Blocked |
| Year-end / VAT return | — | — | — | Blocked |
| Delete transactions | — | — | — | Blocked |
| User / permission management | — | — | — | Blocked |

### 6.3 Audit Trail

Every MCP tool call logged to append-only file:

```json
{
  "timestamp": "2026-03-27T14:30:00Z",
  "tool": "sage_create_transaction",
  "args": { "transaction_type": "journal", "lines": ["..."], "dry_run": true },
  "result_status": "success",
  "dry_run": true,
  "user_confirmed": false,
  "sage_reference": null
}
```

### 6.4 RRR-ONT Alignment

Following RRR-ONT (Roles, RACI, RBAC) conventions:

| Role | Sage Access | Agent Interaction |
|------|------------|-------------------|
| **Operations Manager** | Full read + write (approved) | Can instruct agent to create transactions. Approval required |
| **Finance Controller** | Full read + write (direct) | Can instruct agent. Reviews dry_run outputs before confirmation |
| **Logistics Coordinator** | Read: stock, orders. No write | Can query stock, vessel status, ETA. Cannot create financial transactions |
| **Claude Agent (system)** | Per RBAC matrix above | Executes within tool constraints. Never autonomous writes |

---

## 7. PFC/PFI Architecture Mapping

### 7.1 Skill Registration

New skills required for Sage 200 integration:

| Skill | Entry ID | Classification | Cascade Tier | Description |
|-------|----------|---------------|-------------|-------------|
| `pfc-erp-connector` | SKL-160 (TBC) | AGENT_ORCHESTRATOR | PFC | Generic ERP connector — config-driven, multi-vendor (Sage/Xero/SAP) |
| `w4m-sage200-adapter` | SKL-161 (TBC) | SKILL_STANDALONE | PFI-W4M-WWG | Sage 200 specific adapter — entity mapping, auth, nominal codes |
| `pfc-erp-reconciler` | SKL-162 (TBC) | SKILL_CHAIN | PFC | Cross-reference tracker events with ERP transactions — discrepancy detection |

**Pattern:** Mirrors SKL-154/155 (api-connector/ais-adapter) — generic connector at PFC tier, domain-specific adapter at PFI tier.

### 7.2 Cascade Distribution

```
PFC Hub (Azlan-EA-AAA)
  └── skills/pfc-erp-connector/           ← Generic ERP connector (PFC tier)
        │
        ├── pfc-release.yml ──────────────▶ PFI-W4M-WWG-dev (Sage 200 adapter)
        │                                   PFI-BAIV-dev (Xero adapter, future)
        │                                   PFI-AIRL-dev (if ERP needed)
        │
        └── promote.yml within PFI ───────▶ dev → test → prod
                                            (TDD gate: ≥0.70 / ≥0.90)
```

### 7.3 Ontology Touchpoints

| Ontology | Relationship to Sage Integration |
|----------|--------------------------------|
| **LSC-ONT** | Logistics events trigger Sage transactions (discharge → GRN, delay → demurrage journal) |
| **OFM-ONT** | Order fulfilment entities map to Sage sales/purchase objects |
| **QVF-ONT** | Financial metrics (spoilage cost, demurrage, margin) sourced from Sage actuals |
| **RRR-ONT** | RBAC roles govern agent access levels to Sage modules |
| **VP-ONT** | Value realisation benefits (B1–B6) measurable via Sage financial data |
| **KPI-ONT** | KPIs (OTIF, spoilage rate, margin) calculable from Sage + tracker data |
| **BSC-ONT** | Balanced scorecard perspectives sourced from Sage financial + tracker operational data |

### 7.4 Relationship to Existing Epics

| Epic/Feature | Relationship |
|-------------|-------------|
| **Epic 90 F90.11** (#50) | Direct parent — F90.11 defined the data flow architecture. Epic 91 implements it for Sage 200 specifically |
| **Epic 90 F90.1** (#40) | SKL-154 pfc-api-connector — reused for Sage REST API calls |
| **Epic 90 F90.5** (#44) | Microsoft Environment Integration — shared Teams/Outlook/SharePoint infrastructure |
| **Epic 90 F90.6** (#45) | VE/QVF metrics — Sage actuals feed QVF financial model validation |
| **Epic 90 F90.10** (#49) | Microsoft IT Prep — On-Premises Data Gateway setup shared |
| **Epic 41** (Azlan #600) | OFM-ONT — ontology that bridges logistics to commercial (Sage is the commercial system) |
| **Epic 77** (Azlan #1204) | URG — skill registration pipeline for SKL-160/161/162 |

---

## 8. Relationship to F90.11 Scope

F90.11 (#50) defined 10 stories for "Accounting & Stock Order Fulfilment Data Flow Back." Epic 91 **does not duplicate** F90.11 — it extends it:

| F90.11 Story | Epic 91 Responsibility |
|-------------|----------------------|
| S90.11.1: Define ERP/accounting API integration | Epic 91 F91.1–F91.2: Sage 200 specific implementation |
| S90.11.2: Map tracker events → accounting entries | Epic 91 F91.3: Power Automate flow implementation |
| S90.11.3: Create outbound pfc-api-connector config | Epic 91 F91.1: Sage 200 API configuration |
| S90.11.4–S90.11.7: OFM stock/goods/insurance/customer | Epic 91 F91.5–F91.6: AI-augmented OFM operations |
| S90.11.8: Monthly cost waterfall export | Epic 91 F91.7: Power BI corridor P&L |
| S90.11.9: PowerBI financial impact trending | Epic 91 F91.7: Power BI dashboards |
| S90.11.10: Landed cost calculation | Epic 91 F91.8: Landed cost engine |

**F90.11 remains the design specification. Epic 91 is the Sage 200 implementation epic.**

---

## 9. Document Cross-References

| Document | Location | Relationship |
|----------|----------|-------------|
| Microsoft VE/QVF Strategy | PBS/STRATEGY/PFC-STRAT-BRIEF-W4M-WWG-Microsoft-VE-QVF-Strategy-v1.0.0.md | Strategic context, VE analysis, competitive positioning |
| Epic 90 Plan | PBS/STRATEGY/PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md | Parent epic plan — F90.11 data flow architecture |
| API Connector Dtree | PBS/STRATEGY/PFC-ARCH-BRIEF-API-Integration-Skill-Dtree-Review-v1.0.0.md | SKL-154/155 classification — reusable for ERP connector |
| MCP Architecture | (PFC Hub) PBS/STRATEGY/PFC-SUPP/PFC-SUPP-PROP-Supabase-Secure-Connections-CLI-API-MCP-v1.2.0.md | MCP server design principles (5 coarse tools, token-efficient) |
| OFM-ONT Briefing | (PFC Hub) PBS/STRATEGY/PFC-ONTL-BRIEF-OFM-ONT-Order-Fulfilment-v1.0.0.md | OFM entity model — maps to Sage objects |
| Fleet Intelligence Tracker | PBS/LSC-DEMOS/LSC-DEMO-DOC-MeatTrackAI-Fleet-Intelligence-Tracker-v1.0.0.md | Tracker architecture — event source for Sage integration |

---

*Architecture note authored following PFC-ARCH NOTES convention. Sage 200 integration assessed against existing PFC MCP architecture, Microsoft 365 strategy, and OFM-ONT entity model. VP-ONT ↔ RRR-ONT alignment applied to RBAC design. Skill registration follows URG G1/G2/G3 pipeline.*

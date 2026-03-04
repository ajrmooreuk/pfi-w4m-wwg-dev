# CONVERGENCE: FairSlice Supabase Schema to PFC JSONB Graph Patterns

## Schema Convergence Map — FairSlice Tables = F34.5 JSONB PoC

| Field | Value |
|---|---|
| **Date** | 2026-03-04 |
| **Version** | 1.1.0 |
| **Status** | PROPOSAL — For Review & Approval |
| **Classification** | CONFIDENTIAL — Strategic Planning Asset |
| **Parent** | Epic 50: FairSlice Platform Economics (#754) + Epic 34 F34.5 (JSONB Graph Storage PoC) |
| **Lead Document** | [BRIEFING-FairSlice-Strategy-Implementation-Proposals.md](BRIEFING-FairSlice-Strategy-Implementation-Proposals.md) |
| **Purpose** | Demonstrate that FairSlice's Supabase schema IS the JSONB graph storage PoC — not a separate system |
| **Ontology Alignment** | FAIRSLICE-ONT v1.0.0, PARTNER-ONT v1.0.0, GRC-FW-ONT, EMC-ONT |

---

## 1. The Core Thesis

FairSlice's database schema and PF-Core's JSONB graph storage are **the same thing**. The `pies` table with JSONB `ontology_config` is an instance of the same pattern as the Unified Registry's `pfc_registry` table with JSONB `configuration`. Building one builds the other.

```
FairSlice Schema          PFC JSONB Graph Pattern        Same Pattern?
------------------        ----------------------         -------------
pies.ontology_config      pfc_registry.configuration     YES - JSONB business rules
smart_contracts           pfc_registry (artifactType)    YES - registry artifacts
partners + referrals      pfc_registry (scope=instance)  YES - cascade inheritance
pie_members               graph_nodes (entity type)      YES - nodes with relationships
waterfall_rules           graph_edges (ordered)           YES - priority-ordered edges
audit_logs                grc_audit_trail                YES - GRC-FW audit pattern
```

---

## 2. Table-by-Table Convergence

### 2.1 Pies = Graph Tenants

| FairSlice Column | PFC Graph Equivalent | Convergence |
|-----------------|---------------------|-------------|
| `pies.id` | `graph_tenants.id` | UUID tenant identifier |
| `pies.name` | `graph_tenants.name` | Human-readable name |
| `pies.ontology_config` (JSONB) | `graph_tenants.configuration` (JSONB) | **Key convergence:** JSONB stores business rules. In FairSlice = multipliers, waterfall priorities. In PFC = ontology set, composition rules. Same column, different domain data. |
| `pies.status` | `graph_tenants.status` | Lifecycle state |
| `pies.instance_ref` | `graph_tenants.pfi_instance_id` | Maps to PFI instance (BAIV, W4M, etc.) |

**The `ontology_config` JSONB column follows the Unified Registry cascade:**

```json
// PFC-Core defaults (inherited by all pies)
{
  "multipliers": {
    "builder": 2.0,
    "rainmaker": 1.0,
    "architect": 1.5,
    "partner": 1.0,
    "advisor": 0.5
  },
  "waterfall_defaults": {
    "platform_fee_pct": 5,
    "dividend_distribution": "remainder"
  },
  "claim_verification": {
    "auto_approve_threshold": 0.85,
    "dispute_escalation": true
  }
}

// PFI-BAIV override (extends Core)
{
  "multipliers": {
    "content_architect": 2.0,  // BAIV-specific role
    "ai_visibility_sales": 1.0
  },
  "waterfall_defaults": {
    "platform_fee_pct": 5,
    "agency_retainer_pct": 5,
    "architect_royalty": true
  },
  "baiv_specific": {
    "mention_rate_commission_trigger": 0.4,
    "ai_visibility_score_threshold": 25
  }
}

// Pie-specific override (extends Instance)
{
  "custom_multipliers": {
    "cto_founder": 2.5  // Custom for this specific pie
  },
  "waterfall_overrides": {
    "agency_retainer_pct": 7  // This agency negotiated 7%
  }
}
```

**Resolution function:** `resolve_pie_config(pie_id)` merges Core + Instance + Pie using the same `deepMerge` semantics as `resolve_artifact_config()` from the Unified Registry.

---

### 2.2 Smart Contracts = Registry Artifacts

| FairSlice Column | PFC Registry Equivalent | Convergence |
|-----------------|------------------------|-------------|
| `smart_contracts.id` | `pfc_registry.id` | UUID artifact identifier |
| `smart_contracts.name` | `pfc_registry.name` | Human-readable name |
| `smart_contracts.version` | `pfc_registry.version` | Semantic version |
| `smart_contracts.category` | `pfc_registry.artifact_category` | Domain classification |
| `smart_contracts.system_prompt` | `pfc_registry.configuration.system_prompt` | **Key convergence:** the system prompt IS config |
| `smart_contracts.validation_rules` (JSONB) | `pfc_registry.configuration` (JSONB) | Business logic as JSONB |
| `smart_contracts.licensing_terms` (JSONB) | `pfc_registry.configuration.licensing` (JSONB) | Nested JSONB licensing |
| `smart_contracts.status` | `pfc_registry.status` | Lifecycle state |
| `smart_contracts.registry_artifact_ref` | `pfc_registry.artifact_id` | **Direct reference** — FK to registry |

**Convergence decision:** Smart contracts should be rows in `pfc_registry` with `artifact_type = 'smart-contract'`, not a separate table. The FairSlice `smart_contracts` table is a **view** over `pfc_registry` filtered by type.

```sql
-- Converged approach: smart contracts ARE registry artifacts
CREATE VIEW fairslice_smart_contracts AS
SELECT
  id,
  name,
  version,
  artifact_category AS category,
  configuration->>'system_prompt' AS system_prompt,
  configuration->'validation_rules' AS validation_rules,
  configuration->'licensing_terms' AS licensing_terms,
  status,
  instance_id,
  scope
FROM pfc_registry
WHERE artifact_type = 'smart-contract';
```

---

### 2.3 Partners + Referrals = Graph Nodes + Edges

| FairSlice Table | PFC Graph Pattern | Convergence |
|----------------|-------------------|-------------|
| `partners` | `graph_nodes` (type: partner) | Partners are graph nodes with properties |
| `referrals` | `graph_edges` (type: referral) | Referrals are edges linking partners to pies |
| `commission_rules` | `graph_edges` (type: commission) | Commission rules are edges with JSONB properties |
| `partner_payouts` | `ledger_transactions` (type: partner-payout) | Payouts are ledger entries |

**The graph pattern:**

```
[partner:Agency "MarTech Pro"]
  --[referral: {code: "MTP-001", type: "management-fee"}]--> [pie: "Startup X"]
  --[commission: {rate: 5, type: "percentage", trigger: "revenue-event"}]--> [waterfall_rule: priority 3]

[partner:Affiliate "AI Blogger"]
  --[referral: {code: "AIB-042", type: "platform-referral"}]--> [pie: "Startup Y"]
  --[commission: {rate: 10, type: "percentage-of-platform-fee"}]--> [waterfall_rule: priority 2]
```

---

### 2.4 Pie Members = Graph Nodes with Role Properties

| FairSlice Column | PFC Graph Equivalent | Convergence |
|-----------------|---------------------|-------------|
| `pie_members.id` | `graph_nodes.id` | Node identifier |
| `pie_members.role` | `graph_nodes.properties.role` | JSONB property |
| `pie_members.multiplier` | `graph_nodes.properties.multiplier` | JSONB property |
| `pie_members.profile_ref` | `graph_nodes.properties.user_ref` | External reference |
| `pie_members` -- `pies` join | `graph_edges` (type: member-of) | Edge connecting member to pie |

---

### 2.5 Waterfall Rules = Ordered Graph Edges

| FairSlice Column | PFC Graph Equivalent | Convergence |
|-----------------|---------------------|-------------|
| `waterfall_rules.priority` | `graph_edges.weight` or `graph_edges.properties.priority` | Ordered edge |
| `waterfall_rules.step_type` | `graph_edges.edge_type` | Edge classification |
| `waterfall_rules.value` | `graph_edges.properties.value` | JSONB property |
| `waterfall_rules.conditions` (JSONB) | `graph_edges.properties.conditions` (JSONB) | Conditional edge |

**Waterfall as graph traversal:**

```
[revenue_event: $100]
  --[waterfall: {priority: 1, type: "platform-fee", value: 5%}]--> [distribution: $5 to Platform]
  --[waterfall: {priority: 2, type: "affiliate", value: 10% of fee}]--> [distribution: $0.50 to Affiliate]
  --[waterfall: {priority: 3, type: "agency", value: 5%}]--> [distribution: $5 to Agency]
  --[waterfall: {priority: 4, type: "royalty"}]--> [distribution: $2 to Architect]
  --[waterfall: {priority: 7, type: "dividend", value: remainder}]--> [distribution: $87.50 to Pool]
```

Processing the waterfall IS a graph traversal — follow edges in priority order, extract value at each step, remainder flows to the final node.

---

### 2.6 Audit Logs = GRC-FW Audit Trail

| FairSlice Column | GRC-FW Pattern | Convergence |
|-----------------|---------------|-------------|
| `audit_logs.id` | `grc_audit_trail.id` | Audit entry identifier |
| `audit_logs.action` | `grc_audit_trail.action_type` | What happened |
| `audit_logs.input_data` (JSONB) | `grc_audit_trail.input_context` (JSONB) | What went in |
| `audit_logs.output_data` (JSONB) | `grc_audit_trail.output_result` (JSONB) | What came out |
| `audit_logs.reasoning` | `grc_audit_trail.reasoning` | AI Judge reasoning (BR-FS-009) |
| `audit_logs.pie_ref` | `grc_audit_trail.tenant_ref` | Tenant scope |
| `audit_logs.created_at` | `grc_audit_trail.event_timestamp` | Immutable timestamp |

**Key requirement (BR-FS-004):** Audit logs are append-only. No UPDATE or DELETE. This matches GRC-FW's GovernanceAssurance finding pattern — immutable by design.

---

## 3. Unified Table Strategy

### Option A: Separate Tables (FairSlice-first)

```
pros: Simple, domain-specific, fast to build
cons: Duplicates graph patterns, harder to converge later
tables: 16 FairSlice-specific tables

Recommended for: Phase 1 MVP
```

### Option B: Converged Tables (Graph-first)

```
pros: Single graph storage, all domains share same patterns
cons: More abstract, needs graph query layer, upfront design cost
tables: 5 core tables (graph_nodes, graph_edges, pfc_registry, graph_tenants, grc_audit_trail)

Recommended for: Phase 2 Platform
```

### Option C: Hybrid (Recommended)

```
Phase 1: Build FairSlice tables with graph-compatible JSONB patterns
Phase 2: Refactor into graph tables once patterns are proven
Phase 3: Add graph query layer (Supabase Functions or Neo4j sync)

Migration path: Views first, then table consolidation
```

**The hybrid approach means:**

1. Build `pies` with JSONB `ontology_config` NOW (FairSlice needs it)
2. Build `smart_contracts` as `pfc_registry` rows with `artifact_type = 'smart-contract'` NOW (converged from day one)
3. Build `audit_logs` following GRC-FW audit trail pattern NOW (same schema, same governance)
4. Build `partners`, `referrals`, `pie_members` as domain tables NOW
5. Refactor to `graph_nodes` + `graph_edges` in Phase 2 when patterns are validated

---

## 4. JSONB Config Resolution — Shared Function

Both FairSlice and the Unified Registry need the same config resolution:

```sql
-- This function serves BOTH FairSlice pies and Unified Registry artifacts
CREATE OR REPLACE FUNCTION resolve_cascaded_config(
  p_scope_type TEXT,          -- 'pie' or 'artifact'
  p_scope_id TEXT,            -- pie_id or artifact_id
  p_instance_id TEXT DEFAULT NULL,
  p_client_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  core_config JSONB;
  instance_config JSONB;
  scope_config JSONB;
  result JSONB;
BEGIN
  -- Level 1: Core defaults
  IF p_scope_type = 'pie' THEN
    SELECT configuration INTO core_config FROM pfc_registry
      WHERE artifact_type = 'fairslice-defaults' AND scope = 'core' AND status = 'active';
  ELSE
    SELECT configuration INTO core_config FROM pfc_registry
      WHERE artifact_id = p_scope_id AND scope = 'core' AND status = 'active';
  END IF;
  result := COALESCE(core_config, '{}'::jsonb);

  -- Level 2: Instance override
  IF p_instance_id IS NOT NULL THEN
    IF p_scope_type = 'pie' THEN
      SELECT configuration INTO instance_config FROM pfc_registry
        WHERE artifact_type = 'fairslice-defaults' AND scope = 'instance'
        AND instance_id = p_instance_id AND status = 'active';
    ELSE
      SELECT base_configuration INTO instance_config FROM pfc_registry
        WHERE artifact_id = p_scope_id AND scope = 'instance'
        AND instance_id = p_instance_id AND status = 'active';
    END IF;
    IF instance_config IS NOT NULL THEN
      result := result || instance_config;
    END IF;
  END IF;

  -- Level 3: Pie/Client override
  IF p_scope_type = 'pie' THEN
    SELECT ontology_config INTO scope_config FROM pies WHERE id = p_scope_id::uuid;
  ELSIF p_client_id IS NOT NULL THEN
    SELECT base_configuration INTO scope_config FROM pfc_registry
      WHERE artifact_id = p_scope_id AND scope = 'client'
      AND client_id = p_client_id AND status = 'active';
  END IF;
  IF scope_config IS NOT NULL THEN
    result := result || scope_config;
  END IF;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**One function, two consumers.** FairSlice pies resolve `Core defaults → Instance override → Pie-specific`. Registry artifacts resolve `Core → Instance → Client`. Same cascade. Same semantics. Same function.

---

## 5. RLS Convergence

Both FairSlice and the broader PFC platform need the same RLS patterns:

| Pattern | FairSlice | PFC Platform | Same Policy? |
|---------|-----------|-------------|-------------|
| Tenant isolation | `auth.uid() IN pie_members(pie_id)` | `auth.uid() IN graph_tenants(tenant_id)` | YES |
| Agency access | `auth.uid() IN partners → referrals → pies` | `auth.uid() IN instances → scoped_tenants` | YES (scope chain) |
| Admin override | `auth.uid() IN platform_admins` | `auth.uid() IN pfc_admins` | YES |
| Audit immutability | No UPDATE/DELETE on audit_logs | No UPDATE/DELETE on grc_audit_trail | YES |

---

## 6. Entity Count Convergence

| Domain | FairSlice Tables | PFC Graph Tables | Converged |
|--------|:----------------:|:----------------:|:---------:|
| Tenants | pies (1) | graph_tenants (1) | 1 |
| Members | pie_members (1) | graph_nodes (1) | 1 |
| Contributions | slices, claims (2) | graph_nodes (1) | 1-2 |
| Waterfall | waterfall_rules, revenue_events, distributions (3) | graph_edges + graph_nodes (2) | 2 |
| Smart Contracts | smart_contracts, licenses (2) | pfc_registry (1) | 1 |
| Partners | partners, referrals, commission_rules, partner_payouts (4) | graph_nodes + graph_edges (2) | 2 |
| Audit | audit_logs, ledger_transactions (2) | grc_audit_trail (1) | 1 |
| **Total** | **16 tables** | **~8 tables** | **~9 tables** |

**Epic 34 target (OBJ-IP3):** Consolidate to <= 24 tables. FairSlice at 16 tables is within budget. Converged approach at ~9 tables leaves room for other domains.

---

## 7. Migration Path

```
Phase 1 (Now): FairSlice Tables with Graph-Compatible JSONB
  - Build pies, pie_members, slices, claims, waterfall_rules, etc.
  - Use JSONB ontology_config with cascade resolution
  - Smart contracts as pfc_registry rows from day one
  - Audit logs follow GRC-FW pattern from day one

Phase 2 (Month 3-6): Graph Abstraction Layer
  - Create graph_nodes and graph_edges views over FairSlice tables
  - Build graph query functions (traversals, shortest path, subgraph)
  - Validate that waterfall processing = graph traversal

Phase 3 (Month 6-12): Full Graph Convergence
  - Migrate domain tables into graph_nodes + graph_edges
  - Add Neo4j sync for complex graph queries
  - All PFC domains (VE, PE, GRC, FairSlice) share same graph tables
```

---

## 8. Summary: What Building FairSlice Proves

| Epic 34 Requirement | FairSlice Proves It |
|--------------------|--------------------|
| **F34.5: JSONB Graph Storage PoC** | `pies.ontology_config` = JSONB business rules in Postgres |
| **S1: Graph-First Architecture** | Waterfall traversal = graph traversal. Members, edges, priorities. |
| **S2: VE-Driven Everything** | Waterfall rules trace to VSOM strategies (JP-FS-005) |
| **S3: Agentic Orchestration** | AI Judge = Agent Template v6.0.0 claim verification |
| **S4: Instance Customisation** | Pie inherits PFI instance config via quasi-OO cascade |
| **S5: UI/UX Pipeline** | Agency dashboard = Next.js + shadcn/ui Figma Make target |
| **S6: Integration** | Stripe Connect = external integration pattern |
| **OBJ-IP3: <= 24 tables** | 16 domain tables, converging to ~9 in graph phase |
| **OBJ-SH2: 10+ partners** | Full partner/agency/affiliate model with attribution |
| **OBJ-F4: GBP 100K partner revenue** | Revenue waterfall with automated partner payouts |

**FairSlice is not a separate product. It is the first full implementation of the PFC graph architecture.** Every pattern it proves (JSONB config, cascade resolution, RLS isolation, audit trail, graph traversal) transfers directly to VE, PE, GRC, and every other PFC domain.

---

*Schema Convergence Map v1.0.0 — FairSlice as PFC JSONB Graph PoC*

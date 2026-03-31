# PFI-WWG-ARCH-Database-Integration-v2.0.0

**Version:** 2.0.0 | **Status:** Verified | **Date:** 1 April 2026
**Instance:** pfi-w4m-wwg | **Product:** LSC (Logistics Supply Chain)
**Supabase Project:** pfc-pfi (`jhlugiprdwgzshxctbdj`) — ajrmooreuk's Org
**Migration:** [20260401120000_wwg_v2_ontology_instances.sql](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/supabase/migrations/20260401120000_wwg_v2_ontology_instances.sql)
**Supersedes:** [v1.0.0](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/docs/PFI-WWG-ARCH-Database-Integration-v1.0.0.md) (33 flattened tables)

---

## 1. Overview

Ontology-driven database architecture for the W4M-WWG LSC product. Replaces 18 flattened domain tables with 4 JSONB instance tables following the OAA v7 pattern proven by `farsight_threads` and `uacl_execution_records` in the PFC web app.

**Key design principle:** Store ontology instance documents as JSONB, conforming to LSC-ONT, OFM-ONT, and SOP-ONT entity schemas. Extract columns only for querying (entity_type, entity_status, parent_ref). PE-ONT process governance, FUNC-ONT C-Suite domain mapping, and RRR-ONT RACI/RBAC are embedded in every instance document.

---

## 2. Schema Architecture — 16 Tables

| Group | Tables | Purpose |
|-------|--------|---------|
| Ontology Instances | 4 | `wwg_lsc_instances`, `wwg_ofm_instances`, `wwg_sop_instances`, `wwg_parties` |
| Foundation | 1 | `wwg_db_config` |
| Financial Reference | 1 | `wwg_fx_rates` |
| Creditors & Insurance | 2 | `wwg_creditor_accounts`, `wwg_insurance_profiles` |
| RAID + RMF | 3 | `wwg_raid_log`, `wwg_rmf_assessments`, `wwg_rmf_controls` |
| 4Voices Analytics | 1 | `wwg_insights` |
| Intelligence | 2 | `wwg_cast_interactions`, `wwg_farsight_threads` |
| Audit & Control | 2 | `wwg_audit_log`, `wwg_control_checks` |

### v1.0.0 → v2.0.0 Reduction

| | v1.0.0 | v2.0.0 |
|---|---|---|
| Domain tables (flattened columns) | 18 | 0 |
| Ontology instance tables (JSONB) | 0 | 4 |
| Operational tables | 15 | 12 |
| **Total** | **33** | **16** |

---

## 3. Ontology Instance Table Pattern

All 4 instance tables share the same structure:

```sql
CREATE TABLE wwg_{ont}_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id TEXT NOT NULL UNIQUE,    -- @id from JSONLD
  entity_type TEXT NOT NULL,           -- @type (e.g. "lsc:Shipment")
  pfi_instance TEXT NOT NULL,          -- RLS partition key
  instance_data JSONB NOT NULL,        -- Full OAA v7 entity document
  entity_status TEXT,                  -- Extracted for WHERE clauses
  parent_ref TEXT,                     -- FK-like parent entity @id
  ont_version TEXT NOT NULL,           -- Ontology version conformance
  created_at / updated_at / origin_db  -- Standard PFC columns
);

CREATE INDEX ... USING GIN (instance_data);  -- JSONB containment queries
```

---

## 4. Instance Table Contents

### wwg_lsc_instances (LSC-ONT v1.2.0)

| Entity Type | Count | Source (v1.0.0) |
|-------------|-------|-----------------|
| lsc:SupplyChain | 2 | wwg_corridors |
| lsc:ChainNode | 7 | wwg_ports |
| lsc:Shipment | 12 | wwg_shipments |
| lsc:ShipmentLeg | 28 | wwg_voyage_events |
| lsc:Incident | 6 | wwg_risk_events |
| lsc:ComplianceGate | 12 | wwg_compliance_gates |
| lsc:ColdChainEvent | 10 | wwg_cold_chain_readings |
| lsc:RiskAssessment | 10 | wwg_alerts |
| lsc:ImpactAssessment | 12 | wwg_impact_assessments |
| **Total** | **99** | |

### wwg_ofm_instances (OFM-ONT v1.1.0)

| Entity Type | Count | Source (v1.0.0) |
|-------------|-------|-----------------|
| ofm:SalesOrder | 12 | wwg_orders + wwg_order_lines (embedded) |
| ofm:LandedCost | 12 | wwg_landed_costs |
| ofm:MarginAnalysis | 12 | wwg_margin_analysis |
| ofm:OrderMilestone | 18 | wwg_cashflow_events |
| ofm:CustomerSatisfaction | 8 | wwg_customer_satisfaction |
| ofm:CustomerNotification | 8 | wwg_customer_notifications |
| ofm:ServiceLevelAgreement | 6 | wwg_sla_tracking |
| **Total** | **76** | |

### wwg_parties (LSC-ONT + RRR-ONT)

| Party Type | Count | Source (v1.0.0) |
|------------|-------|-----------------|
| carrier | 7 | wwg_carriers (with embedded vessels) |
| supplier | 5 | wwg_suppliers |
| customer | 6 | wwg_customers |
| product | 12 | wwg_products |
| **Total** | **30** | |

### wwg_sop_instances (SOP-ONT v1.0.0)

Empty — ready for sales order processing data.

---

## 5. Ontology Governance Embedded in JSONB

Every instance document includes PE-ONT, FUNC-ONT, and RRR-ONT governance:

### PE-ONT (Process Governance)

```json
{ "pe:governedBy": "pe:process-lsc-shipment-tracking", "pe:processType": "operational" }
```

### FUNC-ONT (C-Suite Domain Mapping)

```json
{
  "servesFunction": [
    { "func:domainCode": "COO", "func:accountability": "Supply chain execution" },
    { "func:domainCode": "CFO", "func:accountability": "Landed cost management" }
  ]
}
```

### RRR-ONT (Roles, RACI, RBAC)

```json
{
  "raciBinding": {
    "responsible": { "@type": "pf:FunctionalRole", "roleTitle": "Operations Manager" },
    "accountable": { "@type": "pf:ExecutiveRole", "func:domainCode": "COO" },
    "consulted": ["Finance Manager", "Risk Officer"],
    "informed": ["CRO", "Customer"]
  },
  "rbacAccess": {
    "read": ["trader", "admin", "pf-owner"],
    "write": ["admin", "pf-owner"],
    "delete": ["pf-owner"]
  }
}
```

---

## 6. Value Chain Query (JSONB)

```sql
SELECT
  s.instance_data->>'shipmentId' AS container,
  s.instance_data->>'scenario' AS scenario,
  (s.instance_data->>'delayDays')::int AS delay,
  ia.instance_data->'financialImpact'->>'totalImpactGbp' AS total_impact,
  m.instance_data->'actual'->>'marginPct' AS actual_margin,
  c.instance_data->'scores'->>'overall' AS csat
FROM wwg_lsc_instances s
LEFT JOIN wwg_lsc_instances ia ON ia.parent_ref = s.instance_id
  AND ia.entity_type = 'lsc:ImpactAssessment'
LEFT JOIN wwg_ofm_instances m ON m.parent_ref = s.instance_id
  AND m.entity_type = 'ofm:MarginAnalysis'
LEFT JOIN wwg_ofm_instances c ON c.parent_ref = s.instance_id
  AND c.entity_type = 'ofm:CustomerSatisfaction'
WHERE s.entity_type = 'lsc:Shipment'
ORDER BY (ia.instance_data->'financialImpact'->>'totalImpactGbp')::numeric DESC;
```

---

## 7. Cross-Ontology Relationships

Entity references use `@id` pointers within JSONB — no SQL foreign keys needed:

```
lsc:Shipment.carrier → @id: "lsc:party-MAERSK" (wwg_parties)
lsc:Shipment.origin → @id: "lsc:node-AUMEL" (wwg_lsc_instances, entity_type=lsc:ChainNode)
ofm:SalesOrder.shipmentRef → @id: "lsc:shipment-MRKU4821073" (wwg_lsc_instances)
ofm:SalesOrder.customerRef → @id: "lsc:party-CUST-A" (wwg_parties)
```

The `parent_ref` extracted column enables efficient joins without JSONB parsing.

---

## 8. Migration History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0-wwg-mvp | 2026-03-31 | Initial — 33 flattened tables, ~340 rows |
| 2.0.0-wwg-ont | 2026-04-01 | Ontology-driven — 16 tables, ~205 JSONB instances + 30 parties |

---

## 9. Links

- **Repo:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev
- **v2.0.0 Migration:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/supabase/migrations/20260401120000_wwg_v2_ontology_instances.sql
- **v1.0.0 Migration:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/supabase/migrations/20260331233000_wwg_schema_and_seed.sql
- **Supabase Dashboard:** https://supabase.com/dashboard/project/jhlugiprdwgzshxctbdj/editor
- **LSC-ONT v1.2.0:** https://github.com/ajrmooreuk/Azlan-EA-AAA/blob/main/PBS/ONTOLOGIES/ontology-library/PE-Series/LSC-ONT/lsc-ontology-v1.2.0-oaa-v7.json
- **OFM-ONT v1.1.0:** https://github.com/ajrmooreuk/Azlan-EA-AAA/blob/main/PBS/ONTOLOGIES/ontology-library/PE-Series/OFM-ONT/ofm-ontology-v1.1.0-oaa-v7.json
- **Epic 90:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/39

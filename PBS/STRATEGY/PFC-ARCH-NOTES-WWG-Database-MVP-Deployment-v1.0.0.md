# PFC-ARCH-NOTES-WWG-Database-MVP-Deployment-v1.0.0

> **Product Code:** PFC-ARCH
> **Doc Type:** NOTES (Architecture Technical Notes — Deployment Runbook)
> **Version:** 1.0.0
> **Status:** Active
> **Date:** 2026-03-31
> **PFI Instance:** W4M-WWG (World Wide Gourmet)
> **Epic Ref:** [Epic 90 (#39)](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/39) — LSC Live Integration
> **Cross-ref:** [PFI-WWG-ARCH-Database-Integration-v1.0.0.md](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/docs/PFI-WWG-ARCH-Database-Integration-v1.0.0.md), [PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md](https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/PBS/STRATEGY/PFC-ARCH-PLAN-W4M-WWG-LSC-Integration-Epic-Plan-v1.0.0.md)
> **Cascade Target:** PFI-W4M-WWG → `PBS/STRATEGY/`

---

## 1. Purpose

Step-by-step deployment runbook for the W4M-WWG LSC Database MVP — 33 tables, ~340 rows of anonymised seed data, covering the full logistics value chain from shipment tracking through financial impact assessment to customer satisfaction.

This runbook is designed for the on-site demo on **1 April 2026** and covers:
- Supabase deployment
- Data verification
- Demo query walkthrough
- Connecting the LSC Shipping App
- Converting current schedule data to anonymised test data
- Rollback procedure

---

## 2. Pre-Requisites

| Requirement | Status | Detail |
|-------------|--------|--------|
| Supabase project access | Ready | `pfc-pfi` project (`jhlugiprdwgzshxctbdj`) — ajrmooreuk's Org |
| Migration file | Ready | `supabase/migrations/001_wwg_schema_and_seed.sql` |
| Architecture doc | Ready | `docs/PFI-WWG-ARCH-Database-Integration-v1.0.0.md` |
| LSC Shipping App | Live | https://ajrmooreuk.github.io/pfi-w4m-wwg-dev/PBS/LSC-DEMOS/lsc-shipping-tracker.html |
| EOMS tables (existing) | Deployed | 11 `eoms_` tables already in same Supabase project — no conflict |

---

## 3. Deployment Steps

### Step 1: Initialise & Link Supabase CLI

```bash
cd /Users/amandamoore/pfi-w4m-wwg-dev
supabase init                                        # creates supabase/config.toml
supabase link --project-ref jhlugiprdwgzshxctbdj     # links to pfc-pfi remote project
```

### Step 2: Check Migration Status

```bash
supabase migration list
```

If EOMS migrations (001-010) show as remote-only, mark them as reverted so they don't block our push:

```bash
supabase migration repair --status reverted 001 002 005 006 007 008 009 010
```

### Step 3: Deploy to Supabase

```bash
supabase db push
```

Confirms: `Applying migration 20260331233000_wwg_schema_and_seed.sql... Finished supabase db push.`

**DEPLOYED 2026-03-31** via Supabase CLI `v2.84.2` — no manual SQL pasting required.

### Step 4: Verify Table Count

Run in SQL Editor:
```sql
SELECT count(*)
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'wwg_%';
```
**Expected result:** `33`

### Step 5: Verify Seed Data

Run in SQL Editor:
```sql
SELECT 'wwg_shipments' AS t, count(*) FROM wwg_shipments
UNION ALL SELECT 'wwg_orders', count(*) FROM wwg_orders
UNION ALL SELECT 'wwg_impact_assessments', count(*) FROM wwg_impact_assessments
UNION ALL SELECT 'wwg_margin_analysis', count(*) FROM wwg_margin_analysis
UNION ALL SELECT 'wwg_customer_satisfaction', count(*) FROM wwg_customer_satisfaction
UNION ALL SELECT 'wwg_raid_log', count(*) FROM wwg_raid_log
UNION ALL SELECT 'wwg_creditor_accounts', count(*) FROM wwg_creditor_accounts
UNION ALL SELECT 'wwg_insurance_profiles', count(*) FROM wwg_insurance_profiles
UNION ALL SELECT 'wwg_insights', count(*) FROM wwg_insights
UNION ALL SELECT 'wwg_control_checks', count(*) FROM wwg_control_checks
UNION ALL SELECT 'wwg_audit_log', count(*) FROM wwg_audit_log
ORDER BY t;
```

**Expected results:**

| Table | Rows |
|-------|------|
| wwg_audit_log | 12 |
| wwg_control_checks | 10 |
| wwg_creditor_accounts | 10 |
| wwg_customer_satisfaction | 8 |
| wwg_impact_assessments | 12 |
| wwg_insights | 12 |
| wwg_insurance_profiles | 12 |
| wwg_margin_analysis | 12 |
| wwg_orders | 12 |
| wwg_raid_log | 16 |
| wwg_shipments | 12 |

### Step 6: Verify the Value Chain Query

This is the **demo money shot** — the single query that shows the full cause-effect chain:

```sql
SELECT
  s.container_id,
  s.scenario,
  s.current_delay_days AS delay,
  ia.risk_severity AS risk,
  ia.spoilage_cost_gbp AS spoilage,
  ia.demurrage_cost_gbp AS demurrage,
  ia.sla_penalty_gbp AS penalty,
  ia.total_impact_gbp AS total_impact,
  ma.planned_margin_pct,
  ma.actual_margin_pct,
  ma.margin_erosion_gbp,
  ma.erosion_cause,
  cs.overall_score AS csat,
  cs.repeat_business_probability AS repeat_prob,
  ip.insured,
  ip.claim_status,
  ca.entity_name AS creditor,
  ca.blocked AS creditor_blocked
FROM wwg_shipments s
LEFT JOIN wwg_impact_assessments ia ON ia.shipment_id = s.id
LEFT JOIN wwg_margin_analysis ma ON ma.shipment_id = s.id
LEFT JOIN wwg_customer_satisfaction cs ON cs.shipment_id = s.id
LEFT JOIN wwg_insurance_profiles ip ON ip.shipment_id = s.id
LEFT JOIN wwg_suppliers sup ON sup.id = s.supplier_id
LEFT JOIN wwg_creditor_accounts ca ON ca.entity_ref = sup.supplier_code
ORDER BY ia.total_impact_gbp DESC NULLS LAST;
```

**Expected: 12 rows showing the full spectrum from CRITICAL (HLXU9901234, £34.8k impact, CSAT 2.5) to BENEFIT (EVRU8821100, £0, CSAT 9.5).**

### Step 7: Verify RAID Log

```sql
SELECT raid_type, raid_id, title, severity, status
FROM wwg_raid_log
ORDER BY raid_type, raid_id;
```

**Expected: 16 entries (4 risks, 4 assumptions, 3 issues, 3 dependencies, 2 requirements).**

### Step 8: Verify Control Checks

```sql
SELECT check_id, check_name, category, status
FROM wwg_control_checks
ORDER BY check_id;
```

**Expected: 10 entries (CC-001 to CC-010). 4 PASS, 5 WARNING, 1 FAIL.**

### Step 9: Verify 4Voices Insights

```sql
SELECT perspective, insight_category, title, confidence, predicted_impact_gbp
FROM wwg_insights
ORDER BY perspective, insight_category;
```

**Expected: 12 entries across 4 perspectives (macro, industry, corridor, operational).**

---

## 4. Connecting the LSC Shipping App (Next Phase)

Following the EOMS dual-mode pattern:

### Step 4.1: Install Supabase Client

```bash
cd /Users/amandamoore/pfi-w4m-wwg-dev
npm install @supabase/supabase-js
```

### Step 4.2: Create Supabase Client Config

Create `instance-data/config/supabase.ts`:
```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://jhlugiprdwgzshxctbdj.supabase.co';
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseKey);
```

### Step 4.3: Environment Toggle

Add to `.env.local`:
```
NEXT_PUBLIC_DATA_SOURCE=supabase
NEXT_PUBLIC_SUPABASE_URL=https://jhlugiprdwgzshxctbdj.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
```

### Step 4.4: Data Store Pattern (Dual-Mode)

Same pattern as EOMS `order-store.ts` — each function checks `NEXT_PUBLIC_DATA_SOURCE`:
- `supabase` → async fetch from Supabase
- `local` → sync read from localStorage/hardcoded JS

**No component changes needed** — same function signatures.

---

## 5. Converting Current Schedule Data for Demo

### Step 5.1: Prepare Current Schedule

1. Export the current operational schedule (spreadsheet/CSV) with these fields:
   - Container ID, carrier, vessel, voyage, origin, destination
   - Product, type (frozen/chilled/fresh), weight
   - Departure date, ETA
   - Customer, supplier

### Step 5.2: Anonymise

Replace real values with demo equivalents:

| Real Field | Anonymised |
|-----------|------------|
| Customer names | CUST-A through CUST-F (Alpha, Bravo, Charlie...) |
| Supplier names | SUP-AU-001 through SUP-AU-005 |
| Container IDs | Keep format (4 letters + 7 digits) but randomise |
| Order numbers | ORD-2026-NNN sequential |
| Financial values | Scale by random factor (0.8-1.2x) |
| Dates | Keep relative spacing, shift to demo window |

### Step 5.3: Generate INSERT Statements

Use the seed data in `001_wwg_schema_and_seed.sql` as the template. Replace container definitions with anonymised real schedule data. The CTE pattern (WITH clauses) handles FK resolution automatically.

### Step 5.4: Deploy Updated Data

1. Run rollback (Step 10) to clear existing seed data
2. Re-run modified migration with real anonymised data
3. Re-verify with Steps 4-9

---

## 6. Demo Walkthrough (On-Site)

### Opening: The Problem

> "Every delayed shipment costs money. But how much? And where does the cost come from?"

### Demo Flow (15 minutes)

| Step | What to Show | Where | Key Message |
|------|-------------|-------|-------------|
| 1 | LSC Shipping Tracker | GitHub Pages | "12 containers, real-time simulation. 7 delayed, 2 clean, 1 early." |
| 2 | Container HLXU9901234 | Tracker → click | "Temp breach: 2.8C deviation for 24hrs. Chilled beef — shelf life CRITICAL." |
| 3 | Value Chain Query | Supabase SQL | "One query shows the FULL picture: event → cost → margin → satisfaction." |
| 4 | HLXU9901234 row | Query results | "£34.8k impact. Margin: 18% planned → -14% actual. CSAT: 2.5. Insurance claim submitted." |
| 5 | MRKU7734901 row | Query results | "Contrast: on-time, zero impact, CSAT 9.2. This is what good looks like." |
| 6 | CSNU2234567 row | Query results | "UNINSURED. £12.75k exposure. Fresh lamb, Hormuz divert. Full risk on margin." |
| 7 | Creditor Analysis | Supabase Table Editor | "Supplier blocked at £42k overdue. Backlog offer: 3 instalments. Supply chain at risk." |
| 8 | Control Checks | Supabase → wwg_control_checks | "10 automated checks. 4 PASS, 5 WARNING, 1 FAIL. SLA compliance: 25%." |
| 9 | 4Voices Insights | Supabase → wwg_insights | "Macro: Red Sea structural shift. Industry: cold-chain premium opportunity. Operational: Customer C churn risk." |
| 10 | RAID Log | Supabase → wwg_raid_log | "16 items tracked. R-004: uninsured shipment accepted risk. I-001: temp breach escalated." |

### Closing: The Value

> "One database. Every perspective — operational, financial, customer, risk. From container to cashflow. The question isn't 'did we deliver?' — it's 'at what cost, and what did we learn?'"

---

## 7. RAID Items (Database Deployment)

### New Risks

| ID | Title | Severity | Status | Mitigation |
|----|-------|----------|--------|------------|
| R-DB-001 | Supabase shared project — EOMS and WWG tables coexist | MEDIUM | Accepted | Namespace isolation via `wwg_` prefix. No FK cross-references between EOMS and WWG. |
| R-DB-002 | Demo data not representative of real schedule | MEDIUM | Open | Convert current schedule to anonymised test data before on-site (Step 5) |
| R-DB-003 | Data residency — Stockholm not UK | HIGH | Open | RMF-003 assessment created. Column-level encryption planned. See control check CC-009. |

### New Assumptions

| ID | Title | Status |
|----|-------|--------|
| A-DB-001 | Supabase anon key sufficient for demo (no auth required) | Open |
| A-DB-002 | Team approves table structure and seed data format | Open |
| A-DB-003 | Existing EOMS tables unaffected by WWG deployment | Accepted |

### New Dependencies

| ID | Title | Status |
|----|-------|--------|
| D-DB-001 | Supabase dashboard access on-site (internet required) | Open |
| D-DB-002 | Current schedule data available for anonymisation | Open |

---

## 8. Task Checklist

### Pre-Demo (31 March — Today)

- [x] Migration file created (`001_wwg_schema_and_seed.sql`)
- [x] Architecture doc created (`PFI-WWG-ARCH-Database-Integration-v1.0.0.md`)
- [x] Status report updated (`WWG-Product-Status-Report-2026-03-31.md`)
- [x] ARCH NOTES deployment runbook created (this document)
- [ ] Deploy migration to Supabase (Step 3)
- [ ] Verify table count = 33 (Step 4)
- [ ] Verify seed data counts (Step 5)
- [ ] Run value chain query (Step 6)
- [ ] Run RAID/control/insights verification (Steps 7-9)

### On-Site (1 April)

- [ ] Convert current schedule to anonymised test data (Step 5)
- [ ] Re-deploy with anonymised real data
- [ ] Walk through demo flow (Section 6)
- [ ] Capture team feedback on table structure and data format
- [ ] Record decisions on process and format approval

### Post-Demo

- [ ] Connect LSC Shipping App to Supabase (Section 4)
- [ ] Implement dual-mode data layer
- [ ] Create GitHub issue for database integration feature
- [ ] Update Epic 90 with database milestone

---

## 9. Rollback Procedure

If needed, drop all WWG tables and re-deploy:

```sql
-- Drop all WWG tables (reverse dependency order)
DROP TABLE IF EXISTS wwg_control_checks CASCADE;
DROP TABLE IF EXISTS wwg_audit_log CASCADE;
DROP TABLE IF EXISTS wwg_farsight_threads CASCADE;
DROP TABLE IF EXISTS wwg_cast_interactions CASCADE;
DROP TABLE IF EXISTS wwg_insights CASCADE;
DROP TABLE IF EXISTS wwg_rmf_controls CASCADE;
DROP TABLE IF EXISTS wwg_rmf_assessments CASCADE;
DROP TABLE IF EXISTS wwg_raid_log CASCADE;
DROP TABLE IF EXISTS wwg_sla_tracking CASCADE;
DROP TABLE IF EXISTS wwg_customer_satisfaction CASCADE;
DROP TABLE IF EXISTS wwg_customer_notifications CASCADE;
DROP TABLE IF EXISTS wwg_insurance_profiles CASCADE;
DROP TABLE IF EXISTS wwg_creditor_accounts CASCADE;
DROP TABLE IF EXISTS wwg_cashflow_events CASCADE;
DROP TABLE IF EXISTS wwg_margin_analysis CASCADE;
DROP TABLE IF EXISTS wwg_impact_assessments CASCADE;
DROP TABLE IF EXISTS wwg_landed_costs CASCADE;
DROP TABLE IF EXISTS wwg_fx_rates CASCADE;
DROP TABLE IF EXISTS wwg_order_lines CASCADE;
DROP TABLE IF EXISTS wwg_orders CASCADE;
DROP TABLE IF EXISTS wwg_alerts CASCADE;
DROP TABLE IF EXISTS wwg_cold_chain_readings CASCADE;
DROP TABLE IF EXISTS wwg_compliance_gates CASCADE;
DROP TABLE IF EXISTS wwg_risk_events CASCADE;
DROP TABLE IF EXISTS wwg_voyage_events CASCADE;
DROP TABLE IF EXISTS wwg_shipments CASCADE;
DROP TABLE IF EXISTS wwg_suppliers CASCADE;
DROP TABLE IF EXISTS wwg_customers CASCADE;
DROP TABLE IF EXISTS wwg_products CASCADE;
DROP TABLE IF EXISTS wwg_ports CASCADE;
DROP TABLE IF EXISTS wwg_vessels CASCADE;
DROP TABLE IF EXISTS wwg_carriers CASCADE;
DROP TABLE IF EXISTS wwg_corridors CASCADE;
DROP TABLE IF EXISTS wwg_db_config CASCADE;

-- Drop WWG-specific function (keep set_updated_at — shared with EOMS)
DROP FUNCTION IF EXISTS wwg_audit_trigger() CASCADE;
```

Then re-run `001_wwg_schema_and_seed.sql` from Step 3.

---

## 10. Links

- **Migration SQL:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/supabase/migrations/001_wwg_schema_and_seed.sql
- **Architecture Doc:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/docs/PFI-WWG-ARCH-Database-Integration-v1.0.0.md
- **Supabase SQL Editor:** https://supabase.com/dashboard/project/jhlugiprdwgzshxctbdj/sql/new
- **Supabase Table Editor:** https://supabase.com/dashboard/project/jhlugiprdwgzshxctbdj/editor
- **LSC Tracker (live):** https://ajrmooreuk.github.io/pfi-w4m-wwg-dev/PBS/LSC-DEMOS/lsc-shipping-tracker.html
- **Epic 90:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/issues/39
- **Status Report:** https://github.com/ajrmooreuk/pfi-w4m-wwg-dev/blob/main/docs/WWG-Product-Status-Report-2026-03-31.md

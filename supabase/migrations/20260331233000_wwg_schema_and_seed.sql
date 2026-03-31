-- ============================================================
-- WWG Database Integration — MVP Schema + Seed Data
-- Migration 001: Full schema creation + seed data loading
-- Date: 2026-03-31
-- Project: pfc-pfi (jhlugiprdwgzshxctbdj)
-- Instance: pfi-w4m-wwg
-- Tables: 33 across 10 groups
-- Ontologies: LSC-ONT, OFM-ONT, SOP-ONT, RAID-ONT, RMF-IS27005-ONT
-- ============================================================

-- ============================================================
-- PART 1: FOUNDATION
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- WWG DB Config (singleton)
CREATE TABLE IF NOT EXISTS wwg_db_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schema_version TEXT NOT NULL DEFAULT '1.0.0-wwg-mvp',
  instance_id TEXT NOT NULL DEFAULT 'pfi-w4m-wwg',
  origin_db TEXT NOT NULL DEFAULT 'wwg-dev',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER wwg_db_config_updated_at
  BEFORE UPDATE ON wwg_db_config
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

INSERT INTO wwg_db_config (schema_version, instance_id, origin_db)
VALUES ('1.0.0-wwg-mvp', 'pfi-w4m-wwg', 'wwg-dev');

-- ============================================================
-- PART 2: REFERENCE TABLES (Group 2)
-- ============================================================

-- 2.1 Corridors
CREATE TABLE wwg_corridors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  corridor_code TEXT NOT NULL UNIQUE,
  origin_country TEXT NOT NULL DEFAULT 'AU',
  dest_country TEXT NOT NULL DEFAULT 'UK',
  route_type TEXT NOT NULL CHECK (route_type IN ('CAPE','SUEZ')),
  base_transit_days INTEGER NOT NULL,
  distance_nm INTEGER,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_corridors_updated_at
  BEFORE UPDATE ON wwg_corridors
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2.2 Carriers
CREATE TABLE wwg_carriers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  carrier_code TEXT NOT NULL UNIQUE,
  carrier_name TEXT NOT NULL,
  alliance TEXT CHECK (alliance IN ('2M','Ocean Alliance','THE Alliance','Independent')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_carriers_updated_at
  BEFORE UPDATE ON wwg_carriers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2.3 Vessels
CREATE TABLE wwg_vessels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  carrier_id UUID NOT NULL REFERENCES wwg_carriers(id),
  vessel_name TEXT NOT NULL,
  imo_number TEXT UNIQUE,
  mmsi TEXT,
  vessel_type TEXT NOT NULL DEFAULT 'container' CHECK (vessel_type IN ('container','reefer','general')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_vessels_updated_at
  BEFORE UPDATE ON wwg_vessels
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2.4 Ports
CREATE TABLE wwg_ports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  port_code TEXT NOT NULL UNIQUE,
  port_name TEXT NOT NULL,
  country TEXT NOT NULL,
  lat NUMERIC(9,6),
  lon NUMERIC(9,6),
  port_type TEXT NOT NULL CHECK (port_type IN ('origin','destination','waypoint','both')),
  is_bcp BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_ports_updated_at
  BEFORE UPDATE ON wwg_ports
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2.5 Products
CREATE TABLE wwg_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_code TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL,
  cold_chain_type TEXT NOT NULL CHECK (cold_chain_type IN ('frozen','chilled','fresh')),
  set_point_temp NUMERIC(5,2) NOT NULL,
  shelf_life_days INTEGER NOT NULL,
  temp_sensitivity NUMERIC(4,2) NOT NULL,
  species TEXT NOT NULL CHECK (species IN ('beef','lamb','goat','veal','mixed')),
  halal_certified BOOLEAN NOT NULL DEFAULT false,
  feed_type TEXT CHECK (feed_type IN ('grass_fed','grain_fed','mixed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_products_updated_at
  BEFORE UPDATE ON wwg_products
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2.6 Customers
CREATE TABLE wwg_customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_code TEXT NOT NULL UNIQUE,
  customer_name TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'UK',
  delivery_port TEXT,
  account_tier TEXT NOT NULL CHECK (account_tier IN ('strategic','key','standard','prospect')),
  sla_on_time_pct NUMERIC(5,2) DEFAULT 95.00,
  sla_temp_compliance_pct NUMERIC(5,2) DEFAULT 100.00,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_customers_updated_at
  BEFORE UPDATE ON wwg_customers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 2.7 Suppliers
CREATE TABLE wwg_suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_code TEXT NOT NULL UNIQUE,
  supplier_name TEXT NOT NULL,
  establishment_number TEXT NOT NULL,
  state TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'AU',
  halal_approved BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_suppliers_updated_at
  BEFORE UPDATE ON wwg_suppliers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- PART 3: OPERATIONAL TABLES (Group 3)
-- ============================================================

-- 3.1 Shipments (THE core transactional entity)
CREATE TABLE wwg_shipments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  container_id TEXT NOT NULL UNIQUE,
  carrier_id UUID NOT NULL REFERENCES wwg_carriers(id),
  vessel_id UUID REFERENCES wwg_vessels(id),
  voyage_number TEXT NOT NULL,
  origin_port_id UUID NOT NULL REFERENCES wwg_ports(id),
  dest_port_id UUID NOT NULL REFERENCES wwg_ports(id),
  corridor_id UUID REFERENCES wwg_corridors(id),
  product_id UUID NOT NULL REFERENCES wwg_products(id),
  supplier_id UUID REFERENCES wwg_suppliers(id),
  customer_id UUID REFERENCES wwg_customers(id),
  departure_date DATE NOT NULL,
  base_transit_days INTEGER NOT NULL,
  planned_route TEXT NOT NULL CHECK (planned_route IN ('CAPE','SUEZ')),
  current_route TEXT NOT NULL CHECK (current_route IN ('CAPE','SUEZ')),
  scenario TEXT NOT NULL CHECK (scenario IN ('NORMAL','CAPE_REROUTE','SUEZ_THEN_CAPE','TEMP_BREACH','WEATHER_DELAY','HORMUZ_DIVERT','ROUTE_CHANGE','SLOW_STEAM','CEASEFIRE_BENEFIT')),
  current_status TEXT NOT NULL DEFAULT 'booked' CHECK (current_status IN ('booked','loaded','at_sea','at_sea_alert','port_approach','discharged','btom_cleared','gate_out')),
  current_delay_days INTEGER NOT NULL DEFAULT 0,
  current_eta DATE,
  original_eta DATE,
  set_point_temp NUMERIC(5,2) NOT NULL,
  cold_chain_type TEXT NOT NULL CHECK (cold_chain_type IN ('frozen','chilled','fresh')),
  container_type TEXT NOT NULL DEFAULT '40ft Reefer',
  weight_kg NUMERIC(14,2),
  ont_ref TEXT DEFAULT 'LSC-ONT:Shipment',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_shipments_status ON wwg_shipments(current_status);
CREATE INDEX idx_wwg_shipments_carrier ON wwg_shipments(carrier_id);
CREATE INDEX idx_wwg_shipments_customer ON wwg_shipments(customer_id);
CREATE INDEX idx_wwg_shipments_departure ON wwg_shipments(departure_date);

CREATE TRIGGER wwg_shipments_updated_at
  BEFORE UPDATE ON wwg_shipments
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 3.2 Voyage Events (day-by-day tracking)
CREATE TABLE wwg_voyage_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id),
  event_date DATE NOT NULL,
  day_of_voyage INTEGER NOT NULL,
  status TEXT NOT NULL,
  route TEXT NOT NULL CHECK (route IN ('CAPE','SUEZ')),
  lat NUMERIC(9,6),
  lon NUMERIC(9,6),
  position_name TEXT,
  sog_knots NUMERIC(5,1),
  temp_celsius NUMERIC(5,2),
  temp_breach BOOLEAN NOT NULL DEFAULT false,
  risk_level TEXT NOT NULL DEFAULT 'LOW' CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  delay_days INTEGER NOT NULL DEFAULT 0,
  eta_date DATE,
  ais_gap BOOLEAN NOT NULL DEFAULT false,
  ont_ref TEXT DEFAULT 'LSC-ONT:ShipmentLeg',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-sim',
  UNIQUE (shipment_id, event_date)
);

CREATE INDEX idx_wwg_voyage_shipment_date ON wwg_voyage_events(shipment_id, event_date);

-- 3.3 Risk Events (geopolitical/weather/port)
CREATE TABLE wwg_risk_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_date DATE NOT NULL,
  event_type TEXT NOT NULL CHECK (event_type IN ('GEOPOLITICAL','PORT_CONGESTION','WEATHER','REGULATORY','CARRIER_DECISION')),
  zone TEXT NOT NULL,
  severity TEXT NOT NULL CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  title TEXT NOT NULL,
  detail TEXT,
  active_until DATE,
  ont_ref TEXT DEFAULT 'LSC-ONT:Incident',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_risk_events_date ON wwg_risk_events(event_date);
CREATE INDEX idx_wwg_risk_events_type ON wwg_risk_events(event_type);

CREATE TRIGGER wwg_risk_events_updated_at
  BEFORE UPDATE ON wwg_risk_events
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 3.4 Compliance Gates (BTOM/IPAFFS)
CREATE TABLE wwg_compliance_gates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id),
  gate_type TEXT NOT NULL CHECK (gate_type IN ('IPAFFS_PRE_NOTIFICATION','BTOM_DOC_CHECK','BCP_PHYSICAL_INSPECTION','CUSTOMS_CLEARANCE','VETERINARY_CHECK')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','due_now','submitted','passed','failed','waived')),
  deadline TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  bcp_port TEXT,
  notes TEXT,
  ont_ref TEXT DEFAULT 'LSC-ONT:ComplianceGate',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_compliance_shipment ON wwg_compliance_gates(shipment_id);

CREATE TRIGGER wwg_compliance_gates_updated_at
  BEFORE UPDATE ON wwg_compliance_gates
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 3.5 Cold Chain Readings
CREATE TABLE wwg_cold_chain_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id),
  reading_at TIMESTAMPTZ NOT NULL,
  supply_air_temp NUMERIC(5,2) NOT NULL,
  return_air_temp NUMERIC(5,2),
  set_point_temp NUMERIC(5,2) NOT NULL,
  deviation NUMERIC(5,2) NOT NULL DEFAULT 0,
  is_breach BOOLEAN NOT NULL DEFAULT false,
  shelf_life_remaining_days INTEGER,
  shelf_life_status TEXT CHECK (shelf_life_status IN ('HEALTHY','AT_RISK','CRITICAL')),
  ont_ref TEXT DEFAULT 'LSC-ONT:ColdChainEvent',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-iot'
);

CREATE INDEX idx_wwg_cold_chain_shipment ON wwg_cold_chain_readings(shipment_id);
CREATE INDEX idx_wwg_cold_chain_breach ON wwg_cold_chain_readings(shipment_id) WHERE is_breach = true;

-- 3.6 Alerts
CREATE TABLE wwg_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID REFERENCES wwg_shipments(id),
  risk_event_id UUID REFERENCES wwg_risk_events(id),
  alert_type TEXT NOT NULL CHECK (alert_type IN ('ROUTE_CHANGE','TEMP_BREACH','PORT_DELAY','WEATHER','GEOPOLITICAL','CARRIER_DECISION','ROUTE_RESTORED','AIS_GAP','COMPLIANCE','ETA_CHANGE')),
  severity TEXT NOT NULL CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  title TEXT NOT NULL,
  detail TEXT,
  alert_date DATE NOT NULL,
  acknowledged BOOLEAN NOT NULL DEFAULT false,
  acknowledged_by TEXT,
  acknowledged_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-engine'
);

CREATE INDEX idx_wwg_alerts_shipment ON wwg_alerts(shipment_id);
CREATE INDEX idx_wwg_alerts_severity ON wwg_alerts(severity);
CREATE INDEX idx_wwg_alerts_date ON wwg_alerts(alert_date);

-- ============================================================
-- PART 4: FINANCIAL IMPACT TABLES (Group 4)
-- ============================================================

-- 4.1 Orders
CREATE TABLE wwg_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT NOT NULL UNIQUE,
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id),
  customer_id UUID NOT NULL REFERENCES wwg_customers(id),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','confirmed','in_transit','delivered','completed','cancelled')),
  currency TEXT NOT NULL DEFAULT 'GBP',
  buy_currency TEXT NOT NULL DEFAULT 'AUD',
  sell_currency TEXT NOT NULL DEFAULT 'GBP',
  fx_rate_at_creation NUMERIC(18,8),
  incoterms TEXT NOT NULL DEFAULT 'CIF',
  total_value NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_quantity_kg NUMERIC(14,2) NOT NULL DEFAULT 0,
  delivery_window_start DATE,
  delivery_window_end DATE,
  ont_ref TEXT DEFAULT 'OFM-ONT:SalesOrder',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_orders_status ON wwg_orders(status);
CREATE INDEX idx_wwg_orders_customer ON wwg_orders(customer_id);
CREATE INDEX idx_wwg_orders_shipment ON wwg_orders(shipment_id);

CREATE TRIGGER wwg_orders_updated_at
  BEFORE UPDATE ON wwg_orders
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 4.2 Order Lines
CREATE TABLE wwg_order_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES wwg_orders(id) ON DELETE CASCADE,
  line_number INTEGER NOT NULL,
  product_id UUID NOT NULL REFERENCES wwg_products(id),
  description TEXT NOT NULL,
  quantity_kg NUMERIC(14,2) NOT NULL,
  buy_price_per_kg NUMERIC(14,4) NOT NULL,
  sell_price_per_kg NUMERIC(14,4) NOT NULL,
  line_buy_value NUMERIC(14,2) NOT NULL,
  line_sell_value NUMERIC(14,2) NOT NULL,
  planned_margin_pct NUMERIC(5,2),
  ont_ref TEXT DEFAULT 'OFM-ONT:OrderLine',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_order_lines_order ON wwg_order_lines(order_id);

CREATE TRIGGER wwg_order_lines_updated_at
  BEFORE UPDATE ON wwg_order_lines
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 4.3 FX Rates
CREATE TABLE wwg_fx_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  base_currency TEXT NOT NULL DEFAULT 'AUD',
  quote_currency TEXT NOT NULL,
  rate NUMERIC(18,8) NOT NULL,
  rate_type TEXT NOT NULL DEFAULT 'spot' CHECK (rate_type IN ('spot','contract','manual','average')),
  effective_date DATE NOT NULL,
  valid_until DATE,
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed',
  UNIQUE (base_currency, quote_currency, rate_type, effective_date)
);

CREATE TRIGGER wwg_fx_rates_updated_at
  BEFORE UPDATE ON wwg_fx_rates
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 4.4 Landed Costs
CREATE TABLE wwg_landed_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id) UNIQUE,
  order_id UUID REFERENCES wwg_orders(id),
  fob_value_aud NUMERIC(14,2) NOT NULL,
  freight_cost_usd NUMERIC(14,2) NOT NULL,
  insurance_cost_usd NUMERIC(14,2) NOT NULL DEFAULT 0,
  customs_duty_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  clearance_fees_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  cold_storage_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  last_mile_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  demurrage_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_landed_cost_gbp NUMERIC(14,2) NOT NULL,
  cost_per_kg_gbp NUMERIC(14,4),
  fx_rate_aud_gbp NUMERIC(18,8),
  fx_rate_usd_gbp NUMERIC(18,8),
  ont_ref TEXT DEFAULT 'OFM-ONT:LandedCost',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_landed_costs_updated_at
  BEFORE UPDATE ON wwg_landed_costs
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 4.5 Impact Assessments (QVF value chain)
CREATE TABLE wwg_impact_assessments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id),
  assessment_date DATE NOT NULL,
  risk_score NUMERIC(3,1) NOT NULL CHECK (risk_score >= 0 AND risk_score <= 10),
  risk_severity TEXT NOT NULL CHECK (risk_severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  delay_days INTEGER NOT NULL DEFAULT 0,
  spoilage_cost_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  demurrage_cost_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  sla_penalty_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_impact_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  risk_factors TEXT[],
  reasoning TEXT[],
  confidence NUMERIC(3,2) DEFAULT 0.85,
  ont_ref TEXT DEFAULT 'LSC-ONT:ImpactAssessment',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-engine'
);

CREATE INDEX idx_wwg_impact_shipment ON wwg_impact_assessments(shipment_id);
CREATE INDEX idx_wwg_impact_date ON wwg_impact_assessments(assessment_date);

-- 4.6 Margin Analysis
CREATE TABLE wwg_margin_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id),
  order_id UUID REFERENCES wwg_orders(id),
  planned_sell_value_gbp NUMERIC(14,2) NOT NULL,
  planned_cost_gbp NUMERIC(14,2) NOT NULL,
  planned_margin_gbp NUMERIC(14,2) NOT NULL,
  planned_margin_pct NUMERIC(5,2) NOT NULL,
  actual_sell_value_gbp NUMERIC(14,2),
  actual_cost_gbp NUMERIC(14,2),
  actual_margin_gbp NUMERIC(14,2),
  actual_margin_pct NUMERIC(5,2),
  margin_erosion_gbp NUMERIC(14,2) DEFAULT 0,
  margin_erosion_pct NUMERIC(5,2) DEFAULT 0,
  erosion_cause TEXT CHECK (erosion_cause IN ('none','delay','spoilage','fx','demurrage','penalty','combined')),
  ont_ref TEXT DEFAULT 'OFM-ONT:MarginAnalysis',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_margin_shipment ON wwg_margin_analysis(shipment_id);

CREATE TRIGGER wwg_margin_analysis_updated_at
  BEFORE UPDATE ON wwg_margin_analysis
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 4.7 Cashflow Events
CREATE TABLE wwg_cashflow_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES wwg_shipments(id),
  order_id UUID REFERENCES wwg_orders(id),
  event_type TEXT NOT NULL CHECK (event_type IN ('deposit','balance_payment','freight_payment','insurance_premium','customs_duty','clearance_fee','cold_storage','last_mile','demurrage','penalty','settlement','refund')),
  amount_gbp NUMERIC(14,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'GBP',
  direction TEXT NOT NULL CHECK (direction IN ('inflow','outflow')),
  due_date DATE NOT NULL,
  paid_date DATE,
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','due','paid','overdue','cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_cashflow_shipment ON wwg_cashflow_events(shipment_id);
CREATE INDEX idx_wwg_cashflow_status ON wwg_cashflow_events(status);

CREATE TRIGGER wwg_cashflow_events_updated_at
  BEFORE UPDATE ON wwg_cashflow_events
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- PART 5: CREDITORS & INSURANCE (Group 5)
-- ============================================================

-- 5.1 Creditor Accounts
CREATE TABLE wwg_creditor_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL CHECK (entity_type IN ('supplier','carrier','agent','port_operator')),
  entity_name TEXT NOT NULL,
  entity_ref TEXT,
  credit_limit_gbp NUMERIC(14,2),
  current_balance_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  overdue_amount_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  days_past_due INTEGER NOT NULL DEFAULT 0,
  payment_terms_days INTEGER NOT NULL DEFAULT 30,
  blocked BOOLEAN NOT NULL DEFAULT false,
  block_reason TEXT,
  backlog_offer BOOLEAN NOT NULL DEFAULT false,
  backlog_offer_terms TEXT,
  last_payment_date DATE,
  next_payment_due DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_creditor_blocked ON wwg_creditor_accounts(blocked) WHERE blocked = true;
CREATE INDEX idx_wwg_creditor_overdue ON wwg_creditor_accounts(days_past_due) WHERE days_past_due > 0;

CREATE TRIGGER wwg_creditor_accounts_updated_at
  BEFORE UPDATE ON wwg_creditor_accounts
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 5.2 Insurance Profiles
CREATE TABLE wwg_insurance_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID REFERENCES wwg_shipments(id),
  corridor_id UUID REFERENCES wwg_corridors(id),
  insured BOOLEAN NOT NULL DEFAULT true,
  policy_type TEXT NOT NULL CHECK (policy_type IN ('marine_cargo','cargo_all_risks','credit_insurance','product_liability','blanket')),
  policy_number TEXT,
  provider TEXT,
  cover_amount_gbp NUMERIC(14,2),
  excess_gbp NUMERIC(14,2) NOT NULL DEFAULT 0,
  exclusions TEXT[],
  risk_band TEXT NOT NULL DEFAULT 'standard' CHECK (risk_band IN ('low','standard','elevated','high','uninsurable')),
  claim_status TEXT DEFAULT 'none' CHECK (claim_status IN ('none','submitted','under_review','approved','rejected','settled')),
  claim_amount_gbp NUMERIC(14,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_insurance_shipment ON wwg_insurance_profiles(shipment_id);
CREATE INDEX idx_wwg_insurance_uninsured ON wwg_insurance_profiles(insured) WHERE insured = false;

CREATE TRIGGER wwg_insurance_profiles_updated_at
  BEFORE UPDATE ON wwg_insurance_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- PART 6: CUSTOMER & SATISFACTION (Group 6)
-- ============================================================

-- 6.1 Customer Notifications
CREATE TABLE wwg_customer_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES wwg_customers(id),
  shipment_id UUID REFERENCES wwg_shipments(id),
  notification_type TEXT NOT NULL CHECK (notification_type IN ('eta_update','delay_alert','temp_breach','delivery_confirmed','compliance_update','general')),
  channel TEXT NOT NULL DEFAULT 'email' CHECK (channel IN ('email','sms','portal','teams')),
  subject TEXT NOT NULL,
  body TEXT,
  sent_at TIMESTAMPTZ,
  acknowledged BOOLEAN NOT NULL DEFAULT false,
  ont_ref TEXT DEFAULT 'OFM-ONT:CustomerNotification',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-app'
);

CREATE INDEX idx_wwg_notif_customer ON wwg_customer_notifications(customer_id);
CREATE INDEX idx_wwg_notif_shipment ON wwg_customer_notifications(shipment_id);

-- 6.2 Customer Satisfaction
CREATE TABLE wwg_customer_satisfaction (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES wwg_customers(id),
  shipment_id UUID REFERENCES wwg_shipments(id),
  order_id UUID REFERENCES wwg_orders(id),
  overall_score NUMERIC(3,1) NOT NULL CHECK (overall_score >= 0 AND overall_score <= 10),
  on_time_score NUMERIC(3,1) CHECK (on_time_score >= 0 AND on_time_score <= 10),
  quality_score NUMERIC(3,1) CHECK (quality_score >= 0 AND quality_score <= 10),
  communication_score NUMERIC(3,1) CHECK (communication_score >= 0 AND communication_score <= 10),
  repeat_business_probability NUMERIC(3,2),
  feedback_text TEXT,
  delivery_delta_days INTEGER,
  ont_ref TEXT DEFAULT 'OFM-ONT:CustomerSatisfaction',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-survey'
);

CREATE INDEX idx_wwg_csat_customer ON wwg_customer_satisfaction(customer_id);
CREATE INDEX idx_wwg_csat_shipment ON wwg_customer_satisfaction(shipment_id);

-- 6.3 SLA Tracking
CREATE TABLE wwg_sla_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES wwg_customers(id),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  total_shipments INTEGER NOT NULL DEFAULT 0,
  on_time_shipments INTEGER NOT NULL DEFAULT 0,
  on_time_pct NUMERIC(5,2),
  temp_compliant_shipments INTEGER NOT NULL DEFAULT 0,
  temp_compliance_pct NUMERIC(5,2),
  doc_accuracy_pct NUMERIC(5,2),
  sla_met BOOLEAN NOT NULL DEFAULT true,
  ont_ref TEXT DEFAULT 'OFM-ONT:ServiceLevelAgreement',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_sla_tracking_updated_at
  BEFORE UPDATE ON wwg_sla_tracking
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- PART 7: RAID + RMF (Group 7)
-- ============================================================

-- 7.1 RAID Log
CREATE TABLE wwg_raid_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  raid_type TEXT NOT NULL CHECK (raid_type IN ('risk','assumption','issue','dependency','requirement')),
  raid_id TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  severity TEXT CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','mitigated','closed','accepted','escalated')),
  owner TEXT,
  probability TEXT CHECK (probability IN ('rare','unlikely','possible','likely','almost_certain')),
  impact TEXT,
  mitigation TEXT,
  related_entity_type TEXT,
  related_entity_id TEXT,
  ont_ref TEXT DEFAULT 'RAID-ONT:RAIDLog',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_raid_type ON wwg_raid_log(raid_type);
CREATE INDEX idx_wwg_raid_status ON wwg_raid_log(status);

CREATE TRIGGER wwg_raid_log_updated_at
  BEFORE UPDATE ON wwg_raid_log
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 7.2 RMF Assessments (ISO 27005)
CREATE TABLE wwg_rmf_assessments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_ref TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  scope TEXT NOT NULL,
  asset_type TEXT NOT NULL CHECK (asset_type IN ('data','system','process','infrastructure','personnel')),
  threat_type TEXT NOT NULL CHECK (threat_type IN ('cyber','physical','operational','regulatory','environmental')),
  vulnerability TEXT,
  likelihood TEXT NOT NULL CHECK (likelihood IN ('rare','unlikely','possible','likely','almost_certain')),
  impact_level TEXT NOT NULL CHECK (impact_level IN ('negligible','minor','moderate','major','catastrophic')),
  risk_rating TEXT NOT NULL CHECK (risk_rating IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  treatment_plan TEXT,
  treatment_status TEXT NOT NULL DEFAULT 'identified' CHECK (treatment_status IN ('identified','planned','in_progress','implemented','verified')),
  risk_owner TEXT,
  review_date DATE,
  ont_ref TEXT DEFAULT 'RMF-IS27005-ONT:RiskAssessment',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  archived_by TEXT,
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_rmf_assessments_updated_at
  BEFORE UPDATE ON wwg_rmf_assessments
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 7.3 RMF Controls
CREATE TABLE wwg_rmf_controls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_id UUID NOT NULL REFERENCES wwg_rmf_assessments(id),
  control_ref TEXT NOT NULL,
  control_type TEXT NOT NULL CHECK (control_type IN ('preventive','detective','corrective','deterrent','compensating')),
  description TEXT NOT NULL,
  iso_27001_ref TEXT,
  implementation_status TEXT NOT NULL DEFAULT 'planned' CHECK (implementation_status IN ('planned','in_progress','implemented','verified','not_applicable')),
  effectiveness TEXT CHECK (effectiveness IN ('not_tested','ineffective','partially_effective','effective','highly_effective')),
  ont_ref TEXT DEFAULT 'RMF-IS27005-ONT:Control',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE TRIGGER wwg_rmf_controls_updated_at
  BEFORE UPDATE ON wwg_rmf_controls
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- PART 8: 4VOICES & PREDICTIVE ANALYTICS (Group 8)
-- ============================================================

CREATE TABLE wwg_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  perspective TEXT NOT NULL CHECK (perspective IN ('macro','industry','corridor','operational')),
  insight_category TEXT NOT NULL CHECK (insight_category IN ('swot_strength','swot_weakness','swot_opportunity','swot_threat','inflexion','trend','prediction','anomaly','opportunity')),
  horizon TEXT NOT NULL DEFAULT 'short_term' CHECK (horizon IN ('immediate','short_term','medium_term','long_term')),
  title TEXT NOT NULL,
  narrative TEXT,
  evidence JSONB,
  impact_assessment TEXT,
  confidence NUMERIC(3,2) DEFAULT 0.75,
  predicted_probability NUMERIC(3,2),
  predicted_impact_gbp NUMERIC(14,2),
  data_sources TEXT[],
  related_entity_type TEXT,
  related_entity_id TEXT,
  ont_ref TEXT DEFAULT 'VP-ONT:Hypothesis',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-analytics'
);

CREATE INDEX idx_wwg_insights_perspective ON wwg_insights(perspective);
CREATE INDEX idx_wwg_insights_category ON wwg_insights(insight_category);

-- ============================================================
-- PART 9: INTELLIGENCE (Group 9)
-- ============================================================

-- 9.1 CAST Interactions
CREATE TABLE wwg_cast_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id TEXT NOT NULL,
  user_id TEXT NOT NULL DEFAULT 'demo-user',
  context_entity_type TEXT,
  context_entity_id TEXT,
  interaction_type TEXT DEFAULT 'help' CHECK (interaction_type IN ('help','support','feedback','triage')),
  user_message TEXT NOT NULL,
  assistant_response TEXT,
  model_id TEXT DEFAULT 'claude-opus-4-6',
  tokens_used INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-cast'
);

CREATE INDEX idx_wwg_cast_session ON wwg_cast_interactions(session_id);
CREATE INDEX idx_wwg_cast_context ON wwg_cast_interactions(context_entity_type, context_entity_id);

-- 9.2 Farsight Threads
CREATE TABLE wwg_farsight_threads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_title TEXT NOT NULL,
  insight_type TEXT NOT NULL DEFAULT 'general' CHECK (insight_type IN ('logistics','cold-chain','compliance','risk','financial','market','operational','creditor','general')),
  scope TEXT DEFAULT 'fleet',
  summary TEXT,
  findings JSONB,
  recommendations JSONB,
  data_sources TEXT[],
  confidence_score NUMERIC(3,2),
  created_by TEXT NOT NULL DEFAULT 'demo-user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-farsight'
);

CREATE INDEX idx_wwg_farsight_type ON wwg_farsight_threads(insight_type);

-- ============================================================
-- PART 10: AUDIT & CONTROL (Group 10)
-- ============================================================

-- 10.1 Audit Log (immutable)
CREATE TABLE wwg_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  action TEXT NOT NULL CHECK (action IN (
    'create','update','delete','archive',
    'status_change','route_change','temp_breach','eta_change',
    'compliance_check','alert_generated','credit_block','insurance_claim',
    'fx_import','login','logout','export','notification_sent'
  )),
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  user_id TEXT NOT NULL DEFAULT 'system',
  details TEXT,
  before_value JSONB,
  after_value JSONB,
  origin_db TEXT NOT NULL DEFAULT 'wwg-app'
);

CREATE INDEX idx_wwg_audit_entity ON wwg_audit_log(entity_type, entity_id);
CREATE INDEX idx_wwg_audit_timestamp ON wwg_audit_log(timestamp DESC);
CREATE INDEX idx_wwg_audit_action ON wwg_audit_log(action);

-- 10.2 Control Checks
CREATE TABLE wwg_control_checks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  check_id TEXT NOT NULL,
  check_name TEXT NOT NULL,
  requirement_ref TEXT,
  category TEXT NOT NULL CHECK (category IN ('compliance','financial','operational','security','data-quality')),
  status TEXT NOT NULL CHECK (status IN ('PASS','WARNING','FAIL','INFO')),
  finding TEXT,
  recommendation TEXT,
  checked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-engine'
);

CREATE INDEX idx_wwg_control_status ON wwg_control_checks(status);

-- ============================================================
-- PART 11: AUDIT TRIGGER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION wwg_audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO wwg_audit_log (action, entity_type, entity_id, user_id, details, after_value)
    VALUES (
      'create',
      TG_TABLE_NAME,
      NEW.id::TEXT,
      coalesce(current_setting('app.user_id', true), 'system'),
      'Auto-captured by ' || TG_TABLE_NAME || ' trigger',
      to_jsonb(NEW)
    );
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO wwg_audit_log (action, entity_type, entity_id, user_id, details, before_value, after_value)
    VALUES (
      'update',
      TG_TABLE_NAME,
      NEW.id::TEXT,
      coalesce(current_setting('app.user_id', true), 'system'),
      'Auto-captured by ' || TG_TABLE_NAME || ' trigger',
      to_jsonb(OLD),
      to_jsonb(NEW)
    );
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Attach audit triggers to transactional tables
CREATE TRIGGER wwg_shipments_audit
  AFTER INSERT OR UPDATE ON wwg_shipments
  FOR EACH ROW EXECUTE FUNCTION wwg_audit_trigger();

CREATE TRIGGER wwg_orders_audit
  AFTER INSERT OR UPDATE ON wwg_orders
  FOR EACH ROW EXECUTE FUNCTION wwg_audit_trigger();

CREATE TRIGGER wwg_order_lines_audit
  AFTER INSERT OR UPDATE ON wwg_order_lines
  FOR EACH ROW EXECUTE FUNCTION wwg_audit_trigger();

CREATE TRIGGER wwg_alerts_audit
  AFTER INSERT OR UPDATE ON wwg_alerts
  FOR EACH ROW EXECUTE FUNCTION wwg_audit_trigger();

CREATE TRIGGER wwg_impact_assessments_audit
  AFTER INSERT OR UPDATE ON wwg_impact_assessments
  FOR EACH ROW EXECUTE FUNCTION wwg_audit_trigger();

CREATE TRIGGER wwg_compliance_gates_audit
  AFTER INSERT OR UPDATE ON wwg_compliance_gates
  FOR EACH ROW EXECUTE FUNCTION wwg_audit_trigger();

-- ============================================================
-- PART 12: SEED DATA
-- ============================================================

-- 12.1 Corridors
INSERT INTO wwg_corridors (corridor_code, origin_country, dest_country, route_type, base_transit_days, distance_nm, description) VALUES
  ('AU-UK-CAPE', 'AU', 'UK', 'CAPE', 35, 12500, 'Australia to UK via Cape of Good Hope'),
  ('AU-UK-SUEZ', 'AU', 'UK', 'SUEZ', 28, 11200, 'Australia to UK via Suez Canal');

-- 12.2 Carriers
INSERT INTO wwg_carriers (carrier_code, carrier_name, alliance) VALUES
  ('MAERSK', 'Maersk', '2M'),
  ('CMA_CGM', 'CMA CGM', 'Ocean Alliance'),
  ('HAPAG', 'Hapag-Lloyd', 'THE Alliance'),
  ('MSC', 'MSC', '2M'),
  ('OOCL', 'OOCL', 'Ocean Alliance'),
  ('EVERGREEN', 'Evergreen', 'Ocean Alliance'),
  ('COSCO', 'COSCO', 'Ocean Alliance');

-- 12.3 Vessels (use CTEs for carrier FK resolution)
WITH carr AS (SELECT id, carrier_code FROM wwg_carriers)
INSERT INTO wwg_vessels (carrier_id, vessel_name, imo_number, mmsi) VALUES
  ((SELECT id FROM carr WHERE carrier_code = 'MAERSK'), 'MV Maersk Hobart', 'IMO9876001', '219876001'),
  ((SELECT id FROM carr WHERE carrier_code = 'MAERSK'), 'MV Maersk Darwin', 'IMO9876002', '219876002'),
  ((SELECT id FROM carr WHERE carrier_code = 'CMA_CGM'), 'CMA CGM Coral', 'IMO9876003', '228876003'),
  ((SELECT id FROM carr WHERE carrier_code = 'CMA_CGM'), 'CMA CGM Reef', 'IMO9876004', '228876004'),
  ((SELECT id FROM carr WHERE carrier_code = 'HAPAG'), 'Hapag Sydney Express', 'IMO9876005', '211876005'),
  ((SELECT id FROM carr WHERE carrier_code = 'MSC'), 'MSC Adelaide', 'IMO9876006', '255876006'),
  ((SELECT id FROM carr WHERE carrier_code = 'MSC'), 'MSC Brisbane', 'IMO9876007', '255876007'),
  ((SELECT id FROM carr WHERE carrier_code = 'OOCL'), 'OOCL Southern Cross', 'IMO9876008', '477876008'),
  ((SELECT id FROM carr WHERE carrier_code = 'EVERGREEN'), 'Ever Pacific', 'IMO9876009', '353876009'),
  ((SELECT id FROM carr WHERE carrier_code = 'EVERGREEN'), 'Ever Southern', 'IMO9876010', '353876010'),
  ((SELECT id FROM carr WHERE carrier_code = 'COSCO'), 'COSCO Melbourne', 'IMO9876011', '413876011'),
  ((SELECT id FROM carr WHERE carrier_code = 'COSCO'), 'COSCO Oceania', 'IMO9876012', '413876012');

-- 12.4 Ports
INSERT INTO wwg_ports (port_code, port_name, country, lat, lon, port_type, is_bcp) VALUES
  ('AUMEL', 'Melbourne', 'AU', -37.8136, 144.9631, 'origin', false),
  ('AUSYD', 'Sydney', 'AU', -33.8688, 151.2093, 'origin', false),
  ('AUBNE', 'Brisbane', 'AU', -27.4705, 153.0260, 'origin', false),
  ('AUFRE', 'Fremantle', 'AU', -32.0569, 115.7439, 'origin', false),
  ('AUADL', 'Adelaide', 'AU', -34.9285, 138.6007, 'origin', false),
  ('GBTIL', 'Tilbury', 'UK', 51.4547, 0.3520, 'destination', true),
  ('GBSOU', 'Southampton', 'UK', 50.8998, -1.4044, 'destination', true);

-- 12.5 Products
INSERT INTO wwg_products (product_code, description, cold_chain_type, set_point_temp, shelf_life_days, temp_sensitivity, species, halal_certified, feed_type) VALUES
  ('FRZ-BMB-001', 'Frozen Beef BMB', 'frozen', -18.00, 365, 0.08, 'beef', true, 'grain_fed'),
  ('FRZ-BMB-002', 'Frozen Beef Trim 85CL', 'frozen', -18.00, 365, 0.08, 'beef', true, 'grass_fed'),
  ('FRZ-LMB-001', 'Frozen Lamb Leg Bone-In', 'frozen', -20.00, 365, 0.08, 'lamb', true, 'grass_fed'),
  ('FRZ-LMB-002', 'Frozen Lamb Rack Cap Off', 'frozen', -20.00, 365, 0.08, 'lamb', true, 'grass_fed'),
  ('FRZ-GOT-001', 'Frozen Goat Carcass', 'frozen', -18.00, 365, 0.08, 'goat', true, 'grass_fed'),
  ('CHL-LMB-001', 'Chilled Lamb Shortloin', 'chilled', 0.00, 28, 0.25, 'lamb', true, 'grass_fed'),
  ('CHL-LMB-002', 'Chilled Lamb Tenderloin', 'chilled', 0.00, 28, 0.25, 'lamb', true, 'grass_fed'),
  ('CHL-BEF-001', 'Chilled Beef Striploin', 'chilled', 2.00, 28, 0.25, 'beef', true, 'grain_fed'),
  ('CHL-BEF-002', 'Chilled Beef Cube Roll', 'chilled', 2.00, 28, 0.25, 'beef', true, 'grain_fed'),
  ('FRS-LMB-001', 'Fresh Lamb CA Whole Carcass', 'fresh', 1.00, 14, 0.35, 'lamb', true, 'grass_fed'),
  ('FRS-LMB-002', 'Fresh Lamb CA Shoulder', 'fresh', 1.00, 14, 0.35, 'lamb', true, 'grass_fed'),
  ('FRZ-VEL-001', 'Frozen Veal Osso Buco', 'frozen', -18.00, 365, 0.08, 'veal', true, 'mixed');

-- 12.6 Customers (anonymised)
INSERT INTO wwg_customers (customer_code, customer_name, country, delivery_port, account_tier, sla_on_time_pct, sla_temp_compliance_pct) VALUES
  ('CUST-A', 'Alpha Foods Distribution', 'UK', 'GBTIL', 'strategic', 97.00, 100.00),
  ('CUST-B', 'Bravo Halal Meats', 'UK', 'GBTIL', 'strategic', 95.00, 100.00),
  ('CUST-C', 'Charlie Fresh Imports', 'UK', 'GBSOU', 'key', 95.00, 100.00),
  ('CUST-D', 'Delta Food Service', 'UK', 'GBTIL', 'key', 93.00, 99.00),
  ('CUST-E', 'Echo Premium Meats', 'UK', 'GBSOU', 'standard', 90.00, 98.00),
  ('CUST-F', 'Foxtrot Wholesale', 'UK', 'GBTIL', 'prospect', 90.00, 98.00);

-- 12.7 Suppliers (anonymised)
INSERT INTO wwg_suppliers (supplier_code, supplier_name, establishment_number, state, country, halal_approved) VALUES
  ('SUP-AU-001', 'Southern Cross Meats', 'EST 001', 'VIC', 'AU', true),
  ('SUP-AU-002', 'Outback Premium Foods', 'EST 002', 'NSW', 'AU', true),
  ('SUP-AU-003', 'Pacific Livestock Co', 'EST 003', 'QLD', 'AU', true),
  ('SUP-AU-004', 'Great Southern Lamb', 'EST 004', 'WA', 'AU', true),
  ('SUP-AU-005', 'Adelaide Valley Meats', 'EST 005', 'SA', 'AU', true);

-- 12.8 Risk Events (from tracker simulation)
INSERT INTO wwg_risk_events (event_date, event_type, zone, severity, title, detail, active_until) VALUES
  ('2026-01-08', 'GEOPOLITICAL', 'RED_SEA', 'CRITICAL', 'Houthi Missile Strike on Container Vessel', 'Anti-ship ballistic missile struck a container vessel near Bab el-Mandeb. All carriers suspending Red Sea transit.', NULL),
  ('2026-01-15', 'GEOPOLITICAL', 'STRAIT_OF_HORMUZ', 'HIGH', 'Iran Naval Exercises Block Hormuz Corridor', 'Iranian Revolutionary Guard conducting live-fire exercises. Insurance premiums surging for Gulf of Oman transit.', '2026-02-15'),
  ('2026-01-22', 'WEATHER', 'MAURITIUS', 'MEDIUM', 'Tropical Cyclone Approaching Mauritius', 'Category 2 cyclone forecast to pass within 200nm. Vessels advised to alter course south.', '2026-01-28'),
  ('2026-02-05', 'WEATHER', 'SOUTHERN_OCEAN', 'MEDIUM', 'Southern Ocean Storm System', 'Deep low-pressure system generating 8-10m swells on Cape route. Speed reductions expected.', '2026-02-10'),
  ('2026-02-18', 'PORT_CONGESTION', 'TILBURY', 'HIGH', 'Tilbury Port Industrial Action', 'Unite union members begin 72-hour work-to-rule. Container handling capacity reduced 40%.', '2026-02-21'),
  ('2026-03-01', 'GEOPOLITICAL', 'RED_SEA', 'LOW', 'Ceasefire Announced — Suez Route Reopening', 'UN-brokered ceasefire in effect. First carriers announcing return to Suez transit within 2 weeks.', NULL);

-- 12.9 Shipments (12 containers — the core demo data)
WITH
  carr AS (SELECT id, carrier_code FROM wwg_carriers),
  vess AS (SELECT id, vessel_name FROM wwg_vessels),
  port AS (SELECT id, port_code FROM wwg_ports),
  prod AS (SELECT id, product_code FROM wwg_products),
  cust AS (SELECT id, customer_code FROM wwg_customers),
  supp AS (SELECT id, supplier_code FROM wwg_suppliers),
  corr AS (SELECT id, corridor_code FROM wwg_corridors)
INSERT INTO wwg_shipments (container_id, carrier_id, vessel_id, voyage_number, origin_port_id, dest_port_id, corridor_id, product_id, supplier_id, customer_id, departure_date, base_transit_days, planned_route, current_route, scenario, current_status, current_delay_days, current_eta, original_eta, set_point_temp, cold_chain_type, weight_kg) VALUES
  ('MRKU4821073', (SELECT id FROM carr WHERE carrier_code='MAERSK'), (SELECT id FROM vess WHERE vessel_name='MV Maersk Hobart'), '426W', (SELECT id FROM port WHERE port_code='AUMEL'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='FRZ-BMB-001'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-001'), (SELECT id FROM cust WHERE customer_code='CUST-A'), '2026-01-14', 35, 'SUEZ', 'CAPE', 'CAPE_REROUTE', 'at_sea', 8, '2026-02-26', '2026-02-18', -18.00, 'frozen', 24000.00),
  ('CMAU6712890', (SELECT id FROM carr WHERE carrier_code='CMA_CGM'), (SELECT id FROM vess WHERE vessel_name='CMA CGM Coral'), '891E', (SELECT id FROM port WHERE port_code='AUSYD'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='CHL-LMB-001'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-002'), (SELECT id FROM cust WHERE customer_code='CUST-B'), '2026-01-18', 32, 'SUEZ', 'CAPE', 'CAPE_REROUTE', 'at_sea', 6, '2026-02-25', '2026-02-19', 0.00, 'chilled', 18000.00),
  ('HLXU9901234', (SELECT id FROM carr WHERE carrier_code='HAPAG'), (SELECT id FROM vess WHERE vessel_name='Hapag Sydney Express'), '205S', (SELECT id FROM port WHERE port_code='AUSYD'), (SELECT id FROM port WHERE port_code='GBSOU'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='CHL-BEF-001'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-002'), (SELECT id FROM cust WHERE customer_code='CUST-C'), '2026-01-20', 33, 'CAPE', 'CAPE', 'TEMP_BREACH', 'at_sea_alert', 6, '2026-02-28', '2026-02-22', 2.00, 'chilled', 20000.00),
  ('MSCU3345678', (SELECT id FROM carr WHERE carrier_code='MSC'), (SELECT id FROM vess WHERE vessel_name='MSC Adelaide'), '744N', (SELECT id FROM port WHERE port_code='AUADL'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-SUEZ'), (SELECT id FROM prod WHERE product_code='FRZ-LMB-001'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-005'), (SELECT id FROM cust WHERE customer_code='CUST-A'), '2026-01-10', 28, 'SUEZ', 'SUEZ', 'SUEZ_THEN_CAPE', 'at_sea', 10, '2026-02-17', '2026-02-07', -20.00, 'frozen', 22000.00),
  ('OOLU7789012', (SELECT id FROM carr WHERE carrier_code='OOCL'), (SELECT id FROM vess WHERE vessel_name='OOCL Southern Cross'), '332W', (SELECT id FROM port WHERE port_code='AUBNE'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='FRZ-GOT-001'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-003'), (SELECT id FROM cust WHERE customer_code='CUST-D'), '2026-01-25', 36, 'CAPE', 'CAPE', 'WEATHER_DELAY', 'at_sea', 4, '2026-03-06', '2026-03-02', -18.00, 'frozen', 19000.00),
  ('EVRU8821100', (SELECT id FROM carr WHERE carrier_code='EVERGREEN'), (SELECT id FROM vess WHERE vessel_name='Ever Pacific'), '118E', (SELECT id FROM port WHERE port_code='AUMEL'), (SELECT id FROM port WHERE port_code='GBSOU'), (SELECT id FROM corr WHERE corridor_code='AU-UK-SUEZ'), (SELECT id FROM prod WHERE product_code='FRZ-LMB-002'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-004'), (SELECT id FROM cust WHERE customer_code='CUST-E'), '2026-02-01', 28, 'SUEZ', 'SUEZ', 'CEASEFIRE_BENEFIT', 'discharged', -2, '2026-02-27', '2026-03-01', -20.00, 'frozen', 21000.00),
  ('CSNU2234567', (SELECT id FROM carr WHERE carrier_code='COSCO'), (SELECT id FROM vess WHERE vessel_name='COSCO Melbourne'), '667S', (SELECT id FROM port WHERE port_code='AUMEL'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='FRS-LMB-001'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-001'), (SELECT id FROM cust WHERE customer_code='CUST-B'), '2026-01-28', 38, 'CAPE', 'CAPE', 'HORMUZ_DIVERT', 'at_sea', 5, '2026-03-12', '2026-03-07', 1.00, 'fresh', 15000.00),
  ('MRKU7734901', (SELECT id FROM carr WHERE carrier_code='MAERSK'), (SELECT id FROM vess WHERE vessel_name='MV Maersk Darwin'), '427W', (SELECT id FROM port WHERE port_code='AUFRE'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='FRZ-BMB-002'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-004'), (SELECT id FROM cust WHERE customer_code='CUST-A'), '2026-02-05', 34, 'CAPE', 'CAPE', 'NORMAL', 'gate_out', 0, '2026-03-11', '2026-03-11', -18.00, 'frozen', 25000.00),
  ('CMAU9988776', (SELECT id FROM carr WHERE carrier_code='CMA_CGM'), (SELECT id FROM vess WHERE vessel_name='CMA CGM Reef'), '892E', (SELECT id FROM port WHERE port_code='AUBNE'), (SELECT id FROM port WHERE port_code='GBSOU'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='CHL-BEF-002'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-003'), (SELECT id FROM cust WHERE customer_code='CUST-C'), '2026-02-10', 33, 'CAPE', 'CAPE', 'ROUTE_CHANGE', 'port_approach', 3, '2026-03-18', '2026-03-15', 2.00, 'chilled', 17000.00),
  ('MSCU5567890', (SELECT id FROM carr WHERE carrier_code='MSC'), (SELECT id FROM vess WHERE vessel_name='MSC Brisbane'), '745N', (SELECT id FROM port WHERE port_code='AUSYD'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='FRZ-VEL-001'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-005'), (SELECT id FROM cust WHERE customer_code='CUST-D'), '2026-02-15', 35, 'CAPE', 'CAPE', 'SLOW_STEAM', 'at_sea', 3, '2026-03-25', '2026-03-22', -18.00, 'frozen', 16000.00),
  ('EVRU1122334', (SELECT id FROM carr WHERE carrier_code='EVERGREEN'), (SELECT id FROM vess WHERE vessel_name='Ever Southern'), '119E', (SELECT id FROM port WHERE port_code='AUADL'), (SELECT id FROM port WHERE port_code='GBTIL'), (SELECT id FROM corr WHERE corridor_code='AU-UK-SUEZ'), (SELECT id FROM prod WHERE product_code='FRS-LMB-002'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-005'), (SELECT id FROM cust WHERE customer_code='CUST-F'), '2026-02-20', 28, 'SUEZ', 'SUEZ', 'NORMAL', 'btom_cleared', 0, '2026-03-20', '2026-03-20', 1.00, 'fresh', 14000.00),
  ('CSNU4456789', (SELECT id FROM carr WHERE carrier_code='COSCO'), (SELECT id FROM vess WHERE vessel_name='COSCO Oceania'), '668S', (SELECT id FROM port WHERE port_code='AUFRE'), (SELECT id FROM port WHERE port_code='GBSOU'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), (SELECT id FROM prod WHERE product_code='CHL-LMB-002'), (SELECT id FROM supp WHERE supplier_code='SUP-AU-001'), (SELECT id FROM cust WHERE customer_code='CUST-E'), '2026-02-25', 36, 'CAPE', 'CAPE', 'NORMAL', 'booked', 0, '2026-04-02', '2026-04-02', 0.00, 'chilled', 18500.00);

-- 12.10 Voyage Events (material milestone events — 6 per shipment for key containers)
WITH ship AS (SELECT id, container_id FROM wwg_shipments)
INSERT INTO wwg_voyage_events (shipment_id, event_date, day_of_voyage, status, route, lat, lon, position_name, sog_knots, temp_celsius, temp_breach, risk_level, delay_days, eta_date) VALUES
  -- MRKU4821073 (CAPE_REROUTE) — key milestones
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-01-14', 0, 'Loaded/Departed', 'SUEZ', -37.8136, 144.9631, 'Melbourne', 0.0, -18.10, false, 'LOW', 0, '2026-02-18'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-01-22', 8, 'At Sea', 'SUEZ', -6.0000, 105.0000, 'Malacca Strait', 14.2, -18.05, false, 'LOW', 0, '2026-02-18'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-01-25', 11, 'At Sea — ALERT', 'CAPE', -10.0000, 80.0000, 'Indian Ocean', 13.8, -17.95, false, 'HIGH', 4, '2026-02-22'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-02-05', 22, 'At Sea', 'CAPE', -34.3568, 18.4740, 'Cape of Good Hope', 12.5, -18.10, false, 'MEDIUM', 6, '2026-02-24'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-02-15', 32, 'At Sea', 'CAPE', 28.0000, -15.0000, 'Canary Islands', 14.0, -18.00, false, 'MEDIUM', 8, '2026-02-26'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-02-20', 37, 'At Sea', 'CAPE', 48.0000, -5.0000, 'Bay of Biscay', 14.5, -18.05, false, 'LOW', 8, '2026-02-26'),
  -- HLXU9901234 (TEMP_BREACH) — critical scenario
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-01-20', 0, 'Loaded/Departed', 'CAPE', -33.8688, 151.2093, 'Sydney', 0.0, 1.95, false, 'LOW', 0, '2026-02-22'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-01-28', 8, 'At Sea', 'CAPE', -25.0000, 110.0000, 'Indian Ocean', 14.0, 2.05, false, 'LOW', 0, '2026-02-22'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-03', 14, 'At Sea — ALERT', 'CAPE', -35.0000, 55.0000, 'South Indian Ocean', 13.5, 4.80, true, 'CRITICAL', 2, '2026-02-24'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-06', 17, 'At Sea — ALERT', 'CAPE', -34.3568, 30.0000, 'Mozambique Channel', 12.0, 3.50, true, 'CRITICAL', 4, '2026-02-26'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-12', 23, 'At Sea', 'CAPE', -34.3568, 18.4740, 'Cape Town', 13.0, 2.20, false, 'HIGH', 5, '2026-02-27'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-20', 31, 'At Sea', 'CAPE', 15.0000, -20.0000, 'Mid Atlantic', 14.2, 2.10, false, 'HIGH', 6, '2026-02-28'),
  -- MRKU7734901 (NORMAL) — clean delivery
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), '2026-02-05', 0, 'Loaded/Departed', 'CAPE', -32.0569, 115.7439, 'Fremantle', 0.0, -18.10, false, 'LOW', 0, '2026-03-11'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), '2026-02-20', 15, 'At Sea', 'CAPE', -34.3568, 18.4740, 'Cape of Good Hope', 14.5, -18.05, false, 'LOW', 0, '2026-03-11'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), '2026-03-05', 28, 'Port Approach', 'CAPE', 51.0000, 1.0000, 'English Channel', 12.0, -18.00, false, 'LOW', 0, '2026-03-11'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), '2026-03-11', 34, 'Gate Out', 'CAPE', 51.4547, 0.3520, 'Tilbury', 0.0, -18.05, false, 'LOW', 0, '2026-03-11'),
  -- EVRU8821100 (CEASEFIRE_BENEFIT) — early arrival
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), '2026-02-01', 0, 'Loaded/Departed', 'SUEZ', -37.8136, 144.9631, 'Melbourne', 0.0, -20.10, false, 'LOW', 0, '2026-03-01'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), '2026-02-12', 11, 'At Sea', 'SUEZ', 12.5000, 43.0000, 'Gulf of Aden', 15.0, -20.05, false, 'LOW', 0, '2026-03-01'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), '2026-02-16', 15, 'At Sea', 'SUEZ', 30.0000, 32.5000, 'Suez Canal', 8.0, -20.00, false, 'LOW', -1, '2026-02-28'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), '2026-02-27', 26, 'Discharged', 'SUEZ', 50.8998, -1.4044, 'Southampton', 0.0, -20.05, false, 'LOW', -2, '2026-02-27'),
  -- CSNU2234567 (HORMUZ_DIVERT) — diversion scenario
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), '2026-01-28', 0, 'Loaded/Departed', 'CAPE', -37.8136, 144.9631, 'Melbourne', 0.0, 0.95, false, 'LOW', 0, '2026-03-07'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), '2026-02-08', 11, 'At Sea — ALERT', 'CAPE', 10.0000, 65.0000, 'Arabian Sea', 13.0, 1.05, false, 'HIGH', 3, '2026-03-10'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), '2026-02-18', 21, 'At Sea', 'CAPE', -20.0000, 40.0000, 'Mozambique Channel', 13.5, 1.10, false, 'MEDIUM', 4, '2026-03-11'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), '2026-03-01', 32, 'At Sea', 'CAPE', 10.0000, -20.0000, 'West Africa', 14.0, 1.00, false, 'MEDIUM', 5, '2026-03-12'),
  -- OOLU7789012 (WEATHER_DELAY)
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), '2026-01-25', 0, 'Loaded/Departed', 'CAPE', -27.4705, 153.0260, 'Brisbane', 0.0, -18.10, false, 'LOW', 0, '2026-03-02'),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), '2026-02-05', 11, 'At Sea — ALERT', 'CAPE', -30.0000, 80.0000, 'Southern Indian Ocean', 10.0, -17.90, false, 'HIGH', 2, '2026-03-04'),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), '2026-02-15', 21, 'At Sea', 'CAPE', -34.3568, 18.4740, 'Cape of Good Hope', 13.0, -18.05, false, 'MEDIUM', 3, '2026-03-05'),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), '2026-02-25', 31, 'At Sea', 'CAPE', 28.0000, -15.0000, 'Canary Islands', 14.5, -18.00, false, 'LOW', 4, '2026-03-06');

-- 12.11 Alerts (linked to shipments and risk events)
WITH
  ship AS (SELECT id, container_id FROM wwg_shipments),
  risk AS (SELECT id, title FROM wwg_risk_events)
INSERT INTO wwg_alerts (shipment_id, risk_event_id, alert_type, severity, title, detail, alert_date) VALUES
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM risk WHERE title LIKE 'Houthi%'), 'ROUTE_CHANGE', 'CRITICAL', 'Route Change: Suez to Cape', 'Red Sea security threat forces reroute via Cape of Good Hope. +8 day delay expected.', '2026-01-22'),
  ((SELECT id FROM ship WHERE container_id='CMAU6712890'), (SELECT id FROM risk WHERE title LIKE 'Houthi%'), 'ROUTE_CHANGE', 'CRITICAL', 'Route Change: Suez to Cape', 'Red Sea reroute. +6 day delay expected.', '2026-01-24'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), NULL, 'TEMP_BREACH', 'CRITICAL', 'Temperature Breach: Reefer Fault', 'Supply air temp 4.8C vs set-point 2.0C. Deviation 2.8C sustained >6hrs. Shelf-life impact: CRITICAL.', '2026-02-03'),
  ((SELECT id FROM ship WHERE container_id='MSCU3345678'), (SELECT id FROM risk WHERE title LIKE 'Houthi%'), 'ROUTE_CHANGE', 'HIGH', 'Route Diversion: Suez to Cape mid-voyage', 'Vessel entered Red Sea approach before rerouting. +10 day delay.', '2026-01-20'),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), (SELECT id FROM risk WHERE title LIKE 'Southern Ocean%'), 'WEATHER', 'HIGH', 'Weather Delay: Southern Ocean Storm', '8-10m swells reducing speed to 10 knots. +2 day delay.', '2026-02-05'),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), (SELECT id FROM risk WHERE title LIKE 'Tilbury%'), 'PORT_DELAY', 'HIGH', 'Port Congestion: Tilbury Industrial Action', 'Unite work-to-rule reducing handling capacity 40%. +2 day additional delay.', '2026-02-18'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM risk WHERE title LIKE 'Iran%'), 'GEOPOLITICAL', 'HIGH', 'Hormuz Diversion', 'Vessel diverted away from Strait of Hormuz naval exercises. +3 day delay.', '2026-02-08'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM risk WHERE title LIKE 'Ceasefire%'), 'ROUTE_RESTORED', 'LOW', 'Suez Route Restored', 'Ceasefire in effect. Vessel transited Suez without delay. -2 day benefit.', '2026-02-14'),
  ((SELECT id FROM ship WHERE container_id='CMAU9988776'), NULL, 'CARRIER_DECISION', 'MEDIUM', 'Slow Steam: Fuel Cost Optimisation', 'Carrier reduced speed to 12 knots for fuel savings. +3 day delay.', '2026-02-22'),
  ((SELECT id FROM ship WHERE container_id='MSCU5567890'), NULL, 'ETA_CHANGE', 'MEDIUM', 'Slow Steam: Speed Reduction', 'MSC advisory — speed reduced for bunker savings. +3 day delay.', '2026-02-28');

-- 12.12 Compliance Gates
WITH ship AS (SELECT id, container_id, current_eta FROM wwg_shipments)
INSERT INTO wwg_compliance_gates (shipment_id, gate_type, status, deadline, completed_at, bcp_port, notes) VALUES
  -- MRKU7734901 (NORMAL — completed)
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), 'IPAFFS_PRE_NOTIFICATION', 'passed', '2026-03-08 00:00:00+00', '2026-03-07 14:00:00+00', 'Tilbury BCP', 'Pre-notification submitted 4 days before ETA'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), 'BTOM_DOC_CHECK', 'passed', '2026-03-10 00:00:00+00', '2026-03-09 10:00:00+00', 'Tilbury BCP', 'Documentary check cleared'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), 'BCP_PHYSICAL_INSPECTION', 'passed', '2026-03-11 00:00:00+00', '2026-03-11 08:00:00+00', 'Tilbury BCP', 'Physical inspection — frozen beef, no issues'),
  -- EVRU8821100 (CEASEFIRE_BENEFIT — completed early)
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), 'IPAFFS_PRE_NOTIFICATION', 'passed', '2026-02-25 00:00:00+00', '2026-02-24 09:00:00+00', 'Southampton BCP', 'Pre-notification submitted early due to ahead-of-schedule vessel'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), 'BTOM_DOC_CHECK', 'passed', '2026-02-27 00:00:00+00', '2026-02-26 11:00:00+00', 'Southampton BCP', 'Documentary check cleared'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), 'BCP_PHYSICAL_INSPECTION', 'waived', NULL, NULL, 'Southampton BCP', 'Physical inspection waived — frozen lamb, low risk corridor'),
  -- MRKU4821073 (CAPE_REROUTE — pending, deadline shifted)
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), 'IPAFFS_PRE_NOTIFICATION', 'submitted', '2026-02-23 00:00:00+00', NULL, 'Tilbury BCP', 'Pre-notification submitted, deadline adjusted for ETA delay'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), 'BTOM_DOC_CHECK', 'pending', '2026-02-25 00:00:00+00', NULL, 'Tilbury BCP', 'Awaiting vessel arrival'),
  -- HLXU9901234 (TEMP_BREACH — compliance critical)
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), 'IPAFFS_PRE_NOTIFICATION', 'submitted', '2026-02-25 00:00:00+00', NULL, 'Southampton BCP', 'Pre-notification includes temp breach disclosure'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), 'VETERINARY_CHECK', 'due_now', '2026-02-28 00:00:00+00', NULL, 'Southampton BCP', 'Mandatory vet check required due to cold-chain breach'),
  -- EVRU1122334 (NORMAL via Suez — cleared)
  ((SELECT id FROM ship WHERE container_id='EVRU1122334'), 'IPAFFS_PRE_NOTIFICATION', 'passed', '2026-03-17 00:00:00+00', '2026-03-16 10:00:00+00', 'Tilbury BCP', 'Pre-notification submitted on time'),
  ((SELECT id FROM ship WHERE container_id='EVRU1122334'), 'BTOM_DOC_CHECK', 'passed', '2026-03-19 00:00:00+00', '2026-03-18 14:00:00+00', 'Tilbury BCP', 'Documentary check cleared');

-- 12.13 Cold Chain Readings (key readings including breaches)
WITH ship AS (SELECT id, container_id FROM wwg_shipments)
INSERT INTO wwg_cold_chain_readings (shipment_id, reading_at, supply_air_temp, return_air_temp, set_point_temp, deviation, is_breach, shelf_life_remaining_days, shelf_life_status) VALUES
  -- HLXU9901234 — TEMP_BREACH scenario (chilled beef, set-point 2.0C)
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-03 06:00:00+00', 4.80, 5.20, 2.00, 2.80, true, 8, 'CRITICAL'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-03 12:00:00+00', 4.50, 4.90, 2.00, 2.50, true, 7, 'CRITICAL'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-04 06:00:00+00', 3.80, 4.20, 2.00, 1.80, true, 6, 'CRITICAL'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-05 06:00:00+00', 3.20, 3.60, 2.00, 1.20, true, 5, 'CRITICAL'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-06 06:00:00+00', 2.30, 2.80, 2.00, 0.30, false, 5, 'AT_RISK'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-10 06:00:00+00', 2.10, 2.50, 2.00, 0.10, false, 4, 'AT_RISK'),
  -- MRKU4821073 — normal frozen readings (set-point -18C)
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-01-20 06:00:00+00', -18.10, -17.80, -18.00, 0.00, false, 360, 'HEALTHY'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-02-05 06:00:00+00', -17.95, -17.60, -18.00, 0.05, false, 345, 'HEALTHY'),
  -- MRKU7734901 — clean frozen (set-point -18C)
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), '2026-02-10 06:00:00+00', -18.05, -17.90, -18.00, 0.00, false, 355, 'HEALTHY'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), '2026-03-11 06:00:00+00', -18.00, -17.85, -18.00, 0.00, false, 331, 'HEALTHY');

-- 12.14 Orders (one per shipment)
WITH
  ship AS (SELECT id, container_id FROM wwg_shipments),
  cust AS (SELECT id, customer_code FROM wwg_customers)
INSERT INTO wwg_orders (order_number, shipment_id, customer_id, status, fx_rate_at_creation, total_value, total_quantity_kg, delivery_window_start, delivery_window_end) VALUES
  ('ORD-2026-001', (SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM cust WHERE customer_code='CUST-A'), 'in_transit', 0.51200000, 86400.00, 24000.00, '2026-02-15', '2026-02-21'),
  ('ORD-2026-002', (SELECT id FROM ship WHERE container_id='CMAU6712890'), (SELECT id FROM cust WHERE customer_code='CUST-B'), 'in_transit', 0.51500000, 97200.00, 18000.00, '2026-02-16', '2026-02-22'),
  ('ORD-2026-003', (SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM cust WHERE customer_code='CUST-C'), 'in_transit', 0.51300000, 120000.00, 20000.00, '2026-02-19', '2026-02-25'),
  ('ORD-2026-004', (SELECT id FROM ship WHERE container_id='MSCU3345678'), (SELECT id FROM cust WHERE customer_code='CUST-A'), 'in_transit', 0.50800000, 110000.00, 22000.00, '2026-02-04', '2026-02-10'),
  ('ORD-2026-005', (SELECT id FROM ship WHERE container_id='OOLU7789012'), (SELECT id FROM cust WHERE customer_code='CUST-D'), 'in_transit', 0.51100000, 85500.00, 19000.00, '2026-02-28', '2026-03-05'),
  ('ORD-2026-006', (SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM cust WHERE customer_code='CUST-E'), 'delivered', 0.51400000, 105000.00, 21000.00, '2026-02-27', '2026-03-04'),
  ('ORD-2026-007', (SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM cust WHERE customer_code='CUST-B'), 'in_transit', 0.51000000, 78750.00, 15000.00, '2026-03-04', '2026-03-10'),
  ('ORD-2026-008', (SELECT id FROM ship WHERE container_id='MRKU7734901'), (SELECT id FROM cust WHERE customer_code='CUST-A'), 'completed', 0.51600000, 125000.00, 25000.00, '2026-03-08', '2026-03-14'),
  ('ORD-2026-009', (SELECT id FROM ship WHERE container_id='CMAU9988776'), (SELECT id FROM cust WHERE customer_code='CUST-C'), 'in_transit', 0.51200000, 95200.00, 17000.00, '2026-03-12', '2026-03-18'),
  ('ORD-2026-010', (SELECT id FROM ship WHERE container_id='MSCU5567890'), (SELECT id FROM cust WHERE customer_code='CUST-D'), 'in_transit', 0.50900000, 72000.00, 16000.00, '2026-03-19', '2026-03-25'),
  ('ORD-2026-011', (SELECT id FROM ship WHERE container_id='EVRU1122334'), (SELECT id FROM cust WHERE customer_code='CUST-F'), 'delivered', 0.51300000, 63000.00, 14000.00, '2026-03-17', '2026-03-23'),
  ('ORD-2026-012', (SELECT id FROM ship WHERE container_id='CSNU4456789'), (SELECT id FROM cust WHERE customer_code='CUST-E'), 'draft', 0.51100000, 92500.00, 18500.00, '2026-03-30', '2026-04-05');

-- 12.15 Order Lines
WITH
  ord AS (SELECT id, order_number FROM wwg_orders),
  prod AS (SELECT id, product_code FROM wwg_products)
INSERT INTO wwg_order_lines (order_id, line_number, product_id, description, quantity_kg, buy_price_per_kg, sell_price_per_kg, line_buy_value, line_sell_value, planned_margin_pct) VALUES
  ((SELECT id FROM ord WHERE order_number='ORD-2026-001'), 1, (SELECT id FROM prod WHERE product_code='FRZ-BMB-001'), 'Frozen Beef BMB', 24000.00, 5.6000, 3.6000, 134400.00, 86400.00, 15.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-002'), 1, (SELECT id FROM prod WHERE product_code='CHL-LMB-001'), 'Chilled Lamb Shortloin', 18000.00, 8.2000, 5.4000, 147600.00, 97200.00, 18.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-003'), 1, (SELECT id FROM prod WHERE product_code='CHL-BEF-001'), 'Chilled Beef Striploin', 20000.00, 9.0000, 6.0000, 180000.00, 120000.00, 18.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-004'), 1, (SELECT id FROM prod WHERE product_code='FRZ-LMB-001'), 'Frozen Lamb Leg Bone-In', 22000.00, 7.5000, 5.0000, 165000.00, 110000.00, 16.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-005'), 1, (SELECT id FROM prod WHERE product_code='FRZ-GOT-001'), 'Frozen Goat Carcass', 19000.00, 6.8000, 4.5000, 129200.00, 85500.00, 14.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-006'), 1, (SELECT id FROM prod WHERE product_code='FRZ-LMB-002'), 'Frozen Lamb Rack Cap Off', 21000.00, 7.8000, 5.0000, 163800.00, 105000.00, 14.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-007'), 1, (SELECT id FROM prod WHERE product_code='FRS-LMB-001'), 'Fresh Lamb CA Whole Carcass', 15000.00, 7.6000, 5.2500, 114000.00, 78750.00, 12.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-008'), 1, (SELECT id FROM prod WHERE product_code='FRZ-BMB-002'), 'Frozen Beef Trim 85CL', 25000.00, 7.6000, 5.0000, 190000.00, 125000.00, 16.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-009'), 1, (SELECT id FROM prod WHERE product_code='CHL-BEF-002'), 'Chilled Beef Cube Roll', 17000.00, 8.5000, 5.6000, 144500.00, 95200.00, 15.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-010'), 1, (SELECT id FROM prod WHERE product_code='FRZ-VEL-001'), 'Frozen Veal Osso Buco', 16000.00, 6.6000, 4.5000, 105600.00, 72000.00, 13.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-011'), 1, (SELECT id FROM prod WHERE product_code='FRS-LMB-002'), 'Fresh Lamb CA Shoulder', 14000.00, 6.5000, 4.5000, 91000.00, 63000.00, 11.00),
  ((SELECT id FROM ord WHERE order_number='ORD-2026-012'), 1, (SELECT id FROM prod WHERE product_code='CHL-LMB-002'), 'Chilled Lamb Tenderloin', 18500.00, 7.8000, 5.0000, 144300.00, 92500.00, 14.00);

-- 12.16 FX Rates
INSERT INTO wwg_fx_rates (base_currency, quote_currency, rate, rate_type, effective_date, valid_until, source) VALUES
  ('AUD', 'GBP', 0.51200000, 'spot', '2026-01-14', '2026-01-20', 'Reuters'),
  ('AUD', 'GBP', 0.51500000, 'spot', '2026-01-21', '2026-02-03', 'Reuters'),
  ('AUD', 'GBP', 0.51300000, 'spot', '2026-02-04', '2026-02-17', 'Reuters'),
  ('AUD', 'GBP', 0.51100000, 'spot', '2026-02-18', '2026-03-03', 'Reuters'),
  ('AUD', 'GBP', 0.51400000, 'spot', '2026-03-04', NULL, 'Reuters'),
  ('AUD', 'USD', 0.65000000, 'spot', '2026-01-14', '2026-02-03', 'Reuters'),
  ('AUD', 'USD', 0.64800000, 'spot', '2026-02-04', '2026-03-03', 'Reuters'),
  ('AUD', 'USD', 0.65200000, 'spot', '2026-03-04', NULL, 'Reuters'),
  ('USD', 'GBP', 0.78900000, 'spot', '2026-01-14', '2026-03-03', 'Reuters'),
  ('USD', 'GBP', 0.79100000, 'spot', '2026-03-04', NULL, 'Reuters');

-- 12.17 Landed Costs (per shipment)
WITH ship AS (SELECT id, container_id FROM wwg_shipments)
INSERT INTO wwg_landed_costs (shipment_id, fob_value_aud, freight_cost_usd, insurance_cost_usd, customs_duty_gbp, clearance_fees_gbp, cold_storage_gbp, last_mile_gbp, demurrage_gbp, total_landed_cost_gbp, cost_per_kg_gbp, fx_rate_aud_gbp, fx_rate_usd_gbp) VALUES
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), 134400.00, 4800.00, 960.00, 3456.00, 450.00, 1200.00, 850.00, 6400.00, 81196.00, 3.3832, 0.51200, 0.78900),
  ((SELECT id FROM ship WHERE container_id='CMAU6712890'), 147600.00, 5200.00, 1040.00, 3888.00, 450.00, 1400.00, 750.00, 4800.00, 88298.00, 4.9054, 0.51500, 0.78900),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), 180000.00, 5000.00, 1500.00, 4680.00, 450.00, 1800.00, 900.00, 4800.00, 106370.00, 5.3185, 0.51300, 0.78900),
  ((SELECT id FROM ship WHERE container_id='MSCU3345678'), 165000.00, 4500.00, 900.00, 4290.00, 450.00, 1100.00, 850.00, 8000.00, 98360.00, 4.4709, 0.50800, 0.78900),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), 129200.00, 5400.00, 1080.00, 3330.00, 450.00, 1300.00, 850.00, 3200.00, 75192.00, 3.9575, 0.51100, 0.78900),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), 163800.00, 4200.00, 840.00, 4212.00, 450.00, 800.00, 900.00, 0.00, 90478.00, 4.3085, 0.51400, 0.78900),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), 114000.00, 5800.00, 1160.00, 2925.00, 450.00, 1600.00, 750.00, 4000.00, 67925.00, 4.5283, 0.51000, 0.78900),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), 190000.00, 4600.00, 920.00, 4875.00, 450.00, 900.00, 850.00, 0.00, 105071.00, 4.2028, 0.51600, 0.78900),
  ((SELECT id FROM ship WHERE container_id='CMAU9988776'), 144500.00, 5000.00, 1000.00, 3744.00, 450.00, 1500.00, 900.00, 2400.00, 82974.00, 4.8808, 0.51200, 0.78900),
  ((SELECT id FROM ship WHERE container_id='MSCU5567890'), 105600.00, 4800.00, 960.00, 2700.00, 450.00, 1200.00, 850.00, 2400.00, 62352.00, 3.8970, 0.50900, 0.78900),
  ((SELECT id FROM ship WHERE container_id='EVRU1122334'), 91000.00, 4000.00, 800.00, 2340.00, 450.00, 600.00, 750.00, 0.00, 51033.00, 3.6452, 0.51300, 0.78900),
  ((SELECT id FROM ship WHERE container_id='CSNU4456789'), 144300.00, 5200.00, 1040.00, 3700.00, 450.00, 1100.00, 900.00, 0.00, 80160.00, 4.3330, 0.51100, 0.78900);

-- 12.18 Impact Assessments (QVF value chain — the demo money shot)
WITH ship AS (SELECT id, container_id FROM wwg_shipments)
INSERT INTO wwg_impact_assessments (shipment_id, assessment_date, risk_score, risk_severity, delay_days, spoilage_cost_gbp, demurrage_cost_gbp, sla_penalty_gbp, total_impact_gbp, risk_factors, reasoning, confidence) VALUES
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), '2026-02-20', 7.5, 'HIGH', 8, 9600.00, 6400.00, 1500.00, 17500.00,
    ARRAY['Red Sea reroute','Cape route +8 days','Frozen product — low spoilage risk'],
    ARRAY['Delay triggers demurrage at £800/day','SLA breach (>5d) triggers penalty','Frozen product mitigates spoilage — delay cost only'], 0.90),
  ((SELECT id FROM ship WHERE container_id='CMAU6712890'), '2026-02-20', 8.2, 'HIGH', 6, 7200.00, 4800.00, 500.00, 12500.00,
    ARRAY['Red Sea reroute','Chilled product — elevated spoilage risk','6-day delay on 28-day shelf life'],
    ARRAY['Chilled lamb loses 6 days of 28-day shelf life (21% reduction)','Demurrage £800/day','SLA penalty triggered at 6 days'], 0.88),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), '2026-02-20', 9.5, 'CRITICAL', 6, 27000.00, 4800.00, 3000.00, 34800.00,
    ARRAY['Reefer fault — 2.8C deviation sustained','Chilled beef — extreme spoilage risk','Mandatory vet check on arrival','Insurance claim threshold exceeded'],
    ARRAY['Temp breach: £15,000 base + 6 days * £3,000 = £33,000 spoilage risk (capped at £27,000 assessed loss)','Demurrage: 6 * £800','SLA penalty: 6 * £500','Full cargo may be condemned at BCP inspection'], 0.95),
  ((SELECT id FROM ship WHERE container_id='MSCU3345678'), '2026-02-15', 7.8, 'HIGH', 10, 0.00, 8000.00, 2500.00, 10500.00,
    ARRAY['Suez-to-Cape mid-voyage diversion','Frozen lamb — no spoilage','Longest delay in fleet'],
    ARRAY['Frozen product = zero spoilage despite 10-day delay','Demurrage: 10 * £800','SLA penalty: 10 * £500 (>5 day threshold)'], 0.92),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), '2026-02-25', 5.5, 'MEDIUM', 4, 0.00, 3200.00, 0.00, 3200.00,
    ARRAY['Weather delay + Tilbury congestion','Frozen goat — no spoilage','4-day delay within SLA tolerance'],
    ARRAY['Frozen product = zero spoilage','Demurrage: 4 * £800','4 days under 5-day SLA penalty threshold'], 0.85),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), '2026-02-27', 1.0, 'LOW', -2, 0.00, 0.00, 0.00, 0.00,
    ARRAY['Ceasefire benefit — 2 days early','Suez route restored','Reduced cold storage costs'],
    ARRAY['Early arrival = zero demurrage','Zero spoilage risk — frozen product','Saved £800 cold storage (2 fewer days)'], 0.95),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), '2026-03-01', 7.0, 'HIGH', 5, 8750.00, 4000.00, 0.00, 12750.00,
    ARRAY['Hormuz diversion','Fresh lamb — highest spoilage risk','5-day delay on 14-day shelf life'],
    ARRAY['Fresh lamb loses 5 of 14 shelf-life days (36% reduction)','Spoilage risk: reduced sell window at destination','Demurrage: 5 * £800','5 days = on SLA penalty threshold (not exceeded)'], 0.82),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), '2026-03-11', 0.5, 'LOW', 0, 0.00, 0.00, 0.00, 0.00,
    ARRAY['On-time delivery','Zero temperature issues','Clean compliance'],
    ARRAY['Benchmark delivery — zero impact','Planned margin fully realised','Customer satisfaction: maximum'], 0.98),
  ((SELECT id FROM ship WHERE container_id='CMAU9988776'), '2026-03-15', 4.5, 'MEDIUM', 3, 3600.00, 2400.00, 0.00, 6000.00,
    ARRAY['Carrier slow-steam decision','Chilled product — moderate spoilage','3-day delay within tolerance'],
    ARRAY['Chilled beef loses 3 of 28 shelf-life days (11%)','Demurrage: 3 * £800','Under 5-day SLA penalty threshold'], 0.85),
  ((SELECT id FROM ship WHERE container_id='MSCU5567890'), '2026-03-22', 3.5, 'MEDIUM', 3, 0.00, 2400.00, 0.00, 2400.00,
    ARRAY['MSC slow-steam advisory','Frozen veal — no spoilage','3-day delay'],
    ARRAY['Frozen product = zero spoilage','Demurrage: 3 * £800','Under SLA penalty threshold'], 0.87),
  ((SELECT id FROM ship WHERE container_id='EVRU1122334'), '2026-03-20', 0.8, 'LOW', 0, 0.00, 0.00, 0.00, 0.00,
    ARRAY['On-time via Suez','Normal transit — no issues'],
    ARRAY['Clean delivery — zero impact','Fresh lamb within shelf life window'], 0.95),
  ((SELECT id FROM ship WHERE container_id='CSNU4456789'), '2026-03-31', 1.2, 'LOW', 0, 0.00, 0.00, 0.00, 0.00,
    ARRAY['Booked — not yet departed','Planned Cape route — no known risks'],
    ARRAY['Pre-departure assessment — baseline risk only'], 0.70);

-- 12.19 Margin Analysis (planned vs actual — the value demonstration)
WITH ship AS (SELECT id, container_id FROM wwg_shipments),
     ord AS (SELECT id, order_number FROM wwg_orders)
INSERT INTO wwg_margin_analysis (shipment_id, order_id, planned_sell_value_gbp, planned_cost_gbp, planned_margin_gbp, planned_margin_pct, actual_sell_value_gbp, actual_cost_gbp, actual_margin_gbp, actual_margin_pct, margin_erosion_gbp, margin_erosion_pct, erosion_cause) VALUES
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM ord WHERE order_number='ORD-2026-001'), 86400.00, 74796.00, 11604.00, 15.00, 86400.00, 92296.00, -5896.00, -6.82, 17500.00, 21.82, 'combined'),
  ((SELECT id FROM ship WHERE container_id='CMAU6712890'), (SELECT id FROM ord WHERE order_number='ORD-2026-002'), 97200.00, 83498.00, 13702.00, 18.00, 97200.00, 95998.00, 1202.00, 1.24, 12500.00, 16.76, 'combined'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM ord WHERE order_number='ORD-2026-003'), 120000.00, 101570.00, 18430.00, 18.00, 120000.00, 136370.00, -16370.00, -13.64, 34800.00, 31.64, 'spoilage'),
  ((SELECT id FROM ship WHERE container_id='MSCU3345678'), (SELECT id FROM ord WHERE order_number='ORD-2026-004'), 110000.00, 90360.00, 19640.00, 16.00, 110000.00, 100860.00, 9140.00, 8.31, 10500.00, 7.69, 'delay'),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), (SELECT id FROM ord WHERE order_number='ORD-2026-005'), 85500.00, 71992.00, 13508.00, 14.00, 85500.00, 75192.00, 10308.00, 12.06, 3200.00, 1.94, 'delay'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM ord WHERE order_number='ORD-2026-006'), 105000.00, 91278.00, 13722.00, 14.00, 105000.00, 90478.00, 14522.00, 14.83, -800.00, -0.83, 'none'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM ord WHERE order_number='ORD-2026-007'), 78750.00, 63925.00, 14825.00, 12.00, 78750.00, 76675.00, 2075.00, 2.63, 12750.00, 9.37, 'combined'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), (SELECT id FROM ord WHERE order_number='ORD-2026-008'), 125000.00, 105071.00, 19929.00, 16.00, 125000.00, 105071.00, 19929.00, 15.94, 0.00, 0.00, 'none'),
  ((SELECT id FROM ship WHERE container_id='CMAU9988776'), (SELECT id FROM ord WHERE order_number='ORD-2026-009'), 95200.00, 80574.00, 14626.00, 15.00, 95200.00, 86574.00, 8626.00, 9.06, 6000.00, 5.94, 'delay'),
  ((SELECT id FROM ship WHERE container_id='MSCU5567890'), (SELECT id FROM ord WHERE order_number='ORD-2026-010'), 72000.00, 59952.00, 12048.00, 13.00, 72000.00, 62352.00, 9648.00, 13.40, 2400.00, -0.40, 'demurrage'),
  ((SELECT id FROM ship WHERE container_id='EVRU1122334'), (SELECT id FROM ord WHERE order_number='ORD-2026-011'), 63000.00, 51033.00, 11967.00, 11.00, 63000.00, 51033.00, 11967.00, 19.00, 0.00, 0.00, 'none'),
  ((SELECT id FROM ship WHERE container_id='CSNU4456789'), (SELECT id FROM ord WHERE order_number='ORD-2026-012'), 92500.00, 80160.00, 12340.00, 14.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- 12.20 Cashflow Events (3 key milestones per shipment)
WITH ship AS (SELECT id, container_id, departure_date, current_eta FROM wwg_shipments),
     ord AS (SELECT id, order_number FROM wwg_orders)
INSERT INTO wwg_cashflow_events (shipment_id, order_id, event_type, amount_gbp, direction, due_date, paid_date, status) VALUES
  -- MRKU4821073 (delayed — settlement pushed out)
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM ord WHERE order_number='ORD-2026-001'), 'deposit', 17280.00, 'inflow', '2026-01-07', '2026-01-07', 'paid'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM ord WHERE order_number='ORD-2026-001'), 'freight_payment', 3787.00, 'outflow', '2026-01-14', '2026-01-14', 'paid'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM ord WHERE order_number='ORD-2026-001'), 'settlement', 69120.00, 'inflow', '2026-02-26', NULL, 'overdue'),
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM ord WHERE order_number='ORD-2026-001'), 'demurrage', 6400.00, 'outflow', '2026-03-05', NULL, 'due'),
  -- HLXU9901234 (temp breach — penalty + insurance claim)
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM ord WHERE order_number='ORD-2026-003'), 'deposit', 24000.00, 'inflow', '2026-01-13', '2026-01-13', 'paid'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM ord WHERE order_number='ORD-2026-003'), 'freight_payment', 3945.00, 'outflow', '2026-01-20', '2026-01-20', 'paid'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM ord WHERE order_number='ORD-2026-003'), 'settlement', 96000.00, 'inflow', '2026-03-01', NULL, 'overdue'),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM ord WHERE order_number='ORD-2026-003'), 'penalty', 3000.00, 'outflow', '2026-03-05', NULL, 'due'),
  -- MRKU7734901 (normal — clean cashflow)
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), (SELECT id FROM ord WHERE order_number='ORD-2026-008'), 'deposit', 25000.00, 'inflow', '2026-01-29', '2026-01-29', 'paid'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), (SELECT id FROM ord WHERE order_number='ORD-2026-008'), 'freight_payment', 3629.00, 'outflow', '2026-02-05', '2026-02-05', 'paid'),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), (SELECT id FROM ord WHERE order_number='ORD-2026-008'), 'settlement', 100000.00, 'inflow', '2026-03-18', '2026-03-18', 'paid'),
  -- EVRU8821100 (early — all paid on time)
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM ord WHERE order_number='ORD-2026-006'), 'deposit', 21000.00, 'inflow', '2026-01-25', '2026-01-25', 'paid'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM ord WHERE order_number='ORD-2026-006'), 'freight_payment', 3314.00, 'outflow', '2026-02-01', '2026-02-01', 'paid'),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM ord WHERE order_number='ORD-2026-006'), 'settlement', 84000.00, 'inflow', '2026-03-06', '2026-03-06', 'paid'),
  -- CSNU2234567 (Hormuz divert — mixed)
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM ord WHERE order_number='ORD-2026-007'), 'deposit', 15750.00, 'inflow', '2026-01-21', '2026-01-21', 'paid'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM ord WHERE order_number='ORD-2026-007'), 'freight_payment', 4576.00, 'outflow', '2026-01-28', '2026-01-28', 'paid'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM ord WHERE order_number='ORD-2026-007'), 'settlement', 63000.00, 'inflow', '2026-03-19', NULL, 'scheduled'),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM ord WHERE order_number='ORD-2026-007'), 'demurrage', 4000.00, 'outflow', '2026-03-20', NULL, 'scheduled');

-- 12.21 Creditor Accounts
INSERT INTO wwg_creditor_accounts (entity_type, entity_name, entity_ref, credit_limit_gbp, current_balance_gbp, overdue_amount_gbp, days_past_due, payment_terms_days, blocked, block_reason, backlog_offer, backlog_offer_terms, last_payment_date, next_payment_due) VALUES
  ('supplier', 'Southern Cross Meats', 'SUP-AU-001', 200000.00, 68000.00, 0.00, 0, 30, false, NULL, false, NULL, '2026-03-15', '2026-04-14'),
  ('supplier', 'Outback Premium Foods', 'SUP-AU-002', 250000.00, 145000.00, 42000.00, 45, 30, true, 'Overdue >30 days. Two invoices past payment terms. Temp breach container HLXU9901234 settlement pending.', true, 'Restructured: 3 monthly instalments of £14,000 + continued trading at reduced credit limit £150,000', '2026-02-10', '2026-03-10'),
  ('supplier', 'Pacific Livestock Co', 'SUP-AU-003', 180000.00, 52000.00, 0.00, 0, 30, false, NULL, false, NULL, '2026-03-20', '2026-04-19'),
  ('supplier', 'Great Southern Lamb', 'SUP-AU-004', 220000.00, 78000.00, 12000.00, 15, 30, false, NULL, false, NULL, '2026-03-01', '2026-03-31'),
  ('supplier', 'Adelaide Valley Meats', 'SUP-AU-005', 150000.00, 55000.00, 0.00, 0, 30, false, NULL, false, NULL, '2026-03-18', '2026-04-17'),
  ('carrier', 'Maersk', 'MAERSK', 100000.00, 42000.00, 6400.00, 8, 14, false, NULL, false, NULL, '2026-03-20', '2026-03-28'),
  ('carrier', 'CMA CGM', 'CMA_CGM', 80000.00, 28000.00, 0.00, 0, 14, false, NULL, false, NULL, '2026-03-22', '2026-04-05'),
  ('carrier', 'Hapag-Lloyd', 'HAPAG', 90000.00, 35000.00, 4800.00, 12, 14, false, NULL, false, NULL, '2026-03-10', '2026-03-24'),
  ('agent', 'UK Customs Clearance Ltd', 'AGT-001', 30000.00, 8500.00, 0.00, 0, 7, false, NULL, false, NULL, '2026-03-25', '2026-04-01'),
  ('port_operator', 'Tilbury Port Authority', 'PORT-TIL', 50000.00, 18000.00, 3200.00, 5, 14, false, NULL, false, NULL, '2026-03-18', '2026-03-25');

-- 12.22 Insurance Profiles
WITH ship AS (SELECT id, container_id FROM wwg_shipments),
     corr AS (SELECT id, corridor_code FROM wwg_corridors)
INSERT INTO wwg_insurance_profiles (shipment_id, corridor_id, insured, policy_type, policy_number, provider, cover_amount_gbp, excess_gbp, exclusions, risk_band, claim_status, claim_amount_gbp) VALUES
  ((SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'marine_cargo', 'MC-2026-001', 'Lloyds Syndicate 4472', 100000.00, 5000.00, ARRAY['War risk excluded after Jan 2026 Red Sea advisory'], 'elevated', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='CMAU6712890'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'cargo_all_risks', 'CAR-2026-002', 'AXA Marine', 120000.00, 3000.00, ARRAY['Consequential loss cap £50k'], 'elevated', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'cargo_all_risks', 'CAR-2026-003', 'AXA Marine', 150000.00, 5000.00, ARRAY['Reefer breakdown: covered if maintained per manufacturer spec'], 'high', 'submitted', 29800.00),
  ((SELECT id FROM ship WHERE container_id='MSCU3345678'), (SELECT id FROM corr WHERE corridor_code='AU-UK-SUEZ'), true, 'marine_cargo', 'MC-2026-004', 'Lloyds Syndicate 4472', 130000.00, 5000.00, ARRAY['War risk excluded'], 'elevated', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='OOLU7789012'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'marine_cargo', 'MC-2026-005', 'Zurich Marine', 100000.00, 3000.00, ARRAY['Weather delay: vessel must follow met office routing advice'], 'standard', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM corr WHERE corridor_code='AU-UK-SUEZ'), true, 'marine_cargo', 'MC-2026-006', 'Zurich Marine', 120000.00, 3000.00, NULL, 'low', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), false, 'marine_cargo', NULL, NULL, NULL, 0.00, NULL, 'high', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='MRKU7734901'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'cargo_all_risks', 'CAR-2026-008', 'AXA Marine', 150000.00, 3000.00, NULL, 'standard', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='CMAU9988776'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'marine_cargo', 'MC-2026-009', 'Lloyds Syndicate 4472', 110000.00, 5000.00, NULL, 'standard', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='MSCU5567890'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'marine_cargo', 'MC-2026-010', 'Zurich Marine', 90000.00, 3000.00, NULL, 'standard', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='EVRU1122334'), (SELECT id FROM corr WHERE corridor_code='AU-UK-SUEZ'), true, 'marine_cargo', 'MC-2026-011', 'Zurich Marine', 80000.00, 2000.00, NULL, 'low', 'none', NULL),
  ((SELECT id FROM ship WHERE container_id='CSNU4456789'), (SELECT id FROM corr WHERE corridor_code='AU-UK-CAPE'), true, 'cargo_all_risks', 'CAR-2026-012', 'AXA Marine', 110000.00, 3000.00, NULL, 'standard', 'none', NULL);

-- 12.23 Customer Satisfaction (correlated with delivery performance)
WITH ship AS (SELECT id, container_id FROM wwg_shipments),
     cust AS (SELECT id, customer_code FROM wwg_customers),
     ord AS (SELECT id, order_number FROM wwg_orders)
INSERT INTO wwg_customer_satisfaction (customer_id, shipment_id, order_id, overall_score, on_time_score, quality_score, communication_score, repeat_business_probability, feedback_text, delivery_delta_days) VALUES
  ((SELECT id FROM cust WHERE customer_code='CUST-A'), (SELECT id FROM ship WHERE container_id='MRKU7734901'), (SELECT id FROM ord WHERE order_number='ORD-2026-008'), 9.2, 10.0, 9.0, 8.5, 0.92, 'On-time delivery, excellent product quality. Consistent and reliable.', 0),
  ((SELECT id FROM cust WHERE customer_code='CUST-A'), (SELECT id FROM ship WHERE container_id='MRKU4821073'), (SELECT id FROM ord WHERE order_number='ORD-2026-001'), 4.5, 2.0, 7.0, 5.5, 0.45, 'Significant delay due to rerouting. Product quality acceptable but delivery window missed by 8 days.', 8),
  ((SELECT id FROM cust WHERE customer_code='CUST-B'), (SELECT id FROM ship WHERE container_id='CMAU6712890'), (SELECT id FROM ord WHERE order_number='ORD-2026-002'), 5.0, 3.0, 6.0, 6.0, 0.50, 'Chilled lamb delayed 6 days. Reduced shelf life impacted our distribution window. Need improvement.', 6),
  ((SELECT id FROM cust WHERE customer_code='CUST-C'), (SELECT id FROM ship WHERE container_id='HLXU9901234'), (SELECT id FROM ord WHERE order_number='ORD-2026-003'), 2.5, 2.0, 1.0, 4.5, 0.20, 'Temperature breach is unacceptable. Product quality compromised. Considering alternative suppliers.', 6),
  ((SELECT id FROM cust WHERE customer_code='CUST-D'), (SELECT id FROM ship WHERE container_id='OOLU7789012'), (SELECT id FROM ord WHERE order_number='ORD-2026-005'), 6.5, 5.0, 8.0, 6.5, 0.65, 'Minor delay acceptable given weather conditions. Good communication of ETA changes.', 4),
  ((SELECT id FROM cust WHERE customer_code='CUST-E'), (SELECT id FROM ship WHERE container_id='EVRU8821100'), (SELECT id FROM ord WHERE order_number='ORD-2026-006'), 9.5, 10.0, 9.5, 9.0, 0.95, 'Early delivery — excellent. Product in perfect condition. Very satisfied.', -2),
  ((SELECT id FROM cust WHERE customer_code='CUST-F'), (SELECT id FROM ship WHERE container_id='EVRU1122334'), (SELECT id FROM ord WHERE order_number='ORD-2026-011'), 8.0, 9.0, 7.5, 7.5, 0.80, 'On-time delivery. Fresh lamb in good condition. Good first order experience.', 0),
  ((SELECT id FROM cust WHERE customer_code='CUST-B'), (SELECT id FROM ship WHERE container_id='CSNU2234567'), (SELECT id FROM ord WHERE order_number='ORD-2026-007'), 4.0, 3.0, 5.0, 5.0, 0.40, 'Fresh lamb delayed 5 days — shelf life significantly impacted. Uninsured shipment adds concern.', 5);

-- 12.24 Customer Notifications
WITH ship AS (SELECT id, container_id FROM wwg_shipments),
     cust AS (SELECT id, customer_code FROM wwg_customers)
INSERT INTO wwg_customer_notifications (customer_id, shipment_id, notification_type, channel, subject, sent_at, acknowledged) VALUES
  ((SELECT id FROM cust WHERE customer_code='CUST-A'), (SELECT id FROM ship WHERE container_id='MRKU4821073'), 'delay_alert', 'email', 'ETA Update: MRKU4821073 — Red Sea reroute, revised ETA 26 Feb', '2026-01-23 09:00:00+00', true),
  ((SELECT id FROM cust WHERE customer_code='CUST-C'), (SELECT id FROM ship WHERE container_id='HLXU9901234'), 'temp_breach', 'email', 'ALERT: Temperature Breach — HLXU9901234 Chilled Beef Striploin', '2026-02-03 14:00:00+00', true),
  ((SELECT id FROM cust WHERE customer_code='CUST-C'), (SELECT id FROM ship WHERE container_id='HLXU9901234'), 'eta_update', 'email', 'ETA Update: HLXU9901234 — revised ETA 28 Feb + vet inspection required', '2026-02-07 10:00:00+00', true),
  ((SELECT id FROM cust WHERE customer_code='CUST-E'), (SELECT id FROM ship WHERE container_id='EVRU8821100'), 'delivery_confirmed', 'email', 'Delivery Confirmed: EVRU8821100 — arrived 2 days early at Southampton', '2026-02-27 16:00:00+00', true),
  ((SELECT id FROM cust WHERE customer_code='CUST-A'), (SELECT id FROM ship WHERE container_id='MRKU7734901'), 'delivery_confirmed', 'email', 'Delivery Confirmed: MRKU7734901 — on-time at Tilbury', '2026-03-11 12:00:00+00', true),
  ((SELECT id FROM cust WHERE customer_code='CUST-D'), (SELECT id FROM ship WHERE container_id='OOLU7789012'), 'delay_alert', 'email', 'ETA Update: OOLU7789012 — weather delay + Tilbury congestion, revised ETA 6 Mar', '2026-02-06 08:00:00+00', true),
  ((SELECT id FROM cust WHERE customer_code='CUST-B'), (SELECT id FROM ship WHERE container_id='CSNU2234567'), 'delay_alert', 'teams', 'ETA Update: CSNU2234567 — Hormuz diversion, revised ETA 12 Mar', '2026-02-09 11:00:00+00', false),
  ((SELECT id FROM cust WHERE customer_code='CUST-A'), (SELECT id FROM ship WHERE container_id='MSCU3345678'), 'delay_alert', 'email', 'ETA Update: MSCU3345678 — Suez-to-Cape diversion, +10 day delay', '2026-01-21 10:00:00+00', true);

-- 12.25 SLA Tracking (Q1 2026 per customer)
WITH cust AS (SELECT id, customer_code FROM wwg_customers)
INSERT INTO wwg_sla_tracking (customer_id, period_start, period_end, total_shipments, on_time_shipments, on_time_pct, temp_compliant_shipments, temp_compliance_pct, doc_accuracy_pct, sla_met) VALUES
  ((SELECT id FROM cust WHERE customer_code='CUST-A'), '2026-01-01', '2026-03-31', 3, 1, 33.33, 3, 100.00, 98.00, false),
  ((SELECT id FROM cust WHERE customer_code='CUST-B'), '2026-01-01', '2026-03-31', 2, 0, 0.00, 2, 100.00, 95.00, false),
  ((SELECT id FROM cust WHERE customer_code='CUST-C'), '2026-01-01', '2026-03-31', 2, 0, 0.00, 1, 50.00, 97.00, false),
  ((SELECT id FROM cust WHERE customer_code='CUST-D'), '2026-01-01', '2026-03-31', 2, 0, 0.00, 2, 100.00, 96.00, false),
  ((SELECT id FROM cust WHERE customer_code='CUST-E'), '2026-01-01', '2026-03-31', 2, 1, 50.00, 2, 100.00, 99.00, false),
  ((SELECT id FROM cust WHERE customer_code='CUST-F'), '2026-01-01', '2026-03-31', 1, 1, 100.00, 1, 100.00, 100.00, true);

-- 12.26 RAID Log
INSERT INTO wwg_raid_log (raid_type, raid_id, title, description, severity, status, owner, probability, impact, mitigation, related_entity_type, related_entity_id) VALUES
  ('risk', 'R-001', 'Red Sea Route Disruption', 'Houthi attacks force Cape reroute — +6-10 day delay, increased freight/insurance costs', 'CRITICAL', 'mitigated', 'Operations', 'almost_certain', 'Fleet-wide ETA delay, £100k+ aggregate impact', 'Cape reroute as standard. War risk insurance reviewed.', 'risk_event', 'Houthi'),
  ('risk', 'R-002', 'Cold-Chain Equipment Failure', 'Reefer compressor or thermostat failure causing temperature breach', 'HIGH', 'open', 'Operations', 'possible', 'Product condemnation, £20-35k per container', 'Pre-trip inspections mandated. Carrier SLAs include reefer monitoring.', 'shipment', 'HLXU9901234'),
  ('risk', 'R-003', 'Creditor Default Risk', 'Supplier unable to meet payment terms due to delayed settlements', 'HIGH', 'open', 'Finance', 'likely', 'Supply chain disruption if blocked', 'Backlog offer mechanism. Credit limit reviews monthly.', 'creditor', 'SUP-AU-002'),
  ('risk', 'R-004', 'Uninsured Shipment Exposure', 'CSNU2234567 transiting uninsured on high-risk corridor', 'HIGH', 'accepted', 'Finance', 'possible', 'Full financial exposure £12,750 if incident occurs', 'Accepted risk — cost of insurance exceeded expected loss. Review policy for fresh products.', 'shipment', 'CSNU2234567'),
  ('assumption', 'A-001', 'Datalastic API Available', 'AIS vessel tracking data available via Datalastic trial key', 'MEDIUM', 'open', 'Technology', NULL, NULL, NULL, NULL, NULL),
  ('assumption', 'A-002', 'Suez Canal Will Reopen', 'Ceasefire holds and Suez transit normalises within Q2 2026', 'HIGH', 'open', 'Operations', NULL, NULL, NULL, NULL, NULL),
  ('assumption', 'A-003', 'Halal Certification Accepted', 'AU halal certificates accepted by UK APHA without additional verification', 'LOW', 'accepted', 'Compliance', NULL, NULL, NULL, NULL, NULL),
  ('assumption', 'A-004', 'FX Rates Stable', 'AUD/GBP remains within 0.49-0.53 range for planning period', 'MEDIUM', 'open', 'Finance', NULL, NULL, NULL, NULL, NULL),
  ('issue', 'I-001', 'HLXU9901234 Temperature Breach', 'Reefer fault caused 2.8C deviation for >24hrs. Product quality compromised. Insurance claim submitted.', 'CRITICAL', 'escalated', 'Operations', NULL, '£34,800 total impact. Customer C relationship at risk.', 'Insurance claim CAR-2026-003 submitted. Vet inspection arranged.', 'shipment', 'HLXU9901234'),
  ('issue', 'I-002', 'Outback Premium Foods Overdue', 'Supplier SUP-AU-002 overdue £42,000 (45 days). Credit blocked. Backlog offer issued.', 'HIGH', 'open', 'Finance', NULL, 'Supply disruption if not resolved. Two containers affected.', 'Backlog offer: 3x £14k instalments. Reduced credit limit proposed.', 'creditor', 'SUP-AU-002'),
  ('issue', 'I-003', 'Tilbury Port Congestion', 'Industrial action reduced handling capacity 40%. Two containers delayed.', 'MEDIUM', 'mitigated', 'Operations', NULL, '+2 day delay for GBTIL-bound containers', 'Divert overflow to Southampton where possible.', 'risk_event', 'Tilbury'),
  ('dependency', 'D-001', 'Datalastic Trial Key', 'Live AIS data depends on Datalastic providing trial API key', 'MEDIUM', 'open', 'Technology', NULL, NULL, NULL, NULL, NULL),
  ('dependency', 'D-002', 'Sage 200 Access', 'Epic 91 accounting integration requires client Sage 200 API access', 'HIGH', 'open', 'Technology', NULL, NULL, NULL, NULL, NULL),
  ('dependency', 'D-003', 'Microsoft 365 Tenant', 'MS365 integration requires client tenant configuration (Epic 90 F90.5/F90.10)', 'HIGH', 'open', 'Technology', NULL, NULL, NULL, NULL, NULL),
  ('requirement', 'REQ-001', 'BTOM Compliance', 'All meat imports must comply with Border Target Operating Model (BTOM) requirements', 'HIGH', 'open', 'Compliance', NULL, NULL, NULL, NULL, NULL),
  ('requirement', 'REQ-002', 'Halal Certification Chain', 'End-to-end halal certification from AU establishment to UK distribution', 'HIGH', 'open', 'Compliance', NULL, NULL, NULL, NULL, NULL);

-- 12.27 RMF Assessments
INSERT INTO wwg_rmf_assessments (assessment_ref, title, scope, asset_type, threat_type, vulnerability, likelihood, impact_level, risk_rating, treatment_plan, treatment_status, risk_owner, review_date) VALUES
  ('RMF-001', 'AIS Data Integrity', 'Vessel tracking data from Datalastic/VesselFinder APIs', 'data', 'cyber', 'API keys transmitted as query parameters. No mutual TLS.', 'possible', 'moderate', 'MEDIUM', 'Migrate to header-based auth. Implement response signature verification.', 'planned', 'CTO', '2026-04-30'),
  ('RMF-002', 'Cold-Chain IoT Sensor Tampering', 'Temperature readings from reefer container sensors', 'system', 'physical', 'Sensor firmware not signed. Physical access possible at port.', 'unlikely', 'major', 'HIGH', 'Require signed firmware. Implement anomaly detection on reading patterns.', 'identified', 'Operations', '2026-05-31'),
  ('RMF-003', 'Customer Data Residency', 'UK customer PII stored in Supabase (Stockholm region)', 'data', 'regulatory', 'Data stored outside UK jurisdiction. Post-Brexit data adequacy may change.', 'possible', 'major', 'HIGH', 'Migrate to UK-hosted or implement data-at-rest encryption with UK-held keys.', 'planned', 'DPO', '2026-06-30');

-- 12.28 RMF Controls
WITH rmf AS (SELECT id, assessment_ref FROM wwg_rmf_assessments)
INSERT INTO wwg_rmf_controls (assessment_id, control_ref, control_type, description, iso_27001_ref, implementation_status, effectiveness) VALUES
  ((SELECT id FROM rmf WHERE assessment_ref='RMF-001'), 'CTL-001', 'preventive', 'API key rotation every 90 days', 'A.9.4', 'implemented', 'effective'),
  ((SELECT id FROM rmf WHERE assessment_ref='RMF-001'), 'CTL-002', 'detective', 'Log all API calls with response hash for tamper detection', 'A.12.4', 'implemented', 'effective'),
  ((SELECT id FROM rmf WHERE assessment_ref='RMF-002'), 'CTL-003', 'detective', 'Anomaly detection: flag readings >2 std dev from rolling average', 'A.12.4', 'planned', 'not_tested'),
  ((SELECT id FROM rmf WHERE assessment_ref='RMF-002'), 'CTL-004', 'preventive', 'Physical seal on reefer sensor access panels', 'A.11.1', 'in_progress', 'partially_effective'),
  ((SELECT id FROM rmf WHERE assessment_ref='RMF-003'), 'CTL-005', 'compensating', 'Column-level encryption on customer PII (email, phone, address)', 'A.10.1', 'planned', 'not_tested');

-- 12.29 4Voices Insights (Predictive Analytics)
INSERT INTO wwg_insights (perspective, insight_category, horizon, title, narrative, evidence, impact_assessment, confidence, predicted_probability, predicted_impact_gbp, data_sources, related_entity_type, related_entity_id) VALUES
  -- MACRO
  ('macro', 'trend', 'medium_term', 'Red Sea Disruption — Structural Shift to Cape Route', 'Global shipping patterns show sustained Cape rerouting since Jan 2026. Insurance premiums for Red Sea transit have increased 300%. Even with ceasefire, carriers are cautious about returning to Suez.', '{"freight_rate_increase_pct": 35, "insurance_premium_increase_pct": 300, "carriers_returned_to_suez": 2, "carriers_still_cape": 5}', 'Continued +8-10 day transit times and elevated freight costs for AU-UK corridor through H1 2026', 0.85, 0.75, 180000.00, ARRAY['wwg_risk_events','wwg_shipments','wwg_landed_costs'], 'corridor', 'AU-UK-CAPE'),
  ('macro', 'inflexion', 'short_term', 'Ceasefire Creates Suez Reopening Window', 'UN-brokered ceasefire effective 1 Mar 2026. Two carriers (Evergreen, CMA CGM) announcing trial Suez transits. If sustained, transit times reduce 7-10 days.', '{"ceasefire_date": "2026-03-01", "trial_carriers": ["Evergreen","CMA CGM"], "expected_saving_days": 8}', 'If ceasefire holds: £15k-20k per-shipment cost reduction. If fails: reversion to Cape with additional insurance repricing.', 0.60, 0.55, -200000.00, ARRAY['wwg_risk_events'], NULL, NULL),
  -- INDUSTRY
  ('industry', 'swot_strength', 'immediate', 'Full Cold-Chain Visibility Across Fleet', 'Real-time temperature monitoring, shelf-life calculation, and BTOM compliance tracking gives competitive advantage over importers relying on carrier reports alone.', '{"containers_monitored": 12, "breach_detection_time_hrs": 0.5, "compliance_gate_coverage_pct": 100}', 'Reduced spoilage, faster compliance clearance, stronger customer trust', 0.90, NULL, NULL, ARRAY['wwg_cold_chain_readings','wwg_compliance_gates'], NULL, NULL),
  ('industry', 'swot_threat', 'medium_term', 'AU Meat Export Regulatory Tightening', 'DAFF signalling stricter halal certification requirements and enhanced traceability from farm to port. May increase lead times for export documentation.', '{"regulation_expected": "Q3 2026", "affected_products": "all halal-certified"}', 'Potential 2-3 day delay at origin port for additional documentation checks', 0.70, 0.65, 25000.00, ARRAY['external'], NULL, NULL),
  ('industry', 'swot_opportunity', 'short_term', 'Premium Pricing for Verified Cold-Chain', 'UK retailers increasingly require proof of unbroken cold chain. Importers who can provide IoT-verified temperature logs command 5-8% price premium.', '{"premium_range_pct": "5-8", "retailers_requiring": ["Tesco","Sainsburys","M&S"]}', 'Potential £4-6k per shipment additional margin if cold-chain verification productised', 0.80, 0.70, 60000.00, ARRAY['wwg_cold_chain_readings','wwg_products'], NULL, NULL),
  -- CORRIDOR
  ('corridor', 'prediction', 'short_term', 'AU-UK Cape Route — Freight Rate Stabilisation', 'After 35% spike in Jan-Feb, Cape route freight rates showing signs of stabilisation as carrier capacity adjusts. Expect rates to settle 15-20% above pre-crisis levels.', '{"jan_rate_usd_teu": 4800, "feb_rate_usd_teu": 5200, "mar_rate_usd_teu": 5100, "predicted_stabilisation": 4200}', 'Landed cost reduction of £800-1200 per container from Q2 2026', 0.75, 0.70, -14400.00, ARRAY['wwg_landed_costs','wwg_fx_rates'], 'corridor', 'AU-UK-CAPE'),
  ('corridor', 'anomaly', 'immediate', 'Tilbury Port Recovery Slower Than Expected', 'Post-industrial action, Tilbury handling rates recovering at 70% (expected 90% by now). May indicate deeper operational issues.', '{"current_capacity_pct": 70, "expected_capacity_pct": 90, "recovery_days": 10}', 'Continue routing overflow to Southampton. Monitor weekly.', 0.80, NULL, 8000.00, ARRAY['wwg_risk_events','wwg_alerts'], 'port', 'GBTIL'),
  -- OPERATIONAL
  ('operational', 'prediction', 'immediate', 'HLXU9901234 — High Probability of BCP Rejection', 'Temperature breach of 2.8C for >24hrs on chilled beef. Historical BCP rejection rate for similar breaches: 65%. Vet inspection mandatory.', '{"deviation_celsius": 2.8, "breach_duration_hrs": 28, "historical_rejection_rate": 0.65, "product_type": "chilled_beef"}', 'If rejected: total loss £120k sell value + disposal costs. Insurance claim submitted for £29.8k (partial cover).', 0.88, 0.65, 120000.00, ARRAY['wwg_cold_chain_readings','wwg_impact_assessments','wwg_insurance_profiles'], 'shipment', 'HLXU9901234'),
  ('operational', 'swot_weakness', 'immediate', 'Uninsured Fresh Lamb Shipment — Full Exposure', 'Container CSNU2234567 (fresh lamb, Hormuz divert, +5d delay) transiting without marine cargo insurance. Full financial exposure if incident occurs.', '{"container": "CSNU2234567", "product": "fresh_lamb", "exposure_gbp": 78750, "delay_days": 5}', 'Immediate action: review insurance policy for all fresh product shipments. Consider blanket cover.', 0.95, NULL, 78750.00, ARRAY['wwg_insurance_profiles','wwg_impact_assessments'], 'shipment', 'CSNU2234567'),
  ('operational', 'opportunity', 'short_term', 'Creditor Backlog Resolution — Unlock Supply Capacity', 'Outback Premium Foods (SUP-AU-002) blocked at £42k overdue. Backlog offer of 3x £14k instalments would unblock £250k credit capacity. Two containers dependent.', '{"supplier": "SUP-AU-002", "overdue_gbp": 42000, "blocked_capacity_gbp": 250000, "instalments": 3}', 'Resolving backlog unlocks preferred supplier for chilled beef (HLXU9901234 replacement orders).', 0.85, 0.80, 42000.00, ARRAY['wwg_creditor_accounts','wwg_raid_log'], 'creditor', 'SUP-AU-002'),
  ('operational', 'trend', 'short_term', 'Customer C Satisfaction Declining — Churn Risk', 'Customer C (Charlie Fresh Imports) CSAT dropped to 2.5/10 after temp breach. Repeat business probability: 20%. They represent 17% of Q1 revenue.', '{"customer": "CUST-C", "csat_score": 2.5, "repeat_probability": 0.20, "revenue_share_pct": 17}', 'Priority account recovery: personal outreach, credit note, guaranteed SLA on next 3 shipments.', 0.90, 0.35, 215200.00, ARRAY['wwg_customer_satisfaction','wwg_orders'], 'customer', 'CUST-C');

-- 12.30 CAST Interactions
INSERT INTO wwg_cast_interactions (session_id, user_id, context_entity_type, context_entity_id, interaction_type, user_message, assistant_response, model_id, tokens_used) VALUES
  ('sess-001', 'amanda.moore', 'shipment', 'HLXU9901234', 'support', 'What is the current status of HLXU9901234 and what are our options?', 'Container HLXU9901234 experienced a reefer fault on 3 Feb with a 2.8C temperature deviation sustained for >24 hours. Current status: At Sea — ALERT. The chilled beef striploin has a shelf-life status of CRITICAL with only 4-5 days remaining. An insurance claim (CAR-2026-003) has been submitted for £29,800. A mandatory veterinary check is required on arrival at Southampton BCP. Options: (1) Accept vet inspection outcome, (2) Pre-arrange cold storage at Southampton in case of delayed clearance, (3) Notify Customer C of potential quality impact and discuss credit terms.', 'claude-opus-4-6', 842),
  ('sess-002', 'amanda.moore', 'creditor', 'SUP-AU-002', 'triage', 'Why is Outback Premium Foods blocked and what should we do?', 'Outback Premium Foods is blocked due to £42,000 overdue (45 days past 30-day terms). The overdue amount relates to invoices for containers HLXU9901234 and CMAU6712890. A backlog offer has been generated: 3 monthly instalments of £14,000 with credit limit reduced from £250k to £150k. Recommendation: Approve the backlog offer to unblock supply capacity — they are our preferred supplier for chilled beef products. The temp breach on HLXU9901234 has complicated settlement as we are awaiting insurance claim resolution before releasing full payment.', 'claude-opus-4-6', 756),
  ('sess-003', 'amanda.moore', 'fleet', 'all', 'help', 'Give me a fleet summary — how many containers are delayed and what is total financial impact?', 'Fleet summary (12 containers): 7 delayed (total delay: 40 container-days), 2 on-time/complete, 1 early, 1 cleared, 1 booked. Total financial impact: £99,150. Breakdown: Spoilage £56,150 (57%) — driven primarily by HLXU9901234 temp breach (£27k). Demurrage £37,000 (37%). SLA Penalties £7,500 (8%). Worst affected: HLXU9901234 (CRITICAL, £34.8k), MRKU4821073 (HIGH, £17.5k), CSNU2234567 (HIGH, £12.75k — UNINSURED). Best performers: MRKU7734901 (on-time, zero impact), EVRU8821100 (2 days early, saved £800). Fleet margin erosion: planned 14.8% average → actual 7.2% average.', 'claude-opus-4-6', 1024);

-- 12.31 Farsight Threads
INSERT INTO wwg_farsight_threads (thread_title, insight_type, scope, summary, findings, recommendations, data_sources, confidence_score, created_by) VALUES
  ('Q1 2026 Fleet Financial Impact Analysis', 'financial', 'fleet', 'Aggregate analysis of financial impact across 12 containers in Q1 2026. Total impact £99,150 with 67% attributable to 2 containers.',
    '{"total_impact_gbp": 99150, "containers_affected": 7, "containers_clean": 5, "worst_container": "HLXU9901234", "worst_impact_gbp": 34800, "average_margin_planned_pct": 14.8, "average_margin_actual_pct": 7.2, "margin_erosion_fleet_gbp": 92350}',
    '["1. Implement mandatory reefer pre-trip inspection protocol to prevent HLXU-type failures", "2. Review insurance coverage for fresh product shipments — CSNU2234567 gap unacceptable", "3. Hedge AUD/GBP at contract rate for Q2 to lock in margins", "4. Negotiate volume discount with Cape route carriers given sustained rerouting"]',
    ARRAY['wwg_impact_assessments','wwg_margin_analysis','wwg_landed_costs','wwg_cashflow_events'], 0.92, 'farsight-engine'),
  ('Cold-Chain Compliance & Risk Assessment', 'cold-chain', 'fleet', 'Analysis of cold-chain performance across 12 containers. 1 critical breach detected, 11 within parameters.',
    '{"containers_monitored": 12, "breaches_detected": 1, "breach_container": "HLXU9901234", "max_deviation_celsius": 2.8, "breach_duration_hrs": 28, "products_at_risk": 1, "frozen_compliance_pct": 100, "chilled_compliance_pct": 75, "fresh_compliance_pct": 100}',
    '["1. HLXU9901234 requires mandatory vet check — arrange pre-arrival", "2. Install redundant temperature sensors on chilled product containers", "3. Implement 15-minute polling for chilled/fresh (vs 1-hour for frozen)", "4. Add predictive shelf-life alerting at 50% remaining threshold"]',
    ARRAY['wwg_cold_chain_readings','wwg_compliance_gates','wwg_products'], 0.88, 'farsight-engine'),
  ('Creditor Risk & Cashflow Analysis', 'creditor', 'operations', 'Assessment of creditor positions across suppliers, carriers, and agents. 1 supplier blocked, 2 carriers with minor overdue.',
    '{"total_creditors": 10, "blocked": 1, "overdue": 3, "total_overdue_gbp": 66400, "backlog_offers_active": 1, "highest_risk": "SUP-AU-002", "overdue_concentration_pct": 63}',
    '["1. Approve SUP-AU-002 backlog offer to unblock £250k credit capacity", "2. Chase Maersk £6,400 overdue (8 days) — linked to MRKU4821073 demurrage dispute", "3. Review Hapag-Lloyd £4,800 — linked to HLXU9901234 insurance settlement timing", "4. Implement automated overdue alerts at 7, 14, 21, 30 day thresholds"]',
    ARRAY['wwg_creditor_accounts','wwg_cashflow_events','wwg_raid_log'], 0.85, 'farsight-engine');

-- 12.32 Control Checks
INSERT INTO wwg_control_checks (check_id, check_name, requirement_ref, category, status, finding, recommendation) VALUES
  ('CC-001', 'Audit Trail Completeness', 'REQ-AUD-001', 'data-quality', 'PASS', 'Audit triggers active on 6 transactional tables. All seed data changes logged.', NULL),
  ('CC-002', 'Cold-Chain Temp Compliance', 'REQ-CC-001', 'compliance', 'WARNING', '1 of 12 containers in temperature breach (HLXU9901234). Fleet compliance: 91.7%.', 'Investigate reefer fault root cause. Add pre-trip inspection mandate.'),
  ('CC-003', 'BTOM/IPAFFS Gate Coverage', 'REQ-BTOM-001', 'compliance', 'WARNING', '8 of 12 containers have compliance gates. 4 containers pending gate creation.', 'Create compliance gates for remaining 4 containers before ETA.'),
  ('CC-004', 'FX Rate Currency', 'REQ-FX-001', 'financial', 'PASS', '10 FX rates loaded (AUD/GBP, AUD/USD, USD/GBP). All orders have fx_rate_at_creation.', NULL),
  ('CC-005', 'Insurance Coverage', 'REQ-INS-001', 'financial', 'WARNING', '1 of 12 shipments uninsured (CSNU2234567 — fresh lamb, high-risk corridor).', 'Review insurance policy for fresh product. Consider blanket marine cargo cover.'),
  ('CC-006', 'Creditor Overdue Exposure', 'REQ-CRED-001', 'financial', 'WARNING', '£66,400 total overdue across 3 creditors. 1 supplier blocked (SUP-AU-002, £42k).', 'Approve backlog offer for SUP-AU-002. Chase carrier overdue amounts.'),
  ('CC-007', 'SLA Compliance Rate', 'REQ-SLA-001', 'operational', 'FAIL', 'Fleet on-time rate: 25% (3/12). Only CUST-F meeting SLA target. Red Sea disruption primary cause.', 'Review SLA terms with strategic customers. Consider force majeure clause for geopolitical events.'),
  ('CC-008', 'Halal Certification Coverage', 'REQ-HALAL-001', 'compliance', 'PASS', '12/12 products halal certified. All 5 suppliers halal approved.', NULL),
  ('CC-009', 'Data Residency', 'NFR-CMP-001', 'security', 'WARNING', 'Supabase project hosted in Stockholm (eu-north-1). UK data residency requirement flagged.', 'Plan migration to UK-hosted instance or implement column-level encryption with UK-held keys.'),
  ('CC-010', 'RLS Policy Enforcement', 'NFR-SEC-001', 'security', 'INFO', 'RLS enabled on all 33 tables. Permissive MVP policies in place. Granular RBAC pending.', 'Phase 2: Implement role-based policies (trader/admin/pf-owner) before production promotion.');

-- 12.33 Audit Log (seed entries for key events)
INSERT INTO wwg_audit_log (timestamp, action, entity_type, entity_id, user_id, details) VALUES
  ('2026-03-31 08:00:00+00', 'create', 'wwg_db_config', '1.0.0-wwg-mvp', 'system', 'Schema v1.0.0-wwg-mvp deployed'),
  ('2026-01-22 09:15:00+00', 'route_change', 'wwg_shipments', 'MRKU4821073', 'system', 'Red Sea reroute: SUEZ → CAPE. +8 day delay.'),
  ('2026-02-03 06:30:00+00', 'temp_breach', 'wwg_shipments', 'HLXU9901234', 'system', 'Temperature breach detected: 4.8C vs 2.0C set-point. Deviation 2.8C.'),
  ('2026-02-03 14:00:00+00', 'alert_generated', 'wwg_alerts', 'HLXU9901234', 'system', 'CRITICAL alert: Temperature Breach on chilled beef striploin'),
  ('2026-02-03 15:00:00+00', 'notification_sent', 'wwg_customer_notifications', 'CUST-C', 'amanda.moore', 'Temperature breach notification sent to Charlie Fresh Imports'),
  ('2026-02-14 10:00:00+00', 'route_change', 'wwg_shipments', 'EVRU8821100', 'system', 'Suez route restored — ceasefire benefit. -2 day ETA improvement.'),
  ('2026-02-20 11:00:00+00', 'insurance_claim', 'wwg_insurance_profiles', 'HLXU9901234', 'amanda.moore', 'Insurance claim CAR-2026-003 submitted to AXA Marine for £29,800'),
  ('2026-03-01 09:00:00+00', 'credit_block', 'wwg_creditor_accounts', 'SUP-AU-002', 'system', 'Supplier blocked: £42,000 overdue (45 days past terms)'),
  ('2026-03-11 12:00:00+00', 'status_change', 'wwg_shipments', 'MRKU7734901', 'system', 'Container MRKU7734901 — Gate Out at Tilbury. On-time delivery.'),
  ('2026-03-11 13:00:00+00', 'notification_sent', 'wwg_customer_notifications', 'CUST-A', 'amanda.moore', 'Delivery confirmation sent to Alpha Foods Distribution'),
  ('2026-03-27 16:00:00+00', 'eta_change', 'wwg_shipments', 'MSCU5567890', 'system', 'MSC slow-steam advisory: ETA revised +3 days'),
  ('2026-03-31 08:30:00+00', 'compliance_check', 'wwg_control_checks', 'CC-001-to-CC-010', 'system', 'Control checks batch executed: 4 PASS, 5 WARNING, 1 FAIL, 1 INFO');

-- ============================================================
-- PART 13: ROW LEVEL SECURITY
-- ============================================================

DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'wwg_db_config','wwg_corridors','wwg_carriers','wwg_vessels','wwg_ports',
    'wwg_products','wwg_customers','wwg_suppliers',
    'wwg_shipments','wwg_voyage_events','wwg_risk_events','wwg_compliance_gates',
    'wwg_cold_chain_readings','wwg_alerts',
    'wwg_orders','wwg_order_lines','wwg_fx_rates','wwg_landed_costs',
    'wwg_impact_assessments','wwg_margin_analysis','wwg_cashflow_events',
    'wwg_creditor_accounts','wwg_insurance_profiles',
    'wwg_customer_notifications','wwg_customer_satisfaction','wwg_sla_tracking',
    'wwg_raid_log','wwg_rmf_assessments','wwg_rmf_controls',
    'wwg_insights',
    'wwg_cast_interactions','wwg_farsight_threads',
    'wwg_audit_log','wwg_control_checks'
  ]) LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY %I ON %I FOR ALL USING (true) WITH CHECK (true)',
      'allow_all_' || t, t
    );
  END LOOP;
END $$;

-- ============================================================
-- MIGRATION COMPLETE
-- Tables: 33 (+ 1 shared function)
-- Seed rows: ~380
-- Ontologies: LSC-ONT, OFM-ONT, SOP-ONT, RAID-ONT, RMF-IS27005-ONT
-- ============================================================

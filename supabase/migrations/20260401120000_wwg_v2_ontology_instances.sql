-- ============================================================
-- WWG Database v2.0.0 — Ontology-Driven JSONB Instance Architecture
-- Migration: v1.0.0 flattened tables → OAA v7 JSONB instance tables
-- Date: 2026-04-01
-- Project: pfc-pfi (jhlugiprdwgzshxctbdj)
-- Instance: pfi-w4m-wwg
-- Pattern: farsight_threads / uacl_execution_records (JSONB + GIN)
-- Ontologies: LSC-ONT v1.2.0, OFM-ONT v1.1.0, SOP-ONT v1.0.0, RRR-ONT v5.0.0
-- ============================================================

-- ============================================================
-- PART 1: CREATE ONTOLOGY INSTANCE TABLES
-- ============================================================

-- 1.1 LSC Instances (replaces: shipments, voyage_events, risk_events, compliance_gates, cold_chain_readings, alerts, corridors, ports)
CREATE TABLE wwg_lsc_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id TEXT NOT NULL UNIQUE,
  entity_type TEXT NOT NULL,
  pfi_instance TEXT NOT NULL DEFAULT 'pfi-w4m-wwg',
  instance_data JSONB NOT NULL,
  entity_status TEXT,
  parent_ref TEXT,
  ont_version TEXT NOT NULL DEFAULT '1.2.0',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_lsc_entity_type ON wwg_lsc_instances(entity_type);
CREATE INDEX idx_wwg_lsc_parent ON wwg_lsc_instances(parent_ref);
CREATE INDEX idx_wwg_lsc_status ON wwg_lsc_instances(entity_status);
CREATE INDEX idx_wwg_lsc_data ON wwg_lsc_instances USING GIN (instance_data);

CREATE TRIGGER wwg_lsc_instances_updated_at
  BEFORE UPDATE ON wwg_lsc_instances
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 1.2 OFM Instances (replaces: orders, order_lines, landed_costs, margin_analysis, cashflow_events, customer_satisfaction, sla_tracking, customer_notifications)
CREATE TABLE wwg_ofm_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id TEXT NOT NULL UNIQUE,
  entity_type TEXT NOT NULL,
  pfi_instance TEXT NOT NULL DEFAULT 'pfi-w4m-wwg',
  instance_data JSONB NOT NULL,
  entity_status TEXT,
  parent_ref TEXT,
  ont_version TEXT NOT NULL DEFAULT '1.1.0',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_ofm_entity_type ON wwg_ofm_instances(entity_type);
CREATE INDEX idx_wwg_ofm_parent ON wwg_ofm_instances(parent_ref);
CREATE INDEX idx_wwg_ofm_status ON wwg_ofm_instances(entity_status);
CREATE INDEX idx_wwg_ofm_data ON wwg_ofm_instances USING GIN (instance_data);

CREATE TRIGGER wwg_ofm_instances_updated_at
  BEFORE UPDATE ON wwg_ofm_instances
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 1.3 SOP Instances (new — sales order processing)
CREATE TABLE wwg_sop_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id TEXT NOT NULL UNIQUE,
  entity_type TEXT NOT NULL,
  pfi_instance TEXT NOT NULL DEFAULT 'pfi-w4m-wwg',
  instance_data JSONB NOT NULL,
  entity_status TEXT,
  parent_ref TEXT,
  ont_version TEXT NOT NULL DEFAULT '1.0.0',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_sop_entity_type ON wwg_sop_instances(entity_type);
CREATE INDEX idx_wwg_sop_parent ON wwg_sop_instances(parent_ref);
CREATE INDEX idx_wwg_sop_status ON wwg_sop_instances(entity_status);
CREATE INDEX idx_wwg_sop_data ON wwg_sop_instances USING GIN (instance_data);

CREATE TRIGGER wwg_sop_instances_updated_at
  BEFORE UPDATE ON wwg_sop_instances
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 1.4 Parties (unified: carriers, suppliers, customers, products, vessels — all lsc:Party with RRR-ONT roles)
CREATE TABLE wwg_parties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  party_id TEXT NOT NULL UNIQUE,
  party_type TEXT NOT NULL,
  party_data JSONB NOT NULL,
  pfi_instance TEXT NOT NULL DEFAULT 'pfi-w4m-wwg',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  origin_db TEXT NOT NULL DEFAULT 'wwg-seed'
);

CREATE INDEX idx_wwg_parties_type ON wwg_parties(party_type);
CREATE INDEX idx_wwg_parties_data ON wwg_parties USING GIN (party_data);

CREATE TRIGGER wwg_parties_updated_at
  BEFORE UPDATE ON wwg_parties
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- PART 2: MIGRATE PARTIES (carriers, vessels, suppliers, customers, products, ports)
-- ============================================================

-- 2.1 Carriers → lsc:Party (carrier)
INSERT INTO wwg_parties (party_id, party_type, party_data)
SELECT
  'lsc:party-' || carrier_code,
  'carrier',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/', 'pf', 'https://oaa-ontology.org/v7/rrr/'),
    '@id', 'lsc:party-' || carrier_code,
    '@type', 'lsc:Party',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'LSC-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'partyRole', 'carrier',
    'partyName', carrier_name,
    'carrierCode', carrier_code,
    'alliance', alliance,
    'vessels', (
      SELECT coalesce(jsonb_agg(jsonb_build_object(
        '@id', 'lsc:vessel-' || replace(vessel_name, ' ', '-'),
        '@type', 'lsc:Vessel',
        'vesselName', vessel_name,
        'imoNumber', imo_number,
        'mmsi', mmsi,
        'vesselType', vessel_type
      )), '[]'::jsonb)
      FROM wwg_vessels v WHERE v.carrier_id = c.id
    ),
    'pf:roleAssignment', jsonb_build_object(
      '@type', 'pf:RoleAssignment',
      'functionalRole', 'Logistics Service Provider',
      'raciDefault', 'responsible',
      'servesFunction', 'COO'
    )
  )
FROM wwg_carriers c;

-- 2.2 Suppliers → lsc:Party (supplier)
INSERT INTO wwg_parties (party_id, party_type, party_data)
SELECT
  'lsc:party-' || supplier_code,
  'supplier',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:party-' || supplier_code,
    '@type', 'lsc:Party',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'LSC-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'partyRole', 'supplier',
    'partyName', supplier_name,
    'supplierCode', supplier_code,
    'establishmentNumber', establishment_number,
    'state', state,
    'country', country,
    'halalApproved', halal_approved,
    'pf:roleAssignment', jsonb_build_object(
      '@type', 'pf:RoleAssignment',
      'functionalRole', 'Meat Processor / Exporter',
      'raciDefault', 'responsible',
      'servesFunction', 'CSSO'
    )
  )
FROM wwg_suppliers;

-- 2.3 Customers → lsc:Party (customer)
INSERT INTO wwg_parties (party_id, party_type, party_data)
SELECT
  'lsc:party-' || customer_code,
  'customer',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:party-' || customer_code,
    '@type', 'lsc:Party',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'LSC-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'partyRole', 'customer',
    'partyName', customer_name,
    'customerCode', customer_code,
    'country', country,
    'deliveryPort', delivery_port,
    'accountTier', account_tier,
    'sla', jsonb_build_object(
      'onTimePct', sla_on_time_pct,
      'tempCompliancePct', sla_temp_compliance_pct
    ),
    'pf:roleAssignment', jsonb_build_object(
      '@type', 'pf:RoleAssignment',
      'functionalRole', 'UK Importer / Buyer',
      'raciDefault', 'informed',
      'servesFunction', 'CRO'
    )
  )
FROM wwg_customers;

-- 2.4 Products → lsc:Party (product — commodity entity)
INSERT INTO wwg_parties (party_id, party_type, party_data)
SELECT
  'lsc:product-' || product_code,
  'product',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:product-' || product_code,
    '@type', 'lsc:Commodity',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'LSC-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'productCode', product_code,
    'description', description,
    'commodityClass', cold_chain_type,
    'species', species,
    'halalCertified', halal_certified,
    'feedType', feed_type,
    'coldChain', jsonb_build_object(
      'setPointTemp', set_point_temp,
      'shelfLifeDays', shelf_life_days,
      'tempSensitivity', temp_sensitivity
    )
  )
FROM wwg_products;

-- ============================================================
-- PART 3: MIGRATE LSC INSTANCES
-- ============================================================

-- 3.1 Corridors → lsc:SupplyChain
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status)
SELECT
  'lsc:corridor-' || corridor_code,
  'lsc:SupplyChain',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:corridor-' || corridor_code,
    '@type', 'lsc:SupplyChain',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'LSC-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'corridorCode', corridor_code,
    'originCountry', origin_country,
    'destCountry', dest_country,
    'routeType', route_type,
    'baseTransitDays', base_transit_days,
    'distanceNm', distance_nm,
    'description', description,
    'servesFunction', jsonb_build_array('COO', 'CFO')
  ),
  'active'
FROM wwg_corridors;

-- 3.2 Ports → lsc:ChainNode
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status)
SELECT
  'lsc:node-' || port_code,
  'lsc:ChainNode',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:node-' || port_code,
    '@type', 'lsc:ChainNode',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'LSC-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'portCode', port_code,
    'portName', port_name,
    'country', country,
    'location', jsonb_build_object('lat', lat, 'lon', lon),
    'nodeType', port_type,
    'isBCP', is_bcp
  ),
  'active'
FROM wwg_ports;

-- 3.3 Shipments → lsc:Shipment
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'lsc:shipment-' || s.container_id,
  'lsc:Shipment',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/', 'pf', 'https://oaa-ontology.org/v7/rrr/', 'func', 'https://oaa-ontology.org/v7/func/'),
    '@id', 'lsc:shipment-' || s.container_id,
    '@type', 'lsc:Shipment',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'LSC-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'shipmentId', s.container_id,
    'carrier', jsonb_build_object('@id', 'lsc:party-' || ca.carrier_code, '@type', 'lsc:Party'),
    'vessel', v.vessel_name,
    'voyage', s.voyage_number,
    'origin', jsonb_build_object('@id', 'lsc:node-' || op.port_code, '@type', 'lsc:ChainNode'),
    'destination', jsonb_build_object('@id', 'lsc:node-' || dp.port_code, '@type', 'lsc:ChainNode'),
    'corridor', jsonb_build_object('@id', 'lsc:corridor-' || co.corridor_code),
    'commodity', jsonb_build_object(
      '@id', 'lsc:product-' || pr.product_code,
      'commodityClass', s.cold_chain_type,
      'product', pr.description,
      'species', pr.species
    ),
    'supplier', jsonb_build_object('@id', 'lsc:party-' || su.supplier_code),
    'customer', jsonb_build_object('@id', 'lsc:party-' || cu.customer_code),
    'departureDate', s.departure_date,
    'originalETA', s.original_eta,
    'currentETA', s.current_eta,
    'delayDays', s.current_delay_days,
    'baseTransitDays', s.base_transit_days,
    'scenario', s.scenario,
    'shipmentStatus', s.current_status,
    'route', jsonb_build_object('planned', s.planned_route, 'current', s.current_route),
    'coldChain', jsonb_build_object('setPoint', s.set_point_temp, 'type', s.cold_chain_type, 'containerType', s.container_type),
    'weight', jsonb_build_object('value', s.weight_kg, 'unit', 'kg'),
    'servesFunction', jsonb_build_array(
      jsonb_build_object('func:domainCode', 'COO', 'func:accountability', 'Supply chain execution'),
      jsonb_build_object('func:domainCode', 'CFO', 'func:accountability', 'Landed cost management')
    ),
    'raciBinding', jsonb_build_object(
      'responsible', jsonb_build_object('@type', 'pf:FunctionalRole', 'roleTitle', 'Operations Manager'),
      'accountable', jsonb_build_object('@type', 'pf:ExecutiveRole', 'func:domainCode', 'COO'),
      'consulted', jsonb_build_array('Finance Manager', 'Risk Officer'),
      'informed', jsonb_build_array('CRO', 'Customer')
    ),
    'rbacAccess', jsonb_build_object('read', jsonb_build_array('trader','admin','pf-owner'), 'write', jsonb_build_array('admin','pf-owner'), 'delete', jsonb_build_array('pf-owner'))
  ),
  s.current_status,
  'lsc:corridor-' || co.corridor_code
FROM wwg_shipments s
LEFT JOIN wwg_carriers ca ON ca.id = s.carrier_id
LEFT JOIN wwg_vessels v ON v.id = s.vessel_id
LEFT JOIN wwg_ports op ON op.id = s.origin_port_id
LEFT JOIN wwg_ports dp ON dp.id = s.dest_port_id
LEFT JOIN wwg_corridors co ON co.id = s.corridor_id
LEFT JOIN wwg_products pr ON pr.id = s.product_id
LEFT JOIN wwg_suppliers su ON su.id = s.supplier_id
LEFT JOIN wwg_customers cu ON cu.id = s.customer_id;

-- 3.4 Voyage Events → lsc:ShipmentLeg
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'lsc:leg-' || s.container_id || '-' || ve.event_date,
  'lsc:ShipmentLeg',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:leg-' || s.container_id || '-' || ve.event_date,
    '@type', 'lsc:ShipmentLeg',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'eventDate', ve.event_date,
    'dayOfVoyage', ve.day_of_voyage,
    'status', ve.status,
    'route', ve.route,
    'position', jsonb_build_object('lat', ve.lat, 'lon', ve.lon, 'name', ve.position_name),
    'sogKnots', ve.sog_knots,
    'temperature', jsonb_build_object('celsius', ve.temp_celsius, 'breach', ve.temp_breach),
    'riskLevel', ve.risk_level,
    'delayDays', ve.delay_days,
    'etaDate', ve.eta_date,
    'aisGap', ve.ais_gap
  ),
  ve.status,
  'lsc:shipment-' || s.container_id
FROM wwg_voyage_events ve
JOIN wwg_shipments s ON s.id = ve.shipment_id;

-- 3.5 Risk Events → lsc:Incident
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status)
SELECT
  'lsc:incident-' || re.id,
  'lsc:Incident',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:incident-' || re.id,
    '@type', 'lsc:Incident',
    'oaa:schemaVersion', '7.0.0',
    'eventDate', re.event_date,
    'incidentType', re.event_type,
    'zone', re.zone,
    'severity', re.severity,
    'title', re.title,
    'detail', re.detail,
    'activeUntil', re.active_until
  ),
  CASE WHEN re.active_until IS NULL THEN 'active' ELSE 'resolved' END
FROM wwg_risk_events re;

-- 3.6 Compliance Gates → lsc:ComplianceGate
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'lsc:gate-' || cg.id,
  'lsc:ComplianceGate',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:gate-' || cg.id,
    '@type', 'lsc:ComplianceGate',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'gateType', cg.gate_type,
    'gateStatus', cg.status,
    'deadline', cg.deadline,
    'completedAt', cg.completed_at,
    'bcpPort', cg.bcp_port,
    'notes', cg.notes
  ),
  cg.status,
  'lsc:shipment-' || s.container_id
FROM wwg_compliance_gates cg
JOIN wwg_shipments s ON s.id = cg.shipment_id;

-- 3.7 Cold Chain Readings → lsc:ColdChainEvent
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'lsc:cc-' || cc.id,
  'lsc:ColdChainEvent',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:cc-' || cc.id,
    '@type', 'lsc:ColdChainEvent',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'readingAt', cc.reading_at,
    'supplyAirTemp', cc.supply_air_temp,
    'returnAirTemp', cc.return_air_temp,
    'setPointTemp', cc.set_point_temp,
    'deviation', cc.deviation,
    'isBreach', cc.is_breach,
    'shelfLife', jsonb_build_object('remainingDays', cc.shelf_life_remaining_days, 'status', cc.shelf_life_status)
  ),
  CASE WHEN cc.is_breach THEN 'breach' ELSE 'normal' END,
  'lsc:shipment-' || s.container_id
FROM wwg_cold_chain_readings cc
JOIN wwg_shipments s ON s.id = cc.shipment_id;

-- 3.8 Alerts → lsc:RiskAssessment
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'lsc:alert-' || a.id,
  'lsc:RiskAssessment',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:alert-' || a.id,
    '@type', 'lsc:RiskAssessment',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', CASE WHEN s.container_id IS NOT NULL THEN jsonb_build_object('@id', 'lsc:shipment-' || s.container_id) ELSE NULL END,
    'riskEventRef', CASE WHEN a.risk_event_id IS NOT NULL THEN jsonb_build_object('@id', 'lsc:incident-' || a.risk_event_id) ELSE NULL END,
    'alertType', a.alert_type,
    'severity', a.severity,
    'title', a.title,
    'detail', a.detail,
    'alertDate', a.alert_date,
    'acknowledged', a.acknowledged
  ),
  a.severity,
  CASE WHEN s.container_id IS NOT NULL THEN 'lsc:shipment-' || s.container_id ELSE NULL END
FROM wwg_alerts a
LEFT JOIN wwg_shipments s ON s.id = a.shipment_id;

-- 3.9 Impact Assessments → lsc:ImpactAssessment
INSERT INTO wwg_lsc_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'lsc:impact-' || ia.id,
  'lsc:ImpactAssessment',
  jsonb_build_object(
    '@context', jsonb_build_object('lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'lsc:impact-' || ia.id,
    '@type', 'lsc:ImpactAssessment',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'assessmentDate', ia.assessment_date,
    'riskScore', ia.risk_score,
    'riskSeverity', ia.risk_severity,
    'delayDays', ia.delay_days,
    'financialImpact', jsonb_build_object(
      'spoilageCostGbp', ia.spoilage_cost_gbp,
      'demurrageCostGbp', ia.demurrage_cost_gbp,
      'slaPenaltyGbp', ia.sla_penalty_gbp,
      'totalImpactGbp', ia.total_impact_gbp
    ),
    'riskFactors', to_jsonb(ia.risk_factors),
    'reasoning', to_jsonb(ia.reasoning),
    'confidence', ia.confidence,
    'servesFunction', jsonb_build_array('CFO', 'COO')
  ),
  ia.risk_severity,
  'lsc:shipment-' || s.container_id
FROM wwg_impact_assessments ia
JOIN wwg_shipments s ON s.id = ia.shipment_id;

-- ============================================================
-- PART 4: MIGRATE OFM INSTANCES
-- ============================================================

-- 4.1 Orders → ofm:SalesOrder (with embedded order lines)
INSERT INTO wwg_ofm_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'ofm:order-' || o.order_number,
  'ofm:SalesOrder',
  jsonb_build_object(
    '@context', jsonb_build_object('ofm', 'https://oaa-ontology.org/v7/ofm/', 'lsc', 'https://oaa-ontology.org/v7/lsc/'),
    '@id', 'ofm:order-' || o.order_number,
    '@type', 'ofm:SalesOrder',
    'oaa:schemaVersion', '7.0.0',
    'oaa:ontologyId', 'OFM-ONT',
    'oaa:pfiInstance', 'PFI-W4M-WWG',
    'orderNumber', o.order_number,
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'customerRef', jsonb_build_object('@id', 'lsc:party-' || cu.customer_code),
    'orderStatus', o.status,
    'currency', jsonb_build_object('buy', o.buy_currency, 'sell', o.sell_currency),
    'fxRateAtCreation', o.fx_rate_at_creation,
    'incoterms', o.incoterms,
    'totalValue', o.total_value,
    'totalQuantityKg', o.total_quantity_kg,
    'deliveryWindow', jsonb_build_object('start', o.delivery_window_start, 'end', o.delivery_window_end),
    'hasOrderLines', (
      SELECT coalesce(jsonb_agg(jsonb_build_object(
        '@id', 'ofm:line-' || o.order_number || '-' || ol.line_number,
        '@type', 'ofm:OrderLine',
        'lineNumber', ol.line_number,
        'productRef', jsonb_build_object('@id', 'lsc:product-' || pr.product_code),
        'description', ol.description,
        'quantityKg', ol.quantity_kg,
        'buyPricePerKg', ol.buy_price_per_kg,
        'sellPricePerKg', ol.sell_price_per_kg,
        'lineBuyValue', ol.line_buy_value,
        'lineSellValue', ol.line_sell_value,
        'plannedMarginPct', ol.planned_margin_pct
      ) ORDER BY ol.line_number), '[]'::jsonb)
      FROM wwg_order_lines ol
      LEFT JOIN wwg_products pr ON pr.id = ol.product_id
      WHERE ol.order_id = o.id
    ),
    'servesFunction', jsonb_build_array('CRO', 'CFO'),
    'raciBinding', jsonb_build_object(
      'responsible', 'Sales Manager',
      'accountable', 'CRO',
      'consulted', jsonb_build_array('Finance', 'Operations'),
      'informed', jsonb_build_array('Customer')
    )
  ),
  o.status,
  'lsc:shipment-' || s.container_id
FROM wwg_orders o
JOIN wwg_shipments s ON s.id = o.shipment_id
LEFT JOIN wwg_customers cu ON cu.id = o.customer_id;

-- 4.2 Landed Costs → ofm:LandedCost
INSERT INTO wwg_ofm_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'ofm:landed-' || s.container_id,
  'ofm:LandedCost',
  jsonb_build_object(
    '@context', jsonb_build_object('ofm', 'https://oaa-ontology.org/v7/ofm/'),
    '@id', 'ofm:landed-' || s.container_id,
    '@type', 'ofm:LandedCost',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'fobValueAud', lc.fob_value_aud,
    'freightCostUsd', lc.freight_cost_usd,
    'insuranceCostUsd', lc.insurance_cost_usd,
    'customsDutyGbp', lc.customs_duty_gbp,
    'clearanceFeesGbp', lc.clearance_fees_gbp,
    'coldStorageGbp', lc.cold_storage_gbp,
    'lastMileGbp', lc.last_mile_gbp,
    'demurrageGbp', lc.demurrage_gbp,
    'totalLandedCostGbp', lc.total_landed_cost_gbp,
    'costPerKgGbp', lc.cost_per_kg_gbp,
    'fxRates', jsonb_build_object('audGbp', lc.fx_rate_aud_gbp, 'usdGbp', lc.fx_rate_usd_gbp),
    'servesFunction', jsonb_build_array('CFO')
  ),
  'calculated',
  'lsc:shipment-' || s.container_id
FROM wwg_landed_costs lc
JOIN wwg_shipments s ON s.id = lc.shipment_id;

-- 4.3 Margin Analysis → ofm:MarginAnalysis
INSERT INTO wwg_ofm_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'ofm:margin-' || s.container_id,
  'ofm:MarginAnalysis',
  jsonb_build_object(
    '@context', jsonb_build_object('ofm', 'https://oaa-ontology.org/v7/ofm/'),
    '@id', 'ofm:margin-' || s.container_id,
    '@type', 'ofm:MarginAnalysis',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'planned', jsonb_build_object('sellValueGbp', ma.planned_sell_value_gbp, 'costGbp', ma.planned_cost_gbp, 'marginGbp', ma.planned_margin_gbp, 'marginPct', ma.planned_margin_pct),
    'actual', jsonb_build_object('sellValueGbp', ma.actual_sell_value_gbp, 'costGbp', ma.actual_cost_gbp, 'marginGbp', ma.actual_margin_gbp, 'marginPct', ma.actual_margin_pct),
    'erosion', jsonb_build_object('amountGbp', ma.margin_erosion_gbp, 'pct', ma.margin_erosion_pct, 'cause', ma.erosion_cause),
    'servesFunction', jsonb_build_array('CFO', 'CRO')
  ),
  coalesce(ma.erosion_cause, 'pending'),
  'lsc:shipment-' || s.container_id
FROM wwg_margin_analysis ma
JOIN wwg_shipments s ON s.id = ma.shipment_id;

-- 4.4 Customer Satisfaction → ofm:CustomerSatisfaction
INSERT INTO wwg_ofm_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'ofm:csat-' || cs.id,
  'ofm:CustomerSatisfaction',
  jsonb_build_object(
    '@context', jsonb_build_object('ofm', 'https://oaa-ontology.org/v7/ofm/'),
    '@id', 'ofm:csat-' || cs.id,
    '@type', 'ofm:CustomerSatisfaction',
    'oaa:schemaVersion', '7.0.0',
    'customerRef', jsonb_build_object('@id', 'lsc:party-' || cu.customer_code),
    'shipmentRef', CASE WHEN s.container_id IS NOT NULL THEN jsonb_build_object('@id', 'lsc:shipment-' || s.container_id) ELSE NULL END,
    'scores', jsonb_build_object('overall', cs.overall_score, 'onTime', cs.on_time_score, 'quality', cs.quality_score, 'communication', cs.communication_score),
    'repeatBusinessProbability', cs.repeat_business_probability,
    'feedbackText', cs.feedback_text,
    'deliveryDeltaDays', cs.delivery_delta_days,
    'servesFunction', jsonb_build_array('CRO')
  ),
  CASE WHEN cs.overall_score >= 7 THEN 'satisfied' WHEN cs.overall_score >= 4 THEN 'neutral' ELSE 'dissatisfied' END,
  CASE WHEN s.container_id IS NOT NULL THEN 'lsc:shipment-' || s.container_id ELSE NULL END
FROM wwg_customer_satisfaction cs
LEFT JOIN wwg_customers cu ON cu.id = cs.customer_id
LEFT JOIN wwg_shipments s ON s.id = cs.shipment_id;

-- 4.5 Cashflow Events → ofm:OrderMilestone
INSERT INTO wwg_ofm_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'ofm:cashflow-' || cf.id,
  'ofm:OrderMilestone',
  jsonb_build_object(
    '@context', jsonb_build_object('ofm', 'https://oaa-ontology.org/v7/ofm/'),
    '@id', 'ofm:cashflow-' || cf.id,
    '@type', 'ofm:OrderMilestone',
    'oaa:schemaVersion', '7.0.0',
    'shipmentRef', jsonb_build_object('@id', 'lsc:shipment-' || s.container_id),
    'milestoneType', cf.event_type,
    'amountGbp', cf.amount_gbp,
    'currency', cf.currency,
    'direction', cf.direction,
    'dueDate', cf.due_date,
    'paidDate', cf.paid_date,
    'paymentStatus', cf.status,
    'servesFunction', jsonb_build_array('CFO')
  ),
  cf.status,
  'lsc:shipment-' || s.container_id
FROM wwg_cashflow_events cf
JOIN wwg_shipments s ON s.id = cf.shipment_id;

-- 4.6 SLA Tracking → ofm:ServiceLevelAgreement
INSERT INTO wwg_ofm_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'ofm:sla-' || st.id,
  'ofm:ServiceLevelAgreement',
  jsonb_build_object(
    '@context', jsonb_build_object('ofm', 'https://oaa-ontology.org/v7/ofm/'),
    '@id', 'ofm:sla-' || st.id,
    '@type', 'ofm:ServiceLevelAgreement',
    'oaa:schemaVersion', '7.0.0',
    'customerRef', jsonb_build_object('@id', 'lsc:party-' || cu.customer_code),
    'period', jsonb_build_object('start', st.period_start, 'end', st.period_end),
    'metrics', jsonb_build_object(
      'totalShipments', st.total_shipments,
      'onTimeShipments', st.on_time_shipments,
      'onTimePct', st.on_time_pct,
      'tempCompliantShipments', st.temp_compliant_shipments,
      'tempCompliancePct', st.temp_compliance_pct,
      'docAccuracyPct', st.doc_accuracy_pct
    ),
    'slaMet', st.sla_met,
    'servesFunction', jsonb_build_array('CRO', 'COO')
  ),
  CASE WHEN st.sla_met THEN 'met' ELSE 'breached' END,
  'lsc:party-' || cu.customer_code
FROM wwg_sla_tracking st
JOIN wwg_customers cu ON cu.id = st.customer_id;

-- 4.7 Customer Notifications → ofm:CustomerNotification
INSERT INTO wwg_ofm_instances (instance_id, entity_type, instance_data, entity_status, parent_ref)
SELECT
  'ofm:notif-' || cn.id,
  'ofm:CustomerNotification',
  jsonb_build_object(
    '@context', jsonb_build_object('ofm', 'https://oaa-ontology.org/v7/ofm/'),
    '@id', 'ofm:notif-' || cn.id,
    '@type', 'ofm:CustomerNotification',
    'oaa:schemaVersion', '7.0.0',
    'customerRef', jsonb_build_object('@id', 'lsc:party-' || cu.customer_code),
    'shipmentRef', CASE WHEN s.container_id IS NOT NULL THEN jsonb_build_object('@id', 'lsc:shipment-' || s.container_id) ELSE NULL END,
    'notificationType', cn.notification_type,
    'channel', cn.channel,
    'subject', cn.subject,
    'sentAt', cn.sent_at,
    'acknowledged', cn.acknowledged
  ),
  CASE WHEN cn.acknowledged THEN 'acknowledged' ELSE 'sent' END,
  CASE WHEN s.container_id IS NOT NULL THEN 'lsc:shipment-' || s.container_id ELSE NULL END
FROM wwg_customer_notifications cn
LEFT JOIN wwg_customers cu ON cu.id = cn.customer_id
LEFT JOIN wwg_shipments s ON s.id = cn.shipment_id;

-- ============================================================
-- PART 5: ENABLE RLS ON NEW TABLES
-- ============================================================

DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'wwg_lsc_instances','wwg_ofm_instances','wwg_sop_instances','wwg_parties'
  ]) LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY %I ON %I FOR ALL USING (true) WITH CHECK (true)',
      'allow_all_' || t, t
    );
  END LOOP;
END $$;

-- ============================================================
-- PART 6: DROP REPLACED TABLES
-- ============================================================

-- Remove audit triggers first (attached to tables being dropped)
DROP TRIGGER IF EXISTS wwg_shipments_audit ON wwg_shipments;
DROP TRIGGER IF EXISTS wwg_orders_audit ON wwg_orders;
DROP TRIGGER IF EXISTS wwg_order_lines_audit ON wwg_orders;
DROP TRIGGER IF EXISTS wwg_alerts_audit ON wwg_alerts;
DROP TRIGGER IF EXISTS wwg_impact_assessments_audit ON wwg_impact_assessments;
DROP TRIGGER IF EXISTS wwg_compliance_gates_audit ON wwg_compliance_gates;

-- Drop in reverse dependency order
DROP TABLE IF EXISTS wwg_customer_notifications CASCADE;
DROP TABLE IF EXISTS wwg_customer_satisfaction CASCADE;
DROP TABLE IF EXISTS wwg_sla_tracking CASCADE;
DROP TABLE IF EXISTS wwg_cashflow_events CASCADE;
DROP TABLE IF EXISTS wwg_margin_analysis CASCADE;
DROP TABLE IF EXISTS wwg_impact_assessments CASCADE;
DROP TABLE IF EXISTS wwg_landed_costs CASCADE;
DROP TABLE IF EXISTS wwg_order_lines CASCADE;
DROP TABLE IF EXISTS wwg_orders CASCADE;
DROP TABLE IF EXISTS wwg_cold_chain_readings CASCADE;
DROP TABLE IF EXISTS wwg_compliance_gates CASCADE;
DROP TABLE IF EXISTS wwg_alerts CASCADE;
DROP TABLE IF EXISTS wwg_voyage_events CASCADE;
DROP TABLE IF EXISTS wwg_risk_events CASCADE;
DROP TABLE IF EXISTS wwg_shipments CASCADE;
DROP TABLE IF EXISTS wwg_products CASCADE;
DROP TABLE IF EXISTS wwg_suppliers CASCADE;
DROP TABLE IF EXISTS wwg_customers CASCADE;
DROP TABLE IF EXISTS wwg_vessels CASCADE;
DROP TABLE IF EXISTS wwg_carriers CASCADE;
DROP TABLE IF EXISTS wwg_corridors CASCADE;
DROP TABLE IF EXISTS wwg_ports CASCADE;

-- ============================================================
-- PART 7: UPDATE SCHEMA VERSION
-- ============================================================

UPDATE wwg_db_config
SET schema_version = '2.0.0-wwg-ont',
    updated_at = now();

-- ============================================================
-- MIGRATION COMPLETE
-- v1.0.0 (33 tables) → v2.0.0 (19 tables)
-- 18 flattened domain tables → 4 ontology instance tables
-- 15 operational tables retained
-- Pattern: OAA v7 JSONB + GIN indexes + extracted query columns
-- Ontologies: LSC-ONT v1.2.0, OFM-ONT v1.1.0, SOP-ONT v1.0.0
-- Governance: PE-ONT process, FUNC-ONT domain, RRR-ONT RACI/RBAC
-- ============================================================

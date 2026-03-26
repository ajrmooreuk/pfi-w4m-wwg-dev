
"""
eta_impact_engine.py
--------------------
Analyses ETA deviations and determines:
  - Which orders are at risk
  - What the impact is (delay / shelf-life / cancellation risk)
  - Which clients need notifying
  - What urgency/tone the notification should have

Impact classification matrix:
  ┌────────────────┬─────────────────────────────────────────────────────┐
  │ Delta Days     │ Impact Class                                        │
  ├────────────────┼─────────────────────────────────────────────────────┤
  │ 0              │ ON_TIME   — no action                               │
  │ +1 to +3       │ ADVISORY  — heads-up, delivery window likely ok     │
  │ +4 to +7       │ DELAY     — notify client, review delivery window   │
  │ +8 to +14      │ SIGNIFICANT — client must reschedule                │
  │ >14            │ CRITICAL  — contract review, possible force majeure │
  └────────────────┴─────────────────────────────────────────────────────┘
  
  Cold chain breach adds one severity level to any classification.
"""

from datetime import datetime, timedelta, timezone
from enum import Enum
from dataclasses import dataclass, field
from typing import List, Optional, Dict

class ImpactClass(Enum):
    ON_TIME     = "ON_TIME"
    ADVISORY    = "ADVISORY"
    DELAY       = "DELAY"
    SIGNIFICANT = "SIGNIFICANT"
    CRITICAL    = "CRITICAL"

class NotificationUrgency(Enum):
    NONE    = "NONE"
    INFO    = "INFO"
    WARNING = "WARNING"
    URGENT  = "URGENT"
    CRITICAL= "CRITICAL"

@dataclass
class OrderImpact:
    order_id:           str
    customer_name:      str
    customer_email:     str
    product:            str
    quantity_kg:        float
    delivery_due:       str       # ISO date
    delivery_window_end:str       # ISO date (last acceptable date)
    container_id:       str
    eta_current:        str       # ISO date
    eta_original:       str       # ISO date
    eta_delta_days:     float
    cold_chain_breach:  bool      = False
    breach_hours:       float     = 0.0
    shelf_life_impact:  str       = ""
    impact_class:       ImpactClass = ImpactClass.ON_TIME
    urgency:            NotificationUrgency = NotificationUrgency.NONE
    action_required:    str       = ""
    btom_deadline:      str       = ""
    notes:              str       = ""

class ETAImpactEngine:
    """
    Core impact analysis. Ingests a voyage record (from TrackerStore)
    and a client order manifest. Returns list of OrderImpact objects.
    """

    # Shelf life impact per product type per degree-hour above set point
    SHELF_LIFE_SENSITIVITY = {
        "fresh":   0.12,   # days per degree-hour — most sensitive
        "chilled": 0.05,
        "frozen":  0.01,
    }

    def analyse_voyage(self, voyage: dict, orders: List[dict]) -> List[OrderImpact]:
        """
        voyage  — TrackerStore voyage record
        orders  — list of order dicts linked to this container
        Returns list of OrderImpact objects.
        """
        container_id    = voyage.get("identifier", "")
        eta_current_str = voyage.get("etaCurrent", "")
        eta_orig_str    = voyage.get("etaOriginal", "")
        delta_days      = float(voyage.get("etaDeltaDays", 0))
        breach_active   = voyage.get("coldChain", {}).get("breachActive", False)
        breach_hours    = float(voyage.get("coldChain", {}).get("cumulativeBreachHours", 0))
        prod_type       = voyage.get("cargo", {}).get("productType", "frozen").lower()

        results = []
        for order in orders:
            impact = self._classify_order(
                order, container_id, eta_current_str, eta_orig_str,
                delta_days, breach_active, breach_hours, prod_type
            )
            results.append(impact)
        return results

    def _classify_order(self, order, cid, eta_cur, eta_orig, delta,
                        breach, breach_hrs, prod_type) -> OrderImpact:
        oi = OrderImpact(
            order_id           = order.get("order_id", ""),
            customer_name      = order.get("customer_name", ""),
            customer_email     = order.get("customer_email", ""),
            product            = order.get("product", ""),
            quantity_kg        = float(order.get("quantity_kg", 0)),
            delivery_due       = order.get("delivery_due", ""),
            delivery_window_end= order.get("delivery_window_end", order.get("delivery_due", "")),
            container_id       = cid,
            eta_current        = eta_cur,
            eta_original       = eta_orig,
            eta_delta_days     = delta,
            cold_chain_breach  = breach,
            breach_hours       = breach_hrs,
        )

        # ── Base impact class from delta days ─────────────────────────────────
        if   delta <= 0:   base_class = ImpactClass.ON_TIME
        elif delta <= 3:   base_class = ImpactClass.ADVISORY
        elif delta <= 7:   base_class = ImpactClass.DELAY
        elif delta <= 14:  base_class = ImpactClass.SIGNIFICANT
        else:              base_class = ImpactClass.CRITICAL

        # ── Delivery window check ─────────────────────────────────────────────
        window_exceeded = False
        if eta_cur and oi.delivery_window_end:
            try:
                eta_dt = datetime.fromisoformat(eta_cur)
                win_dt = datetime.fromisoformat(oi.delivery_window_end)
                # Add 2 days for BCP + customs clearance
                effective_delivery = eta_dt + timedelta(days=2)
                window_exceeded = effective_delivery > win_dt
                if window_exceeded and base_class.value < ImpactClass.DELAY.value:
                    base_class = ImpactClass.DELAY
            except: pass

        # ── Cold chain breach escalation ──────────────────────────────────────
        if breach:
            sensitivity = self.SHELF_LIFE_SENSITIVITY.get(prod_type, 0.05)
            shelf_days_lost = round(breach_hrs * sensitivity, 1)
            oi.shelf_life_impact = (
                f"Estimated {shelf_days_lost} days shelf-life reduction "
                f"({breach_hrs:.0f}hrs cumulative deviation). "
                f"QA assessment required on arrival."
            )
            # Escalate by one level
            classes = list(ImpactClass)
            idx = classes.index(base_class)
            base_class = classes[min(idx + 1, len(classes) - 1)]

        oi.impact_class = base_class

        # ── Urgency mapping ───────────────────────────────────────────────────
        urgency_map = {
            ImpactClass.ON_TIME:     NotificationUrgency.NONE,
            ImpactClass.ADVISORY:    NotificationUrgency.INFO,
            ImpactClass.DELAY:       NotificationUrgency.WARNING,
            ImpactClass.SIGNIFICANT: NotificationUrgency.URGENT,
            ImpactClass.CRITICAL:    NotificationUrgency.CRITICAL,
        }
        oi.urgency = urgency_map[base_class]

        # ── Action required text ──────────────────────────────────────────────
        actions = {
            ImpactClass.ON_TIME:     "No action required.",
            ImpactClass.ADVISORY:    "Monitor situation. No delivery changes anticipated at this stage.",
            ImpactClass.DELAY:       "Review delivery schedule. Confirm new delivery window with customer. Update warehouse booking.",
            ImpactClass.SIGNIFICANT: "Customer notification required. Reschedule delivery. Review contract terms and SLA.",
            ImpactClass.CRITICAL:    "Urgent customer consultation required. Contract force majeure review. Legal team to advise.",
        }
        oi.action_required = actions[base_class]
        if breach:
            oi.action_required += " QA team to assess shelf-life and confirm product acceptance criteria on arrival."
        if window_exceeded:
            oi.action_required += " Delivery window exceeded — customer must confirm revised acceptance date."

        # BTOM deadline
        if eta_cur:
            try:
                btom = datetime.fromisoformat(eta_cur) - timedelta(days=2)
                oi.btom_deadline = btom.strftime("%Y-%m-%d")
            except: pass

        return oi

    def generate_impact_report(self, impacts: List[OrderImpact]) -> dict:
        """Returns structured impact report for the notification agent."""
        critical = [i for i in impacts if i.impact_class == ImpactClass.CRITICAL]
        significant = [i for i in impacts if i.impact_class == ImpactClass.SIGNIFICANT]
        delays = [i for i in impacts if i.impact_class == ImpactClass.DELAY]
        advisory = [i for i in impacts if i.impact_class == ImpactClass.ADVISORY]
        on_time = [i for i in impacts if i.impact_class == ImpactClass.ON_TIME]

        return {
            "generated_at":    datetime.now(timezone.utc).isoformat(),
            "total_orders":    len(impacts),
            "summary": {
                "critical":    len(critical),
                "significant": len(significant),
                "delay":       len(delays),
                "advisory":    len(advisory),
                "on_time":     len(on_time),
            },
            "requires_notification": len(critical) + len(significant) + len(delays) + len(advisory),
            "cold_chain_affected": len([i for i in impacts if i.cold_chain_breach]),
            "impacts": [
                {
                    "order_id":        i.order_id,
                    "customer":        i.customer_name,
                    "email":           i.customer_email,
                    "impact_class":    i.impact_class.value,
                    "urgency":         i.urgency.value,
                    "eta_delta_days":  i.eta_delta_days,
                    "cold_chain":      i.cold_chain_breach,
                    "shelf_life":      i.shelf_life_impact,
                    "action":          i.action_required,
                    "btom_deadline":   i.btom_deadline,
                }
                for i in sorted(impacts, key=lambda x: list(ImpactClass).index(x.impact_class), reverse=True)
            ]
        }

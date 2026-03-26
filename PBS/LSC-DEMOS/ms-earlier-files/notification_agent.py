
"""
notification_agent.py
---------------------
Automated client email notification system.
Generates context-aware HTML emails based on impact classification.
Dispatches via Microsoft Graph (OutlookReader.send_email).
Logs all sent notifications to TrackerStore.

Email tone matrix:
  ON_TIME     → silent (no email)
  ADVISORY    → professional heads-up, light blue header
  DELAY       → clear delay notification, amber header
  SIGNIFICANT → formal delay notice, orange-red header, action items
  CRITICAL    → urgent executive notification, red header, legal caveat
"""

from datetime import datetime, timezone
from typing import List
import logging

log = logging.getLogger(__name__)

# Company branding config (override via env vars)
COMPANY_NAME   = os.getenv("COMPANY_NAME", "UK Premium Meats Ltd")
COMPANY_EMAIL  = os.getenv("COMPANY_EMAIL", "shipping@ukpremiummeats.co.uk")
COMPANY_PHONE  = os.getenv("COMPANY_PHONE", "+44 (0)1375 000 000")
COMPANY_LOGO_URL = os.getenv("COMPANY_LOGO_URL", "")

COLOUR_MAP = {
    "ADVISORY":    {"header": "#0A6B8A", "badge": "#E0F7FA", "badge_text": "#004D66"},
    "DELAY":       {"header": "#B45309", "badge": "#FEF3C7", "badge_text": "#78350F"},
    "SIGNIFICANT": {"header": "#B91C1C", "badge": "#FEE2E2", "badge_text": "#7F1D1D"},
    "CRITICAL":    {"header": "#7F1D1D", "badge": "#FEE2E2", "badge_text": "#450A0A"},
}

SUBJECT_MAP = {
    "ADVISORY":    "Shipping Update — {container} ETA Advisory",
    "DELAY":       "Delivery Delay Notice — {container} | {delta} days | Order {order}",
    "SIGNIFICANT": "URGENT: Significant Delivery Delay — {container} | {delta} days | Order {order}",
    "CRITICAL":    "CRITICAL DELAY NOTICE — {container} | Order {order} — Immediate Response Required",
}

class NotificationAgent:
    """
    Generates and dispatches client impact notifications.
    One email per affected customer per container per event.
    De-duplicates: will not re-send if identical notification already logged.
    """

    def __init__(self, outlook_reader=None, tracker_store=None):
        self.mailer  = outlook_reader    # OutlookReader instance (optional — can mock)
        self.tracker = tracker_store     # TrackerStore instance

    def process_impacts(self, impacts: List, voyage: dict, dry_run: bool = False) -> List[dict]:
        """
        Takes list of OrderImpact objects + voyage dict.
        Returns list of notification result dicts.
        """
        results = []
        # Group by customer email to avoid duplicate emails for same customer
        by_customer: dict = {}
        for impact in impacts:
            if impact.urgency.value == "NONE":
                continue
            key = impact.customer_email
            if key not in by_customer:
                by_customer[key] = []
            by_customer[key].append(impact)

        for email, customer_impacts in by_customer.items():
            # Check dedup — skip if already notified at same or higher level
            if self._already_notified(voyage, email, customer_impacts):
                log.info(f"Skipping duplicate notification to {email}")
                continue

            # Use highest urgency impact for email tone
            top_impact = max(customer_impacts,
                key=lambda i: list(["NONE","INFO","WARNING","URGENT","CRITICAL"]).index(i.urgency.value))

            subject, html_body = self._build_email(top_impact, customer_impacts, voyage)
            result = {
                "recipient":  email,
                "subject":    subject,
                "urgency":    top_impact.urgency.value,
                "orders":     [i.order_id for i in customer_impacts],
                "sent":       False,
                "dry_run":    dry_run,
            }

            if dry_run:
                result["html_preview"] = html_body
                log.info(f"[DRY RUN] Would send to {email}: {subject}")
            elif self.mailer:
                success = self.mailer.send_email(
                    to=[email],
                    subject=subject,
                    html_body=html_body,
                    cc=[COMPANY_EMAIL],
                )
                result["sent"] = success
            else:
                log.warning("No mailer configured — storing notification only.")

            # Log to tracker regardless
            if self.tracker:
                notif_log = {
                    "type":       top_impact.urgency.value,
                    "recipient":  email,
                    "subject":    subject,
                    "orders":     result["orders"],
                    "sent":       result["sent"] or dry_run,
                }
                self.tracker.append_notification(voyage["identifier"], notif_log)

            results.append(result)
        return results

    def _already_notified(self, voyage: dict, email: str, impacts: list) -> bool:
        """Check if we already sent a notification at same urgency to this email today."""
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        top_urgency = max(impacts, key=lambda i: i.urgency.value).urgency.value
        for log_entry in voyage.get("notificationLog", []):
            if (log_entry.get("recipient") == email
                    and log_entry.get("type") == top_urgency
                    and log_entry.get("sentAt", "").startswith(today)):
                return True
        return False

    def _build_email(self, top: "OrderImpact", all_impacts: List["OrderImpact"], voyage: dict) -> tuple:
        """Builds (subject, html_body) for a client notification."""
        impact_class = top.impact_class.value
        urgency = top.urgency.value
        colours = COLOUR_MAP.get(urgency, COLOUR_MAP["DELAY"])
        container = voyage.get("identifier", "")
        carrier   = voyage.get("provider", {}).get("name", "")
        vessel    = voyage.get("vessel", {}).get("name", "")
        product   = voyage.get("cargo", {}).get("name", "")
        eta_orig  = voyage.get("etaOriginal", "—")[:10]
        eta_cur   = voyage.get("etaCurrent", "—")[:10]
        delta     = voyage.get("etaDeltaDays", 0)
        delay_reason = voyage.get("delayReason", "Operational factors as advised by carrier.")
        breach    = voyage.get("coldChain", {}).get("breachActive", False)
        port_dest = voyage.get("arrivalLocation", {}).get("name", "UK port")

        subject_tmpl = SUBJECT_MAP.get(urgency, SUBJECT_MAP["DELAY"])
        subject = subject_tmpl.format(
            container=container, delta=f"+{delta}" if delta > 0 else str(delta),
            order=top.order_id
        )

        urgency_labels = {
            "INFO":    "Advisory Notice",
            "WARNING": "Delivery Delay Notice",
            "URGENT":  "Significant Delay Notice",
            "CRITICAL":"CRITICAL — Immediate Action Required",
        }
        urgency_label = urgency_labels.get(urgency, "Shipping Update")

        # Build orders table rows
        orders_rows = ""
        for imp in all_impacts:
            status_color = "#C0392B" if imp.impact_class.value in ("CRITICAL","SIGNIFICANT") else                            "#B45309" if imp.impact_class.value == "DELAY" else "#0A6B8A"
            orders_rows += f"""
            <tr>
              <td style="padding:8px 10px;border-bottom:1px solid #e5e7eb;font-family:monospace;font-size:12px;color:#1B2A4A">{imp.order_id}</td>
              <td style="padding:8px 10px;border-bottom:1px solid #e5e7eb;font-size:13px">{imp.product}</td>
              <td style="padding:8px 10px;border-bottom:1px solid #e5e7eb;font-size:13px;text-align:right">{imp.quantity_kg:,.0f} kg</td>
              <td style="padding:8px 10px;border-bottom:1px solid #e5e7eb;font-size:12px">{imp.delivery_due}</td>
              <td style="padding:8px 10px;border-bottom:1px solid #e5e7eb;font-size:12px">{imp.delivery_window_end}</td>
              <td style="padding:8px 10px;border-bottom:1px solid #e5e7eb;font-size:12px;font-weight:bold;color:{status_color}">{imp.impact_class.value}</td>
            </tr>"""

        breach_section = ""
        if breach:
            breach_section = f"""
            <div style="margin:16px 0;padding:14px 16px;background:#FEF2F2;border:1px solid #FECACA;border-left:4px solid #DC2626;border-radius:4px">
              <strong style="color:#991B1B">⚠ Cold Chain Alert</strong><br>
              <span style="font-size:13px;color:#7F1D1D">{top.shelf_life_impact}</span>
            </div>"""

        legal_caveat = ""
        if urgency == "CRITICAL":
            legal_caveat = """
            <p style="font-size:11px;color:#6B7280;margin-top:20px;padding-top:12px;border-top:1px solid #e5e7eb">
              This notice is issued in accordance with our contractual obligations under the terms of the 
              shipment agreement. Should this delay constitute a force majeure event under your contract, 
              please refer to the relevant clause and notify your legal team accordingly. 
              All carrier documentation will be provided upon request.
            </p>"""

        html = f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<style>
  body{{font-family:'Segoe UI',Arial,sans-serif;background:#f9fafb;margin:0;padding:0}}
  .wrap{{max-width:680px;margin:24px auto;background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)}}
  .hdr{{background:{colours["header"]};padding:24px 28px;color:#fff}}
  .hdr-label{{font-size:11px;text-transform:uppercase;letter-spacing:0.15em;opacity:0.8;margin-bottom:6px}}
  .hdr-title{{font-size:20px;font-weight:700;margin:0}}
  .hdr-sub{{font-size:13px;opacity:0.9;margin-top:4px}}
  .body{{padding:24px 28px}}
  .badge{{display:inline-block;padding:4px 10px;border-radius:4px;font-size:11px;font-weight:600;
    background:{colours["badge"]};color:{colours["badge_text"]};text-transform:uppercase;letter-spacing:0.08em;margin-bottom:14px}}
  h3{{font-size:14px;color:#1B2A4A;margin:16px 0 8px}}
  table{{width:100%;border-collapse:collapse;font-size:13px}}
  thead th{{background:#F1F5F9;padding:8px 10px;text-align:left;font-size:11px;
    text-transform:uppercase;letter-spacing:0.08em;color:#475569;border-bottom:2px solid #e2e8f0}}
  .kv-row{{display:flex;gap:8px;margin-bottom:6px;font-size:13px}}
  .kv-label{{font-weight:600;color:#475569;width:160px;flex-shrink:0}}
  .kv-value{{color:#1B2A4A}}
  .kv-value.delta{{color:{colours["header"]};font-weight:700}}
  .action-box{{background:#F8FAFC;border:1px solid #E2E8F0;border-radius:6px;padding:14px 16px;margin:16px 0}}
  .footer{{background:#F1F5F9;padding:16px 28px;font-size:12px;color:#6B7280;border-top:1px solid #e5e7eb}}
</style></head>
<body>
<div class="wrap">
  <div class="hdr">
    <div class="hdr-label">{COMPANY_NAME} — Inbound Shipment Intelligence</div>
    <div class="hdr-title">{urgency_label}</div>
    <div class="hdr-sub">{container} · {carrier} · {vessel}</div>
  </div>
  <div class="body">
    <div class="badge">{urgency_label}</div>
    <p style="font-size:14px;color:#374151;line-height:1.6">
      Dear {top.customer_name},<br><br>
      We are writing to advise you of a {"significant " if urgency in ("URGENT","CRITICAL") else ""}
      change to the estimated arrival of your shipment. Please review the details below carefully.
    </p>

    <h3>Shipment Details</h3>
    <div style="background:#F8FAFC;border-radius:6px;padding:14px 16px;margin-bottom:12px">
      <div class="kv-row"><span class="kv-label">Container No.</span><span class="kv-value" style="font-family:monospace">{container}</span></div>
      <div class="kv-row"><span class="kv-label">Carrier / Vessel</span><span class="kv-value">{carrier} · {vessel}</span></div>
      <div class="kv-row"><span class="kv-label">Product</span><span class="kv-value">{product}</span></div>
      <div class="kv-row"><span class="kv-label">Port of Discharge</span><span class="kv-value">{port_dest}</span></div>
      <div class="kv-row"><span class="kv-label">Original ETA</span><span class="kv-value">{eta_orig}</span></div>
      <div class="kv-row"><span class="kv-label">Revised ETA</span><span class="kv-value delta">{eta_cur} (+{delta} days)</span></div>
      <div class="kv-row"><span class="kv-label">BTOM Pre-Notification Due</span><span class="kv-value">{top.btom_deadline}</span></div>
    </div>

    <div style="margin:12px 0;padding:12px 14px;background:#FFF7ED;border-left:3px solid {colours["header"]};border-radius:0 4px 4px 0">
      <strong style="font-size:13px;color:{colours["header"]}">Reason for Delay:</strong>
      <span style="font-size:13px;color:#374151"> {delay_reason}</span>
    </div>

    {breach_section}

    <h3>Affected Orders</h3>
    <table>
      <thead><tr>
        <th>Order ID</th><th>Product</th><th style="text-align:right">Qty (kg)</th>
        <th>Due Date</th><th>Window End</th><th>Status</th>
      </tr></thead>
      <tbody>{orders_rows}</tbody>
    </table>

    <div class="action-box">
      <strong style="font-size:13px;color:#1B2A4A">Required Actions:</strong>
      <p style="font-size:13px;color:#374151;margin:6px 0 0">{top.action_required}</p>
    </div>

    <p style="font-size:13px;color:#374151">
      We will continue to monitor this shipment and provide updates as conditions change.
      If you have any questions or need to discuss delivery arrangements, please contact our
      logistics team immediately.
    </p>

    {legal_caveat}
  </div>
  <div class="footer">
    <strong>{COMPANY_NAME}</strong><br>
    {COMPANY_EMAIL} · {COMPANY_PHONE}<br>
    This notification was generated automatically by MeatTrackAI Shipment Intelligence.<br>
    Ref: {container} · Generated: {datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")}
  </div>
</div>
</body></html>"""

        return subject, html

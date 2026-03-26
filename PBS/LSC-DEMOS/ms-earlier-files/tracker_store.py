
"""
tracker_store.py
----------------
JSON-native state store for the MeatTrackAI reefer tracker.
Replaces the Excel file as the live source of truth.
Schema: schema.org/Trip + GeoCoordinates + PropertyValue extensions.

Why JSON over Excel for the live store:
  ✓ Machine-readable without openpyxl overhead
  ✓ Atomic per-container updates (no file lock contention)
  ✓ Supabase JSONB-compatible (direct upsert)
  ✓ Full event history preserved
  ✓ Excel auto-generated on demand from JSON state
"""

import json, os, shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, List, Dict, Any
import copy

TRACKER_PATH = os.getenv("TRACKER_PATH", "data/reefer_tracker.json")
HISTORY_DIR  = os.getenv("HISTORY_DIR",  "data/history")

# ── Schema ────────────────────────────────────────────────────────────────────

def empty_tracker() -> dict:
    """Returns the root tracker document structure."""
    return {
        "@context": "https://schema.org",
        "@type": "ItemList",
        "name": "MeatTrackAI Inbound Reefer Tracker",
        "description": "Live state store for AU→UK refrigerated container shipments",
        "dateModified": _now(),
        "numberOfItems": 0,
        "itemListElement": [],   # List of VoyageRecord
        "_meta": {
            "version": "1.0",
            "last_pdf_processed": None,
            "last_eta_check": None,
            "notification_queue": [],
        }
    }

def empty_voyage(container_id: str) -> dict:
    """Schema.org/Trip-grounded voyage record."""
    return {
        "@type": "Trip",
        "@id": f"urn:meattrack:voyage:{container_id}",
        "identifier": container_id,

        # Carrier / vessel
        "provider": {
            "@type": "Organization",
            "name": "",
            "identifier": ""   # SCAC code
        },
        "vessel": {
            "name": "",
            "imoNumber": "",
            "mmsi": "",
            "voyageNumber": "",
            "serviceString": ""
        },

        # Cargo
        "cargo": {
            "@type": "Product",
            "name": "",
            "productType": "",      # frozen / chilled / fresh
            "hsCode": "",
            "grossWeightKg": None,
            "netWeightKg": None,
            "numberOfPackages": "",
            "setPointCelsius": None,
            "blNumber": "",
            "bookingRef": "",
            "sealNo": "",
            "shipper": "",
            "consignee": ""
        },

        # Route
        "departureLocation": {"@type": "Port", "locode": "", "name": ""},
        "arrivalLocation":   {"@type": "Port", "locode": "", "name": ""},
        "departuretime":     None,   # ISO datetime string
        "etaOriginal":       None,
        "etaCurrent":        None,
        "etaDeltaDays":      0,
        "delayReason":       "",
        "routeType":         "CAPE",  # SUEZ / CAPE / HORMUZ

        # Live position (latest AIS)
        "currentPosition": {
            "@type": "GeoCoordinates",
            "latitude": None,
            "longitude": None,
            "description": "",
            "speedOverGroundKnots": None,
            "courseOverGround": None,
            "navigationStatus": "",
            "aisSource": "satellite",
            "positionTimestamp": None
        },

        # Cold chain (latest Captain Peter)
        "coldChain": {
            "supplyAirTempCelsius":  None,
            "returnAirTempCelsius":  None,
            "setPointCelsius":       None,
            "humidityPct":           None,
            "powerStatus":           "UNKNOWN",
            "alarmActive":           False,
            "breachActive":          False,
            "breachStartedAt":       None,
            "cumulativeBreachHours": 0,
            "lastReadingAt":         None
        },

        # Compliance
        "compliance": {
            "ipaffsRef":          "",
            "ipaffsStatus":       "PENDING",
            "chedppStatus":       "PENDING",
            "healthCertNo":       "",
            "bcp":                "",
            "btomStatus":         "PENDING",
            "btomNotificationDue": None,
            "coldStoreRef":       ""
        },

        # Voyage status
        "voyageStatus":   "Booked",
        "riskLevel":      "LOW",
        "ordersAtRisk":   [],

        # Event history
        "eventLog": [],   # List of VoyageEvent
        "alertLog": [],   # List of Alert
        "notificationLog": [],  # List of SentNotification

        # Processing metadata
        "_meta": {
            "sourceDocuments":  [],
            "lastUpdatedAt":    _now(),
            "lastUpdatedFrom":  "system",
            "processingStatus": "active"
        }
    }

def voyage_event(event_type: str, description: str, source: str = "system") -> dict:
    return {
        "@type": "Event",
        "eventType": event_type,
        "description": description,
        "startDate": _now(),
        "source": source
    }

def _now() -> str:
    return datetime.now(timezone.utc).isoformat()

# ── TrackerStore class ────────────────────────────────────────────────────────

class TrackerStore:
    """
    JSON-native state store. Thread-safe reads; atomic writes via temp file swap.
    All mutations go through update_voyage() which preserves event history.
    """

    def __init__(self, path: str = None):
        self.path = Path(path or TRACKER_PATH)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        Path(HISTORY_DIR).mkdir(parents=True, exist_ok=True)
        if not self.path.exists():
            self._write(empty_tracker())

    # ── Read ──────────────────────────────────────────────────────────────────

    def load(self) -> dict:
        with open(self.path) as f:
            return json.load(f)

    def get_voyage(self, container_id: str) -> Optional[dict]:
        tracker = self.load()
        for item in tracker["itemListElement"]:
            if item.get("identifier") == container_id:
                return item
        return None

    def all_voyages(self) -> List[dict]:
        return self.load()["itemListElement"]

    def active_voyages(self) -> List[dict]:
        return [v for v in self.all_voyages()
                if v.get("voyageStatus") not in ("Gate Out", "Delivered", "Cancelled")]

    def voyages_by_risk(self, level: str) -> List[dict]:
        return [v for v in self.all_voyages() if v.get("riskLevel") == level]

    # ── Write ─────────────────────────────────────────────────────────────────

    def _write(self, tracker: dict):
        """Atomic write via temp file + rename."""
        tracker["dateModified"] = _now()
        tracker["numberOfItems"] = len(tracker.get("itemListElement", []))
        tmp = self.path.with_suffix(".tmp")
        with open(tmp, "w") as f:
            json.dump(tracker, f, indent=2, default=str)
        tmp.rename(self.path)

    def _archive_snapshot(self):
        """Save timestamped snapshot to history folder."""
        stamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        dest = Path(HISTORY_DIR) / f"tracker_{stamp}.json"
        shutil.copy2(self.path, dest)

    def upsert_voyage(self, container_id: str, updates: dict,
                      event_description: str = None, source: str = "pdf_parser") -> dict:
        """
        Create or update a voyage record.
        Deep-merges updates into existing record.
        Appends event to log. Returns updated record.
        """
        tracker = self.load()
        existing_idx = None
        for i, item in enumerate(tracker["itemListElement"]):
            if item.get("identifier") == container_id:
                existing_idx = i
                break

        if existing_idx is not None:
            voyage = tracker["itemListElement"][existing_idx]
            voyage = _deep_merge(voyage, updates)
        else:
            voyage = empty_voyage(container_id)
            voyage = _deep_merge(voyage, updates)
            tracker["itemListElement"].append(voyage)
            existing_idx = len(tracker["itemListElement"]) - 1

        voyage["_meta"]["lastUpdatedAt"] = _now()
        voyage["_meta"]["lastUpdatedFrom"] = source

        if event_description:
            voyage["eventLog"].append(voyage_event(
                updates.get("voyageStatus", "UPDATE"), event_description, source
            ))

        tracker["itemListElement"][existing_idx if existing_idx >= 0 else -1] = voyage
        self._write(tracker)
        return voyage

    def append_alert(self, container_id: str, alert: dict):
        """Add an alert to a voyage's alert log."""
        tracker = self.load()
        for item in tracker["itemListElement"]:
            if item.get("identifier") == container_id:
                item["alertLog"].append({**alert, "loggedAt": _now()})
                break
        self._write(tracker)

    def append_notification(self, container_id: str, notification: dict):
        """Record a sent notification in the voyage's notification log."""
        tracker = self.load()
        for item in tracker["itemListElement"]:
            if item.get("identifier") == container_id:
                item["notificationLog"].append({**notification, "sentAt": _now()})
                break
        self._write(tracker)

    def queue_notification(self, container_id: str, notif_type: str,
                           recipients: List[str], payload: dict):
        """Add a notification to the pending queue."""
        tracker = self.load()
        tracker["_meta"]["notification_queue"].append({
            "container_id": container_id,
            "type": notif_type,
            "recipients": recipients,
            "payload": payload,
            "queued_at": _now(),
            "status": "PENDING"
        })
        self._write(tracker)

    def dequeue_notification(self, idx: int):
        """Mark a queued notification as sent."""
        tracker = self.load()
        if idx < len(tracker["_meta"]["notification_queue"]):
            tracker["_meta"]["notification_queue"][idx]["status"] = "SENT"
            tracker["_meta"]["notification_queue"][idx]["sent_at"] = _now()
        self._write(tracker)

    def pending_notifications(self) -> List[tuple]:
        """Returns (idx, notification) pairs for pending items."""
        tracker = self.load()
        return [(i, n) for i, n in enumerate(tracker["_meta"]["notification_queue"])
                if n.get("status") == "PENDING"]

    def export_summary(self) -> dict:
        """Returns a summary dict suitable for dashboard/API consumption."""
        voyages = self.all_voyages()
        return {
            "generatedAt": _now(),
            "totalVoyages": len(voyages),
            "activeVoyages": len([v for v in voyages if v["voyageStatus"] not in ("Gate Out","Delivered")]),
            "delayed": len([v for v in voyages if v.get("etaDeltaDays", 0) > 0]),
            "criticalRisk": len([v for v in voyages if v.get("riskLevel") == "CRITICAL"]),
            "coldChainBreaches": len([v for v in voyages if v.get("coldChain", {}).get("breachActive")]),
            "voyages": [{
                "containerId":   v["identifier"],
                "carrier":       v.get("provider", {}).get("name", ""),
                "vessel":        v.get("vessel", {}).get("name", ""),
                "product":       v.get("cargo", {}).get("name", ""),
                "status":        v.get("voyageStatus", ""),
                "etaCurrent":    v.get("etaCurrent", ""),
                "etaDeltaDays":  v.get("etaDeltaDays", 0),
                "riskLevel":     v.get("riskLevel", "LOW"),
                "breachActive":  v.get("coldChain", {}).get("breachActive", False),
                "ordersAtRisk":  v.get("ordersAtRisk", []),
            } for v in voyages]
        }

def _deep_merge(base: dict, updates: dict) -> dict:
    """Recursively merge updates into base dict."""
    result = copy.deepcopy(base)
    for k, v in updates.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = _deep_merge(result[k], v)
        elif v is not None:
            result[k] = v
    return result

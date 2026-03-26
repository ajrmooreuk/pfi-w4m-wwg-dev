
"""
outlook_reader.py
-----------------
Reads shipping PDF notifications from Microsoft 365 Outlook inbox
using Microsoft Graph API (OAuth 2.0 Client Credentials).

SETUP REQUIRED (one-time):
  1. Register an app in Azure Entra ID (portal.azure.com)
     → Azure Active Directory → App registrations → New registration
  2. Under "API permissions" add:
        Microsoft Graph → Application permissions:
        ✓ Mail.Read
        ✓ Mail.ReadWrite  (to mark as processed)
        ✓ Mail.Send       (for notification dispatch)
     → Grant admin consent
  3. Create a client secret under "Certificates & secrets"
  4. Copy Tenant ID, Client ID, Client Secret into .env

ENVIRONMENT VARIABLES (.env):
  AZURE_TENANT_ID=your-tenant-id
  AZURE_CLIENT_ID=your-client-id
  AZURE_CLIENT_SECRET=your-client-secret
  MAILBOX_EMAIL=reefer-inbox@yourcompany.com
  PROCESSED_FOLDER=MeatTrackAI-Processed   (auto-created if missing)
  SENDER_FILTER=@maersk.com,@hapag-lloyd.com,@msc.com,@cma-cgm.com
  SUBJECT_FILTER=reefer,arrival notice,temperature,eta,departure
"""

import os, requests, json, base64, logging
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

log = logging.getLogger(__name__)

GRAPH_BASE = "https://graph.microsoft.com/v1.0"

class OutlookReader:
    """
    Connects to Microsoft 365 via Graph API.
    Scans inbox for carrier shipping notifications.
    Downloads PDF attachments.
    Moves processed messages to archive folder.
    """

    def __init__(self):
        self.tenant_id    = os.getenv("AZURE_TENANT_ID")
        self.client_id    = os.getenv("AZURE_CLIENT_ID")
        self.client_secret= os.getenv("AZURE_CLIENT_SECRET")
        self.mailbox      = os.getenv("MAILBOX_EMAIL")
        self.proc_folder  = os.getenv("PROCESSED_FOLDER", "MeatTrackAI-Processed")
        self.sender_filter= [s.strip() for s in os.getenv("SENDER_FILTER",
                             "@maersk.com,@hapag-lloyd.com,@msc.com,@cma-cgm.com,@oocl.com").split(",")]
        self.subject_kw   = [s.strip().lower() for s in os.getenv("SUBJECT_FILTER",
                             "reefer,arrival,temperature,eta,departure,alert,shipment").split(",")]
        self._token       = None
        self._token_expiry= None
        self._proc_folder_id = None

    # ── Authentication ────────────────────────────────────────────────────────

    def _get_token(self) -> str:
        """OAuth 2.0 Client Credentials flow. Token cached until expiry."""
        now = datetime.now(timezone.utc).timestamp()
        if self._token and self._token_expiry and now < self._token_expiry - 60:
            return self._token

        url = f"https://login.microsoftonline.com/{self.tenant_id}/oauth2/v2.0/token"
        resp = requests.post(url, data={
            "grant_type":    "client_credentials",
            "client_id":     self.client_id,
            "client_secret": self.client_secret,
            "scope":         "https://graph.microsoft.com/.default",
        }, timeout=30)
        resp.raise_for_status()
        data = resp.json()
        self._token = data["access_token"]
        self._token_expiry = now + data.get("expires_in", 3600)
        log.info("Graph API token acquired.")
        return self._token

    def _headers(self) -> dict:
        return {
            "Authorization": f"Bearer {self._get_token()}",
            "Content-Type":  "application/json",
            "Accept":        "application/json",
        }

    def _get(self, path: str, params: dict = None) -> dict:
        r = requests.get(f"{GRAPH_BASE}{path}", headers=self._headers(),
                         params=params, timeout=30)
        r.raise_for_status()
        return r.json()

    def _post(self, path: str, body: dict) -> dict:
        r = requests.post(f"{GRAPH_BASE}{path}", headers=self._headers(),
                          json=body, timeout=30)
        r.raise_for_status()
        return r.json() if r.content else {}

    # ── Folder management ─────────────────────────────────────────────────────

    def _ensure_processed_folder(self) -> str:
        """Get or create the processed mail folder. Returns folder ID."""
        if self._proc_folder_id:
            return self._proc_folder_id

        folders = self._get(f"/users/{self.mailbox}/mailFolders")
        for f in folders.get("value", []):
            if f["displayName"] == self.proc_folder:
                self._proc_folder_id = f["id"]
                return self._proc_folder_id

        # Create it
        new_folder = self._post(
            f"/users/{self.mailbox}/mailFolders",
            {"displayName": self.proc_folder}
        )
        self._proc_folder_id = new_folder["id"]
        log.info(f"Created mail folder: {self.proc_folder}")
        return self._proc_folder_id

    # ── Message scanning ──────────────────────────────────────────────────────

    def _is_carrier_notification(self, msg: dict) -> bool:
        """Filter: sender domain OR subject keyword match."""
        sender = (msg.get("from", {}).get("emailAddress", {}).get("address") or "").lower()
        subject = (msg.get("subject") or "").lower()
        sender_match  = any(dom in sender for dom in self.sender_filter)
        subject_match = any(kw in subject for kw in self.subject_kw)
        return sender_match or subject_match

    def scan_inbox(self, max_messages: int = 50) -> List[dict]:
        """
        Scans inbox for unread carrier notifications.
        Returns list of message metadata dicts.
        """
        params = {
            "$filter":  "isRead eq false",
            "$orderby": "receivedDateTime desc",
            "$top":     str(max_messages),
            "$select":  "id,subject,from,receivedDateTime,hasAttachments,bodyPreview",
        }
        data = self._get(f"/users/{self.mailbox}/mailFolders/inbox/messages", params)
        messages = data.get("value", [])
        log.info(f"Inbox: {len(messages)} unread messages scanned.")

        # Handle pagination (odata.nextLink)
        while "@odata.nextLink" in data and len(messages) < max_messages:
            next_url = data["@odata.nextLink"].replace(GRAPH_BASE, "")
            data = self._get(next_url)
            messages.extend(data.get("value", []))

        filtered = [m for m in messages if self._is_carrier_notification(m)]
        log.info(f"Carrier notifications found: {len(filtered)}")
        return filtered

    # ── Attachment extraction ─────────────────────────────────────────────────

    def download_pdf_attachments(self, message_id: str, out_dir: str) -> List[str]:
        """
        Downloads all PDF attachments from a message.
        Returns list of saved file paths.
        """
        out_path = Path(out_dir)
        out_path.mkdir(parents=True, exist_ok=True)

        attachments = self._get(
            f"/users/{self.mailbox}/messages/{message_id}/attachments",
            {"$select": "id,name,contentType,size,contentBytes"}
        )
        saved = []
        for att in attachments.get("value", []):
            name = att.get("name", "attachment")
            ctype = att.get("contentType", "")
            if "pdf" not in ctype.lower() and not name.lower().endswith(".pdf"):
                continue

            # Decode base64 content
            content_b64 = att.get("contentBytes")
            if not content_b64:
                # Large attachment — fetch separately
                att_full = self._get(
                    f"/users/{self.mailbox}/messages/{message_id}/attachments/{att['id']}"
                )
                content_b64 = att_full.get("contentBytes", "")

            if not content_b64:
                log.warning(f"Could not retrieve attachment: {name}")
                continue

            # Sanitise filename, add inbox prefix for pipeline compatibility
            safe_name = re.sub(r'[^a-zA-Z0-9._\-]', '_', name)
            if not safe_name.startswith("inbox_"):
                safe_name = f"inbox_{safe_name}"
            dest = out_path / safe_name

            with open(dest, "wb") as f:
                f.write(base64.b64decode(content_b64))
            saved.append(str(dest))
            log.info(f"Saved: {dest} ({att.get('size', 0):,} bytes)")

        return saved

    # ── Process a full inbox scan ─────────────────────────────────────────────

    def process_inbox(self, pdf_out_dir: str, mark_read: bool = True,
                      move_to_processed: bool = True) -> List[str]:
        """
        Full inbox pipeline:
          1. Scan for carrier notifications
          2. Download PDF attachments
          3. Optionally mark as read
          4. Optionally move to processed folder
        Returns list of all downloaded PDF paths.
        """
        messages = self.scan_inbox()
        all_pdfs = []
        proc_folder_id = self._ensure_processed_folder() if move_to_processed else None

        for msg in messages:
            msg_id = msg["id"]
            subject = msg.get("subject", "")
            sender  = msg.get("from", {}).get("emailAddress", {}).get("address", "")
            log.info(f"Processing: {subject!r} from {sender}")

            if msg.get("hasAttachments"):
                pdfs = self.download_pdf_attachments(msg_id, pdf_out_dir)
                all_pdfs.extend(pdfs)

            if mark_read:
                requests.patch(
                    f"{GRAPH_BASE}/users/{self.mailbox}/messages/{msg_id}",
                    headers=self._headers(), json={"isRead": True}, timeout=30
                )

            if move_to_processed and proc_folder_id:
                requests.post(
                    f"{GRAPH_BASE}/users/{self.mailbox}/messages/{msg_id}/move",
                    headers=self._headers(), json={"destinationId": proc_folder_id}, timeout=30
                )

        log.info(f"Inbox processed. {len(all_pdfs)} PDFs downloaded.")
        return all_pdfs

    # ── Send email via Graph ──────────────────────────────────────────────────

    def send_email(self, to: List[str], subject: str, html_body: str,
                   cc: List[str] = None, reply_to: str = None) -> bool:
        """
        Send email from the configured mailbox via Graph API.
        Used by the notification agent to dispatch client alerts.
        """
        payload = {
            "message": {
                "subject": subject,
                "body": {"contentType": "HTML", "content": html_body},
                "toRecipients": [{"emailAddress": {"address": a}} for a in to],
                "ccRecipients": [{"emailAddress": {"address": a}} for a in (cc or [])],
            },
            "saveToSentItems": True,
        }
        if reply_to:
            payload["message"]["replyTo"] = [{"emailAddress": {"address": reply_to}}]

        try:
            requests.post(
                f"{GRAPH_BASE}/users/{self.mailbox}/sendMail",
                headers=self._headers(), json=payload, timeout=30
            ).raise_for_status()
            log.info(f"Email sent: {subject} → {to}")
            return True
        except Exception as e:
            log.error(f"Send failed: {e}")
            return False

# PFC-LSC-DOC-MeatTrackAI-Microsoft-Integration-Demo-v1.0.0

> **Product:** W4M-WWG LSC Demos
> **Version:** 1.0.0
> **Status:** Demo / Proof of Concept
> **Source:** `MeatTrackAI_Microsoft_Demo_1.html`
> **Cross-ref:** Epic 90 (#39), F90.5 (#44), F90.10 (#49)

---

## 1. Overview

The MeatTrackAI Microsoft Integration Demo is a 6-section interactive prototype demonstrating end-to-end integration of the MeatTrackAI fleet intelligence platform with Microsoft 365 services (Outlook, Excel, Graph API). It simulates the full pipeline from carrier email receipt through PDF data extraction, tracker population, and client notification dispatch.

**Pipeline:** Outlook 365 (carrier PDFs arrive) -> Graph API (OAuth 2.0 read) -> PDF Parser (pdfplumber, 48 fields) -> JSON Tracker (schema.org/Trip) -> Excel (7-sheet workbook) -> Graph API (sendMail HTML) -> Client (notification sent)

**Key principle:** One Microsoft Graph API OAuth token handles both inbound email reading and outbound notification sending -- no separate SMTP setup required.

---

## 2. Demo Sections

### Section 1: Microsoft Integration Architecture

**Azure Setup (One-Time, 15 minutes):**

| Step | Action | Detail |
|------|--------|--------|
| 1 | Register App in Azure Entra ID | portal.azure.com -> App registrations -> "MeatTrackAI-Pipeline" |
| 2 | Grant API permissions | Microsoft Graph Application: `Mail.Read`, `Mail.ReadWrite`, `Mail.Send` -> Admin consent |
| 3 | Create client secret | Certificates & secrets -> copy value (shown once) |
| 4 | Configure .env | `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `MAILBOX_EMAIL` |
| 5 | Test connection | `python src/outlook_reader.py --test-connection` |

**Domain Governance Rules:**

| Domain | Direction | Rule | Action |
|--------|-----------|------|--------|
| @maersk.com | Inbound | Approved carrier | ALLOW |
| @hapag-lloyd.com | Inbound | Approved carrier | ALLOW |
| @msc.com | Inbound | Approved carrier | ALLOW |
| @cma-cgm.com | Inbound | Approved carrier | ALLOW |
| @gmail.com | Inbound | Consumer domain | BLOCK |
| @freightnews.com | Inbound | Not approved | BLOCK |
| @tesco.co.uk | Outbound | Approved client | ALLOW |
| @unknown.io | Outbound | Not in approved list | BLOCK |

**Microsoft vs Google Comparison:**

| Factor | Outlook / Graph | Google GWS |
|--------|----------------|------------|
| Setup time | ~15 min | ~5 min |
| Admin consent | Required (M365) | Not required |
| Best for | Enterprise M365 clients | PoC / Google shops |
| Inbox routing | Exchange rules / folders | Gmail labels |
| Notifications | Send from corporate address | Send from Gmail address |
| PDF parsing | Identical -- pdfplumber | Identical -- pdfplumber |

---

### Section 2: Outlook Inbox Simulation

Simulated Microsoft 365 inbox for `reefer-inbox@ukpremiummeats.co.uk` with:

- **11 inbound emails** from carriers (Maersk, Hapag-Lloyd, MSC, CMA CGM, OOCL, Evergreen, COSCO)
- **2 blocked emails** (consumer/unapproved domains)
- **8 sent notifications** to clients
- **23 processed** emails in archive

**LSC Label System:**
- `lsc-shipping` (8 emails) -- standard shipping notifications
- `lsc-reefer` (2 emails) -- reefer temperature alerts
- `lsc-compliance` (1 email) -- BTOM/IPAFFS compliance

**Graph API Connection:** Connected as `MeatTrackAI-Pipeline` app registration.

Each email click shows extracted data fields, parse source (body vs PDF), and domain governance status.

---

### Section 3: PDF Data Capture -- pdfplumber Extraction

3 carrier PDFs parsed with 48-field extraction:

**Parse strategy:** Body text parsed first (fast). PDF fills supplementary fields (HS code, exact weight, voyage). Body wins on conflict. Each field tagged `[body]` or `[pdf]` for audit trail.

#### PDF 1: Maersk Arrival Notice (MRKU4821073)

| Field | Value | Status |
|-------|-------|--------|
| Shipping Reference | MAEU1234567890 | body+pdf merged |
| Container No. | MRKU4821073 | -- |
| Vessel | MV Maersk Hobart | -- |
| Voyage | 426W | -- |
| HS Code | 0202.30.00 | pdf |
| Gross Weight | 24,840 kg | pdf |
| Original ETA | 2026-03-22 | -- |
| Revised ETA | 2026-03-26 (+4.5d) | DELAY |
| Set Point | -18.0C | -- |
| Latest Temp | -17.8C | OK |
| IPAFFS | SUBMITTED | -- |
| Fields extracted | 46/48 | -- |

#### PDF 2: Hapag-Lloyd Temperature Alert (HLXU9901234)

| Field | Value | Status |
|-------|-------|--------|
| Shipping Reference | HLBU9901234001 | body+pdf merged |
| Container No. | HLXU9901234 | -- |
| Vessel | MV Hapag San Francisco | -- |
| Revised ETA | 2026-04-16 (+6d) | CRITICAL |
| Set Point | +1.0C | -- |
| Current Temp | +2.8C (+1.8C OVER) | BREACH |
| Breach Hours | 150 hours cumulative | -- |
| Shelf Life Impact | Est. -7.5 days | -- |
| CHED-PP | MANDATORY -- declare breach | -- |
| Fields extracted | 48/48 | -- |

#### PDF 3: MSC Departure Confirmation (MSCU5512087)

| Field | Value | Status |
|-------|-------|--------|
| Shipping Reference | MSCUFE5512087001 | body+pdf merged |
| Container No. | MSCU5512087 | -- |
| Vessel | MV MSC Beatrice | -- |
| Route | Cape of Good Hope -- Direct | -- |
| ATD | 2026-02-10 08:00 UTC | -- |
| ETA Southampton | 2026-04-21 | On Time |
| Set Point | -18.0C | -- |
| Latest Temp | -18.2C | OK |
| Fields extracted | 45/48 | -- |

---

### Section 4: Excel Tracker -- 7-Sheet Workbook

Auto-written by the pipeline after each PDF parse. File: `MeatTrackAI_Reefer_Status_Tracker.xlsx`

| Sheet | Content |
|-------|---------|
| **Live Status Tracker** | All 12 containers: ID, carrier, vessel, origin, destination, departure, ETA, delay, status, route, product, set point, current temp, breach |
| **ETA Impact Analysis** | Per-container: original ETA, revised ETA, delay days, delay cause, demurrage cost estimate, customer impact, risk level |
| **Cold Chain Monitor** | Temperature tracking: container, set point, current temp, deviation, breach active, breach duration, shelf life impact |
| **Outlook Inbox Log** | Email audit trail: timestamp, from, domain, subject, parse status, field count, label, action (ALLOW/BLOCK) |
| **Client Notifications** | Dispatch log: container, customer, notification class, send status, timestamp, dedup key |
| **BTOM Compliance** | Pre-arrival status: container, IPAFFS ref, submission date, BCP port, documentary check, physical check risk |
| **Risk Events** | Active geopolitical/operational risks: date, zone, severity, event, affected containers, ETA impact |

---

### Section 5: Live Pipeline Simulation

Interactive 6-stage pipeline simulation with terminal output:

| Stage | Name | Action |
|-------|------|--------|
| 1 | Graph API Auth | Acquire OAuth 2.0 token from Azure Entra ID |
| 2 | Inbox Scan | Read unprocessed emails from reefer-inbox mailbox |
| 3 | PDF Extract | pdfplumber extraction of 48 fields per attachment |
| 4 | Tracker Update | Write to JSON tracker (schema.org/Trip conformant) |
| 5 | Excel Write | Populate 7-sheet workbook with latest data |
| 6 | Notifications | Dispatch HTML emails via Graph API sendMail |

"Run Full Pipeline" button executes all 6 stages sequentially with simulated terminal output.

---

### Section 6: Client Notifications -- Microsoft Graph sendMail

HTML emails dispatched via Graph API with deduplication:

| Container | Customer | Class | Status |
|-----------|----------|-------|--------|
| MRKU4821073 | Tesco Distribution | DELAY | Sent |
| MRKU4821073 | Brakes Group | DELAY | Sent |
| HLXU9901234 | Tesco Distribution | CRITICAL | Sent |
| HLXU9901234 | Co-op Foods | CRITICAL | Sent |
| TCKU8820445 | Iceland Foods | DELAY | Sent |
| TCKU8820445 | Farmfoods | DELAY | Sent |
| OOLU6634128 | Ocado Retail | SIGNIFICANT | Sent |
| MSCU5512087 | Asda Distribution | ON TIME | No email (on-time = no notification) |

**Notification classes:**
- **CRITICAL** -- Temperature breach, shelf-life impact, QA assessment required
- **DELAY** -- ETA revised, reroute, carrier-initiated delay
- **SIGNIFICANT** -- Route change, AIS gap, Hormuz diversion
- **ON TIME** -- No notification sent (only flagged events trigger email)

**Graph API sendMail code pattern:**
```python
requests.post(
    f"https://graph.microsoft.com/v1.0/users/{mailbox}/sendMail",
    headers={"Authorization": f"Bearer {token}"},
    json={"message": {"rawMessage": raw}, "saveToSentItems": True}
)
```

---

## 3. Technology Stack

| Component | Technology |
|-----------|-----------|
| Email access | Microsoft Graph API (OAuth 2.0, Application permissions) |
| PDF extraction | pdfplumber (Python) -- 48 fields per document |
| Data store | JSON (schema.org/Trip conformant) |
| Spreadsheet | openpyxl -> .xlsx (7 sheets) |
| Notifications | Graph API sendMail (HTML email) |
| Demo UI | Single HTML file, DM Sans + IBM Plex Mono fonts |
| Domain governance | Allowlist/blocklist per sender domain |
| Deduplication | Hash-based dedup key per container+customer+event |

---

## 4. Data Model -- 48 Extracted Fields

| Category | Fields |
|----------|--------|
| **Shipping Identity** | Shipping Reference (primary key), Container No., BL Number |
| **Vessel** | Vessel name, IMO, MMSI, Voyage number |
| **Route** | Origin port, Destination port, Route type, Waypoints |
| **Schedule** | ATD, Original ETA, Revised ETA, Delay days, Delay cause |
| **Product** | Product description, HS Code, Gross weight, Net weight, Package count |
| **Cold Chain** | Set point, Current temp, Deviation, Breach active, Breach duration, Shelf life impact |
| **Compliance** | IPAFFS status, CHED-PP requirement, DAFF certificate, BTOM documentary check |
| **Financial** | Demurrage estimate, Spoilage risk, Customer penalty exposure |
| **Parse Metadata** | Source (body/pdf/merged), Field count, Domain, Allow/Block status |

---

## 5. Integration with Epic 90

| Epic 90 Feature | Relationship |
|-----------------|-------------|
| F90.1 (#40) API Connector | Graph API auth pattern reusable via pfc-api-connector |
| F90.5 (#44) Microsoft Integration | This demo is the reference implementation |
| F90.7 (#46) PDF Reports | PDF parsing pattern (pdfplumber) reusable for report generation |
| F90.10 (#49) MS IT Prep | Azure setup steps (Section 1) are the client IT checklist |
| F90.11 (#50) OFM Data Flow Back | Tracker data feeds accounting/stock via same Graph API |

---

## 6. Files

| File | Location | Purpose |
|------|----------|---------|
| MeatTrackAI_Microsoft_Demo_1.html | Downloads (source) | Original interactive demo |
| MeatTrackAI_Microsoft_Demo.html | PBS/LSC-DEMOS/MeatTrackAI/ | Copy in repo |
| This document | PBS/LSC-DEMOS/ | Markdown documentation |

---

*Document generated from MeatTrackAI_Microsoft_Demo_1.html. 6 sections: Architecture, Outlook Inbox, PDF Parsing, Excel Tracker, Pipeline Demo, Client Notifications. 48-field data extraction model. Microsoft Graph API integration pattern.*

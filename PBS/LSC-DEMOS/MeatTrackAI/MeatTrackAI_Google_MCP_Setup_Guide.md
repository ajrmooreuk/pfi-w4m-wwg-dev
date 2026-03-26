# MeatTrackAI — Google MCP Quick-Start Guide
### Body Text + PDF Parsing · LSC Domain Governance · Gmail Notifications
**Version:** 1.0 | **Date:** March 2026 | **Time to run:** ~5 minutes setup

---

## What This Demo Shows

| Capability | How |
|-----------|-----|
| Read Gmail inbox (carrier emails) | `gws` CLI + MCP → Gmail API |
| **Body text parsing** (new) | Extract fields from email HTML/text body — no attachment required |
| PDF attachment parsing | `pdfplumber` — fallback for fields not in body |
| **Body-first merge** | Body fields win on conflict; PDF fills gaps (HS code, weight, voyage) |
| **LSC inbox routing** | Gmail labels route by message type: `lsc-shipping`, `lsc-reefer`, `lsc-compliance` |
| **Domain governance — inbound** | Block non-carrier domains before any parsing occurs |
| **Domain governance — outbound** | Only dispatch to pre-approved client domains |
| Write tracker to Google Sheets | `gws sheets.spreadsheets.values update` |
| Send client notifications | `gws gmail.messages.send` — **HTML body only, no attachments** |

---

## One-Time Setup (5 Minutes)

### Step 1 — Install gws CLI

```bash
npm install -g @googleworkspace/cli
```

> Requires Node.js 18+. Pre-built Rust binary — no Rust toolchain needed. Installs in ~3 seconds.

### Step 2 — Create Google Cloud Project + OAuth Credentials

```bash
gws auth setup
```

Interactive wizard. Opens Google Cloud Console, creates an OAuth 2.0 Desktop client,
downloads `credentials.json`. Takes ~3 minutes including Google Cloud project creation.

### Step 3 — Authenticate (one-time browser flow)

```bash
gws auth login
```

Browser opens → sign in to Google → approve scopes (Gmail read/send + Sheets read/write)
→ done. Tokens stored AES-256-GCM in `~/.config/gws/` using OS keyring.

### Step 4 — Test connection

```bash
gws gmail users.messages list --params '{"maxResults":3}'
```

Should return JSON with your 3 most recent emails. If it works, you're connected.

### Step 5 — Configure Domain Governance (`.env`)

```bash
# Inbound — only these carrier domains allowed to inject data
INBOUND_ALLOWED_DOMAINS=@maersk.com,@hapag-lloyd.com,@msc.com,@cma-cgm.com,@oocl.com,@evergreen-line.com

# Outbound — only these client domains receive notifications
OUTBOUND_ALLOWED_DOMAINS=@tesco.com,@brakes.co.uk,@iceland.co.uk,@coop.co.uk,@waitrose.com,@marks-and-spencer.com

# LSC inbox label (Gmail label — see Step 7)
LSC_GMAIL_LABEL=lsc-shipping

# Google Sheet ID for the tracker
LSC_SHEETS_ID=your-google-sheet-id-here

# Block mode: reject | quarantine | log-only
BLOCK_MODE=reject
```

**Block modes:**
- `reject` — silently drop non-allowed emails, log to Sheets Audit tab
- `quarantine` — move to a `lsc-quarantine` Gmail folder for human review
- `log-only` — process but flag in audit trail (useful during onboarding)

### Step 6 — Install Python PDF parser

```bash
pip install pdfplumber
```

Used as fallback when fields are missing from email body. Body text is always parsed first.

### Step 7 — Create LSC Gmail Labels

```bash
gws gmail users.labels create --data '{"name":"lsc-shipping","labelListVisibility":"labelShow"}'
gws gmail users.labels create --data '{"name":"lsc-reefer","labelListVisibility":"labelShow"}'
gws gmail users.labels create --data '{"name":"lsc-compliance","labelListVisibility":"labelShow"}'
```

The pipeline applies these labels automatically to matching emails. They act as **agent routing signals**,
not folders — all emails stay in the inbox, agents query by label.

| Label | Routes to | Triggered by |
|-------|-----------|-------------|
| `lsc-shipping` | InboxWatcher agent | Arrival notices, departure confirmations, ETA updates |
| `lsc-reefer` | ColdChainMonitor agent | Temperature alerts, reefer fault notifications |
| `lsc-compliance` | BTOMCompliance agent | IPAFFS confirmations, health certificate updates |

### Step 8 — Start MCP Server + Wire to Claude Code

```bash
gws mcp -s gmail,sheets
```

Exposes ~22 tools. Add to your `.mcp.json` so Claude Code connects automatically:

```json
{
  "mcpServers": {
    "gws": {
      "command": "gws",
      "args": ["mcp", "-s", "gmail,sheets"],
      "env": {}
    }
  }
}
```

---

## Body Text vs PDF — Parsing Strategy

Carrier notification emails increasingly embed all key fields in the email body HTML.
This is actually preferable to PDF-only extraction:

```
Email arrives
    │
    ▼
┌─────────────────────────────────┐
│  1. BODY TEXT PARSE (primary)   │  Extracts: container, BL, ETA, delta,
│     regex on email HTML/text    │  vessel, temp, breach flag, BTOM status
└────────────────┬────────────────┘
                 │ Fields found: 8/12
                 ▼
┌─────────────────────────────────┐
│  2. PDF PARSE (supplementary)   │  Fills gaps: HS code, gross weight,
│     pdfplumber on attachment    │  voyage number, ETA original
└────────────────┬────────────────┘
                 │ All 12 fields populated
                 ▼
┌─────────────────────────────────┐
│  3. MERGE (body priority)       │  Body fields win on conflict
│     + source provenance         │  Each field tagged: [body] or [pdf]
└─────────────────────────────────┘
```

**Why body-first matters:**
- Carriers like Maersk embed fields in structured email HTML — no PDF needed
- Temperature alerts (Hapag-Lloyd) include breach data in email subject + body immediately
- Body text arrives faster (no attachment download needed)
- Reduces PDF storage and processing overhead

**When PDF is essential:**
- HS codes and tariff classifications (rarely in body text)
- Exact gross/net weights (often body text is approximate)
- Older carriers that don't embed structured data in body

---

## Domain Governance Architecture

```
INBOUND                          OUTBOUND
────────                         ────────
Carrier email                    Client email
arrives in Gmail                 ready to send
      │                                │
      ▼                                ▼
domain_guard                    domain_guard
.check(sender,                  .check(recipient,
 inbound_rules)                  outbound_rules)
      │                                │
  ┌───┴───┐                       ┌───┴───┐
  │ALLOWED│                       │ALLOWED│
  │ Parse │                       │ Send  │
  │ Label │                       │ Log   │
  └───────┘                       └───────┘
      │                                │
  ┌───┴───┐                       ┌───┴───┐
  │BLOCKED│                       │BLOCKED│
  │ Log   │                       │ Hold  │
  │ Audit │                       │ Queue │
  └───────┘                       └───────┘
```

### Governance Rules File (`.claude/skills/lsc-governance/SKILL.md`)

```markdown
---
name: lsc-domain-governance
description: Domain allow/block rules for LSC inbox management
version: 1.0
---

## Inbound Rules
Only process emails from approved carrier domains.
Any email from a domain not in INBOUND_ALLOWED_DOMAINS must be:
1. Rejected (not parsed)
2. Logged to Sheets Audit tab with: timestamp, sender, domain, subject, reason=DOMAIN_NOT_ALLOWED
3. Never forwarded to any parsing agent

## Outbound Rules  
Only send notifications to approved client domains.
Any notification addressed to a domain not in OUTBOUND_ALLOWED_DOMAINS must be:
1. Held in notification queue (not sent)
2. Logged as HELD with reason=DOMAIN_NOT_APPROVED
3. Flagged for manual review by Logistics Coordinator

## LSC Label Routing
Apply labels based on email subject and sender:
- Subject contains "arrival notice" OR "ETA" → lsc-shipping
- Subject contains "temperature" OR "reefer" OR "deviation" OR "alert" → lsc-reefer
- Subject contains "BTOM" OR "IPAFFS" OR "CHED" OR "compliance" → lsc-compliance
- Multiple matches → apply all matching labels
```

---

## Outbound Notifications — Body HTML Only

Notifications are dispatched as **HTML email bodies only**. No attachments are sent.

**Reasons:**
1. **Governance** — no uncontrolled data leaves via file attachments
2. **Readability** — HTML body readable immediately on mobile, no file to open
3. **Machine-parseable** — structured HTML body can be parsed by recipient's own systems
4. **Security** — eliminates attachment-based phishing risk in logistics email chains
5. **Audit** — full notification content stored in Sheets Notification Log

**What the notification contains (inline in email body):**
- Container number + shipping reference (BL)
- Revised ETA + delta days
- Delay reason
- Affected orders table (order ID, product, quantity, due date, impact class)
- Required actions (colour-coded by urgency)
- BTOM/IPAFFS deadline reminder if applicable

---

## Project Structure After Setup

```
meattrack-google-demo/
├── .env                          ← domain governance + Sheets ID
├── .mcp.json                     ← gws MCP server config
├── CLAUDE.md                     ← project memory for agents
├── .claude/
│   ├── agents/
│   │   ├── inbox-watcher.md      ← scans Gmail, applies labels, downloads
│   │   ├── body-parser.md        ← extracts fields from email body text
│   │   ├── pdf-parser.md         ← pdfplumber fallback extraction
│   │   └── notification-writer.md← generates + sends HTML emails
│   └── skills/
│       ├── lsc-governance/
│       │   └── SKILL.md          ← domain allow/block rules
│       ├── body-extraction/
│       │   └── SKILL.md          ← body field regex patterns per carrier
│       ├── pdf-extraction/
│       │   └── SKILL.md          ← PDF field patterns (supplementary)
│       └── eta-impact/
│           └── SKILL.md          ← impact classification rules
├── src/
│   ├── domain_guard.py           ← inbound + outbound domain enforcement
│   ├── body_parser.py            ← email body HTML/text extraction
│   ├── pdf_parser.py             ← pdfplumber field extraction
│   ├── field_merger.py           ← merge with source provenance
│   ├── eta_engine.py             ← impact classification
│   └── notification_agent.py    ← HTML email builder + Gmail send
└── pdfs/                         ← carrier PDFs (auto-downloaded)
```

---

## Running the Demo

```bash
# Open the interactive demo (no credentials needed)
open MeatTrackAI_Google_MCP_Demo.html

# Run the real pipeline (requires gws auth)
python src/run_pipeline.py

# Dry run (previews notifications, no emails sent)
python src/run_pipeline.py --dry-run

# Test domain governance only
python src/domain_guard.py --test

# Test body parsing on a specific email
python src/body_parser.py --email-id <gmail-message-id>
```

---

## vs Outlook / Microsoft Graph

| Factor | Google gws | Outlook / MS Graph |
|--------|-----------|-------------------|
| Setup time | ~5 min | ~30 min (Azure portal) |
| Admin required? | No | Yes (Entra ID admin consent) |
| Works with personal email | Yes | No (requires M365) |
| Credential complexity | Low (OAuth Desktop) | High (tenant + client secret) |
| Body text parsing | ✓ Same | ✓ Same |
| PDF parsing | ✓ Same | ✓ Same |
| Domain governance | ✓ Same | ✓ Same |
| LSC inbox routing | Gmail labels | Exchange rules / folders |
| Send from custom address | Via Workspace alias | Via mailbox identity |
| Recommended for | PoC / pilots / Google shops | Production in M365 organisations |

Both use identical body parsing, PDF parsing, domain governance, ETA engine, and notification logic.
Only the inbox connector (`gmail_reader.py` vs `outlook_reader.py`) differs.

---

*MeatTrackAI Google MCP Quick-Start Guide · v1.0 · March 2026*

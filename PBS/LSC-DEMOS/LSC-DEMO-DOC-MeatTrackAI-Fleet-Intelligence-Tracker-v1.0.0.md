# LSC-DEMO-DOC-MeatTrackAI-Fleet-Intelligence-Tracker-v1.0.0

> **Product:** W4M-WWG LSC Demos
> **Version:** 1.0.0
> **Status:** Demo / Proof of Concept
> **File:** `PBS/LSC-DEMOS/lsc-shipping-tracker.html`

---

## 1. Overview

MeatTrackAI Fleet Intelligence Tracker is a self-contained, zero-dependency HTML simulation of a 3-month frozen/chilled meat shipping operation from Australia to the UK (January -- March 2026). It demonstrates end-to-end container-level visibility across 12 concurrent voyages, incorporating real-world risk scenarios (geopolitical disruption, weather events, reefer faults, port congestion) and cold-chain monitoring.

The tracker is designed as a **single-file demo** — no build step, no server, no API keys required. Open the HTML file in any modern browser.

---

## 2. Architecture

### 2.1 Application Layout

```
+--------------------------------------------------------------+
|  HEADER  (logo, status pill, simulation date)                |
+----------+---------------------------------------------------+
|          |  TOP ROW                                          |
| SIDEBAR  |  +---------------------------+-----------------+ |
|          |  |  SVG Route Map             | Voyage Timeline | |
| Playback |  |  (AU->UK, risk zones,      | (milestones,    | |
| Controls |  |   vessel dots, trails)     |  alerts, ETA)   | |
|          |  +---------------------------+-----------------+ |
| Fleet    |----------------------------------------------—---+|
| Snapshot |  BOTTOM ROW                                       |
|          |  +---------------------------+-----------------+ |
| Risk     |  |  Detail Panel             | Temp & ETA      | |
| Alerts   |  |  (fleet overview or       |  Charts         | |
|          |  |   container detail)       |  (canvas)       | |
| Container|  +---------------------------+-----------------+ |
| List     |----------------------------------------------—---+|
|          |  STATUS BAR  (per-day blocks for selected voyage) |
+----------+---------------------------------------------------+
```

### 2.2 Technology Stack

| Layer | Technology |
|-------|-----------|
| Markup | Single HTML5 file |
| Styling | CSS custom properties, CSS Grid, Flexbox |
| Fonts | IBM Plex Mono (data), DM Sans (UI) via Google Fonts |
| Map | Inline SVG (900x450 viewBox), Mercator-style projection |
| Charts | HTML5 Canvas (temperature, ETA revision) |
| Data | All simulation data generated client-side in JavaScript |
| Dependencies | None — zero build step, zero npm |

### 2.3 Component Hierarchy

```
body
 +-- header                  Sticky top bar, logo, status pill, date
 +-- .app                    CSS Grid: sidebar (300px) | main
      +-- aside.sidebar
      |    +-- Playback       Date slider, play/pause, speed (1x/3x/7x)
      |    +-- Fleet Stats    Active / Delayed / Alerts / Arrived
      |    +-- Risk Alerts    Active geopolitical + container alerts
      |    +-- Container List 12 clickable container cards
      +-- .main-content
           +-- .top-row       CSS Grid: map | timeline
           |    +-- Map Panel      SVG world map with vessel dots
           |    +-- Timeline Panel Milestone events for selected container
           +-- .bottom-row    CSS Grid: detail | charts
           |    +-- Detail Panel   Fleet overview or container drill-down
           |    +-- Chart Panel    Temperature & ETA canvas charts
           +-- .status-bar    Day-block heatmap for selected voyage
```

---

## 3. Data Model

### 3.1 Container Definitions

12 containers spanning 6 carriers, 5 Australian origin ports, and 2 UK destination ports:

| Container ID | Carrier | Vessel | Origin | Dest | Departure | Product | Type | Set Point | Route | Scenario |
|---|---|---|---|---|---|---|---|---|---|---|
| MRKU4821073 | Maersk | MV Maersk Hobart | AUMEL | GBTIL | 2026-01-14 | Frozen Beef BMB | frozen | -18C | CAPE | CAPE_REROUTE |
| MRKU7734901 | Maersk | MV Sealand Michigan | AUBNE | GBSOU | 2026-01-20 | Chilled Lamb | chilled | 2C | CAPE | NORMAL |
| TCKU8820445 | CMA CGM | MV CMA CGM Liberte | AUADL | GBTIL | 2026-01-28 | Frozen Lamb | frozen | -20C | SUEZ | SUEZ_THEN_CAPE |
| HLXU9901234 | Hapag-Lloyd | MV Hapag San Francisco | AUSYD | GBTIL | 2026-02-05 | Chilled Beef Premium | chilled | 1C | CAPE | TEMP_BREACH |
| MSCU5512087 | MSC | MV MSC Beatrice | AUFRE | GBSOU | 2026-02-10 | Frozen Beef Whole Muscle | frozen | -18C | CAPE | WEATHER_DELAY |
| OOLU6634128 | OOCL | MV OOCL London | AUMEL | GBTIL | 2026-02-15 | Fresh Lamb CA | fresh | 0C | SUEZ | HORMUZ_DIVERT |
| MSDU3310092 | MSC | MV MSC Aurora | AUADL | GBSOU | 2026-02-20 | Frozen Beef Chuck | frozen | -18C | CAPE | NORMAL |
| CMAU7712034 | CMA CGM | MV CMA CGM Roussillon | AUBNE | GBTIL | 2026-02-25 | Frozen Lamb Trim | frozen | -20C | SUEZ | ROUTE_CHANGE |
| HASU4490012 | Hapag-Lloyd | MV Hamburg Express | AUMEL | GBSOU | 2026-03-01 | Chilled Beef Striploin | chilled | 1C | CAPE | SLOW_STEAM |
| MRKU3319021 | Maersk | MV Maersk Hobart | AUSYD | GBTIL | 2026-03-05 | Frozen Beef Ribeye | frozen | -18C | CAPE | NORMAL |
| EVRU8821100 | Evergreen | MV Ever Summit | AUMEL | GBTIL | 2026-03-10 | Chilled Lamb Rack | chilled | 2C | SUEZ | CEASEFIRE_BENEFIT |
| COSU6678234 | COSCO | MV COSCO Pride | AUFRE | GBSOU | 2026-03-15 | Frozen Beef Mixed | frozen | -18C | CAPE | NORMAL |

### 3.2 Product Categories

| Type | Set Point Range | Colour Code |
|------|----------------|-------------|
| Frozen | -18C to -20C | Teal |
| Chilled | 1C to 2C | Blue |
| Fresh | 0C (Controlled Atmosphere) | Green |

### 3.3 Port Codes

| Code | Port | Country | Role |
|------|------|---------|------|
| AUMEL | Melbourne | Australia | Origin |
| AUSYD | Sydney | Australia | Origin |
| AUBNE | Brisbane | Australia | Origin |
| AUFRE | Fremantle | Australia | Origin |
| AUADL | Adelaide | Australia | Origin |
| GBTIL | Tilbury | UK | Destination |
| GBSOU | Southampton | UK | Destination |

### 3.4 Waypoint Network

Vessels transit through a waypoint network projected onto the SVG map. The projection maps longitude -30 to 160 across x:0-900 and latitude 60 to -60 across y:0-450.

```
                    GBTIL/GBSOU (UK)
                        |
                    PORT_SAID
                        |
                    RED_SEA_N
                        |
                    RED_SEA_S ---- ADEN
                        |              \
                   (Suez Route)    HORMUZ / MUSCAT
                        |              |
                    SRI_LANKA ---------+
                   /         \
              MUPLU       MALACCA
                |              \
         CAPE_GOOD_HOPE    AU Ports (MEL/SYD/BNE)
                |
          MID_ATLANTIC
                |
           CANARIES
                |
           GBTIL/GBSOU
```

**Route Selection Logic:**

| Route | Path |
|-------|------|
| SUEZ | Origin -> Malacca -> Sri Lanka -> Aden -> Red Sea S -> Red Sea N -> Port Said -> UK |
| CAPE | Origin -> Sri Lanka -> Mauritius -> Cape of Good Hope -> Mid-Atlantic -> UK |
| CAPE (FRE/ADL) | Origin -> Cape of Good Hope -> Mid-Atlantic -> UK (skip Malacca) |

---

## 4. Risk & Scenario Engine

### 4.1 Global Risk Events

6 global risk events drive the simulation timeline:

| Date | Type | Zone | Severity | Event | Duration |
|------|------|------|----------|-------|----------|
| 2026-01-08 | GEOPOLITICAL | Red Sea | HIGH | Houthi Attack -- MV Nordic Star | -> 2026-03-31 |
| 2026-01-22 | GEOPOLITICAL | Strait of Hormuz | CRITICAL | Iran Naval Exercise -- Hormuz Closure | 7 days |
| 2026-02-14 | PORT_CONGESTION | Mauritius | MEDIUM | Port Louis Terminal Strike | 6 days |
| 2026-02-28 | WEATHER | Southern Ocean | MEDIUM | Storm System -- Southern Indian Ocean | 5 days |
| 2026-03-10 | PORT_CONGESTION | Tilbury | LOW | Tilbury BCP Inspection Backlog | 15 days |
| 2026-03-18 | GEOPOLITICAL | Red Sea | MEDIUM | Ceasefire -- Red Sea Partial Reopening | Ongoing |

### 4.2 Container Scenario Types

Each container is assigned a scenario that determines its delay profile and risk events:

```
Scenario Engine — Per-Container Behaviour
==========================================

  NORMAL            No disruption. Base transit time applies.
       |
  CAPE_REROUTE      Red Sea suspended after Houthi attack.
       |            Reroute via Cape of Good Hope. ETA +8 days.
       |
  SUEZ_THEN_CAPE    Departs on Suez route, switches to Cape
       |            on day 5 (precautionary). ETA +7 days.
       |
  TEMP_BREACH       Port Louis congestion (+4d), then reefer
       |            fault on day 14. Supply air rises to +1.0C
       |            vs set point. CRITICAL alert. ETA +6 days.
       |
  WEATHER_DELAY     Storm diversion in Southern Indian Ocean
       |            (200nm north). ETA +3 days.
       |
  HORMUZ_DIVERT     Hormuz closed by IRGC exercise.
       |            Vessel diverted via Muscat/Cape.
       |            AIS gap for 2 days. ETA +4 days.
       |
  ROUTE_CHANGE      Starts Cape (Red Sea risk), switches back
       |            to Suez after ceasefire on 2026-03-18.
       |            Delay reduces from +7 to +3 days.
       |
  SLOW_STEAM        Carrier orders slow-steaming from day 10
       |            (bunker optimisation). SOG: 18 -> 12.5 kts.
       |            ETA +7 days.
       |
  CEASEFIRE_BENEFIT  Maintains Suez route throughout. After
                    ceasefire, ETA improves by -2 days.
```

### 4.3 Voyage Status Lifecycle

```
  Booked
    |
  Loaded/Departed  (day 0)
    |
  At Sea           (day 1 -> arrival-2)
    |
  At Sea -- ALERT  (if tempBreach active)
    |
  Port Approach    (arrival-2 -> arrival)
    |
  Discharged       (arrival day)
    |
  BTOM Cleared     (arrival+1)
    |
  Gate Out         (arrival+3)
```

### 4.4 Colour Coding

| Status / Risk | Colour | Hex |
|---|---|---|
| At Sea (normal) | Teal | #0A7A8A |
| Delayed | Amber | #B45309 |
| CRITICAL / Alert | Red | #C0392B |
| Arrived / On Time | Green | #16A34A |
| Port Approach | Purple | #7C3AED |
| Booked (not departed) | Grey | #94A3B8 |

---

## 5. UI Panels

### 5.1 Simulation Playback

- **Date range:** 2026-01-14 to 2026-03-31 (77 days)
- **Controls:** Step -7d, -1d, Play/Pause, +1d, +7d
- **Slider:** Scrub through entire simulation
- **Speed:** 1x (800ms/day), 3x, 7x

### 5.2 Fleet Snapshot

4 real-time counters updated on every date change:

| Metric | Includes |
|--------|----------|
| Active | At Sea, At Sea -- ALERT, Port Approach, Loaded/Departed |
| Delayed | Active containers with delay > 0 |
| Alerts | Active containers with tempBreach or CRITICAL risk |
| Arrived | Discharged, BTOM Cleared, Gate Out |

### 5.3 SVG Route Map

- Pre-rendered land masses (stylised), risk zone ellipses (Red Sea, Hormuz, Malacca, Cape, Suez)
- Reference route lines (dashed) for Suez and Cape corridors
- Port markers at MEL/SYD, FRE, TIL/SOT
- Dynamic layers:
  - **Vessel trails** — polyline of last 7 days' positions (colour-coded)
  - **Vessel dots** — current position with glow effect for at-sea vessels
  - **Selection highlight** — enlarged dot + ID label for selected container

### 5.4 Voyage Timeline

Milestone event list for the selected container:
- Departure, route changes, alerts, port approach, discharge, BTOM clearance, gate out
- Dot states: done (green), active (teal, glowing), pending (grey), alert (red)

### 5.5 Detail Panel

- **No selection:** Fleet position overview — all 12 containers in a compact table
- **Container selected:** Full detail grid — status, ETA delta, temperature, carrier, vessel, voyage, route, SOG, position, origin, destination, set point

### 5.6 Temperature & ETA Charts (Canvas)

- **Temperature chart:** Supply air temp vs set point, with breach highlighting
- **ETA revision chart:** Delay accumulation over voyage days, area fill

### 5.7 Status Bar

Day-block heatmap for the selected container's voyage. Each block is colour-coded by status/risk and clickable to jump to that date.

---

## 6. Supporting Demo Files

### 6.1 MeatTrackAI Dashboard Variants (`PBS/LSC-DEMOS/MeatTrackAI/`)

| File | Description |
|------|-------------|
| `MeatTrackAI_Fleet_Intelligence_3Month.html` | Full fleet intelligence dashboard (React-style, multi-tab) |
| `MeatTrackAI_Google_Workspace_Simulation.html` | Google Workspace integration demo |
| `MeatTrackAI_Microsoft_Demo.html` | Microsoft 365 integration demo |
| `MeatTrackAI_Microsoft_Demo_1.html` | Microsoft demo (variant) |
| `MeatTrackAI_Microsoft_Presentation.pdf` | Stakeholder presentation (PDF) |
| `MeatTrackAI_Microsoft_Presentation.pptx` | Stakeholder presentation (PPTX) |
| `MeatTrackAI_Reefer_Status_Tracker.xlsx` | Reefer monitoring spreadsheet |
| `MeatTrackAI_Outlook_Integration_Architecture.docx` | Outlook integration architecture |
| `MeatTrackAI-Documentation.md` | Full product documentation (AIS API, trade lanes, carriers) |
| `MeatTrackAI_Google_MCP_Setup_Guide.md` | Google MCP server setup guide |

### 6.2 Earlier Files (`PBS/LSC-DEMOS/ms-earlier-files/`)

| File | Description |
|------|-------------|
| `eta_impact_engine.py` | ETA impact calculation engine |
| `notification_agent.py` | Automated notification dispatch agent |
| `outlook_reader.py` | Outlook inbox reader for shipping notifications |
| `tracker_store.py` | Persistent tracker data store |
| `impact_report.json` | Sample ETA impact report output |
| `reefer_tracker.json` | Reefer temperature tracking data |
| `notification_MRKU4821073_*.html` | Sample delay notification email |
| `notification_HLXU9901234_*.html` | Sample significant event notification email |
| `MeatTrackAI_Outlook_Integration_Architecture.docx` | Outlook integration architecture |

---

## 7. Data Flow

```
CONTAINER_DEFS (12 static definitions)
        |
        v
    genVoyage()  -----> per-container daily records
        |                   |
        |               scenario logic
        |               (delays, route changes,
        |                temp breaches, alerts)
        |                   |
        v                   v
    VOYAGES[]           RISK_EVENTS[]
        |                   |
        +-------+-----------+
                |
          renderAll() <--- date slider / play controls
                |
    +-----------+------------+-----------+-----------+
    |           |            |           |           |
renderMap  renderStats  renderAlerts renderDetail renderCharts
  (SVG)    (counters)   (sidebar)   (grid/table)  (canvas)
```

---

## 8. Design System

| Token | Value | Usage |
|-------|-------|-------|
| `--teal` | #0A7A8A | Primary brand, at-sea status, interactive |
| `--amber` | #B45309 | Delays, warnings |
| `--red` | #C0392B | Critical alerts, temperature breaches |
| `--green` | #16A34A | Arrived, on-time, healthy |
| `--purple` | #7C3AED | Port approach, AIS gaps |
| `--navy` | #0F2744 | Headings, emphasis |
| `--mono` | IBM Plex Mono | Data values, container IDs, dates |
| `--sans` | DM Sans | UI labels, body text |

---

## 9. File Inventory

```
PBS/LSC-DEMOS/
+-- lsc-shipping-tracker.html              <-- This file (simulation tracker)
+-- LSC-DEMO-DOC-MeatTrackAI-*.md          <-- This document
+-- MeatTrackAI/                            <-- Dashboard variants & presentations
|   +-- MeatTrackAI-Documentation.md
|   +-- MeatTrackAI_Fleet_Intelligence_3Month.html
|   +-- MeatTrackAI_Google_MCP_Setup_Guide.md
|   +-- MeatTrackAI_Google_Workspace_Simulation.html
|   +-- MeatTrackAI_Microsoft_Demo.html
|   +-- MeatTrackAI_Microsoft_Demo_1.html
|   +-- MeatTrackAI_Microsoft_Presentation.pdf
|   +-- MeatTrackAI_Microsoft_Presentation.pptx
|   +-- MeatTrackAI_Outlook_Integration_Architecture.docx
|   +-- MeatTrackAI_Reefer_Status_Tracker.xlsx
+-- ms-earlier-files/                       <-- Python agents & notification samples
    +-- eta_impact_engine.py
    +-- notification_agent.py
    +-- outlook_reader.py
    +-- tracker_store.py
    +-- impact_report.json
    +-- reefer_tracker.json
    +-- notification_HLXU9901234_*.html
    +-- notification_MRKU4821073_*.html
    +-- MeatTrackAI_Outlook_Integration_Architecture.docx
```

# 🥩 MeatTrackAI — Inbound Vessel Intelligence Dashboard

> Real-time AIS vessel tracking for UK international meat importers.
> Monitors inbound supply chain vessels across four trade lanes: **Australia · New Zealand · Iceland · Brazil → UK**

---

## Quick Start

```bash
unzip meattrack-ai.zip
cd meattrack-ai
npm install
cp .env.example .env
# Paste your Datalastic API key into .env
npm run dev
```

Open **http://localhost:5173** in your browser.

---

## Project Structure

```
meattrack-ai/
├── src/
│   ├── components/
│   │   └── MeatTrackDashboard.jsx   ← Main dashboard UI (all tabs, all lanes)
│   ├── data/
│   │   └── tradeLanes.js            ← Trade lane config, carriers, sample vessels
│   ├── hooks/
│   │   └── useVesselTracking.js     ← Datalastic AIS API hook (live polling)
│   ├── App.jsx                      ← Root component
│   └── main.jsx                     ← Vite entry point
├── .env.example                     ← API key slots (copy to .env)
├── vite.config.js
├── package.json
└── README.md
```

---

## AIS API Setup

The dashboard runs in **mock/sample data mode** by default. To activate live AIS vessel positions, add an API key to `.env`.

### Recommended: Datalastic (€9 trial → €199/mo)

The best fit for MeatTrackAI — self-serve, instant key, commercial use permitted, bulk vessel requests.

1. Sign up at https://datalastic.com/pricing/
2. Choose a plan (14-day trial available on all plans)
3. Receive API key by email within minutes
4. Add to `.env`:

```env
VITE_DATALASTIC_API_KEY=your_key_here
```

Live vessel positions will begin polling every **5 minutes** automatically via the `useVesselTracking` hook.

**Datalastic pricing tiers:**

| Plan | Credits/mo | Price | Best for |
|------|-----------|-------|----------|
| Trial | Limited | €9 | Testing & development |
| Starter | 20,000 | €199/mo | Small fleet (10–20 vessels) |
| Experimenter | 80,000 | ~€399/mo | Dashboard with frequent refresh |
| Developer Pro+ | Unlimited | €679/mo | Full production, large fleet |

> Annual subscriptions receive a 10% discount. Credits are only deducted on successful data returns.

### Alternative: VesselFinder (credit-based)

- Request a free trial: https://api.vesselfinder.com/docs/faq.html
- Credit model: 1 credit per terrestrial position · 10 credits per satellite position
- Add to `.env`: `VITE_VESSELFINDER_API_KEY=your_key_here`

> **Note:** For vessels mid-ocean (AU/NZ → UK), you will need satellite AIS credits (10×) as they are out of terrestrial range for most of the voyage.

### MarineTraffic / Kpler (enterprise)

- Web plans: $10/mo (Basic) · $100/mo (Essential)
- API access: Enterprise only, contact sales at https://servicedocs.marinetraffic.com/
- No self-serve API trial available
- Best suited once MeatTrackAI scales and requires port congestion data or container-level tracking

---

## Trade Lanes Covered

| Lane | Origin Ports | UK Destination Ports | Transit Time | Commodity |
|------|-------------|---------------------|-------------|-----------|
| 🇦🇺 Australia | Melbourne, Sydney, Fremantle, Brisbane | Tilbury, Felixstowe, Southampton | 28–35 days | Beef, Lamb, Chilled/Frozen Meat |
| 🇳🇿 New Zealand | Auckland, Tauranga, Lyttelton, Port Chalmers | Tilbury, Felixstowe, Southampton | 30–38 days | Lamb, Mutton, Venison, Dairy |
| 🇮🇸 Iceland | Reykjavik, Akureyri, Hafnarfjörður | Grimsby, Hull, Tilbury, Aberdeen | 3–7 days | Cod, Haddock, Skrei, Frozen Fish |
| 🇧🇷 Brazil | Santos, Rio de Janeiro, Paranaguá, Itajaí | Tilbury, Felixstowe, Liverpool | 18–25 days | Beef, Poultry, Pork |

---

## Carriers by Lane

### 🇦🇺 Australia

| Carrier | Code | Tracking Input | Services |
|---------|------|---------------|----------|
| Maersk | MAERSK | Booking / Container # | AE-1/Shogun, Oceania Express |
| MSC | MSC | Container / BL # | Indus, Shogun |
| CMA CGM | CMACGM | Container / BL # | NEEMO, Boomerang |
| Evergreen | EVERGREEN | Container / BL # | AEX |
| ANL (CMA CGM) | ANL | Container # | AAX, AUE |

### 🇳🇿 New Zealand

| Carrier | Code | Tracking Input | Services |
|---------|------|---------------|----------|
| Maersk | MAERSK | Booking / Container # | Oceania Express |
| MSC | MSC | Container / BL # | Shogun |
| COSCO | COSCO | Container / BL # | ANZ2UK |
| Hapag-Lloyd | HAPAG | Container # | NZX |

### 🇮🇸 Iceland

| Carrier | Code | Tracking Input | Services |
|---------|------|---------------|----------|
| Samskip | SAMSKIP | Container / BL # | IS-UK Express |
| Eimskip | EIMSKIP | BL / Container # | North Atlantic |
| Stena Line Freight | STENA | Booking # | Rosslare-Fishguard |

### 🇧🇷 Brazil

| Carrier | Code | Tracking Input | Services |
|---------|------|---------------|----------|
| Maersk | MAERSK | Booking / Container # | BRAVO, EC2 |
| MSC | MSC | Container / BL # | Fenix, Brazex |
| Hamburg Süd | HAMBURGSUD | Container / BL # | SAWC, SALAV |
| CMA CGM | CMACGM | Container / BL # | BRAVO |

---

## Dashboard Features

- **4 trade lane selector** — switch between AU, NZ, IS, BR with vessel counts per lane
- **Inbound Vessels tab** — per-vessel cards with progress bars, ETA, cargo type, cold chain temp
- **Carriers tab** — all carriers per lane with direct tracking portal links
- **Live AIS Map tab** — VesselFinder free JS embed centred on origin region (no key needed)
- **API Guide tab** — pricing and trial info for all four AIS platforms
- **All Vessels summary table** — full cross-lane overview at the bottom
- **Cold chain temperature** badges per vessel (reefer monitoring)
- **Expandable vessel cards** — click to reveal MMSI, IMO, direct tracking links
- **Auto-poll** every 5 minutes once Datalastic API key is set
- **Live AIS overlay** on vessel cards when API is connected (speed, position, ETA)

---

## Environment Variables

Copy `.env.example` to `.env` and populate:

```env
# Datalastic (recommended)
VITE_DATALASTIC_API_KEY=your_key_here

# VesselFinder (optional alternative)
VITE_VESSELFINDER_API_KEY=your_key_here

# MarineTraffic (optional, enterprise)
VITE_MARINETRAFFIC_API_KEY=your_key_here
```

---

## How the AIS Hook Works

`src/hooks/useVesselTracking.js` uses the Datalastic bulk vessel endpoint:

```
GET https://api.datalastic.com/api/v0/vessel?api-key=KEY&mmsi=MMSI1,MMSI2,...
```

- Accepts up to 100 MMSIs per call — all vessels across all lanes in a single request
- Returns position, speed, heading, destination, ETA, nav status
- Only deducts credits on successful data returns
- Hook polls on a configurable interval (default: 300 seconds)
- Falls back gracefully to sample data if no key present

---

## Next Steps for Claude Code

- [ ] IPAFFS / BTOM compliance status per shipment (Gov.uk API)
- [ ] Cold chain shelf-life calculator — ETA × departure temp × product type
- [ ] Email / Slack alerts when vessel ETA shifts > 24 hours
- [ ] HMRC tariff code lookup per cargo category
- [ ] Port congestion overlay (MarineTraffic enterprise API)
- [ ] Multi-user auth with per-supplier vessel assignment
- [ ] Container-level tracking via Datalastic BL endpoint
- [ ] Historical voyage playback for audit / compliance
- [ ] Integration with MeatTrackAI order fulfillment module

---

## Key External Links

| Resource | URL |
|----------|-----|
| Datalastic pricing | https://datalastic.com/pricing/ |
| Datalastic API reference | https://datalastic.com/api-reference/ |
| VesselFinder API docs | https://api.vesselfinder.com/docs/ |
| MarineTraffic API docs | https://servicedocs.marinetraffic.com/ |
| VesselFinder free embed | https://www.vesselfinder.com/embed |
| MarineTraffic free embed | https://www.marinetraffic.com/en/p/embed-map |

> **Read-only copy** distributed from [PF-Core source repo](https://github.com/ajrmooreuk/Azlan-EA-AAA). Do not edit directly — changes will be overwritten on next PFC release.

---

# OAA Ontology Visualiser — Design Token Map & UI/UX Guide

**Version**: 2.0.0
**Date**: 2026-02-21
**Source CSS**: `css/viewer.css`
**DS-ONT Reference**: `ontology-library/PE-Series/DS-ONT/` v2.0.0
**App Skeleton**: `ontology-library/PE-Series/DS-ONT/instance-data/pfc-app-skeleton-v1.0.0.jsonld`
**Interactive Panel**: `js/design-token-tree.js` — **"Token Map"** button in toolbar
**Purpose**: Maps every colour, token and CSS custom property to the UI zone/component it styles, cross-referenced to DS-ONT semantic and primitive tokens. v2.0.0 adds 48 new CSS custom properties covering status badges, priority badges, series indicators, authoring/selection toolbars, diff/revision indicators, and cross-reference colours.

## How to Access the Token Map Panel

1. Open the visualiser in browser (`browser-viewer.html`)
2. In the **toolbar row**, find the **"Token Map"** button (next to "DS Tokens")
3. Click it — the panel slides in from the **left side** (420px wide)

### Panel Features

- **By Zone** view (default): expand Z1–Z20 to see every token per UI zone
- **By Category** view: browse by Surfaces, Text, Accent, Status, Archetypes, Edges, Typography, Spacing, Hardcoded
- **Search**: type any token name, CSS var, hex value, or DS-ONT token to filter
- **Live swatches**: colour dots reflect the current computed CSS value (updates when a DS brand is applied/reset)
- **HARDCODED badge** (orange): flags values not yet on CSS custom properties
- **OVERRIDE badge** (teal): appears when a DS brand has changed the value from the default
- **Summary cards**: total tokens, tokenised count, hardcoded count, coverage %

---

## 1. Token Architecture Overview

The visualiser uses a **three-tier token cascade** aligned with DS-ONT:

```
┌─────────────────────────────────────────────────────────┐
│  DS-ONT Primitive Token  (colour scale, spacing, type)  │
│  e.g. color.teal.500 = #00a4bf                          │
├─────────────────────────────────────────────────────────┤
│  DS-ONT Semantic Token   (intent-based, theme-aware)    │
│  e.g. primary.surface.default → color.teal.500          │
├─────────────────────────────────────────────────────────┤
│  CSS Custom Property     (applied in viewer.css)        │
│  e.g. --viz-accent: #9dfff5                             │
└─────────────────────────────────────────────────────────┘
```

**Mutability rules** (DS-ONT BR-DS-006):
- **PF-Core** (immutable): spacing, radius, typography scale, container surfaces
- **PF-Instance** (brand-overridable): colours, font families, semantic colour values

---

## 2. UI Zone Map

```
┌─────────────────────────────────────────────────────────────┐
│ Z1  HEADER                                                  │
├─────────────────────────────────────────────────────────────┤
│ Z2  TOOLBAR                                                 │
├─────────────────────────────────────────────────────────────┤
│ Z3  CONTEXT IDENTITY BAR  (conditional — when brand set)    │
├─────────────────────────────────────────────────────────────┤
│ Z4  AUTHORING TOOLBAR  (conditional — authoring mode)       │
├─────────────────────────────────────────────────────────────┤
│ Z5  BREADCRUMB BAR  (conditional)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Z6  GRAPH CANVAS  (vis-network / mermaid / mindmap)        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                                                      │   │
│  │  Z7 LEGEND (bottom-left, floating)                   │   │
│  │  Z8 LAYER PANEL (bottom-right, floating)             │   │
│  │                                                      │   │
│  │  Z9  SIDEBAR (right, 380px, sliding)                 │   │
│  │  Z10 AUDIT PANEL (left, 340px, sliding)              │   │
│  │  Z11 LIBRARY PANEL (right, 420px, sliding)           │   │
│  │  Z12 DS PANEL (left, 380px, sliding)                 │   │
│  │  Z13 BACKLOG PANEL (right, 480px, sliding)           │   │
│  │  Z14 MERMAID EDITOR (left, 380px, sliding)           │   │
│  │  Z15 MINDMAP PROPERTIES (right, 320px, sliding)      │   │
│  │  Z16 CONTEXT DRAWER (right, 380px, sliding)          │   │
│  │  Z17 CATEGORY PANEL (right, 380px, sliding)          │   │
│  │                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Popup overlays (z-index 100+):
  Z18  MODAL / CONFIRMATION DIALOG
  Z19  TOOLTIP / HOVER CARD
  Z20  DROP ZONE (drag-and-drop file landing)
```

---

## 3. CSS Custom Properties — Full Registry

### 3.1 Surface Tokens

| CSS Variable | Default Hex | DS-ONT Semantic Token | DS-ONT Primitive | Mutability | Zones Applied |
|---|---|---|---|---|---|
| `--viz-surface-default` | `#9BA7A8` | `neutral.surface.default` | `color.grey.400` | PF-Core | Z6 body background, Z5 breadcrumb bg |
| `--viz-surface-elevated` | `#1a1d27` | `neutral.surface.subtle` | `color.grey.950` | PF-Core | Z1, Z2, Z3, Z4, Z7, Z8, Z9, Z10, Z11, Z12, Z13, Z14, Z15, Z16, Z17 (all panels + header/toolbar) |
| `--viz-surface-card` | `#22252f` | `neutral.surface.default` (dark) | `color.grey.900` | PF-Core | Card backgrounds inside Z9, Z10, Z11, Z12, Z13 panels |
| `--viz-surface-subtle` | `#2a2d37` | — (hover surface) | `color.grey.850` | PF-Core | Hover/resting states on buttons, list items across all zones |
| `--viz-container-surface` | `#768181` | `container.surface.default` | — | PF-Core | Z6 graph canvas background only |

### 3.2 Text Tokens

| CSS Variable | Default Hex | DS-ONT Semantic Token | Zones Applied |
|---|---|---|---|
| `--viz-text-primary` | `#e0e0e0` | `neutral.text.body` | All zones — primary readable text |
| `--viz-text-secondary` | `#888888` | `neutral.text.subtitle` | Z1 stats, Z9 field labels, Z10 section headers, Z7 legend secondary |
| `--viz-text-muted` | `#666666` | `neutral.text.caption` | Hints, disabled text, muted labels |

### 3.3 Accent / Interactive Tokens

| CSS Variable | Default Hex | DS-ONT Semantic Token | DS-ONT Primitive | Mutability | Zones Applied |
|---|---|---|---|---|---|
| `--viz-accent` | `#9dfff5` | `primary.text.default` | `color.teal.200` | PF-Instance | Z1 title, Z9 headings, Z3 brand text, Z8 active layer toggle, Z12 DS tier labels |
| `--viz-accent-active` | `#017c75` | `primary.surface.default` | `color.teal.700` | PF-Instance | Active buttons (all zones), active tabs, form focus borders |
| `--viz-accent-subtle` | `rgba(157,255,245,0.05)` | `primary.surface.subtle` | `color.teal.200` @ 5% | PF-Instance | Hover highlight in Z7 legend items, Z8 layer chips |
| `--viz-accent-border` | `#017c75` | `primary.border.default` | `color.teal.700` | PF-Instance | Border emphasis on active elements |

### 3.4 Status / Semantic Tokens

| CSS Variable | Default Hex | DS-ONT Semantic Token | DS-ONT Primitive | Zones Applied |
|---|---|---|---|---|
| `--viz-error` | `#cf057d` | `error.text.default` | `color.magenta.500` | Z14 mermaid error, Z13 blocked badge, status badges |
| `--viz-warning` | `#FF9800` | `warning.text.default` | `color.yellow.600` | Z10 audit warn badge, Z13 priority badge |
| `--viz-success` | `#4CAF50` | `success.text.default` | `color.green.500` | Z10 pass badge, Z13 done badge |
| `--viz-info` | `#2196F3` | `information.text.default` | `color.blue.500` | Z13 in-progress badge, info indicators |

### 3.5 Border Tokens

| CSS Variable | Default Hex | DS-ONT Semantic Token | Zones Applied |
|---|---|---|---|
| `--viz-border-default` | `#2a2d37` | `neutral.border.default` | All panel borders, header/toolbar bottom border, Z7/Z8 container border |
| `--viz-border-subtle` | `#3a3d47` | `neutral.border.subtle` | Hover-state borders, toolbar dividers, button borders |

### 3.6 Archetype Colours (DR-SEMANTIC-001) — Graph Node Colouring

| CSS Variable | Default Hex | Archetype | Graph Meaning | Brand Override Path |
|---|---|---|---|---|
| `--viz-archetype-class` | `#4CAF50` | Class | Green nodes — core class entities | `archetype.class.surface` |
| `--viz-archetype-core` | `#4CAF50` | Core | Green nodes — core structural entities | `archetype.core.surface` |
| `--viz-archetype-framework` | `#2196F3` | Framework | Blue nodes — framework entities | `archetype.framework.surface` |
| `--viz-archetype-supporting` | `#FF9800` | Supporting | Orange nodes — supporting entities | `archetype.supporting.surface` |
| `--viz-archetype-agent` | `#E91E63` | Agent | Pink/magenta nodes — AI agent entities | `archetype.agent.surface` |
| `--viz-archetype-external` | `#9E9E9E` | External | Grey nodes — external/integration entities | `archetype.external.surface` |
| `--viz-archetype-layer` | `#00BCD4` | Layer | Cyan nodes — architectural layer entities | `archetype.layer.surface` |
| `--viz-archetype-concept` | `#AB47BC` | Concept | Purple nodes — abstract concept entities | `archetype.concept.surface` |
| `--viz-archetype-default` | `#017c75` | Default | Teal nodes — fallback when no archetype | `archetype.default.surface` |

### 3.7 Edge Colours (DR-SEMANTIC-002) — Graph Relationship Colouring

| CSS Variable | Default Hex | Edge Category | Graph Meaning | Brand Override Path |
|---|---|---|---|---|
| `--viz-edge-structural` | `#7E57C2` | Structural | Purple edges — composition, hierarchy | `edge.structural.color` |
| `--viz-edge-taxonomy` | `#888888` | Taxonomy | Grey edges — classification, inheritance | `edge.taxonomy.color` |
| `--viz-edge-dependency` | `#EF5350` | Dependency | Red edges — depends-on, requires | `edge.dependency.color` |
| `--viz-edge-informational` | `#42A5F5` | Informational | Light blue edges — references, describes | `edge.informational.color` |
| `--viz-edge-operational` | `#66BB6A` | Operational | Green edges — triggers, enables, governs | `edge.operational.color` |

### 3.8 Dynamic / JS-Set Tokens

| CSS Variable | Default | Set By | Purpose |
|---|---|---|---|
| `--viz-brand-glow-color` | `transparent` | `app.js` → `applyDSToVisualiser()` | Inset shadow glow on Z6 graph container when brand is active (DR-BRAND-001) |

---

## 4. Tokenised in v2.0.0 (DS-ONT Application Skeleton Extension)

v2.0.0 added **48 new CSS custom properties** migrating previously hardcoded values into the token cascade. These are now brand-overridable via `generateCSSVars()` in `ds-loader.js`.

### 4.1 Status Badge Tokens (Z10 Audit, Z13 Backlog, compliance badges, gate badges)

| CSS Variable | Default Hex | Selectors Using It |
|---|---|---|
| `--viz-status-pass-bg` | `#166534` | `.audit-badge.ok`, `.gate-badge.pass`, `.compliance-badge.pass`, `.backlog-status-badge.done` |
| `--viz-status-pass-border` | `#15803d` | `.audit-badge.ok`, `.gate-badge.pass`, `.compliance-badge.pass .dot`, `.gate-result.pass` |
| `--viz-status-pass-text` | `#86efac` | `.audit-badge.ok`, `.gate-badge.pass`, `.compliance-badge.pass`, `.density-dot.green`, `.diff-item.added` |
| `--viz-status-warn-bg` | `#553016` | `.audit-badge.warn`, `.gate-badge.warn`, `.backlog-status-badge.prioritised` |
| `--viz-status-warn-border` | `#834a22` | `.audit-badge.warn`, `.gate-badge.warn`, `.gate-result.warn`, `.compliance-badge.warn` |
| `--viz-status-warn-text` | `#ffb48e` | `.audit-badge.warn`, `.gate-badge.warn`, `.compliance-badge.warn`, `.issue-list li.warning`, `.diff-item.changed` |
| `--viz-status-fail-bg` | `#7f1d1d` | `.audit-badge.fail`, `.gate-badge.fail` |
| `--viz-status-fail-border` | `#991b1b` | `.audit-badge.fail`, `.gate-badge.fail`, `.gate-result.fail`, `.compliance-badge.fail` |
| `--viz-status-fail-text` | `#fca5a5` | `.audit-badge.fail`, `.gate-badge.fail`, `.compliance-badge.fail`, `.density-dot.red`, `.issue-list li.error`, `.diff-item.removed` |
| `--viz-status-info-bg` | `#1e40af` | `.backlog-status-badge.in-progress` |
| `--viz-status-info-text` | `#93c5fd` | `.backlog-status-badge.proposed`, `.backlog-status-badge.in-progress`, `.issue-list li.info` |
| `--viz-status-pending-bg` | `#713f12` | `.backlog-status-badge.pending-review` |
| `--viz-status-pending-text` | `#fcd34d` | `.backlog-status-badge.pending-review`, `.density-dot.yellow` |

### 4.2 Priority Badge Tokens (Z13 Backlog)

| CSS Variable | Default Hex | Selector |
|---|---|---|
| `--viz-priority-low-bg` | `#1a2a1a` | `.backlog-priority-low` |
| `--viz-priority-low-text` | `#86efac` | `.backlog-priority-low` |
| `--viz-priority-medium-bg` | `#2a2a1a` | `.backlog-priority-medium` |
| `--viz-priority-medium-text` | `#fcd34d` | `.backlog-priority-medium` |
| `--viz-priority-high-bg` | `#3a2a1a` | `.backlog-priority-high` |
| `--viz-priority-high-text` | `#ffb48e` | `.backlog-priority-high` |
| `--viz-priority-very-high-bg` | `#3a1a1a` | `.backlog-priority-very-high` |
| `--viz-priority-very-high-text` | `#fca5a5` | `.backlog-priority-very-high` |
| `--viz-priority-critical-bg` | `#4a1a1a` | `.backlog-priority-critical` |
| `--viz-priority-critical-text` | `#f87171` | `.backlog-priority-critical` |

### 4.3 Series Indicator Tokens (Z2 Toolbar)

| CSS Variable | Default Hex | Series |
|---|---|---|
| `--viz-series-ve` | `#cec528` | `.series-toggle.active[data-series="VE-Series"]` |
| `--viz-series-pe` | `#b87333` | `.series-toggle.active[data-series="PE-Series"]` |
| `--viz-series-foundation` | `#FF9800` | `.series-toggle.active[data-series="Foundation"]` |
| `--viz-series-rcsg` | `#9C27B0` | `.series-toggle.active[data-series="RCSG-Series"]` |
| `--viz-series-orchestration` | `#00BCD4` | `.series-toggle.active[data-series="Orchestration"]` |

### 4.4 Authoring Toolbar Tokens (Z4)

| CSS Variable | Default Hex | Element |
|---|---|---|
| `--viz-authoring-surface` | `#1a2a27` | `.authoring-toolbar` background |
| `--viz-authoring-border` | `#1a4a3a` | `.authoring-toolbar` border |
| `--viz-authoring-btn-bg` | `#2a3d37` | `.authoring-toolbar button` background |
| `--viz-authoring-btn-border` | `#3a5d47` | `.authoring-toolbar button` border |
| `--viz-authoring-dirty` | `#fca5a5` | `.authoring-dirty` indicator |

### 4.5 Selection Toolbar Tokens (Z4b)

| CSS Variable | Default Hex | Element |
|---|---|---|
| `--viz-selection-surface` | `#1a2027` | `.selection-toolbar` background |
| `--viz-selection-border` | `#2a3d57` | `.selection-toolbar` border |
| `--viz-selection-btn-bg` | `#2a2d47` | `.selection-toolbar button` background |
| `--viz-selection-btn-border` | `#3a3d67` | `.selection-toolbar button` border |
| `--viz-selection-text` | `#a0c0ff` | `.selection-label`, `.selection-toolbar button` text |

### 4.6 Diff / Revision Tokens

| CSS Variable | Default Hex | Element |
|---|---|---|
| `--viz-diff-added` | `#86efac` | `.diff-item.added` |
| `--viz-diff-removed` | `#fca5a5` | `.diff-item.removed` |
| `--viz-diff-changed` | `#ffb48e` | `.diff-item.changed` |
| `--viz-revision-patch-bg` | `#1a3a2a` | `.revision-badge--patch` |
| `--viz-revision-minor-bg` | `#1a2a3a` | `.revision-badge--minor` |
| `--viz-revision-major-bg` | `#3a1a1a` | `.revision-badge--major` |

### 4.7 Cross-Reference / Bridge Tokens

| CSS Variable | Default Hex | Element |
|---|---|---|
| `--viz-crossref-gold` | `#eab839` | `.legend-dot-crossref`, `.bridge-filter-btn.active` |
| `--viz-bridge-active-bg` | `#856404` | `.bridge-filter-btn.active` background |

### 4.8 Remaining Hardcoded Values (Candidates for Future Tokenisation)

A small number of values remain hardcoded — these are lower-impact or edge cases:

| Context | Value | Notes |
|---|---|---|
| Data instance type badges (Z9) | `#166534`/`#86efac`, `#1e40af`/`#93c5fd`, `#854d0e`/`#fcd34d`, `#7f1d1d`/`#fca5a5` | Could reuse `--viz-status-*` tokens |
| Library compliant/placeholder badges | `#166534`/`#86efac`, `#553922`/`#FFB48E` | Could reuse `--viz-status-*` tokens |
| Admin panel live/override badges | `#4CAF50`, `#5eead4`/`#134e4a`, `#ffb48e`/`#553016` | Specialised admin UI |
| DS tier badges (primitive/semantic/component) | `#166534`/`#86efac`, `#1e40af`/`#93c5fd`, `#854d0e`/`#fcd34d` | Could reuse status tokens |
| Mermaid editor error highlight | `rgba(207,5,125,0.1)` | Uses `--viz-error` conceptually |
| Modal/export overlay shadows | `rgba(0,0,0,0.4-0.8)` | Structural, not brand-specific |

---

## 5. Zone → Token Matrix

Shows which CSS custom properties are consumed by each zone.

| Token | Z1 Hdr | Z2 Tbar | Z3 Ctx | Z6 Canvas | Z7 Leg | Z8 Lyr | Z9 Side | Z10 Aud | Z11 Lib | Z12 DS | Z13 Blg | Z14 Merm |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `--viz-surface-elevated` | bg | bg | bg | — | bg | bg | bg | bg | bg | bg | bg | bg |
| `--viz-surface-card` | — | — | — | — | — | — | cards | cards | cards | cards | cards | — |
| `--viz-surface-subtle` | — | btn | btn | — | — | hover | hover | hover | hover | — | — | — |
| `--viz-container-surface` | — | — | — | **bg** | — | — | — | — | — | — | — | — |
| `--viz-text-primary` | — | btn | label | — | items | items | values | items | items | items | cards | code |
| `--viz-text-secondary` | stats | — | — | — | — | — | labels | headers | — | — | — | — |
| `--viz-accent` | title | — | brand | — | — | active | h3 | — | — | tier | — | — |
| `--viz-accent-active` | — | active | — | — | — | — | active | — | loaded | — | — | focus |
| `--viz-accent-subtle` | — | — | — | — | hover | hover | — | — | — | — | — | — |
| `--viz-border-default` | btm | btm | btm | — | border | border | left | left | — | — | — | — |
| `--viz-border-subtle` | — | btn | btn | — | — | — | — | — | — | — | — | border |
| `--viz-error` | — | — | — | — | — | — | — | fail | — | — | blocked | error |
| `--viz-warning` | — | — | — | — | — | — | — | warn | — | — | priority | — |
| `--viz-success` | — | — | — | — | — | — | — | pass | compliant | — | done | — |
| `--viz-info` | — | — | — | — | — | — | — | — | — | — | progress | — |
| `--viz-brand-glow-color` | — | — | — | **glow** | — | — | — | — | — | — | — | — |
| `--viz-archetype-*` | — | — | — | **nodes** | dots | — | — | — | — | — | — | — |
| `--viz-edge-*` | — | — | — | **edges** | lines | — | — | — | — | — | — | — |

---

## 6. DS-ONT → CSS Variable Mapping (ds-loader.js Resolution)

When a DS brand instance (e.g. BAIV) is loaded, `ds-loader.js` resolves tokens as follows:

```
DS-ONT Semantic Token             →  CSS Custom Property
──────────────────────────────────────────────────────────────
primary.surface.default           →  --viz-accent-active
primary.surface.subtle            →  --viz-accent-subtle
primary.text.default              →  --viz-accent
primary.border.default            →  --viz-accent-border
neutral.surface.subtle            →  --viz-surface-elevated
neutral.surface.default           →  --viz-surface-card
neutral.text.body                 →  --viz-text-primary
neutral.text.subtitle             →  --viz-text-secondary
neutral.text.caption              →  --viz-text-muted
neutral.border.default            →  --viz-border-default
neutral.border.subtle             →  --viz-border-subtle
error.text.default                →  --viz-error
warning.text.default              →  --viz-warning
success.text.default              →  --viz-success
information.text.default          →  --viz-info
container.surface.default         →  --viz-container-surface
archetype.{type}.surface          →  --viz-archetype-{type}
edge.{type}.color                 →  --viz-edge-{type}
```

**14 required semantic tokens** (BR-DS-008): The above mappings form the minimum token set that must be present for CSS variable generation to succeed.

---

## 7. Design Rules (DR-*) — Relevant to UI Zones

### Canvas Rules (Z6)
| Rule | Requirement | Zone |
|---|---|---|
| DR-CANVAS-001 | Canvas background luminance must be < 0.05 or >= 0.2 | Z6 |
| DR-GRAPH-001 | Node fill on dark canvas: light archetype colour, dark text | Z6 nodes |
| DR-GRAPH-002 | Node fill on light canvas: inverted palette | Z6 nodes |
| DR-GRAPH-003 | Node label font must match DS font family | Z6 node labels |

### Edge Rules (Z6)
| Rule | Requirement | Zone |
|---|---|---|
| DR-EDGE-001 | Edge colour by relationship category | Z6 edges |
| DR-EDGE-002 | Edge width: 1–3px based on cardinality | Z6 edges |
| DR-EDGE-003–008 | Dash patterns, labels, arrow styles | Z6 edges |

### Brand Rules (Z3, Z6)
| Rule | Requirement | Zone |
|---|---|---|
| DR-BRAND-001 | Brand glow = 0 0 12px accent on key nodes | Z6 nodes, Z3 identity bar |
| DR-PFI-001 | Instance brand resolved from EMC config | Z3, Z12 |

### Container Rules (Z6, all panels)
| Rule | Requirement | Zone |
|---|---|---|
| DR-CONTAINER-001 | Container surfaces use PF-Core tokens only (immutable) | Z6, all panel bgs |
| DR-CONTAINER-002–006 | Fill opacity, stroke, radius, padding | All panels |

### Context Rules (Z3, Z6)
| Rule | Requirement | Zone |
|---|---|---|
| DR-CTX-SWITCH-001 | Context identity bar shows active brand | Z3 |
| DR-CTX-SWITCH-002 | Canvas border glow when context active | Z6 border |
| DR-CTX-SWITCH-003 | Dynamic document title | Browser tab |
| DR-CTX-SWITCH-004 | Confirmation modal on switch | Z18 modal |

### WCAG / Accessibility
| Rule | Requirement | Zone |
|---|---|---|
| DR-SEMANTIC-005 | Min 3:1 contrast ratio for archetype colours vs canvas | Z6 nodes |
| DR-SEMANTIC-006 | Brand overrides validated against luminance bounds | Z6 |

---

## 8. Component Token Bindings (DS-ONT Component Tier)

These are the 15 component-level tokens from DS-ONT that bind to specific UI widgets:

| DS-ONT Component Token | Hex (BAIV) | CSS Target | UI Component | Zones |
|---|---|---|---|---|
| `button.primary.background` | (from primary.surface.default) | `.toolbar button.active bg` | Primary action buttons | Z2, Z4 |
| `button.primary.text` | (from primary.text.default) | `.toolbar button.active color` | Button text | Z2, Z4 |
| `button.primary.hover` | (from primary.surface.darker) | `.toolbar button:hover bg` | Hover state | Z2, Z4 |
| `button.secondary.background` | (from neutral.surface.subtle) | `.toolbar button bg` | Secondary buttons | Z2, all panels |
| `button.secondary.text` | (from neutral.text.body) | `.toolbar button color` | Button text | Z2, all panels |
| `button.secondary.hover` | (from neutral.border.subtle) | `.toolbar button:hover bg` | Hover state | Z2, all panels |
| `button.destructive.background` | (from error.surface.default) | `.exit-authoring bg` | Destructive actions | Z4 |
| `button.primary.radius` | (from radius.md = 8px) | `.toolbar button border-radius` | Corner radius | All buttons |
| `input.background` | (from neutral.surface.default) | `input, select bg` | Form inputs | Z9, Z14 |
| `input.border.default` | (from neutral.border.default) | `input, select border` | Input border | Z9, Z14 |
| `input.border.focus` | (from primary.border.default) | `input:focus border` | Focus ring | Z9, Z14 |
| `input.border.error` | (from error.border.default) | `input.error border` | Error state | Z9, Z14 |
| `input.text` | (from neutral.text.body) | `input color` | Input text | Z9, Z14 |
| `checkbox.unchecked.background` | (from neutral.surface.default) | `input[type=checkbox] bg` | Unchecked state | Z2 toggles |
| `checkbox.checked.background` | (from primary.surface.default) | `input[type=checkbox]:checked bg` | Checked state | Z2 toggles |

---

## 9. Typography Tokens (PF-Core — Immutable)

From DS-ONT primitive tokens:

| Token | Value | CSS Applied | Zones |
|---|---|---|---|
| `font.family.heading` | Jura | Not yet applied (uses system-ui) | — |
| `font.family.body` | Jura | Not yet applied (uses system-ui) | — |
| `font.family.mono` | JetBrains Mono | `font-family: monospace` fallback in Z14 | Z14 mermaid editor |
| `font.size.xs` | 11px | `.field-label font-size` | Z9 labels |
| `font.size.sm` | 13px | `.toolbar button`, `.field-value` | Z2, Z9 |
| `font.size.md` | 14px | `h3` headings in panels | Z9, Z10, Z11, Z12 |
| `font.size.lg` | 16px | `h1` in header | Z1 |
| `font.weight.regular` | 400 | Body text | All zones |
| `font.weight.semibold` | 600 | `h1`, `h3` headings | Z1, panels |
| `font.weight.bold` | 700 | Emphasis, badges | Various |

---

## 10. Spacing & Radius Tokens (PF-Core — Immutable)

| Token | Value | CSS Applied | Zones |
|---|---|---|---|
| `spacing.xs` | 4px | Inline gaps, badge padding | Various |
| `spacing.sm` | 8px | Toolbar padding, button gaps | Z2, panels |
| `spacing.md` | 16px | Panel padding, section gaps | All panels |
| `spacing.lg` | 24px | Header padding, toolbar padding | Z1, Z2 |
| `spacing.xl` | 32px | — | — |
| `radius.none` | 0 | — | — |
| `radius.sm` | 4px | Badges, small chips | Various |
| `radius.md` | 8px | Buttons, cards, panels | Z2, Z7, Z8, Z9+ |
| `radius.lg` | 12px | Modal corners | Z18 |
| `radius.xl` | 16px | Large floating panels | Z7, Z8 |
| `radius.full` | 9999px | Circular indicators (dots) | Series dots, density dots |

---

## 11. Brand Override Flow (Runtime)

```
User clicks "Apply DS" in Z12 DS Panel
        │
        ▼
ds-loader.js: parseDSInstance(jsonld)
        │
        ▼
generateCSSVars(parsed) → { '--viz-accent': '#newcolor', ... }
        │
        ▼
applyCSSVars(cssVars) → document.documentElement.style.setProperty(...)
        │
        ├── DR-SEMANTIC-005 contrast validation
        │   └── Reverts non-compliant overrides with console warning
        │
        ├── state.dsAppliedCSSVars = cssVars  (for reset)
        │
        └── state.brandContext = { brand, tier, accentColor }
                │
                ▼
        graph-renderer.js picks up brandContext
        for node glow effect (DR-BRAND-001)
                │
                ▼
        localStorage.setItem('ds-applied', ...)
        for persistence across page reload
```

**Reset**: `resetDSTheme()` → removes all properties → clears localStorage → reverts to `:root` defaults.

---

## 12. Tokenisation Gap Summary

| Category | Tokenised (CSS vars) | Hardcoded | Gap % |
|---|---|---|---|
| Surface colours | 5 | 0 | **0%** |
| Text colours | 3 | 0 | **0%** |
| Accent colours | 4 | 0 | **0%** |
| Status colours | 4 | 0 | **0%** |
| Border colours | 2 | 0 | **0%** |
| Archetype colours | 9 | 0 | **0%** |
| Edge colours | 5 | 0 | **0%** |
| Status badge bg/text | 0 | **12** | **100%** |
| Priority badge bg/text | 0 | **10** | **100%** |
| Status badge variants | 0 | **10** | **100%** |
| Series indicator colours | 0 | **5** | **100%** |
| Authoring toolbar colours | 0 | **5** | **100%** |
| Selection toolbar colours | 0 | **5** | **100%** |
| Mermaid primary colour | 0 | **1** | **100%** |
| **Totals** | **32** | **48** | **60% hardcoded** |

---

## 13. Recommended Next Steps

1. **Tokenise status badge palette** — Add `--viz-success-bg`, `--viz-success-border`, `--viz-success-text-bright` (and equivalents for warning/error/info) to `:root`
2. **Tokenise series colours** — Add `--viz-series-ve`, `--viz-series-pe`, etc. to `:root` and remove inline HTML styles
3. **Tokenise priority/status badge colours** — Move from hardcoded to CSS vars
4. **Tokenise authoring/selection toolbar** — These are custom-tinted zones that should use semantic tokens
5. **Apply DS-ONT typography** — Replace `system-ui` with Jura/JetBrains Mono from DS primitives
6. **Add dark/light theme mode** — DS-ONT ThemeMode entities support `prefers-color-scheme`; current CSS is single-mode only
7. **Figma MCP sync** — Use `get_variable_defs` to extract live token values and validate against this map

---

## Appendix A: Complete Colour Palette (Visual Reference)

### Primary Accent Family
```
#9dfff5  ████  --viz-accent (bright cyan)
#017c75  ████  --viz-accent-active (dark teal)
```

### Surface Family
```
#9BA7A8  ████  --viz-surface-default (body bg)
#768181  ████  --viz-container-surface (canvas)
#1a1d27  ████  --viz-surface-elevated (panels)
#22252f  ████  --viz-surface-card (cards)
#2a2d37  ████  --viz-surface-subtle (hover)
```

### Text Family
```
#e0e0e0  ████  --viz-text-primary
#888888  ████  --viz-text-secondary
#666666  ████  --viz-text-muted
```

### Status Family
```
#cf057d  ████  --viz-error (magenta)
#FF9800  ████  --viz-warning (orange)
#4CAF50  ████  --viz-success (green)
#2196F3  ████  --viz-info (blue)
```

### Status Bright (badge text — not yet tokenised)
```
#86efac  ████  success bright (light green)
#ffb48e  ████  warning bright (light orange)
#fca5a5  ████  error bright (light red)
#93c5fd  ████  info bright (light blue)
#fcd34d  ████  warning alt (yellow)
```

### Archetype Family (graph nodes)
```
#4CAF50  ████  class / core (green)
#2196F3  ████  framework (blue)
#FF9800  ████  supporting (orange)
#E91E63  ████  agent (pink)
#9E9E9E  ████  external (grey)
#00BCD4  ████  layer (cyan)
#AB47BC  ████  concept (purple)
#017c75  ████  default (teal)
```

### Edge Family (graph relationships)
```
#7E57C2  ████  structural (purple)
#888888  ████  taxonomy (grey)
#EF5350  ████  dependency (red)
#42A5F5  ████  informational (light blue)
#66BB6A  ████  operational (green)
```

### Series Family (not yet tokenised)
```
#cec528  ████  VE-Series (gold)
#b87333  ████  PE-Series (brown)
#FF9800  ████  Foundation (orange)
#9C27B0  ████  RCSG-Series (purple)
#00BCD4  ████  Orchestration (cyan)
```

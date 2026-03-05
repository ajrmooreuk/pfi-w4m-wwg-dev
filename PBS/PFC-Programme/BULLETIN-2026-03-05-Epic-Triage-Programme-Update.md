# Programme Bulletin: Epic Triage & Forward Plan

**Date**: 2026-03-05
**From**: Programme Office
**To**: All PFI Instance Dev Teams (AIRL, BAIV, W4M/WWG)
**Classification**: Internal — Programme Communication
**Ref**: [Prioritisation Review](https://github.com/ajrmooreuk/Azlan-EA-AAA/blob/main/PBS/STRATEGY/PRIORITISATION-Epics-and-Strategy-Alignment-2026-03-05.md)

---

## Summary

A major programme triage has been completed across all 34 open epics and 30+ strategy briefings. The result is a cleaner backlog, two new epics, and a clear 5-tier priority framework that defines the critical path to a working platform.

**Key numbers**: 7 epics closed | 2 epics created | 35 briefings triaged | 29 epics now open

---

## What Changed

### Epics Closed (Roll-Forward to Epic 56)

The following legacy epics have been **closed as superseded**. Their valuable scope has been rolled forward into Epic 56 features. No work is lost — it's restructured into the forward plan.

| Closed Epic | Reason | Rolled Into |
|-------------|--------|-------------|
| Epic 9H (#147) — Client-Org & Vertical Market Config | Superseded by ORG-CONTEXT + EMC composition | F56.5, F56.7 |
| Epic 13 (#88) — PFI-W4M-PF-Core & Client Sub-Instances | Superseded by Epic 45 + Epic 19 + Epic 46a | F56.7, F56.8, F56.9 |
| Epic 15 (#90) — PFI-W4M-EA-Togaf | Superseded by EA sub-series restructure | F56.2, F56.5 |
| Epic 16 (#91) — PFI-RCS-W4M-AIR-Collab | Superseded by individual PFI instance epics | F56.7, F56.8 |
| Epic 17 (#141) — PF-Core-W4M-EA | Absorbed into EA sub-series + Epic 34 S6 | F56.2, F56.5 |
| Epic 18 (#190) — VSOM-SC Strategy Communication | Delivered (4 ontologies committed) | F56.2, F56.5 |
| Epic 32 (#479) — Cross-Repo Programme Visibility | Absorbed into Epic 55 | F55.1-F55.7 |

### New Epics Created

| Epic | Issue | Title | Tier |
|------|-------|-------|------|
| **55** | [#836](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/836) | Federated Portfolio Reporting, Registry Health & Programme Analytics | Tier 2 (Enabler) |
| **56** | [#834](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/834) | Strategy-to-Build Pipeline — Component-Led PFC-PFI Framework | Tier 1 (Critical Path) |

### Epic 46 Numbering Collision Fixed

| Old | New | Issue | Title |
|-----|-----|-------|-------|
| Epic 46 | **Epic 46a** | [#683](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/683) | PFC-ONT Unified Registry & Context Assistant |
| Epic 46 | **Epic 46b** | [#668](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/668) | PFI-PC-DICE FloodGraph AI |

---

## Priority Framework

All 29 open epics are now organised into 5 tiers:

### Tier 1: CRITICAL PATH (Do Now)

| Epic | Title | Why It Matters to PFI Teams |
|------|-------|-----------------------------|
| 19 | Graph-Scope Rules & Composed Instance Data | **Your instance data graphs depend on this.** EMC composition engine determines what ontologies and data each PFI can access. |
| 46a | Unified Registry & Context Assistant | **Single source of truth for all platform artifacts.** The quasi-OO cascade (Core->Instance->Product->Client) governs what's available to your instance. |
| 10A | Security MVP — Multi-PFI Foundation | **Nothing goes to production without this.** Supabase Auth + RLS = your instance data is isolated and protected. |
| 8 | Design-Director — DS-ONT + Multi-Brand | **Your UI component library.** Token cascade + design rules = consistent, brand-specific rendering for each PFI. |
| 56 | Strategy-to-Build Pipeline | **The pipeline from idea to running app.** VE skill chain -> EFS -> PPM -> skeleton -> components -> deployed application. |

### Tier 2: ENABLERS (Do Next)

Epics 21 (OAA v7), 31 (CI/CD), 38 (Strategy Analysis), 44 (WWG Design System), 30 (GRC), 54 (PE-L6S), 55 (Portfolio Reporting)

### Tier 3: PFI INSTANCES (Parallel Tracks)

| Epic | PFI | Readiness |
|------|-----|-----------|
| 12 | **BAIV** (MarTech) | 80% — Lead instance |
| 14 | **AIRL** (Azure AI Readiness) | 60% — Proves GRC + compliance |
| 45 | **W4M-WWG** (Supply-Demand) | 40% — Proves LSC + OFM + EFS |

---

## What This Means for Your Instance

### BAIV Dev Team (`pfi-baiv-aiv-dev`)

- You remain the **lead PFI instance** — first to prove the full platform stack
- Epic 56 F56.10 targets W4M-WWG as MVP proof, but BAIV patterns inform the component library (F56.5)
- Your 16 agent definitions will wire through OAA v7 (Epic 21) once registry (Epic 46a) is stable
- DS-ONT token extraction (Epic 44 pattern) will be applied to your brand instance next

### AIRL Dev Team (`pfi-airl-caf-aza-dev`)

- Your VE Skill Chain briefing (8 files in PBS/STRATEGY/PFI-AIRL/) is triaged as **NEXT** priority
- GRC Series (Epic 30) feeds directly into your compliance audit capability
- Epic 20 (CAF & DSPT Assessment) depends on GRC — sequenced after Epic 30 P2.5
- The Strategy-to-OKR-to-PMF worked example (your AI Audit Services model) validates the VE chain for all instances

### W4M / WWG Dev Team (`pfi-w4m-wwg-dev`)

- Epic 45 (W4M-WWG Supply-Demand Graph) remains active with 7 declared ontologies
- **You are the MVP proof target for Epic 56** — F56.10 will build W4M-WWG end-to-end from the component library
- WWG Design System (Epic 44, P2.4) token re-extraction is queued as Tier 2 enabler
- Your 4 LSC corridors (AU/NZ/IS/IE->UK) + 82 OFM entities are the richest instance dataset

---

## Briefing Triage Process (Standing)

All 30+ strategy briefings have been catalogued in the [F56.1 Briefing Triage Matrix](https://github.com/ajrmooreuk/Azlan-EA-AAA/blob/main/PBS/STRATEGY/F56.1-BRIEFING-TRIAGE-MATRIX.md). Going forward:

```
BRIEFING -> TRIAGE -> EPIC ALIGNMENT -> STORIES -> SPRINT -> BUILD -> CLOSE-OUT
```

Every briefing now has a triage status (ALIGNED / ABSORBED / APPROVED / SHAPE-UP / DEFER) and a timing decision (NOW / NEXT / LATER / DEFER). No more orphan briefings.

---

## Key Documents

| Document | URL |
|----------|-----|
| Prioritisation Review | [PRIORITISATION-Epics-and-Strategy-Alignment-2026-03-05.md](https://github.com/ajrmooreuk/Azlan-EA-AAA/blob/main/PBS/STRATEGY/PRIORITISATION-Epics-and-Strategy-Alignment-2026-03-05.md) |
| F56.1 Briefing Triage Matrix | [F56.1-BRIEFING-TRIAGE-MATRIX.md](https://github.com/ajrmooreuk/Azlan-EA-AAA/blob/main/PBS/STRATEGY/F56.1-BRIEFING-TRIAGE-MATRIX.md) |
| Outstanding Epics (updated) | [OUTSTANDING-EPICS-BREAKDOWN.md](https://github.com/ajrmooreuk/Azlan-EA-AAA/blob/main/PBS/STRATEGY/OUTSTANDING-EPICS-BREAKDOWN.md) |
| Epic 56 | [#834](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/834) |
| Epic 55 | [#836](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/836) |

---

*Next review: Weekly rollup. Questions or feedback — raise in the relevant PFI Dev board or tag in Azlan-EA-AAA.*

# PFC-EFS Skill — Release Bulletin v1.0.0

**Date:** 2026-02-25
**Skill:** `pfc-efs` (Epic-Feature-Story Generator)
**Version:** 1.0.0
**Dtree Classification:** `SKILL_STANDALONE`
**Status:** Released to PFC-Core, distributing to PFI triads

---

## What Is It?

`pfc-efs` is a Claude Code skill that generates complete Product Requirements Documents (PRDs) with Agile Epic-Feature-Story hierarchies from Terms of Reference, VSOM context, or Value Proposition briefs. It outputs GitHub-ready `gh` CLI issue creation scripts.

## Why It Matters

- **Eliminates manual PRD scaffolding** — structured 8-section workflow replaces ad-hoc document creation
- **Enforces strategic traceability** — 5-layer lineage (VSOM→OKR/KPI→VP→ICP→EFS) with mandatory VP-RRR alignment
- **GitHub-native output** — generates `gh issue create` commands with correct naming conventions (`Epic N:`, `FN.x:`, `SN.x.y:`)
- **Quality-gated** — 5 gates (G1-G5) prevent incomplete or misaligned output

## What's Included

| File | Purpose |
|------|---------|
| `SKILL.md` | The skill definition (334 lines, 8 sections) |
| `registry-entry-v1.0.0.jsonld` | UniRegistry entry for discovery |
| `RELEASE-BULLETIN-v1.0.0.md` | This document |
| `TEST-PLAN-v1.0.0.md` | Test plan for PFC team validation |
| `EFSOPS-GUIDE-v1.0.0.md` | Operator guide for running the skill |
| `ARCHITECTURE-v1.0.0.md` | Technical architecture and design decisions |

## Invocation

```
/azlan-github-workflow:pfc-efs [ToR file or VSOM context]
```

## Accepted Inputs

- Terms of Reference (ToR) — briefs, RFPs, scope documents
- VSOM context — Vision, Strategy, Objectives, Measures
- VP brief — Value Proposition with problems/solutions/benefits
- Existing PRD — for decomposition into EFS hierarchy

## Outputs

1. **PRD document** (`PRD-{PRODUCT_CODE}-v0.1.md`) — full structured PRD
2. **GitHub issue scripts** — `gh issue create` commands for epics, features, stories
3. **Lineage map** — 5-layer strategic traceability trace

## Quality Gates

| Gate | Name | Section | Checks |
|------|------|---------|--------|
| G1 | Context Completeness | 1 | Product name, objective, persona, capabilities |
| G2 | Strategic Traceability | 2 | L1-L2 connection, VP-RRR alignment, persona pains |
| G3 | Epic Alignment | 3 | VSOM trace, MECE coverage, business outcomes |
| G4 | Feature Completeness | 4 | Acceptance criteria, dependencies, 2-7 per epic |
| G5 | Story Quality | 5 | As/Want/SoThat, INVEST, RRR trace, 2-5 per feature |

## Distribution

- **Source:** `Azlan-EA-AAA/azlan-github-workflow/skills/pfc-efs/`
- **Distributed via:** `pfc-release.yml` → PFI dev repos
- **Promotion:** `promote.yml` (dev → test → prod) within each triad
- **Target triads:** BAIV, AIRL, W4M-WWG

## Ontology Dependencies

EFS-ONT v2.0.0, VSOM-ONT, OKR-ONT, KPI-ONT, VP-ONT, RRR-ONT, ORG-ONT, PMF-ONT, PE-ONT

## Known Limitations (v1.0.0)

- No automated PRD versioning (manual `v0.1` → `v0.2` bump)
- No direct GitHub Projects field mapping (issues only, not project board custom fields)
- No agent orchestration — runs as standalone skill per Dtree classification
- Requires user confirmation before executing `gh issue create` commands

## Roadmap

- **v1.1:** Auto-link features to parent epic issues via `--body-file` cross-references
- **v1.2:** GitHub Projects custom field population (Priority, Story Points, Release)
- **v2.0:** Promote to `SKILL_COMPOSABLE` — integrate with pfc-vsom-vsem skill chain

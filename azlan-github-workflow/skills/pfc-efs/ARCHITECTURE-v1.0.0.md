# PFC-EFS Skill — Architecture v1.0.0

**Date:** 2026-02-25
**Status:** Implemented
**Classification:** `SKILL_STANDALONE` (Dtree)

---

## 1. Overview

The `pfc-efs` skill is a Claude Code CLI skill that transforms unstructured product context (ToR, VSOM, VP) into structured Agile delivery artefacts (PRD, GitHub issues) through an 8-section pipeline with 5 quality gates.

```
┌──────────────────────────────────────────────────────────────────┐
│                    PFC-EFS SKILL PIPELINE                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT                TRANSFORM              OUTPUT              │
│  ─────                ─────────              ──────              │
│  ToR / VSOM     ──►  S1: Ingest     ──►  Structured Context     │
│  VP Brief             S2: Lineage          5-Layer Map           │
│  Existing PRD         S3: Epics            MECE Hierarchy        │
│                       S4: Features         Acceptance Criteria   │
│                       S5: Stories    ──►   INVEST Stories        │
│                       S6: PRD        ──►   PRD-{CODE}-v0.1.md   │
│                       S7: GH Issues  ──►   gh issue create *    │
│                       S8: Deploy           (reference only)      │
│                                                                  │
│  QUALITY GATES: G1 ─── G2 ─── G3 ─── G4 ─── G5                │
└──────────────────────────────────────────────────────────────────┘
```

## 2. Design Decisions

### D1: Standalone Skill (not Agent or Plugin)

**Decision:** Classify as `SKILL_STANDALONE` per Dtree analysis.

**Rationale:**
- **Autonomy = 4** (low) — follows structured template, no autonomous decision-making
- **Orchestration = none** — single-concern, doesn't coordinate other skills
- **Bundling = 3** (low) — self-contained, no multi-skill composition needed

**Future path:** Promote to `SKILL_COMPOSABLE` (v2.0) when chaining with `pfc-vsom-vsem`.

### D2: Quality Gates as Hard Stops

**Decision:** Gates G1-G5 are mandatory checkpoints, not advisories.

**Rationale:**
- EFS lineage integrity is the core value proposition
- Allowing incomplete context through produces garbage-in/garbage-out PRDs
- Gates enforce the VP-RRR alignment that's a standing project convention

### D3: `--body-file` for All Issue Bodies

**Decision:** Write all issue bodies to `/tmp/` temp files, use `--body-file`.

**Rationale:**
- Project convention: never use `sed` on issue bodies (special char regex errors)
- Complex markdown with tables/checklists breaks inline `--body` quoting
- Temp files provide audit trail and retry capability

### D4: Auto-Detect Epic Numbering

**Decision:** Scan existing issues to find next sequential epic number.

**Rationale:**
- Matches `create-epic` skill pattern exactly
- Prevents numbering collisions across concurrent PRD generation
- Supports letter suffixes for sub-epics (`Epic 9K:`)

### D5: 5-Layer Lineage (Not Flat)

**Decision:** Enforce full VSOM→OKR/KPI→VP→ICP→EFS lineage, not just EFS.

**Rationale:**
- EFS-ONT v2.0.0 Lineage Specification v3.0.0 defines this chain
- Strategic traceability is a platform differentiator
- Without lineage, epics become disconnected wish lists

## 3. Ontology Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ONTOLOGY DEPENDENCY GRAPH                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  L1 ┌──────────┐                                            │
│     │ VSOM-ONT │ Vision → Strategy → Objective → Measure    │
│     └────┬─────┘                                            │
│          │                                                   │
│  L2 ┌────▼─────┐  ┌─────────┐                              │
│     │ OKR-ONT  │──│ KPI-ONT │  Objectives → KPIs           │
│     └────┬─────┘  └────┬────┘                               │
│          │              │                                    │
│  L3 ┌────▼──────────────▼────┐  ┌─────────┐                │
│     │       VP-ONT           │──│ RRR-ONT │  JP-VP-RRR-001 │
│     │ Problem/Solution/Benefit│  │Risk/Req/Result│           │
│     └────┬───────────────────┘  └─────────┘                 │
│          │                                                   │
│  L4 ┌────▼─────┐  ┌───────────┐  ┌─────────┐              │
│     │ ORG-ONT  │  │ORG-CONTEXT│  │ PMF-ONT │  ICP/Persona  │
│     └────┬─────┘  └───────────┘  └─────────┘               │
│          │                                                   │
│  L5 ┌────▼─────┐                                            │
│     │ EFS-ONT  │ Epic → Feature → Story → Task              │
│     │  v2.0.0  │                                            │
│     └──────────┘                                            │
│                                                              │
│  Cross-cutting: PE-ONT (process execution)                   │
└─────────────────────────────────────────────────────────────┘
```

### Join Patterns

| Pattern | Source | Target | Cardinality |
|---------|--------|--------|-------------|
| JP-VP-RRR-001 | vp:Problem | rrr:Risk | 1:1 mandatory |
| JP-VP-RRR-001 | vp:Solution | rrr:Requirement | 1:1 mandatory |
| JP-VP-RRR-001 | vp:Benefit | rrr:Result | 1:1 mandatory |
| JP-EFS-VSOM-001 | efs:Epic.alignsToObjective | vsom:StrategicObjective | N:1 |
| JP-EFS-KPI-001 | efs:Epic.successMetric | kpi:KPI | N:M |
| JP-EFS-GH-001 | efs:Epic | gh:Milestone | 1:1 |
| JP-EFS-GH-001 | efs:Feature | gh:Issue(feature) | 1:1 |
| JP-EFS-GH-001 | efs:Story | gh:Issue(story) | 1:1 |

## 4. Quality Gate Architecture

```
S1 ──► G1 ──► S2 ──► G2 ──► S3 ──► G3 ──► S4 ──► G4 ──► S5 ──► G5 ──► S6 ──► S7 ──► S8
       │             │             │             │             │
       FAIL→ASK      FAIL→ASK     FAIL→ASK      FAIL→ASK     FAIL→ASK
```

Each gate is a **hard stop**. On failure:
1. Skill halts at the failing section
2. Presents specific missing/invalid items to user
3. User provides corrections
4. Gate re-evaluates
5. Only proceeds when all gate conditions are met

### Gate Specifications

| Gate | Inputs Checked | Failure Mode |
|------|---------------|--------------|
| G1 | Product name, objective, persona, 2+ capabilities | Ask user for missing items |
| G2 | L1-L2 link, VP-RRR alignment, persona pains | Flag unlinked layers, ask for VP elements |
| G3 | Epic→Objective trace, MECE check, business outcomes | Highlight overlap/gaps, ask to merge/split |
| G4 | Acceptance criteria exist, dependencies, 2-7 features/epic | Flag missing criteria, suggest splits |
| G5 | As/Want/SoThat format, INVEST, RRR trace, 2-5 stories/feature | Rewrite non-compliant stories |

## 5. Distribution Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  PFC-CORE HUB (Azlan-EA-AAA)            │
│  azlan-github-workflow/skills/pfc-efs/                  │
│    SKILL.md + registry + docs                           │
└──────────┬──────────────┬──────────────┬────────────────┘
           │              │              │
     pfc-release.yml  pfc-release.yml  pfc-release.yml
           │              │              │
           ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ pfi-baiv-dev │ │ pfi-airl-dev │ │ pfi-w4m-dev  │
│  skills/     │ │  skills/     │ │  skills/     │
│  pfc-efs/    │ │  pfc-efs/    │ │  pfc-efs/    │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
   promote.yml      promote.yml      promote.yml
       │                │                │
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ pfi-baiv-test│ │ pfi-airl-test│ │ pfi-w4m-test │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
   promote.yml      promote.yml      promote.yml
       │                │                │
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ pfi-baiv-prod│ │ pfi-airl-prod│ │ pfi-w4m-prod │
└──────────────┘ └──────────────┘ └──────────────┘
```

### What Gets Distributed

| Artefact | Distributed? | Reason |
|----------|-------------|--------|
| SKILL.md | Yes | Core skill definition |
| registry-entry-v1.0.0.jsonld | Yes | Discovery metadata |
| RELEASE-BULLETIN-v1.0.0.md | Yes (docs) | Team awareness |
| TEST-PLAN-v1.0.0.md | Yes (docs) | Instance validation |
| EFSOPS-GUIDE-v1.0.0.md | Yes (docs) | Operator reference |
| ARCHITECTURE-v1.0.0.md | Yes (docs) | Technical reference |

### Distribution Rules

1. **Never edit skills in PFI repos** — changes come from PFC-Core only
2. **Version bumps** require updating SKILL.md frontmatter + registry entry
3. **Breaking changes** require incrementing major version + migration notes
4. **Instance customisation** is done via PFI-specific input files, not skill edits

## 6. Security Considerations

- Skill runs within Claude Code sandbox with restricted tool access
- `gh` commands require pre-authenticated GitHub CLI
- No secrets stored in skill files
- Issue bodies written to `/tmp/` — ephemeral, not persisted
- Output classification labels prevent accidental core contamination

## 7. Future Architecture (v2.0)

```
┌─────────────────────────────────────────────────────┐
│              SKILL COMPOSITION CHAIN (v2.0)          │
├─────────────────────────────────────────────────────┤
│                                                      │
│  pfc-vsom-vsem ──► pfc-efs ──► pfc-gh-projects      │
│  (strategy)       (PRD/EFS)    (board setup)         │
│                                                      │
│  Orchestrated by: pfc-product-pipeline (AGENT)       │
└─────────────────────────────────────────────────────┘
```

Requires Dtree reclassification: `SKILL_STANDALONE` → `SKILL_COMPOSABLE` → `AGENT_ORCHESTRATED`.

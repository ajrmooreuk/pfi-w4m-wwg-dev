# PFC-EFS Skill — Test Plan v1.0.0

**Date:** 2026-02-25
**Author:** PFC-Core Team
**Skill Under Test:** `pfc-efs` v1.0.0
**Target:** All PFC team members + PFI instance leads

---

## 1. Test Objectives

Validate that the `pfc-efs` skill:
1. Correctly ingests diverse input formats (ToR, VSOM, VP, existing PRD)
2. Produces valid 5-layer lineage mappings with VP-RRR alignment
3. Generates MECE epic decompositions with VSOM traceability
4. Outputs syntactically correct `gh issue create` commands
5. All 5 quality gates enforce their constraints

## 2. Test Environment

| Component | Requirement |
|-----------|-------------|
| Claude Code CLI | Latest version with skill support |
| GitHub CLI (`gh`) | v2.x+ authenticated to `ajrmooreuk` org |
| Target repo | Use a **test** triad repo (e.g., `pfi-baiv-aiv-test`) — NOT prod |
| Skill path | `azlan-github-workflow/skills/pfc-efs/SKILL.md` |

## 3. Test Scenarios

### TC-01: Minimal ToR Input

**Input:** A 1-paragraph Terms of Reference with product name and 2 capabilities.
**Expected:** G1 passes. Skill asks for missing strategic objective and persona.
**Quality Gate:** G1 (Context Completeness)

```
/azlan-github-workflow:pfc-efs
> Input: "Build a customer onboarding portal that supports self-registration and document upload."
```

**Pass criteria:**
- [ ] Extracts product name ("Customer Onboarding Portal")
- [ ] Identifies 2 capabilities (self-registration, document upload)
- [ ] Asks user for strategic objective and persona
- [ ] Does NOT proceed to Section 2 until G1 passes

### TC-02: Full VSOM Context Input

**Input:** A VSOM brief with Vision, 2 Strategies, 3 Objectives, KPIs.
**Expected:** G1 and G2 pass. Full lineage mapping produced.

```
/azlan-github-workflow:pfc-efs
> Input: PBS/STRATEGY/VSOM-Programme-Distribution-Strategy.md
```

**Pass criteria:**
- [ ] L1 populated (Vision + Strategies)
- [ ] L2 populated (Objectives + KPIs)
- [ ] L3 VP-RRR alignment attempted (may flag [TBD] if VP not in input)
- [ ] G2 passes or clearly flags gaps

### TC-03: VP Brief with RRR Alignment

**Input:** A Value Proposition brief with 3 problems, 3 solutions, 3 benefits.
**Expected:** VP-RRR alignment enforced — each Problem→Risk, Solution→Requirement, Benefit→Result.

**Pass criteria:**
- [ ] All 3 problems mapped to `rrr:Risk`
- [ ] All 3 solutions mapped to `rrr:Requirement`
- [ ] All 3 benefits mapped to `rrr:Result`
- [ ] JP-VP-RRR-001 join pattern referenced
- [ ] G2 passes

### TC-04: Epic MECE Validation

**Input:** Scope document covering 4 distinct capability areas.
**Expected:** 4 epics, no overlap, full coverage.

**Pass criteria:**
- [ ] Each epic has unique business outcome
- [ ] No capability appears in 2+ epics (Mutually Exclusive)
- [ ] All input capabilities covered (Collectively Exhaustive)
- [ ] Each epic traces to an L1-L2 objective
- [ ] G3 passes

### TC-05: Feature and Story Generation

**Input:** Single epic with clear scope for 3 features.
**Expected:** 3 features with 2-5 stories each, all INVEST-compliant.

**Pass criteria:**
- [ ] Features have acceptance criteria (Given/When/Then or checklist)
- [ ] Feature count 2-7 per epic
- [ ] Stories follow As/Want/SoThat format
- [ ] Story benefits trace to VP benefits or RRR results
- [ ] G4 and G5 pass

### TC-06: GitHub Issue Script Generation

**Input:** Complete EFS hierarchy (2 epics, 4 features, 10 stories).
**Expected:** Valid `gh` CLI commands with correct naming convention.

**Pass criteria:**
- [ ] Epic titles: `Epic N: <outcome>` with auto-detected N
- [ ] Feature titles: `FN.x: <capability>`
- [ ] Story titles: `SN.x.y: <summary>`
- [ ] All use `--body-file` (no inline complex bodies)
- [ ] Labels applied: `type:epic`, `type:feature`, `type:story`
- [ ] Offers 3 execution options (execute now, script, PRD-only)

### TC-07: Quality Gate Rejection

**Input:** Deliberately incomplete input (no personas, no objectives).
**Expected:** G1 fails, skill halts and requests missing info.

**Pass criteria:**
- [ ] Skill does NOT proceed past Section 1
- [ ] Clear error message listing missing G1 items
- [ ] After user provides info, skill resumes from Section 2

### TC-08: Triad Repo Targeting

**Input:** Valid EFS hierarchy with user specifying `pfi-baiv-aiv-test` as target.
**Expected:** All `gh` commands target the specified repo.

**Pass criteria:**
- [ ] `--repo ajrmooreuk/pfi-baiv-aiv-test` on all commands
- [ ] Epic numbering auto-detected from that repo's existing issues
- [ ] Output classification labels applied

## 4. Regression Checks

| Check | Expectation |
|-------|-------------|
| Naming convention | Matches `create-epic` pattern exactly |
| Label application | `type:epic,visualiser` on epics (not just `type:epic`) |
| Body files | Uses `/tmp/` temp files, never `sed` on issue bodies |
| Large scope | 5+ epics should not cause truncation or loss |

## 5. Sign-Off

| Role | Name | Date | Status |
|------|------|------|--------|
| PFC-Core Lead | | | |
| BAIV Instance Lead | | | |
| AIRL Instance Lead | | | |
| W4M Instance Lead | | | |

## 6. Defect Log

| ID | Scenario | Description | Severity | Status |
|----|----------|-------------|----------|--------|
| | | | | |

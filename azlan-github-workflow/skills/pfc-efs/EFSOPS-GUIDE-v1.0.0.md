# EFSOps Guide — PFC-EFS Skill v1.0.0

**Date:** 2026-02-25
**Audience:** PFC team members, PFI instance leads, product owners
**Prerequisite:** Claude Code CLI with `azlan-github-workflow` skills installed

---

## 1. Quick Start

```bash
# Navigate to any repo with the skill installed
cd pfi-baiv-aiv-dev

# Invoke the skill with a ToR file
/azlan-github-workflow:pfc-efs PBS/STRATEGY/my-terms-of-reference.md

# Or invoke with inline context
/azlan-github-workflow:pfc-efs "Build a customer dashboard with real-time analytics and role-based access"
```

The skill walks you through 8 sections. You cannot skip sections — each quality gate must pass.

## 2. Input Preparation

### Best Results — Provide These Upfront

| Input Element | Why It Matters | Example |
|---------------|----------------|---------|
| Product/project name | Seeds all IDs and filenames | "BAIV Marketing Analytics Platform" |
| VSOM objective | Enables L1-L2 lineage | "OBJ-S1-01: Achieve 100 active clients" |
| Target personas | Drives story generation | "Marketing Manager, Data Analyst" |
| Problems/pain points | VP-RRR alignment source | "No real-time campaign visibility" |
| Success metrics | KPI linkage | "Dashboard load time < 2s, 80% adoption" |

### Acceptable Input Formats

1. **Markdown file** — ToR, VSOM brief, VP canvas, existing PRD
2. **Inline text** — Skill argument or pasted into conversation
3. **GitHub issue** — Reference an existing epic or feature issue
4. **Multiple files** — Skill reads all, merges context

### Minimum Viable Input

The skill enforces G1 (Context Completeness). At minimum you need:
- Product name
- 1 strategic objective (or inferable from context)
- 1 persona/segment
- 2 problems or capabilities

If your input is thinner than this, the skill will ask you to fill gaps before proceeding.

## 3. Section-by-Section Walkthrough

### S1: Context Ingestion
- Skill reads your input and extracts structured data
- Presents extracted context for your confirmation
- **You do:** Confirm or correct the extracted elements
- **Gate G1:** Must have product name + objective + persona + 2 capabilities

### S2: Lineage Mapping
- Maps your context to the 5-layer architecture
- Flags any layer with `[TBD]` gaps
- Enforces VP-RRR alignment (Problem→Risk, Solution→Requirement, Benefit→Result)
- **You do:** Fill TBD gaps or confirm they're acceptable
- **Gate G2:** L1-L2 connected, VP-RRR aligned, persona has pains/gains

### S3: Epic Decomposition
- Proposes epics as customer-facing outcomes
- Checks MECE (no overlap, full coverage)
- **You do:** Approve, merge, split, or re-prioritise epics
- **Gate G3:** Every epic traces to objective, MECE verified

### S4: Feature Breakdown
- Decomposes each epic into 2-7 features
- Each feature gets acceptance criteria
- **You do:** Review criteria, add missing features, flag dependencies
- **Gate G4:** All features have criteria + dependencies identified

### S5: Story Generation
- Generates As/Want/SoThat stories per feature (2-5 each)
- Stories must be INVEST-compliant
- **You do:** Review stories, adjust personas, refine benefits
- **Gate G5:** All stories traced to VP benefits or RRR results

### S6: PRD Assembly
- Assembles full PRD markdown document
- Writes to `PRD-{PRODUCT_CODE}-v0.1.md`
- **You do:** Review the PRD, request edits

### S7: GitHub Issue Generation
- Generates `gh` CLI commands for all epics/features/stories
- Auto-detects next epic number from target repo
- **You do:** Choose execution mode:
  1. **Execute now** — creates all issues immediately
  2. **Script file** — writes commands to `.sh` for review
  3. **PRD only** — skip issue creation

### S8: Triad Deployment (reference only)
- Documents how this skill reaches PFI triad repos
- Not an interactive section — informational

## 4. Common Workflows

### Workflow A: New Product PRD from Scratch

```
Input: VSOM brief + VP canvas
→ S1-S5: Full lineage + EFS hierarchy
→ S6: PRD written
→ S7: Issues created in pfi-{instance}-dev
```

### Workflow B: Decompose Existing Epic

```
Input: "Decompose Epic 45 into features and stories"
→ S1: Reads epic issue body as context
→ S3: Skips (epic already exists)
→ S4-S5: Generates features + stories
→ S7: Creates feature/story issues under existing epic
```

### Workflow C: Strategic Audit of Existing PRD

```
Input: Existing PRD markdown file
→ S1-S2: Extracts and validates lineage
→ Flags: Missing VSOM traces, broken RRR alignment, orphan features
→ S6: Outputs annotated PRD with gaps highlighted
```

### Workflow D: Cross-Instance Pattern

```
Input: VP brief for W4M-WWG supply chain
→ S1-S7: Full generation targeting pfi-w4m-wwg-dev
→ Output label: output:shared-pattern (if reusable) or output:instance-specific
```

## 5. Output Classification

When generating issues for a PFI triad repo, the skill applies distribution labels:

| Label | Meaning | Example |
|-------|---------|---------|
| `output:core-contribution` | Reusable pattern → promote back to PFC-Core | Generic PRD template improvement |
| `output:instance-specific` | Stays in this PFI triad only | W4M-WWG supply chain stories |
| `output:shared-pattern` | Useful across instances → share via PFC-Core | Dashboard analytics feature pattern |

## 6. Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| G1 keeps failing | Input too thin | Add product name, objective, persona |
| VP-RRR alignment flagged | No VP elements in input | Provide problems/solutions/benefits |
| Epic numbering wrong | Stale issue cache | Run `gh issue list --repo REPO --state all --limit 500` manually |
| `gh` commands fail | Not authenticated | Run `gh auth login` |
| Skill not found | Not in skill path | Check `azlan-github-workflow/skills/pfc-efs/SKILL.md` exists |

## 7. Maintenance

- **Skill updates** come from PFC-Core via `pfc-release.yml`
- **Do not edit** the skill in PFI repos directly — changes will be overwritten
- **To propose changes:** Open a PR against `Azlan-EA-AAA/azlan-github-workflow/skills/pfc-efs/`
- **Version bumps:** Update SKILL.md frontmatter + registry entry + this guide

# Programme Summary — MS 9.00 Platform Database Architecture & Security Foundation

**Generated**: 2026-03-05
**Milestone**: [MS 9.00](https://github.com/ajrmooreuk/Azlan-EA-AAA/milestone/11)
**Repository**: [ajrmooreuk/Azlan-EA-AAA](https://github.com/ajrmooreuk/Azlan-EA-AAA)
**Label**: `cross-programme`
**Parent**: [Epic 34: PF-Core Graph-Based Agentic Platform Strategy (#518)](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/518)

---

## Programme Vision

Deliver the PFC-PFI database architecture as a live, per-stage, cascade-aware platform — covering git triad separation, security foundations (Auth, RLS, RBAC), per-stage database isolation, CI/CD pipeline integration, and cloud sovereignty options.

---

## Programme Totals

| Metric | Count |
|--------|-------|
| Epics | 5 |
| Features | 32 |
| Stories | 137 |
| Stories Done | 16 |
| Stories Remaining | 121 |
| Features Done | 2 (F31.8, F31.9) |

---

## Dependency Chain

```
DB-ARCH-01  Epic 58 (#837) ── PFC-Core Own Triad
    │
    ▼
DB-ARCH-02  Epic 10A (#127) ── Security MVP (Schema, Auth, RLS, Login)
    │
    ▼
DB-ARCH-03  Epic 59 (#840) ── DB Platform Architecture (Per-Stage, Promotion, PFC→PFI)
    │
    ├──────────────────┐
    ▼                  ▼
DB-ARCH-04          DB-ARCH-05
Epic 31 (#394)      Epic 53 (#775)
CI/CD Pipeline      Cloud Sovereignty
(Git + DB Promote)  (Azure/Supabase per PFI)
```

---

## PBS Briefing Index

| WBS | Epic | Primary PBS Briefing | Additional Briefings |
|-----|------|---------------------|---------------------|
| DB-ARCH-01 | Epic 58 | `PBS/STRATEGY/BRIEFING-Epic58-PFC-Core-Triad-Separation-Strategy.md` | — |
| DB-ARCH-02 | Epic 10A | `PBS/ARCHITECTURE/Security/MVP-Security-VSOM-v1.1.0.md` | `PBS/ARCHITECTURE/ARCH-MVP-Security/RBAC-PERMISSION-MATRIX.md`, `PBS/ONTOLOGIES/ontology-library/VE-Series/RRR-ONT/RRR_RACI_RBAC_Ontology_Visual_Guide.md` |
| DB-ARCH-03 | Epic 59 | `PBS/STRATEGY/BRIEFING-Epic59-DTP-Database-Sync-Micro-SaaS-Strategy.md` | `PBS/STRATEGY/BRIEFING-Epic59-VE-Skill-Chain-OKR-VP-Kano-PMF.md`, `PBS/STRATEGY/PFI-AIRL/08-DB-Platform-Cascade.md` |
| DB-ARCH-04 | Epic 31 | `PBS/ARCHITECTURE/arch-cicd/01-hub-and-spoke-proposal.md` | `PBS/ARCHITECTURE/arch-cicd/02-promotion-pipeline-detail.md`, `PBS/ARCHITECTURE/arch-cicd/04-operating-guide.md` |
| DB-ARCH-05 | Epic 53 | `PBS/STRATEGY/BRIEFING-PFC-EA-Arch-DB-Migrations-Azure-Supabase.md` | `PBS/STRATEGY/STRATEGY-Cloud-Vendor-Sovereignty-Multi-Platform-v1.0.0.md`, `PBS/STRATEGY/PFI-AIRL/05-Execution-Architecture.md` |

---

## Epic & Feature/Story Breakdown

---

### DB-ARCH-01 — Epic 58: PFC-Core Own Triad

**Issue**: [#837](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/837) | **Priority**: P0 | **Features**: 4 | **Stories**: 16 (0 done)
**Depends on**: — (first in chain)
**PBS**: `PBS/STRATEGY/BRIEFING-Epic58-PFC-Core-Triad-Separation-Strategy.md`

#### F58.1: PFC Triad Bootstrap — [#838](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/838)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-01.1.1 | Extend `bootstrap-triad.sh` for PFC-internal variant | [#839](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/839) | Backlog |
| DB-ARCH-01.1.2 | Create pfc-dev, pfc-test, pfc-prod repos with branch protection | [#841](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/841) | Backlog |
| DB-ARCH-01.1.3 | Seed pfc-dev with distributable assets from Azlan-EA-AAA | [#842](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/842) | Backlog |
| DB-ARCH-01.1.4 | Configure promotion.env for PFC triad | [#843](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/843) | Backlog |

#### F58.2: Pipeline Migration — [#844](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/844)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-01.2.1 | Move `pfc-release.yml` to pfc-prod, update source paths | [#845](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/845) | Backlog |
| DB-ARCH-01.2.2 | Update PROMOTION_PAT scope to pfc-prod only | [#846](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/846) | Backlog |
| DB-ARCH-01.2.3 | Add PFC-specific validation jobs to pfc-test CI | [#847](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/847) | Backlog |
| DB-ARCH-01.2.4 | Dry-run full pipeline: pfc-dev → pfc-test → pfc-prod → PFI dev | [#848](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/848) | Backlog |

#### F58.3: Cutover and Documentation — [#849](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/849)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-01.3.1 | First tagged release from pfc-prod (`pfc-v2.0.0`) | [#850](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/850) | Backlog |
| DB-ARCH-01.3.2 | Archive release trigger from Azlan-EA-AAA | [#851](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/851) | Backlog |
| DB-ARCH-01.3.3 | Update ARCH-CICD-004 operating guide | [#852](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/852) | Backlog |
| DB-ARCH-01.3.4 | Update training guide and team session agenda | [#853](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/853) | Backlog |
| DB-ARCH-01.3.5 | Update e2e-cicd-diagram.md with PFC triad layer | [#854](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/854) | Backlog |

#### F58.4: Ongoing Governance — [#855](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/855)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-01.4.1 | Drift detection between Azlan-EA-AAA reference and pfc-dev | [#856](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/856) | Backlog |
| DB-ARCH-01.4.2 | Monthly audit process | [#857](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/857) | Backlog |
| DB-ARCH-01.4.3 | Document Azlan-EA-AAA post-separation role | [#858](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/858) | Backlog |

---

### DB-ARCH-02 — Epic 10A: Security MVP — Multi-PFI Foundation

**Issue**: [#127](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/127) | **Priority**: P0 | **Features**: 4 | **Stories**: 14 (0 done)
**Depends on**: Epic 58 (#837)
**PBS**: `PBS/ARCHITECTURE/Security/MVP-Security-VSOM-v1.1.0.md`

#### F10A.1: Supabase Schema & RLS Foundation — [#435](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/435)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-02.1.1 | Create Supabase project and configure environment | [#439](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/439) | Backlog |
| DB-ARCH-02.1.2 | Deploy 5-table schema with constraints | [#440](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/440) | Backlog |
| DB-ARCH-02.1.3 | Deploy RLS policies with role-gated write/delete separation | [#441](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/441) | Backlog |
| DB-ARCH-02.1.4 | Seed PFI instances and verify RLS isolation — **Gate G1** | [#442](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/442) | Backlog |

#### F10A.2: Authentication & User Management — [#436](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/436)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-02.2.1 | Integrate Supabase Auth email provider in visualiser | [#448](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/448) | Backlog |
| DB-ARCH-02.2.2 | Create auto-profile trigger and default role assignment | [#457](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/457) | Backlog |
| DB-ARCH-02.2.3 | Implement PFI assignment flow for admin users | [#458](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/458) | Backlog |
| DB-ARCH-02.2.4 | Build PFI context switcher component | [#459](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/459) | Backlog |

#### F10A.3: PFI-Scoped Ontology Storage — [#437](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/437)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-02.3.1 | Create SupabaseProvider data-store abstraction module | [#460](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/460) | Backlog |
| DB-ARCH-02.3.2 | Replace IndexedDB reads with Supabase PFI-scoped queries | [#461](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/461) | Backlog |
| DB-ARCH-02.3.3 | Implement audit log writes on all ontology mutations | [#462](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/462) | Backlog |

#### F10A.4: Minimal Security UI — [#438](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/438)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-02.4.1 | Build login/logout form with Supabase Auth | [#463](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/463) | Backlog |
| DB-ARCH-02.4.2 | Implement protected routes and role-based access | [#464](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/464) | Backlog |
| DB-ARCH-02.4.3 | Create admin-only audit log viewer page | [#465](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/465) | Backlog |

---

### DB-ARCH-03 — Epic 59: Platform Database Architecture — PFC-PFI Cascade, Per-Stage Isolation & Micro-SaaS Foundation

**Issue**: [#840](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/840) | **Priority**: P0 Critical | **Features**: 9 | **Stories**: 37 (0 done)
**Depends on**: Epic 10A (#127)
**PBS**: `PBS/STRATEGY/BRIEFING-Epic59-DTP-Database-Sync-Micro-SaaS-Strategy.md`

#### F59.1: Supabase Project Provisioning — Phase 1

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.1.1 | Provision 3 PFC Supabase projects (pfc-core-dev, test, prod) | — | Backlog |
| DB-ARCH-03.1.2 | Provision 15 PFI Supabase projects (5 instances x 3 stages) | — | Backlog |
| DB-ARCH-03.1.3 | Document project naming, billing, region strategy | — | Backlog |
| DB-ARCH-03.1.4 | Configure SUPABASE_URL + ANON_KEY + SERVICE_KEY on all 18 repos | — | Backlog |

#### F59.2: Missing Migrations & Full Schema Deployment — Phase 1

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.2.1 | Write migration 003 (pfc_registry + resolve_artifact_config) | — | Backlog |
| DB-ARCH-03.2.2 | Write migration 004 (resolve_cascaded_config — 4-tier cascade) | — | Backlog |
| DB-ARCH-03.2.3 | Deploy migrations 001-005 to all 18 Supabase projects | — | Backlog |
| DB-ARCH-03.2.4 | Validate RLS policies per project with test users per cascade tier | — | Backlog |

#### F59.3: Secrets & Access Resolution — Phase 1

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.3.1 | Create scoped PATs per triad (PFC + per-PFI) | — | Backlog |
| DB-ARCH-03.3.2 | Set PROMOTION_PAT on remaining 3 PFI repos | — | Backlog |
| DB-ARCH-03.3.3 | Verify guard-core.yml blocks human PRs on all PFI repos | — | Backlog |

#### F59.4: PFC DB Promotion Workflow — Phase 2

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.4.1 | Create `promote-db.yml` for PFC triad (dev→test→prod) | — | Backlog |
| DB-ARCH-03.4.2 | Schema dry-run validation (`supabase db push --dry-run`) on test | — | Backlog |
| DB-ARCH-03.4.3 | SME approval gate for test→prod with `needs-sme-approval` label | — | Backlog |
| DB-ARCH-03.4.4 | Cascade resolution integration test suite (all 4 tiers) | — | Backlog |

#### F59.5: PFC→PFI Database Distribution — Phase 2

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.5.1 | Create `pfc-db-release.yml` workflow | — | Backlog |
| DB-ARCH-03.5.2 | Series-subscription filter using `hubSpokeConfig.ontologySeries` | — | Backlog |
| DB-ARCH-03.5.3 | Seed core ontologies from registry → JSONB with `source='pfc-core'` | — | Backlog |
| DB-ARCH-03.5.4 | Seed `pfc_registry` core rows (10 artifact domains) | — | Backlog |
| DB-ARCH-03.5.5 | Validate full cycle: pfc-dev → pfc-test → pfc-prod → BAIV-dev | — | Backlog |

#### F59.6: PFI DB Promotion Template — Phase 3

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.6.1 | Create `promote-db.yml` template for PFI triads | — | Backlog |
| DB-ARCH-03.6.2 | PFI-owned data export (`source != 'pfc-core'` filter) | — | Backlog |
| DB-ARCH-03.6.3 | FK integrity + cascade resolution validation post-promotion | — | Backlog |
| DB-ARCH-03.6.4 | Seed BAIV-dev with VP + RRR + graph scope + brand_config data | — | Backlog |

#### F59.7: PFI Triad Activation — Phase 3

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.7.1 | BAIV full cycle: dev → test → prod (PoC — lead instance) | — | Backlog |
| DB-ARCH-03.7.2 | AIRL full cycle | — | Backlog |
| DB-ARCH-03.7.3 | W4M-WWG full cycle | — | Backlog |
| DB-ARCH-03.7.4 | W4M-EOMS full cycle | — | Backlog |
| DB-ARCH-03.7.5 | VHF full cycle | — | Backlog |

#### F59.8: DB Drift Detection & Governance — Phase 4

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.8.1 | Create `db-drift-detect.yml` cron workflow | — | Backlog |
| DB-ARCH-03.8.2 | Schema diff reporting between stages (per PFC + per PFI) | — | Backlog |
| DB-ARCH-03.8.3 | Auto-create issues on drift detection | — | Backlog |
| DB-ARCH-03.8.4 | DB-inclusive operating guide + runbooks | — | Backlog |
| DB-ARCH-03.8.5 | Sovereignty adaptation docs (Azure/self-hosted per Epic 53) | — | Backlog |

#### F59.9: Cross-Instance Licensing Framework — Phase 5 (Horizon 2)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-03.9.1 | Extend `pfc_registry` for `licensed-pfi-contribution` type | — | Backlog |
| DB-ARCH-03.9.2 | PFI export workflow (source PFI-prod → PFC-prod → target PFI-dev) | — | Backlog |
| DB-ARCH-03.9.3 | FairSlice royalty integration (CONVERGENCE patterns) | — | Backlog |
| DB-ARCH-03.9.4 | First cross-PFI transfer PoC (BAIV VP template → AIRL) | — | Backlog |
| DB-ARCH-03.9.5 | Sovereignty tier licensing rules (Epic 53 alignment) | — | Backlog |

---

### DB-ARCH-04 — Epic 31: Multi-Instance Platform Delivery — Hub-and-Spoke CI/CD Pipeline

**Issue**: [#394](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/394) | **Priority**: P0 | **Features**: 9 | **Stories**: 37 (14 done)
**Depends on**: Epic 59 (#840)
**PBS**: `PBS/ARCHITECTURE/arch-cicd/01-hub-and-spoke-proposal.md`

#### F31.1: PFC-Core Release Workflow — [#400](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/400)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.1.1 | Create `pfc-release.yml` workflow | [#411](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/411) | Backlog |
| DB-ARCH-04.1.2 | Define release archive structure | [#412](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/412) | Backlog |
| DB-ARCH-04.1.3 | Tag first PFC release `pfc-v1.0.0` | [#413](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/413) | Backlog |
| DB-ARCH-04.1.4 | Update GitHub Pages deploy to include release metadata | [#414](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/414) | Backlog |

#### F31.2: Convention Promotion Pipeline — [#406](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/406)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.2.1 | Create `convention-manifest.json` | [#415](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/415) | Backlog |
| DB-ARCH-04.2.2 | Create `promote.yml` workflow | [#416](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/416) | Backlog |
| DB-ARCH-04.2.3 | Create `auto-tag.yml` workflow | [#417](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/417) | Backlog |
| DB-ARCH-04.2.4 | Configure branch protection per tier | [#418](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/418) | Backlog |

#### F31.3: Live Repo Sync & Version Pinning — [#407](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/407)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.3.1 | Create `live-repos.json` registry | [#419](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/419) | Backlog |
| DB-ARCH-04.3.2 | Create `sync-to-live.yml` workflow | [#420](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/420) | Backlog |
| DB-ARCH-04.3.3 | Implement `azlan-workflow-version` pin check | [#421](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/421) | Backlog |
| DB-ARCH-04.3.4 | Create sync PR template with changelog diff | [#422](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/422) | Backlog |

#### F31.4: Bootstrap & Instance Provisioning — [#408](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/408)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.4.1 | Create `bootstrap-triad.sh` | [#423](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/423) | ✅ Done |
| DB-ARCH-04.4.2 | Create instance repo template structure | [#424](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/424) | Backlog |
| DB-ARCH-04.4.3 | Apply labels and project board setup | [#425](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/425) | Backlog |
| DB-ARCH-04.4.4 | Bootstrap BAIV-AIV triad as proof-of-concept | [#426](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/426) | Backlog |

#### F31.5: Drift Detection & Governance — [#409](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/409)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.5.1 | Create `drift-detection.yml` cron workflow | [#427](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/427) | Backlog |
| DB-ARCH-04.5.2 | Implement convention file diff against prod | [#428](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/428) | Backlog |
| DB-ARCH-04.5.3 | Auto-create/update GitHub issues on drift | [#429](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/429) | Backlog |
| DB-ARCH-04.5.4 | Create drift resolution runbook | [#430](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/430) | Backlog |

#### F31.6: Operating Guide & Runbooks — [#410](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/410)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.6.1 | Write operating guide | [#431](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/431) | ✅ Done |
| DB-ARCH-04.6.2 | Write secret management runbook | [#432](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/432) | Backlog |
| DB-ARCH-04.6.3 | Write incident response runbook | [#433](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/433) | Backlog |
| DB-ARCH-04.6.4 | Write onboarding guide for new PFI delivery teams | [#434](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/434) | Backlog |

#### F31.7: CICD-ONT — CI/CD Pipeline & Delivery Ontology — [#585](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/585)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.7.1 | Create `pfc-cicd-v1.0.0-oaa-v6.json` | — | ✅ Done |
| DB-ARCH-04.7.2 | Create `Entry-ONT-CICD-001.json` registry entry | — | ✅ Done |
| DB-ARCH-04.7.3 | Update `ont-registry-index.json` v9.1.0 | — | ✅ Done |
| DB-ARCH-04.7.4 | Validate with visualiser (load + cross-ref resolution) | — | Backlog |

#### ✅ F31.8: CICD-ONT v1.1.0 — OAA Compliance Fix — [#586](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/586)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.8.1 | Fix G2C — Add `filteredBy` and `syncsConventions` relationships | — | ✅ Done |
| DB-ARCH-04.8.2 | Fix G8 — Rename `ownerOrganisation` to `ownedByOrganisation` | — | ✅ Done |
| DB-ARCH-04.8.3 | Update changeControl to v1.1.0, add versionHistory | — | ✅ Done |
| DB-ARCH-04.8.4 | Rename ontology file to v1.1.0, update Entry and registry | — | ✅ Done |

#### ✅ F31.9: Sealed Skill Distribution — Guard-Core & PFC-Release Extension — [#819](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/819)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-04.9.1 | Create `guard-core.yml` CI gate workflow | — | ✅ Done |
| DB-ARCH-04.9.2 | Create `sealed-skills-manifest.json` | — | ✅ Done |
| DB-ARCH-04.9.3 | Create `pfc-core/.claude-plugin/plugin.json` sealed plugin manifest | — | ✅ Done |
| DB-ARCH-04.9.4 | Extend `pfc-release.yml` with sealed skills distribution | — | ✅ Done |
| DB-ARCH-04.9.5 | Extend `bootstrap-triad.sh` with sealed skills + guard-core | — | ✅ Done |

---

### DB-ARCH-05 — Epic 53: Cloud Vendor Sovereignty & Multi-Platform PFI Delivery

**Issue**: [#775](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/775) | **Priority**: P1 | **Features**: 6 | **Stories**: 33 (0 done)
**Depends on**: Epic 59 (#840)
**PBS**: `PBS/STRATEGY/BRIEFING-PFC-EA-Arch-DB-Migrations-Azure-Supabase.md`

#### F53.1: Azure DevOps PFI Bootstrap & Triad Support — [#776](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/776)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-05.1.1 | Create `bootstrap-triad-azure.sh` script | [#782](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/782) | Backlog |
| DB-ARCH-05.1.2 | Azure Boards work item templates (Epic/Feature/Story with EFS) | [#783](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/783) | Backlog |
| DB-ARCH-05.1.3 | Azure Pipeline equivalents (promote, validate, enforce-registry) | [#784](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/784) | Backlog |
| DB-ARCH-05.1.4 | `pfc-release-azure.yml` — Azure Artifacts spoke | [#785](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/785) | Backlog |
| DB-ARCH-05.1.5 | Azure environment approval gates (dev→test→prod) | [#786](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/786) | Backlog |
| DB-ARCH-05.1.6 | PoC — Bootstrap PFI-AIRL on Azure DevOps | [#787](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/787) | Backlog |

#### F53.2: Multi-Provider AI Model Router & Claude Regional — [#777](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/777)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-05.2.1 | Define `aiConfig` schema in PFI config | [#788](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/788) | Backlog |
| DB-ARCH-05.2.2 | Claude via Google Vertex Frankfurt deployment guide | [#789](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/789) | Backlog |
| DB-ARCH-05.2.3 | Claude via AWS Bedrock Frankfurt deployment guide | [#790](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/790) | Backlog |
| DB-ARCH-05.2.4 | Azure OpenAI adapter — function calling translation | [#791](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/791) | Backlog |
| DB-ARCH-05.2.5 | Model router implementation (auto-select based on PFI config) | [#792](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/792) | Backlog |
| DB-ARCH-05.2.6 | Token budget tracking per DELTA cycle | [#793](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/793) | Backlog |

#### F53.3: EFS-ONT Platform Adapter Layer — [#778](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/778)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-05.3.1 | EFS ↔ Azure Boards adapter (`az boards` CLI wrapper) | [#794](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/794) | Backlog |
| DB-ARCH-05.3.2 | EFS ↔ GitHub Issues adapter (formalised) | [#795](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/795) | Backlog |
| DB-ARCH-05.3.3 | EFS ↔ GitLab Issues adapter (`glab` CLI wrapper) | [#796](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/796) | Backlog |
| DB-ARCH-05.3.4 | Adapter interface specification (common CRUD contract) | [#797](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/797) | Backlog |
| DB-ARCH-05.3.5 | Cross-platform hierarchy validation tool | [#798](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/798) | Backlog |

#### F53.4: Data Sovereignty Tier Classification & GRC Alignment — [#779](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/779)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-05.4.1 | Sovereignty tier schema in PFI config (`sovereigntyTier: 0-4`) | [#799](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/799) | Backlog |
| DB-ARCH-05.4.2 | CLOUD Act risk assessment per vendor (GRC-FW-ONT aligned) | [#800](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/800) | Backlog |
| DB-ARCH-05.4.3 | ZDR addendum procurement checklist | [#801](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/801) | Backlog |
| DB-ARCH-05.4.4 | Regulatory reference matrix (UK GDPR, e-evidence, NIS2, DORA) | [#802](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/802) | Backlog |
| DB-ARCH-05.4.5 | Sovereignty audit workflow — validate PFI config against tier | [#803](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/803) | Backlog |

#### F53.5: Sovereign Self-Hosted Stack — Gitea + OSS LLM — [#780](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/780)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-05.5.1 | Gitea deployment playbook (Docker Compose + Actions runner) | [#804](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/804) | Backlog |
| DB-ARCH-05.5.2 | vLLM + Llama 4 / Mistral Large serving guide | [#805](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/805) | Backlog |
| DB-ARCH-05.5.3 | LangChain/LangGraph skill adapter | [#806](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/806) | Backlog |
| DB-ARCH-05.5.4 | Keycloak auth integration (replaces Supabase Auth) | [#807](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/807) | Backlog |
| DB-ARCH-05.5.5 | `bootstrap-triad-sovereign.sh` script | [#808](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/808) | Backlog |
| DB-ARCH-05.5.6 | Quality benchmark — DELTA pipeline on OSS vs Claude Opus | [#809](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/809) | Backlog |

#### F53.6: Enterprise M365 Value-Add Integration — [#781](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/781)

| WBS | Story | Issue | Status |
|-----|-------|-------|--------|
| DB-ARCH-05.6.1 | Power BI BSC dashboard template from VSOM KPI-ONT metrics | [#810](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/810) | Backlog |
| DB-ARCH-05.6.2 | Viva Goals ↔ VSOM-ONT OKR sync specification | [#811](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/811) | Backlog |
| DB-ARCH-05.6.3 | Copilot Studio bot for DELTA output consumption | [#812](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/812) | Backlog |
| DB-ARCH-05.6.4 | SharePoint document library for ontology artefact hosting | [#813](https://github.com/ajrmooreuk/Azlan-EA-AAA/issues/813) | Backlog |

---

## Downstream Consumers (Not In This Programme)

These epics/features are **not blocked** by MS 9.00 and continue independently:

| Epic | What Continues | What's Blocked |
|------|---------------|----------------|
| Epic 8 (#80) Design System | F8.1, F8.3-F8.4, F8.6-F8.15 (all done) | F8.2 (Token Storage), F8.5 (Agentic) → rolled to Epic 61 |
| Epic 61 (#876) DS Maturity | F61.1-F61.4 (Token Gap), F61.7-F61.8 (Slides) | F61.5 (ex-F8.2), F61.6 (ex-F8.5) — blocked by F59.1+F59.2 |
| Epic 45 (#634) W4M-WWG | Instance data authoring in git | DB storage of instance data |
| Epic 49 (#747) VSOM App Planner | Skeleton, nav, zone layout | DB-backed state persistence |

---

## Key Decisions Required

| # | Decision | Affects | Options |
|---|----------|---------|---------|
| 1 | 4-role MVP vs 7-role RBAC | Epic 10A | 4-role (simple) vs 7-role (agents+API) — recommend 4-role with extension points |
| 2 | Supabase-only or AIRL on Azure from Phase 1 | Epic 59 F59.1 | 18 Supabase vs 15 Supabase + 3 Azure PostgreSQL |
| 3 | Git promote triggers DB promote | Epic 31 + 59 | Unified pipeline vs separate pipelines with webhook |
| 4 | Login UI framework | Epic 10A F10A.4 | Vanilla JS (current stack) vs Shadcn micro-components (Epic 8 bridge) |
| 5 | `resolve_token()` alignment | Epic 59 + 61 | Same function signature as `resolve_cascaded_config()` vs separate |

---

*Programme Summary — MS 9.00 Platform Database Architecture & Security Foundation*
*Generated: 2026-03-05 | 5 Epics, 32 Features, 137 Stories*
*Milestone: https://github.com/ajrmooreuk/Azlan-EA-AAA/milestone/11*

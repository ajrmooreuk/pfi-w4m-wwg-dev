# CLAUDE.md — pfi-w4m-wwg-dev

## Project Overview

W4M-WWG PFI instance dev repo — **World Wide Global** supply chain and logistics platform. Part of the W4M-WWG triad (dev/test/prod). W4M-WWG is a PFC-owner PFI instance with full cross-PFI visibility.

**PFI Instance ID:** PFI-W4M-WWG
**PFI Class:** pfc-owner
**Parent Platform:** PFC (Azlan-EA-AAA)

## Directory Structure

```
.github/                    <- CI/CD workflows (doc naming, label validation, promotion)
PBS/                        <- Programme Breakdown Structure — strategy docs
azlan-github-workflow/      <- Skills distributed from PFC via pfc-release.yml
instance-data/              <- PFI instance configuration (EMC, DS-ONT, domain ontologies)
pfc-core/                   <- Sealed PFC core assets — DO NOT EDIT
pfc-docs/                   <- PFC-distributed documentation
promotion/                  <- Promotion config (dev → test → prod)
scripts/                    <- Utility scripts
supabase/                   <- Supabase migrations and seed data
tools/                      <- Local tooling
```

## Instance Ontologies

| Ontology | Version | Purpose |
|---|---|---|
| LSC-ONT | v1.0.0 | Logistics Supply Chain — corridors, routes, shipments |
| OFM-ONT | v1.0.0 | Order Fulfilment Management — orders, SLAs, fulfilment |
| DS-ONT (WWG instance) | v1.0.0 | WWG brand design system tokens |

## Naming Conventions

**Mandatory for all new `.md` files in `PBS/STRATEGY/`:**
```
PFI-WWG-[PRODUCT]-[DOC-TYPE]-<Subject>-v<version>.md
```

### Tier
- **PFI-WWG** — this is a PFI repo. `PFC-` prefix is BLOCKED for new files.

### Product Codes
| Code | Domain |
|---|---|
| STRAT | General strategy |
| ARCH | Architecture, ontology |
| DSY | Design system, skeleton, UI |
| VE | Value engineering |
| LSC | Logistics supply chain |
| OFM | Order fulfilment management |
| SEC | Security |
| CICD | CI/CD pipelines |

### Doc Types
`ARCH` | `OPS` | `REL` | `BRIEF` | `STD` | `PLAN` | `GUIDE` | `SPEC` | `TEST` | `IDX`

## Key Files

| File | Purpose |
|---|---|
| `instance-data/` | EMC instance config, DS-ONT brand tokens, LSC/OFM instances |
| `pfc-core/ontology-registry.json` | Sealed PFC ontology registry (DO NOT EDIT) |
| `promotion/promotion.env` | Promotion pipeline configuration |

## CI/CD

- `validate-doc-naming.yml` — blocks PRs with non-compliant `.md` files
- PFC- prefix is blocked (tier-aware enforcement)
- Promotion: dev → test → prod via `promote.yml` (manual trigger)

## Related Repos

| Repo | Purpose |
|---|---|
| `ajrmooreuk/Azlan-EA-AAA` | Hub — source of truth for ontologies, workflows, standards |
| `ajrmooreuk/pfi-w4m-wwg-test` | WWG test triad |
| `ajrmooreuk/pfi-w4m-wwg-prod` | WWG prod triad |

## Status

- Active development
- PFC-owner PFI with full cross-PFI visibility
- LSC-ONT + OFM-ONT domain ontologies active

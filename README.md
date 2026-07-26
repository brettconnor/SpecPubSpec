<!-- GENERATED FILE: do not edit directly. -->
<!-- Source of truth: docs/seed-doc.md -->
<!-- Regenerate with: scripts/sync-readme.sh -->
<!-- Repository orientation, build, and contribution instructions: QUICKSTART.md -->

# Agentic Specification Publication Specification

Version: 0.1.0.
Status: Standard.
Date: 2026-07-26.

## Abstract

This document specifies the Agentic Specification Publication Specification (SpecPubSpec), a repository pattern for publishing specifications that are simultaneously machine-readable by coding agents and human-browsable as rendered documentation.
A SpecPubSpec-conformant repository has exactly one canonical source of truth and prevents content drift between source and site.

## Conformance

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).
A repository conforms to this specification only if it satisfies REQ-001 through REQ-035 and passes the validation contract in section 6.

---

## Core

### Purpose

SpecPubSpec defines a dual-purpose repository model in which the same canonical markdown source serves agents and humans.

### Principles

1. Single source of truth: canonical documents exist once and are rendered without duplication.
2. Dual-purpose delivery: source is directly agent-readable and site-rendered for humans.
3. Self-hosting: the repository contains all artifacts required to build and publish rendered output.
4. Atomic publication: validation failures block publication completely.
5. Agent-first authoring: canonical markdown follows deterministic formatting rules defined in AGENTS.md.

## Normative Requirements

### Canonical Document

REQ-001: The repository MUST contain a file at path `docs/seed-doc.md`. Enforced by: `scripts/validate-structure.sh`.

REQ-002: The canonical document MUST NOT be a symbolic link. Enforced by: `scripts/validate-structure.sh`.

### Content Unification

REQ-003: The `site/` generation directory MUST NOT contain copies of canonical documents; the directories `site/content/` and `site/docs/` MUST NOT exist. Enforced by: `scripts/validate-structure.sh` (existence checks) and `scripts/audit-repo.sh` (reverse accounting for any other duplicate).

### Repository Metadata

REQ-004: The repository MUST contain `AGENTS.md` at repository root. Enforced by: `scripts/validate-structure.sh`.

REQ-005: The repository MUST contain `README.md` at repository root. Enforced by: `scripts/validate-structure.sh`.

### Static Site Generation

REQ-006: `site/lib/content.ts` MUST exist and define `CANONICAL_SOURCE_PATHS`. Enforced by: `scripts/validate-structure.sh`.

REQ-007: `CANONICAL_SOURCE_PATHS` MUST reference `docs/seed-doc.md`. Rationale: combined with REQ-006, this is how the site generator reads canonical documents directly from repository paths at build time rather than from a copy. Enforced by: `scripts/validate-structure.sh`.

### Site Generator Core Artifacts

REQ-008: The repository MUST contain `site/package.json` defining a `build` script. Enforced by: `scripts/validate-structure.sh` (existence only; REQ-019 verifies the script's content-validation ordering).

REQ-009: The repository MUST contain `site/next.config.mjs` and `site/tsconfig.json` configuring the site generator. Enforced by: `scripts/validate-structure.sh`.

REQ-010: The repository MUST contain `site/app/layout.tsx`, `site/app/page.tsx`, and `site/app/globals.css` implementing the root route that renders the canonical document; `layout.tsx` MUST import `globals.css`. Enforced by: `scripts/validate-structure.sh`.

REQ-011: The repository MUST contain `site/components/MarkdownPage.tsx` and `site/components/DownloadButton.tsx`, both imported by `site/app/page.tsx`. Rationale: renders and offers download of the canonical document. Enforced by: `scripts/validate-structure.sh`.

REQ-012: The repository MUST contain `site/app/favicon.ico`. Rationale: serves the root route's browser tab icon. Enforced by: `scripts/validate-structure.sh` (existence only).

### Continuous Integration Dependencies

REQ-013: The repository MUST contain `site/package-lock.json`. Rationale: CI installs dependencies via `npm ci`, which requires an exact lockfile. Enforced by: `scripts/validate-structure.sh` (existence only).

REQ-014: The repository MUST contain `site/scripts/check-links.mjs`. Rationale: invoked by the pull-request build-check workflow to fail on broken internal cross-references between rendered pages. Enforced by: `scripts/validate-structure.sh` (existence only).

REQ-015: The repository MUST contain `site/.eslintrc.json`. Rationale: `next build` runs its own lint pass and fails on any violation of the rules this file configures; without it, that lint pass is silently skipped rather than falling back to a default rule set, degrading CI without signal. Enforced by: `scripts/validate-structure.sh` (existence only).

### Required Directories

REQ-016: The repository MUST contain the directories `docs/`, `site/`, `site/lib/`, `site/scripts/`, `.github/`, `.github/workflows/`, `scripts/`, `site/app/`, and `site/components/`. Rationale: each directory houses one or more files already mandated elsewhere in this section (see the Required Paths table below for the exact file-to-REQ mapping); this REQ additionally asserts each directory's own existence, rather than leaving it implied by its files. Enforced by: `scripts/validate-structure.sh`.

### Repository-Wide Accounting

REQ-017: The repository MUST contain `scripts/audit-repo.sh`, MUST be executable, and MUST fail (non-zero exit) if any file or directory on disk is not either listed in `scripts/validate-structure.sh`'s `REQUIRED_FILES`/`REQUIRED_DIRS` arrays or explicitly exempted as out-of-scope repo hygiene; `.github/workflows/governance-check.yml` MUST invoke it. Rationale: this is the reverse check of the REQ items above — those ask "does every required path exist?", this asks "does every existing path have a reason to be there?" — and is what actually catches an accidental duplicate canonical document stored in a parallel location, since no independent content-diffing check exists. Enforced by: `scripts/audit-repo.sh` (self) and `.github/workflows/governance-check.yml`.

### Content Validation

REQ-018: `site/scripts/validate-content.mjs` MUST exist. Enforced by: `scripts/validate-structure.sh` (existence only).

REQ-019: Content validation MUST execute before site generation; `site/package.json`'s `build` script MUST invoke `validate-content.mjs` (or an equivalent content-validation step) before `next build` runs, not merely define a `build` script that happens to exist. Enforced by: `scripts/validate-structure.sh` (extracts the `build` script's value and checks ordering).

REQ-020: Build MUST fail if a canonical document is missing or malformed. Rationale: this is a build-time content guarantee, distinct from the structural existence checks elsewhere in this section. Enforced by: `site/scripts/validate-content.mjs`, exercised when CI runs `npm run build` — not `scripts/validate-structure.sh`, which per REQ-019 only checks that `validate-content.mjs` runs before `next build`, not what it decides.

REQ-021: `scripts/validate-structure.sh` MUST exist and be executable. Enforced by: `.github/workflows/governance-check.yml` invoking it (REQ-035).

### Continuous Integration

REQ-022: `.github/workflows/publish-site.yml` MUST exist. Enforced by: `scripts/validate-structure.sh` (existence only).

REQ-023: Publish workflow MUST trigger on pushes to the `main` branch and deploy via a build-then-deploy job sequence. Enforced by: `scripts/validate-structure.sh`.

REQ-024: `.github/workflows/site-build-check.yml` MUST exist. Enforced by: `scripts/validate-structure.sh` (existence only).

REQ-025: Build-check workflow MUST trigger on `pull_request` and MUST NOT contain a deployment step. Enforced by: `scripts/validate-structure.sh`.

### Document Structure

REQ-026: This canonical document MUST contain a section titled `## Core`. Enforced by: `scripts/validate-structure.sh`.

REQ-027: This canonical document MUST contain a section titled `## Repository Structure`. Enforced by: `scripts/validate-structure.sh`.

REQ-028: This canonical document MUST contain a section titled `## Version`. Enforced by: `scripts/validate-structure.sh`.

REQ-029: `AGENTS.md` MUST contain a section titled `## Repository Map`. Enforced by: `scripts/validate-structure.sh`.

REQ-030: `AGENTS.md` MUST contain a section titled `## Markdown Authoring Rules`. Enforced by: `scripts/validate-structure.sh`.

### Repository Orientation

REQ-031: `QUICKSTART.md` MUST contain a section titled `## Bootstrapping Your Own Spec`, documenting how an operator forking this repo replaces the canonical content, decides whether to rename the required section headers for their domain (and updates `scripts/validate-structure.sh` accordingly if so), sets code review ownership, confirms the default branch, enables GitHub Pages, and validates conformance before publishing their own specification. Rationale: this section serves the role of a traditional README.md for forking operators, since REQ-032 constrains `README.md` itself to be a mechanical mirror rather than free-form prose. Enforced by: `scripts/validate-structure.sh` (section-title check only; the guidance's content is not independently verified).

### README Mirror Invariant

REQ-032: `README.md` MUST be generated as a byte-for-byte mirror of `docs/seed-doc.md` and MUST NOT be hand-edited. Enforced by: `scripts/validate-structure.sh`, which fails the workflow run in continuous integration if drift is detected.

REQ-033: `scripts/sync-readme.sh` MUST exist, MUST be executable, and MUST support a `--target-path` option for drift-checking without overwriting the checked-in `README.md`. Enforced by: `scripts/validate-structure.sh` (existence/executable check); REQ-032's drift check depends on the `--target-path` option.

### Governance Enforcement

REQ-034: The repository MUST contain `.github/CODEOWNERS` containing at least one non-comment ownership rule requiring review of governed artifacts. Enforced by: `scripts/validate-structure.sh`.

REQ-035: `.github/workflows/governance-check.yml` MUST exist and MUST invoke `scripts/validate-structure.sh` on both `push` and `pull_request` triggers. Rationale: so this specification's own conformance is dogfooded by CI rather than left to manual review. Enforced by: `scripts/validate-structure.sh` (checks the workflow file's own invocation and triggers).

---

## Repository Structure

### Required Paths

The following paths are REQUIRED for conformance. Each path's normative requirement (and its enforcement mechanism) is stated in its own REQ in Normative Requirements above.

```
.github/                                Governance root
.github/CODEOWNERS                      Review ownership
.github/workflows/                      CI workflows
.github/workflows/governance-check.yml  Governance CI self-check
.github/workflows/publish-site.yml      Publish workflow
.github/workflows/site-build-check.yml  PR build check
AGENTS.md                               Repo map, authoring rules
QUICKSTART.md                           Orientation & build guide
README.md                               Generated seed-doc mirror
docs/                                   Canonical doc directory
docs/seed-doc.md                        Canonical specification
scripts/                                Conformance scripts
scripts/audit-repo.sh                   Reverse-accounting audit
scripts/sync-readme.sh                  Regenerates README.md
scripts/validate-structure.sh           Structure validation
site/                                   Site generator root
site/.eslintrc.json                     Build lint-gate config
site/app/                               Next.js app router
site/app/favicon.ico                    Browser tab icon
site/app/globals.css                    Root route styles
site/app/layout.tsx                     Root route layout
site/app/page.tsx                       Root route page
site/components/                        Rendering components
site/components/DownloadButton.tsx      Doc download button
site/components/MarkdownPage.tsx        Doc renderer
site/lib/                               Doc loader directory
site/lib/content.ts                     Canonical doc loader
site/next.config.mjs                    Site generator config
site/package-lock.json                  Exact dependency lockfile
site/package.json                       Build/lint/dev scripts
site/scripts/                           Build/validation scripts
site/scripts/check-links.mjs            Broken link check
site/scripts/validate-content.mjs       Pre-build content check
site/tsconfig.json                      Site generator config
```

---

## Validation

A repository claiming SpecPubSpec conformance MUST pass the following check.

```bash
bash scripts/validate-structure.sh
echo $?  # MUST output 0
```

A non-zero exit code is non-conformance.

Conformance also requires a zero-diff comparison between the checked-in `README.md` and the output of `scripts/sync-readme.sh --target-path <tmp-file>` (REQ-032, REQ-033). A non-empty diff is non-conformance.

---

## Terminology

Agent: An autonomous coding system that reads and applies repository specifications.

Atomic publication: A publish model where partial deployment is impossible.

Canonical document: The single authoritative specification file at `docs/seed-doc.md`.

Conformant repository: A repository that satisfies REQ-001 through REQ-035 and passes section 6 validation.

Dual-purpose repository: A repository that serves machine-readable source and human-rendered documentation from one source.

README mirror: The invariant that `README.md` is a byte-for-byte regenerated copy of `docs/seed-doc.md`, produced by `scripts/sync-readme.sh` and never hand-edited.

---

## Version

This specification follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html); see the Version line at the top of this document and the history table below for the current version.
This section intentionally does not restate the version number, to avoid the two ever drifting apart.

| Version | Date | Change |
|---|---|---|
| 0.1.0 | 2026-07-26 | Initial release |

Version policy.
MAJOR increments change conformance semantics.
MINOR increments add backward-compatible requirements or clarifications.
PATCH increments fix wording or defects without changing conformance semantics.

---

End of specification.

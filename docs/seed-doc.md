# Agentic Specification Publication Specification

Version: 5.0.0.
Status: Standard.
Date: 2026-07-25.

## Abstract

This document specifies the Agentic Specification Publication Specification (SpecPubSpec), a repository pattern for publishing specifications that are simultaneously machine-readable by coding agents and human-browsable as rendered documentation.
A SpecPubSpec-conformant repository has exactly one canonical source of truth and prevents content drift between source and site.

## Conformance

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).
A repository conforms to this specification only if it satisfies REQ-001 through REQ-036 and passes the validation contract in section 6.

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

REQ-001: The repository MUST contain a file at path `docs/seed-doc.md`.

REQ-002: The canonical document MUST NOT be a symbolic link.

### Content Unification

REQ-003: The `site/` generation directory MUST NOT contain copies of canonical documents; the directories `site/content/` and `site/docs/` MUST NOT exist.

### Repository Metadata

REQ-004: The repository MUST contain `AGENTS.md` at repository root.

REQ-005: The repository MUST contain `README.md` at repository root.

### Static Site Generation

REQ-006: `site/lib/content.ts` MUST exist and define `CANONICAL_SOURCE_PATHS`.

REQ-007: `CANONICAL_SOURCE_PATHS` MUST reference `docs/seed-doc.md`. Combined with REQ-006, this is how the site generator reads canonical documents directly from repository paths at build time rather than from a copy.

### Site Generator Core Artifacts

REQ-008: The repository MUST contain `site/package.json` defining a `build` script that runs content validation before `next build`.

REQ-009: The repository MUST contain `site/next.config.mjs` and `site/tsconfig.json` configuring the site generator.

REQ-010: The repository MUST contain `site/app/layout.tsx`, `site/app/page.tsx`, and `site/app/globals.css` implementing the root route that renders the canonical document; `layout.tsx` MUST import `globals.css`.

REQ-011: The repository MUST contain `site/components/MarkdownPage.tsx` and `site/components/DownloadButton.tsx`, both imported by `site/app/page.tsx`, to render and offer download of the canonical document.

REQ-012: The repository MUST contain `site/app/favicon.ico`, serving the root route's browser tab icon.

### Continuous Integration Dependencies

REQ-013: The repository MUST contain `site/package-lock.json`, since CI installs dependencies via `npm ci`, which requires an exact lockfile.

REQ-014: The repository MUST contain `site/scripts/check-links.mjs`, invoked by the pull-request build-check workflow to fail on broken internal cross-references between rendered pages.

REQ-015: The repository MUST contain `site/.eslintrc.json`. `next build` runs its own lint pass and fails the build on any violation of the rules this file configures; without this file present, that lint pass is silently skipped rather than falling back to a default rule set, so its absence would degrade CI without signal.

### Required Directories

REQ-016: The repository MUST contain the directories `docs/`, `site/`, `site/lib/`, `site/scripts/`, `.github/`, `.github/workflows/`, `scripts/`, `site/app/`, and `site/components/`. The latter three (`scripts/`, `site/app/`, `site/components/`) house the files already mandated by REQ-010, REQ-011, REQ-012, REQ-017, and REQ-033; the rest each house exactly one other REQUIRED_FILES entry (`docs/seed-doc.md`, `site/package.json`, `site/lib/content.ts`, `site/scripts/validate-content.mjs`, `.github/CODEOWNERS`, `.github/workflows/publish-site.yml`, respectively) and are asserted directly here rather than left implied by those files' existence.

### Repository-Wide Accounting

REQ-017: The repository MUST contain `scripts/audit-repo.sh`, MUST be executable, and MUST fail (non-zero exit) if any file or directory on disk is not either listed in `scripts/validate-structure.sh`'s `REQUIRED_FILES`/`REQUIRED_DIRS` arrays or explicitly exempted as out-of-scope repo hygiene; `.github/workflows/governance-check.yml` MUST invoke it. This is the reverse check of the REQ items above: those ask "does every required path exist?", this asks "does every existing path have a reason to be there?".

### Validation

REQ-018: `site/scripts/validate-content.mjs` MUST exist.

REQ-019: Content validation MUST execute before site generation; `site/package.json`'s `build` script MUST invoke `validate-content.mjs` (or an equivalent content-validation step) before `next build` runs, not merely define a `build` script that happens to exist.

REQ-020: Build MUST fail if a canonical document is missing or malformed. This is enforced by `site/scripts/validate-content.mjs` (REQ-018) actually running and exiting non-zero at build time — verified when CI executes `npm run build` — not by `scripts/validate-structure.sh`, which only checks that `validate-content.mjs` exists and runs before `next build` (REQ-019), not what it decides.

REQ-021: `scripts/validate-structure.sh` MUST exist and be executable.

### Continuous Integration

REQ-022: `.github/workflows/publish-site.yml` MUST exist.

REQ-023: Publish workflow MUST trigger on pushes to the `main` branch and deploy via a build-then-deploy job sequence.

REQ-024: `.github/workflows/site-build-check.yml` MUST exist.

REQ-025: Build-check workflow MUST trigger on `pull_request` and MUST NOT contain a deployment step.

### Document Structure

REQ-026: This canonical document MUST contain a section titled `## Core`.

REQ-027: This canonical document MUST contain a section titled `## Repository Structure`.

REQ-028: This canonical document MUST contain a section titled `## Version`.

REQ-029: `AGENTS.md` MUST contain a section titled `## Repository Map`.

REQ-030: `AGENTS.md` MUST contain a section titled `## Markdown Authoring Rules`.

### Repository Orientation

REQ-031: `QUICKSTART.md` MUST contain a section titled `## Bootstrapping Your Own Spec`, documenting how an operator forking this repo replaces the canonical content, decides whether to rename the required section headers for their domain (and updates `scripts/validate-structure.sh` accordingly if so), sets code review ownership, confirms the default branch, enables GitHub Pages, and validates conformance before publishing their own specification.

### README Mirror Invariant

REQ-032: `README.md` MUST be generated as a byte-for-byte mirror of `docs/seed-doc.md` and MUST NOT be hand-edited.

REQ-033: `scripts/sync-readme.sh` MUST exist, MUST be executable, and MUST support a `--target-path` option for drift-checking without overwriting the checked-in `README.md`.

REQ-034: Continuous integration MUST verify `README.md` has zero drift from `docs/seed-doc.md` and MUST fail the workflow run if drift is detected.

### Governance Enforcement

REQ-035: The repository MUST contain `.github/CODEOWNERS` containing at least one non-comment ownership rule requiring review of governed artifacts.

REQ-036: `.github/workflows/governance-check.yml` MUST exist and MUST invoke `scripts/validate-structure.sh` on both `push` and `pull_request` triggers, so this specification's own conformance is dogfooded by CI rather than left to manual review.

---

## Repository Structure

### Required Paths

The following paths are REQUIRED for conformance.

| Path | Purpose | Requirement Links |
|---|---|---|
| `docs/seed-doc.md` | Canonical specification document | REQ-001, REQ-002, REQ-026, REQ-027, REQ-028 |
| `AGENTS.md` | Repository map and authoring rules | REQ-004, REQ-029, REQ-030 |
| `README.md` | Repository entry point; generated mirror of the canonical document | REQ-005, REQ-032 |
| `site/lib/content.ts` | Canonical document loader | REQ-006, REQ-007 |
| `site/scripts/validate-content.mjs` | Pre-build content validation | REQ-018, REQ-019, REQ-020 |
| `scripts/validate-structure.sh` | Structure conformance validation | REQ-021 |
| `.github/workflows/publish-site.yml` | Publish workflow | REQ-022, REQ-023 |
| `.github/workflows/site-build-check.yml` | Pull-request build workflow | REQ-024, REQ-025 |
| `QUICKSTART.md` | Repository orientation, build, and contribution guide | REQ-031 |
| `scripts/sync-readme.sh` | Regenerates README.md as a mirror of docs/seed-doc.md | REQ-032, REQ-033 |
| `.github/CODEOWNERS` | Review ownership of governed artifacts | REQ-035 |
| `.github/workflows/governance-check.yml` | Dogfoods this specification's own conformance in CI | REQ-036 |
| `site/package.json` | Site build/lint/dev script definitions | REQ-008, REQ-019 |
| `site/next.config.mjs`, `site/tsconfig.json` | Site generator configuration | REQ-009 |
| `site/app/layout.tsx`, `site/app/page.tsx`, `site/app/globals.css` | Root route rendering the canonical document | REQ-010 |
| `site/components/MarkdownPage.tsx`, `site/components/DownloadButton.tsx` | Canonical document rendering and download components | REQ-011 |
| `site/app/favicon.ico` | Root route browser tab icon | REQ-012 |
| `site/package-lock.json` | Exact dependency lockfile required by CI's `npm ci` | REQ-013 |
| `site/scripts/check-links.mjs` | Broken internal link check in PR build-check workflow | REQ-014 |
| `site/.eslintrc.json` | `next build`'s lint-gate configuration | REQ-015 |
| `scripts/audit-repo.sh` | Reverse-accounting audit: every on-disk path has a reason to exist | REQ-017 |
| `docs/` | Canonical document directory | REQ-016 |
| `site/` | Site generator root | REQ-016 |
| `site/lib/` | Canonical document loader directory | REQ-016 |
| `site/scripts/` | Site build/validation script directory | REQ-016 |
| `.github/` | Repository governance root | REQ-016 |
| `.github/workflows/` | CI workflow directory | REQ-016 |
| `scripts/` | Repository conformance script directory | REQ-016 |
| `site/app/` | Next.js app router directory | REQ-016 |
| `site/components/` | Site rendering component directory | REQ-016 |

### Forbidden Patterns

1. Creating `site/content/` or `site/docs/`.
2. Using symbolic links for canonical documents.
3. Storing duplicate canonical content in parallel locations. Not independently checked by content-diffing; enforced as a side effect of REQ-017's exhaustive reverse-accounting audit, which fails on any on-disk path — including an accidental duplicate — that isn't a `REQUIRED_FILES`/`REQUIRED_DIRS` entry or an explicit `EXEMPT_PATHS` exemption.
4. Hand-editing `README.md` instead of regenerating it via `scripts/sync-readme.sh`.

---

## Validation

Validation enforces structural and publication conformance.
`site/scripts/validate-content.mjs` enforces REQ-018 through REQ-020.
`scripts/validate-structure.sh` enforces repository requirements and forbidden patterns.

### Validation Contract

A repository claiming SpecPubSpec conformance MUST pass the following check.

```bash
bash scripts/validate-structure.sh
echo $?  # MUST output 0
```

A non-zero exit code is non-conformance.

`scripts/sync-readme.sh` enforces REQ-032 through REQ-034 by regenerating `README.md` from `docs/seed-doc.md`.
Conformance also requires a zero-diff comparison between the checked-in `README.md` and the output of `scripts/sync-readme.sh --target-path <tmp-file>`.
A non-empty diff is non-conformance.

### CI Execution Rules

1. Publish workflow MUST run content validation and build before deploy.
2. Build-check workflow MUST run validation and build on pull requests.
3. Any validation failure MUST fail the workflow run.
4. Any workflow validating conformance MUST fail the run if `README.md` has drifted from `docs/seed-doc.md`.

---

## Terminology

Agent: An autonomous coding system that reads and applies repository specifications.
Canonical document: The single authoritative specification file at `docs/seed-doc.md`.
Dual-purpose repository: A repository that serves machine-readable source and human-rendered documentation from one source.
Conformant repository: A repository that satisfies REQ-001 through REQ-036 and passes section 6 validation.
README mirror: The invariant that `README.md` is a byte-for-byte regenerated copy of `docs/seed-doc.md`, produced by `scripts/sync-readme.sh` and never hand-edited.
Atomic publication: A publish model where partial deployment is impossible.

---

## Version

This specification follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html); see the Version line at the top of this document and the history table below for the current version.
This section intentionally does not restate the version number, to avoid the two ever drifting apart.

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2026-07-24 | Initial SpecPubSpec release with normative requirement set REQ-001 through REQ-027 and executable validation contract |
| 1.1.0 | 2026-07-24 | Added REQ-028 through REQ-031, formalizing QUICKSTART.md, the README.md generated-mirror invariant, and scripts/sync-readme.sh as required conformance artifacts |
| 1.2.0 | 2026-07-25 | Added REQ-032 and REQ-033, formalizing .github/CODEOWNERS and CI-enforced dogfooding of this specification's own conformance as required artifacts |
| 2.0.0 | 2026-07-25 | Relocated the structure-validation script from site/scripts/validate-structure.sh to scripts/validate-structure.sh (REQ-017, REQ-033), changing conformance semantics for the mandated path |
| 2.1.0 | 2026-07-25 | Added REQ-034 through REQ-037, formalizing the Next.js site generator's own build-critical artifacts (package.json, next.config.mjs, tsconfig.json, app/layout.tsx, app/page.tsx, app/globals.css, and the MarkdownPage/DownloadButton components) as required conformance artifacts |
| 2.2.0 | 2026-07-25 | Added REQ-038 and REQ-039, formalizing site/package-lock.json (required by CI's npm ci) and site/scripts/check-links.mjs (invoked by the PR build-check workflow) as required conformance artifacts |
| 2.3.0 | 2026-07-25 | Added REQ-040, formalizing site/app/favicon.ico as a required conformance artifact; removed the orphaned site/README.md in favor of QUICKSTART.md's existing Website section, which already documented the same build/preview workflow |
| 2.4.0 | 2026-07-25 | Added REQ-041, formalizing site/.eslintrc.json as a required conformance artifact (its absence silently disables next build's lint gate rather than falling back to defaults); removed the orphaned site/.prettierrc.json, site/.prettierignore, and the prettier/eslint-config-prettier devDependencies and eslintrc extends entry that referenced them, none of which were ever wired into any script or CI step |
| 2.5.0 | 2026-07-25 | Added REQ-042, formalizing scripts/, site/app/, and site/components/ as required directories in validate-structure.sh's own REQUIRED_DIRS check, closing a redundant-but-real gap where these directories' existence was only ever implied by their required files, never asserted directly |
| 2.6.0 | 2026-07-25 | Added REQ-043, formalizing QUICKSTART.md's new Bootstrapping Your Own Spec section (including guidance on renaming seed-doc.md's required section headers for a new domain, and updating validate-structure.sh's matching check if so) as a required conformance artifact; removed a stray timestamped branch name from publish-site.yml's push trigger and annotated .github/CODEOWNERS to prompt forking operators to replace the owner handle |
| 2.7.0 | 2026-07-25 | Added REQ-044, formalizing scripts/audit-repo.sh as a required, executable, governance-check.yml-invoked conformance artifact that fails if any file/directory on disk is not accounted for in validate-structure.sh's REQUIRED_FILES/REQUIRED_DIRS or explicitly exempted as repo hygiene, closing the loop opened by REQ-001 through REQ-042's forward existence checks with a reverse accounting check |
| 3.0.0 | 2026-07-25 | Post-completion audit of the requirement set: renumbered REQ-001 through REQ-044 to REQ-001 through REQ-038 in strict document reading order (numbers had drifted to reflect the chronological order requirements were added rather than where they appear in the document); removed REQ-002 ("sole canonical document"), old REQ-005 ("generator reads directly at build time"), old REQ-008 ("AGENTS.md documents structure and rules"), and old REQ-010/REQ-011 (generic "site/ includes a generator"/"renders without manual copying") as non-normative restatements of Principles with no independent enforcement; merged old REQ-004 and REQ-006 into one REQ-003 covering both the general no-copies rule and its concrete forbidden-directory check; dropped README.md's unenforceable "describing the dual-purpose model" clause (old REQ-009, now REQ-005) since that's automatically satisfied by the README-mirror invariant; added real validate-structure.sh checks for REQ-019 (build script must invoke content validation before next build, not merely exist), REQ-024/REQ-026 (publish-site.yml push-to-main trigger and site-build-check.yml pull_request-trigger-without-deploy content checks), and REQ-037 (CODEOWNERS must contain at least one non-comment ownership rule); fixed old REQ-042 (now REQ-016)'s stale cross-reference, which predated and omitted scripts/audit-repo.sh even though that file also lives in scripts/; reworded REQ-017's reverse-check description to reference "the REQ items above" instead of a hardcoded numeric range, so it can no longer go stale as REQs are added or removed. This is a MAJOR change: every externally-cited REQ-NNN identifier's meaning shifted |
| 3.0.1 | 2026-07-25 | Formatting fix: inserted a blank line between every consecutive REQ-NNN line in the Normative Requirements section. Consecutive lines with no blank line between them collapse into a single run-on paragraph under CommonMark (the site's rendering pipeline), making the rendered page hard for a human to scan; each REQ now renders as its own paragraph. No wording, numbering, or conformance semantics changed |
| 3.1.0 | 2026-07-25 | Tightened residual testability gaps found in a follow-up review of the Repository Structure section: widened REQ-016 to assert all 9 REQUIRED_DIRS directories directly (6 of the 9 were previously enforced by validate-structure.sh but never stated as a MUST by any REQ) and added their rows to the Required Paths table; added a validate-structure.sh check that publish-site.yml's deploy job actually declares `needs: build` (REQ-024's "build-then-deploy job sequence" claim was previously untested); reworded REQ-020 and REQ-022 to name their actual enforcement point (validate-content.mjs at build time; the script's own self-referential exit-code contract, respectively) instead of implying scripts/validate-structure.sh checks them directly; reworded Forbidden Pattern 3 to document that it's enforced indirectly by REQ-017's exhaustive reverse-accounting audit rather than by independent duplicate-content detection. No REQ was renumbered or removed; this is a MINOR change (added/clarified enforcement, no new required repository state) |
| 4.0.0 | 2026-07-25 | Removed old REQ-022 ("structure validation MUST return exit code 0 on conformance and non-zero on violation"): on review, this REQ is not independently, deterministically dogfoodable — it is scripts/validate-structure.sh's own self-referential contract, restated (and already normatively stated) verbatim by the Validation Contract's `echo $?  # MUST output 0` block in section 6, with nothing external to check it against. A requirement this specification cannot verify about itself is out of scope for the REQ set. Renumbered old REQ-023 through REQ-038 down to REQ-022 through REQ-037 to close the gap. This is a MAJOR change: every REQ-NNN identifier from old REQ-023 onward shifted down by one |
| 5.0.0 | 2026-07-25 | Removed old REQ-031 ("the repository MUST contain QUICKSTART.md at repository root documenting repository orientation, build instructions, and contribution guidance"): its file-existence claim was already redundant with QUICKSTART.md's entry in validate-structure.sh's REQUIRED_FILES array, and its "documenting orientation, build instructions, and contribution guidance" clause was never content-checked by any script — an untestable prose restatement of the same non-normative pattern removed in 3.0.0. Its concrete, testable successor, old REQ-032 (QUICKSTART.md MUST contain a `## Bootstrapping Your Own Spec` section, which validate-structure.sh does grep for), already subsumes it. Renumbered old REQ-032 through REQ-037 down to REQ-031 through REQ-036 to close the gap. This is a MAJOR change: every REQ-NNN identifier from old REQ-032 onward shifted down by one |

Version policy.
MAJOR increments change conformance semantics.
MINOR increments add backward-compatible requirements or clarifications.
PATCH increments fix wording or defects without changing conformance semantics.

---

End of specification.

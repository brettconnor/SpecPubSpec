# Agentic Specification Publication Specification

Version: 6.2.1.
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
| 6.0.0 | 2026-07-25 | Merged old REQ-032 ("README.md MUST be generated as a byte-for-byte mirror of docs/seed-doc.md and MUST NOT be hand-edited") and old REQ-034 ("continuous integration MUST verify README.md has zero drift from docs/seed-doc.md and MUST fail the workflow run if drift is detected") into one requirement: both were enforced by the exact same drift-check code in scripts/validate-structure.sh, making them duplicate REQ numbers for a single check rather than two independently testable requirements. New REQ-032 states the mirror invariant and its CI-enforcement in one sentence. Renumbered old REQ-033 (sync-readme.sh script requirement) to REQ-033 (unchanged position, now directly following the merged REQ-032), and old REQ-035/REQ-036 (CODEOWNERS, governance-check.yml) down to REQ-034/REQ-035. This is a MAJOR change: every REQ-NNN identifier from old REQ-034 onward shifted down by one, and old REQ-034 no longer exists as a separate identifier |
| 6.0.1 | 2026-07-25 | Full review pass over the (now 35-item) REQ set found two stale cross-references left over from 6.0.0's REQ-032/REQ-034 merge: the Validation section claimed `scripts/sync-readme.sh` enforces "REQ-032 through REQ-034" (REQ-034 is CODEOWNERS, unrelated to sync-readme.sh; corrected to "REQ-032 and REQ-033"), and REQ-016's directory-to-REQ cross-reference list omitted REQ-021 (`scripts/validate-structure.sh`, which also lives in `scripts/`). Reworded REQ-016 to reference the Required Paths table instead of hardcoding a REQ-number list, since that hardcoded-list pattern is exactly what went stale here and previously in REQ-017 (fixed in 3.0.0). No REQ was added, removed, or renumbered, and no testable behavior changed; this is a PATCH |
| 6.0.2 | 2026-07-25 | Formatting fix: inserted a blank line between every Terminology entry, same as 3.0.1's fix for the Normative Requirements section. Consecutive lines with no blank line between them collapse into a single run-on paragraph under CommonMark (the site's rendering pipeline), making the Terminology section hard for a human to scan; each term now renders as its own paragraph. No wording, numbering, or conformance semantics changed |
| 6.0.3 | 2026-07-25 | Formatting fix: reordered the Terminology section's entries alphabetically (Agent, Atomic publication, Canonical document, Conformant repository, Dual-purpose repository, README mirror), previously listed in ad hoc addition order. No wording, numbering, or conformance semantics changed |
| 6.0.4 | 2026-07-26 | Wording clarification: REQ-031 now notes that `QUICKSTART.md`'s Bootstrapping Your Own Spec section serves the role of a traditional README.md for forking operators, alongside its existing documentation requirements. No REQ was added, removed, or renumbered, and no testable behavior changed; this is a PATCH |
| 6.1.0 | 2026-07-26 | Standardized every REQ's prose into a consistent tight format: a single normative MUST-sentence, followed by an optional "Rationale: ..." clause (only where a non-obvious "why" exists) and an "Enforced by: ..." clause naming the concrete script/workflow that checks it. Previously, some REQs mixed inline rationale into the normative sentence while others carried no enforcement pointer at all, an inconsistency this pass removes. Also deduplicated REQ-008 and REQ-019, which both claimed the `build` script's content-validation ordering; REQ-008 now states only the script's existence, leaving the ordering claim solely to REQ-019 (already the REQ that `scripts/validate-structure.sh` actually checks it against). No REQ was added, removed, or renumbered, and no conformance semantics or script behavior changed; this is a MINOR clarification per this document's own versioning policy |
| 6.1.1 | 2026-07-26 | Trimmed redundant non-normative prose made obsolete by 6.1.0's per-REQ "Enforced by:" clauses: removed the `## Validation` section's summary sentences restating which script enforces which REQ (now stated once, per-REQ), removed the `### CI Execution Rules` subsection (its 4 rules were pure restatements of REQ-019/REQ-020/REQ-023/REQ-025/REQ-032 with no independent testable content — the same category of non-normative restatement removed from the REQ set itself in 3.0.0/4.0.0/5.0.0), and removed the `### Forbidden Patterns` subsection (items 1, 2, and 4 restated REQ-003/REQ-002/REQ-032's MUST NOT clauses verbatim; item 3's unique framing was folded into REQ-017's Rationale instead). No REQ was added, removed, or renumbered, no script behavior changed, and every removed sentence's testable content already exists verbatim in a REQ; this is a PATCH |
| 6.1.2 | 2026-07-26 | Renamed the `### Validation` subsection under Normative Requirements (covering REQ-018 through REQ-021) to `### Content Validation`, resolving a same-title collision with the unrelated top-level `## Validation` section. No REQ was added, removed, or renumbered, no script behavior changed (no validate-structure.sh check greps for either heading); this is a PATCH |
| 6.2.0 | 2026-07-26 | Cosmetic overhaul of the Required Paths listing: replaced the 3-column markdown table (Path / Purpose / Requirement Links) with a single fenced, alphabetically-sorted, `ls -l`-style plain-text listing of every required path and its purpose; multi-file table rows (e.g. layout.tsx/page.tsx/globals.css) were split into one line per file for a flat, scannable listing. Dropped the per-path "Requirement Links" column: each path's owning REQ(s), and that REQ's own enforcement mechanism, are already stated once in the REQ's own text (per 6.1.0's "Enforced by:" clause), so the table's reverse-index was a redundant cross-reference rather than unique information. No REQ was added, removed, or renumbered, no script behavior changed (no validate-structure.sh check parses this listing's format); this is a MINOR clarification per this document's own versioning policy |
| 6.2.1 | 2026-07-26 | Shortened the per-path purpose text in the Required Paths listing (longest line 91 chars to 65 chars) so it renders without a horizontal scrollbar in the site's content column. Wording-only trim, no path added/removed/reordered, no REQ or script behavior changed; this is a PATCH |

Version policy.
MAJOR increments change conformance semantics.
MINOR increments add backward-compatible requirements or clarifications.
PATCH increments fix wording or defects without changing conformance semantics.

---

End of specification.

# Agentic Specification Publication Specification

Version: 1.1.0.
Status: Standard.
Date: 2026-07-24.

## Abstract

This document specifies SpecPubSpec, a repository pattern for publishing specifications that are simultaneously machine-readable by coding agents and human-browsable as rendered documentation.
A SpecPubSpec-conformant repository has exactly one canonical source of truth and prevents content drift between source and site.

## Conformance

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).
A repository conforms to this specification only if it satisfies REQ-001 through REQ-031 and passes the validation contract in section 6.

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
REQ-002: The file `docs/seed-doc.md` SHALL be the sole canonical specification document.
REQ-003: The canonical document MUST NOT be a symbolic link.

### Content Unification

REQ-004: The `site/` generation directory MUST NOT contain copies of canonical documents.
REQ-005: The site generator MUST read canonical documents directly from repository paths at build time.
REQ-006: Directories named `site/content/` and `site/docs/` MUST NOT exist.

### Repository Metadata

REQ-007: The repository MUST contain `AGENTS.md` at repository root.
REQ-008: `AGENTS.md` MUST document repository structure and markdown authoring rules.
REQ-009: The repository MUST contain `README.md` at repository root describing the dual-purpose model.

### Static Site Generation

REQ-010: The repository MUST include a static site generator in `site/`.
REQ-011: The site generator MUST render canonical documents without manual content copying.
REQ-012: `site/lib/content.ts` MUST exist and define `CANONICAL_SOURCE_PATHS`.
REQ-013: `CANONICAL_SOURCE_PATHS` MUST reference `docs/seed-doc.md`.

### Validation

REQ-014: `site/scripts/validate-content.mjs` MUST exist.
REQ-015: Content validation MUST execute before site generation.
REQ-016: Build MUST fail if a canonical document is missing or malformed.
REQ-017: `site/scripts/validate-structure.sh` MUST exist and be executable.
REQ-018: Structure validation MUST return exit code 0 on conformance and non-zero on violation.

### Continuous Integration

REQ-019: `.github/workflows/publish-site.yml` MUST exist.
REQ-020: Publish workflow MUST trigger generation and deployment on pushes to default branch.
REQ-021: `.github/workflows/site-build-check.yml` MUST exist.
REQ-022: Build-check workflow MUST validate site generation on pull requests without deployment.

### Document Structure

REQ-023: This canonical document MUST contain a section titled `## Core`.
REQ-024: This canonical document MUST contain a section titled `## Repository Structure`.
REQ-025: This canonical document MUST contain a section titled `## Version`.
REQ-026: `AGENTS.md` MUST contain a section titled `## Repository Map`.
REQ-027: `AGENTS.md` MUST contain a section titled `## Markdown Authoring Rules`.

### Repository Orientation

REQ-028: The repository MUST contain `QUICKSTART.md` at repository root documenting repository orientation, build instructions, and contribution guidance.

### README Mirror Invariant

REQ-029: `README.md` MUST be generated as a byte-for-byte mirror of `docs/seed-doc.md` and MUST NOT be hand-edited.
REQ-030: `scripts/sync-readme.sh` MUST exist, MUST be executable, and MUST support a `--target-path` option for drift-checking without overwriting the checked-in `README.md`.
REQ-031: Continuous integration MUST verify `README.md` has zero drift from `docs/seed-doc.md` and MUST fail the workflow run if drift is detected.

---

## Repository Structure

### Required Paths

The following paths are REQUIRED for conformance.

| Path | Purpose | Requirement Links |
|---|---|---|
| `docs/seed-doc.md` | Canonical specification document | REQ-001, REQ-002, REQ-003, REQ-023, REQ-024, REQ-025 |
| `AGENTS.md` | Repository map and authoring rules | REQ-007, REQ-008, REQ-026, REQ-027 |
| `README.md` | Repository entry point; generated mirror of the canonical document | REQ-009, REQ-029 |
| `site/lib/content.ts` | Canonical document loader | REQ-012, REQ-013 |
| `site/scripts/validate-content.mjs` | Pre-build content validation | REQ-014, REQ-015, REQ-016 |
| `site/scripts/validate-structure.sh` | Structure conformance validation | REQ-017, REQ-018 |
| `.github/workflows/publish-site.yml` | Publish workflow | REQ-019, REQ-020 |
| `.github/workflows/site-build-check.yml` | Pull-request build workflow | REQ-021, REQ-022 |
| `QUICKSTART.md` | Repository orientation, build, and contribution guide | REQ-028 |
| `scripts/sync-readme.sh` | Regenerates README.md as a mirror of docs/seed-doc.md | REQ-029, REQ-030 |

### Forbidden Patterns

1. Creating `site/content/` or `site/docs/`.
2. Using symbolic links for canonical documents.
3. Storing duplicate canonical content in parallel locations.
4. Hand-editing `README.md` instead of regenerating it via `scripts/sync-readme.sh`.

---

## Validation

Validation enforces structural and publication conformance.
`site/scripts/validate-content.mjs` enforces REQ-014 through REQ-016.
`site/scripts/validate-structure.sh` enforces repository requirements and forbidden patterns.

### Validation Contract

A repository claiming SpecPubSpec conformance MUST pass the following check.

```bash
bash site/scripts/validate-structure.sh
echo $?  # MUST output 0
```

A non-zero exit code is non-conformance.

`scripts/sync-readme.sh` enforces REQ-029 through REQ-031 by regenerating `README.md` from `docs/seed-doc.md`.
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
Conformant repository: A repository that satisfies REQ-001 through REQ-031 and passes section 6 validation.
README mirror: The invariant that `README.md` is a byte-for-byte regenerated copy of `docs/seed-doc.md`, produced by `scripts/sync-readme.sh` and never hand-edited.
Atomic publication: A publish model where partial deployment is impossible.

---

## Version

This specification is at version 1.0.0 and follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2026-07-24 | Initial SpecPubSpec release with normative requirement set REQ-001 through REQ-027 and executable validation contract |
| 1.1.0 | 2026-07-24 | Added REQ-028 through REQ-031, formalizing QUICKSTART.md, the README.md generated-mirror invariant, and scripts/sync-readme.sh as required conformance artifacts |

Version policy.
MAJOR increments change conformance semantics.
MINOR increments add backward-compatible requirements or clarifications.
PATCH increments fix wording or defects without changing conformance semantics.

---

End of specification.

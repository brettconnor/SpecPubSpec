# Agentic Specification Publication Specification

**Version:** 1.0.0  
**Status:** Standard  
**Date:** 2026-07-24

## Abstract

This document specifies SpecPubSpec, a repository pattern for publishing specifications that are simultaneously machine-readable by coding agents and human-browsable as rendered documentation.
A SpecPubSpec-conformant repository maintains a single canonical source of truth that eliminates content drift between agent-consumed specifications and human documentation.

## Status of This Document

This is a stable specification.
Implementation of this specification is REQUIRED for repositories claiming SpecPubSpec conformance.

## Conformance

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).

A repository is conformant to this specification if and only if it satisfies all normative requirements in sections 3 through 6.

## Table of Contents

1. Introduction
2. Conformance
3. Core Principles
4. Normative Requirements
5. Repository Structure
6. Validation
7. Terminology

---

## 1. Introduction

### 1.1 Purpose

SpecPubSpec defines a repository pattern that enables specifications to serve dual purposes:

1. **Agent Consumption**: Coding agents read specifications directly from canonical markdown files in the repository without transformation or interpretation layers.
2. **Human Browsing**: The same markdown files render as a static website for human readers without requiring parallel content maintenance.
3. **Truth Unification**: Exactly one copy of every canonical document exists; the rendered website is a view, never a duplicate store.

### 1.2 Scope

This specification applies to:

- Git repositories containing technical specifications
- Projects requiring agent-readable documentation
- Teams maintaining specifications consumed by both humans and autonomous coding agents
- Documentation systems requiring provable single-source-of-truth semantics

This specification does NOT define:

- Markdown rendering engines or styling
- Version control workflows beyond structural requirements
- Authentication or access control mechanisms
- Internationalization or localization approaches

### 1.3 Design Goals

The design of SpecPubSpec prioritizes:

1. **Zero Content Drift**: Structural impossibility of documentation diverging from specification source
2. **Agent Parsability**: Direct file-system access to unambiguous, machine-readable markdown
3. **Validation Automation**: Testable conformance through executable validation contracts
4. **Publication Atomicity**: All-or-nothing deployment preventing partial or inconsistent updates
5. **Minimal Ceremony**: Small set of required files and conventions

---

## 2. Conformance

### 2.1 Conformance Classes

A repository claiming SpecPubSpec conformance MUST satisfy all normative requirements in sections 3 through 6 of this specification.

### 2.2 Conformance Testing

A conformant repository MUST pass the validation contract defined in section 6.3 without error.
The validation script specified in section 5.4 provides a reference implementation of this contract.

---

## 3. Core Principles

### 3.1 Single Source of Truth (Normative)

A conformant repository MUST maintain exactly one canonical copy of each specification document.

Content duplication between the canonical source and any rendered or processed output is FORBIDDEN.

The rendered website MUST be generated from canonical source at build time and MUST NOT persist as a parallel content store.

### 3.2 Dual-Purpose Design (Normative)

The canonical specification document MUST be readable in both its source form (for agents) and its rendered form (for humans) without semantic loss.

Authoring practices MUST optimize for machine parsing while maintaining human comprehension.

### 3.3 Self-Hosting (Normative)

The repository MUST contain all components necessary to generate its rendered documentation from source.

External dependencies SHOULD be minimized and MUST be declared explicitly.

### 3.4 Agent-First Authoring (Informative)

Canonical documents SHOULD follow strict markdown formatting rules to ensure unambiguous machine parsing.
See `AGENTS.md` for normative markdown authoring requirements.

### 3.5 Atomic Publishing (Normative)

Pre-deployment validation MUST prevent publication of malformed or incomplete specifications.

A build failure during validation or rendering MUST block publication entirely.

### 3.6 Transient Artifact Suppression (Informative)

Working artifacts (draft specifications, planning documents, task lists) SHOULD NOT persist in the repository after their associated work completes.

Only stable, published specifications SHOULD remain visible in the canonical document tree.

---

## 4. Normative Requirements

### 4.1 Canonical Document

**REQ-001**: The repository MUST contain a file at the path `docs/seed-doc.md`.

**REQ-002**: The file `docs/seed-doc.md` SHALL be the sole canonical specification document.

**REQ-003**: The canonical document MUST NOT be a symbolic link.

### 4.2 Content Unification

**REQ-004**: The site generation directory (`site/`) MUST NOT contain copies of canonical documents.

**REQ-005**: The site generator MUST read canonical documents directly from their repository paths at build time.

**REQ-006**: Directories named `site/content/` or `site/docs/` MUST NOT exist.

### 4.3 Repository Metadata

**REQ-007**: The repository MUST contain a file named `AGENTS.md` at the repository root.

**REQ-008**: The `AGENTS.md` file MUST document the repository structure and markdown authoring rules.

**REQ-009**: The repository MUST contain a file named `README.md` at the repository root that explains the dual-purpose nature of the repository.

### 4.4 Static Site Generation

**REQ-010**: The repository MUST include a static site generator in the `site/` directory.

**REQ-011**: The site generator MUST render canonical documents without requiring manual content authoring or copying.

**REQ-012**: The file `site/lib/content.ts` MUST exist and define `CANONICAL_SOURCE_PATHS`.

**REQ-013**: The `CANONICAL_SOURCE_PATHS` constant MUST reference `docs/seed-doc.md`.

### 4.5 Validation

**REQ-014**: The file `site/scripts/validate-content.mjs` MUST exist.

**REQ-015**: The validation script MUST execute before the site generation step.

**REQ-016**: The build process MUST fail if a canonical document is missing or malformed.

**REQ-017**: The file `site/scripts/validate-structure.sh` MUST exist and be executable.

**REQ-018**: The structure validation script MUST return exit code 0 if the repository is conformant, non-zero otherwise.

### 4.6 Continuous Integration

**REQ-019**: The repository MUST contain a file at `.github/workflows/publish-site.yml`.

**REQ-020**: The publish workflow MUST trigger site generation and deployment on pushes to the default branch.

**REQ-021**: The repository MUST contain a file at `.github/workflows/site-build-check.yml`.

**REQ-022**: The build check workflow MUST validate site generation on pull requests without deploying.

### 4.7 Document Structure

**REQ-023**: The canonical document MUST contain a section titled `## Core`.

**REQ-024**: The canonical document MUST contain a section titled `## Repository Structure`.

**REQ-025**: The canonical document MUST contain a section titled `## Version`.

**REQ-026**: The `AGENTS.md` file MUST contain a section titled `## Repository Map`.

**REQ-027**: The `AGENTS.md` file MUST contain a section titled `## Markdown Authoring Rules`.


---

## 5. Repository Structure

### 5.1 Directory Layout

A conformant repository SHALL have the following structure:

```text
<repository-root>/
├── docs/
│   └── seed-doc.md              # Canonical specification (REQ-001, REQ-002)
├── site/                         # Site generator directory (REQ-010)
│   ├── lib/
│   │   └── content.ts           # Document loader (REQ-012)
│   └── scripts/
│       ├── validate-content.mjs # Pre-build validation (REQ-014)
│       └── validate-structure.sh # Structure validation (REQ-017)
├── .github/
│   └── workflows/
│       ├── publish-site.yml     # Publish workflow (REQ-019)
│       └── site-build-check.yml # Build check workflow (REQ-021)
├── AGENTS.md                     # Repository map (REQ-007)
└── README.md                     # Entry point (REQ-009)
```

### 5.2 Required Files

The following files MUST exist at the specified paths:

| Path | Purpose | Requirements |
|------|---------|--------------|
| `docs/seed-doc.md` | Canonical specification document | REQ-001, REQ-002, REQ-003, REQ-023, REQ-024, REQ-025 |
| `AGENTS.md` | Repository map and authoring rules | REQ-007, REQ-008, REQ-026, REQ-027 |
| `README.md` | Repository entry point | REQ-009 |
| `site/lib/content.ts` | Canonical document loader | REQ-012, REQ-013 |
| `site/scripts/validate-content.mjs` | Content validation | REQ-014, REQ-015 |
| `site/scripts/validate-structure.sh` | Structure validation | REQ-017, REQ-018 |
| `.github/workflows/publish-site.yml` | Publication workflow | REQ-019, REQ-020 |
| `.github/workflows/site-build-check.yml` | PR validation workflow | REQ-021, REQ-022 |

### 5.3 Forbidden Patterns

The following patterns violate this specification:

1. **Content Duplication**: Creating directories `site/content/` or `site/docs/` (REQ-006)
2. **Symbolic Links**: Making `docs/seed-doc.md` or `AGENTS.md` a symlink (REQ-003)
3. **Multiple Sources**: Having more than one canonical copy of any specification content (Section 3.1)

### 5.4 Document Sections

#### 5.4.1 Canonical Document Sections

The file `docs/seed-doc.md` MUST contain sections with the following titles (REQ-023, REQ-024, REQ-025):

- `## Core` - Core principles and normative requirements
- `## Repository Structure` - Formal structure specification
- `## Version` - Semantic version and change history

Additional sections MAY be present.

#### 5.4.2 AGENTS.md Sections

The file `AGENTS.md` MUST contain sections with the following titles (REQ-026, REQ-027):

- `## Repository Map` - Description of directory structure and key files
- `## Markdown Authoring Rules` - Markdown formatting requirements for canonical documents

Additional sections MAY be present.

---

## 6. Validation

### 6.1 Pre-Build Content Validation

The script at `site/scripts/validate-content.mjs` MUST (REQ-014, REQ-015, REQ-016):

1. Execute before the site build step
2. Verify that `docs/seed-doc.md` exists and is readable
3. Attempt to parse the canonical document as markdown with frontmatter
4. Return a non-zero exit code if validation fails
5. Prevent the build from proceeding if validation fails

### 6.2 Structure Validation

The script at `site/scripts/validate-structure.sh` MUST (REQ-017, REQ-018):

1. Be executable (`chmod +x`)
2. Check that all required files exist (Section 5.2)
3. Check that all required directories exist (Section 5.1)
4. Verify canonical documents are not symlinks (REQ-003)
5. Verify required sections exist in `docs/seed-doc.md` (Section 5.4.1)
6. Verify required sections exist in `AGENTS.md` (Section 5.4.2)
7. Verify `site/lib/content.ts` defines `CANONICAL_SOURCE_PATHS` (REQ-012)
8. Verify `site/lib/content.ts` references `docs/seed-doc.md` (REQ-013)
9. Verify no forbidden directories exist (Section 5.3)
10. Return exit code 0 if conformant, non-zero otherwise

### 6.3 Validation Contract

A repository claiming SpecPubSpec conformance MUST pass the following validation contract:

```bash
bash site/scripts/validate-structure.sh
echo $?  # MUST output: 0
```

Failure of this validation (non-zero exit code) indicates non-conformance.

### 6.4 Continuous Integration

The workflows specified in REQ-019 through REQ-022 MUST execute validation as follows:

**Publish Workflow** (`.github/workflows/publish-site.yml`):
1. Execute on push to default branch
2. Run `site/scripts/validate-content.mjs`
3. Build the static site
4. Deploy only if all previous steps succeed

**Build Check Workflow** (`.github/workflows/site-build-check.yml`):
1. Execute on pull request creation or update
2. Run `site/scripts/validate-content.mjs`
3. Build the static site (without deployment)
4. Fail the check if any step fails

---

## 7. Terminology

This section is informative.

**Agent**: An autonomous coding system that reads and interprets specification documents to perform tasks or generate code.

**Canonical Document**: The single authoritative source file for a specification, located at a fixed repository path (`docs/seed-doc.md`).

**Dual-Purpose Repository**: A repository structured to serve both machine-readable specifications for agents and human-browsable rendered documentation from a single source.

**SpecPubSpec**: Agentic Specification Publication Specification.
The pattern defined by this document for creating dual-purpose specification repositories.

**Single Source of Truth**: A data element that exists in exactly one authoritative location.
Modifications to this element occur only at its canonical location, eliminating synchronization requirements.

**Agent-First Authoring**: Markdown formatting practices optimized for unambiguous machine parsing while remaining readable by humans.
Includes: one sentence per line, ATX-style headers exclusively, no trailing whitespace, repository-relative paths only.

**Conformant Repository**: A repository that satisfies all normative requirements (REQ-001 through REQ-027) and passes the validation contract (Section 6.3).

**Build-Time Rendering**: The process of generating the static website from canonical source documents during the build phase, as opposed to maintaining pre-rendered or duplicated content.

**Atomic Publishing**: The property that publication either succeeds completely or fails completely, with no partial or inconsistent state ever visible to consumers.

---

## 8. Version

This specification is at **version 1.0.0**, following [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### 8.1 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-24 | Initial release defining the SpecPubSpec repository pattern with 27 normative requirements and validation contract |

### 8.2 Version Policy

Changes to this specification follow semantic versioning:

- **MAJOR** version increments indicate breaking changes to conformance requirements
- **MINOR** version increments add new requirements in a backward-compatible manner  
- **PATCH** version increments fix errors or clarify existing requirements without changing conformance

---

## Appendix A: Conformance Checklist (Informative)

Use this checklist to verify conformance:

- [ ] File `docs/seed-doc.md` exists and is not a symlink (REQ-001, REQ-002, REQ-003)
- [ ] File `AGENTS.md` exists at repository root (REQ-007, REQ-008)
- [ ] File `README.md` exists at repository root (REQ-009)
- [ ] Directory `site/` exists with static site generator (REQ-010, REQ-011)
- [ ] File `site/lib/content.ts` defines `CANONICAL_SOURCE_PATHS` referencing `docs/seed-doc.md` (REQ-012, REQ-013)
- [ ] File `site/scripts/validate-content.mjs` exists (REQ-014)
- [ ] Content validation runs before build and can fail the build (REQ-015, REQ-016)
- [ ] File `site/scripts/validate-structure.sh` exists and is executable (REQ-017, REQ-018)
- [ ] File `.github/workflows/publish-site.yml` exists (REQ-019, REQ-020)
- [ ] File `.github/workflows/site-build-check.yml` exists (REQ-021, REQ-022)
- [ ] Section `## Core` exists in `docs/seed-doc.md` (REQ-023)
- [ ] Section `## Repository Structure` exists in `docs/seed-doc.md` (REQ-024)
- [ ] Section `## Version` exists in `docs/seed-doc.md` (REQ-025)
- [ ] Section `## Repository Map` exists in `AGENTS.md` (REQ-026)
- [ ] Section `## Markdown Authoring Rules` exists in `AGENTS.md` (REQ-027)
- [ ] No directories named `site/content/` or `site/docs/` exist (REQ-004, REQ-006)
- [ ] `bash site/scripts/validate-structure.sh` returns exit code 0

---

*End of specification.*

*This specification is self-demonstrating: the repository containing this document conforms to SpecPubSpec and serves as a reference implementation.*

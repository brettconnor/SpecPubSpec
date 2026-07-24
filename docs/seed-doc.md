# Agentic Specification Publication Specification (SpecPubSpec)

This repository is the specification for SpecPubSpec itself - a pattern for creating dual-purpose repositories that serve both humans and coding agents.

---

## Core

### What SpecPubSpec Defines

SpecPubSpec is a repository pattern that enables specifications to be:

1. **Machine-readable** - Coding agents read specifications directly from canonical markdown files in the repository
2. **Human-browsable** - The same markdown files render as a static website for human readers
3. **Single source of truth** - Exactly one copy of every canonical document exists; the website is a rendering, never a parallel content store

### Core Principles

Every SpecPubSpec-conformant repository MUST satisfy these principles:

**I. Single Source of Truth**
One canonical markdown file (`docs/seed-doc.md`) serves both audiences.
No content is duplicated or copied into the site generation directory.

**II. Dual-Purpose Design**
The same content is readable in-repository AND rendered as a browsable website.
Authoring optimizes for both agent parsing and human comprehension.

**III. Self-Hosting**
The site generates from repository source at build time.
The rendered site reads canonical documents directly from their repository paths.

**IV. Agent-First Authoring**
Strict markdown rules (defined in `AGENTS.md`) ensure machine readability.
One sentence per line, ATX headers only, no trailing whitespace, repository-relative paths.

**V. Atomic Publishing**
Validation gates prevent partial or broken deployments.
Content validation runs before build; build failures block publish.

**VI. Surface Only What Survives**
Transient artifacts (working specs/, plan.md, tasks.md) disappear after shipping.
Only stable, canonical documents persist in the repository.

### Functional Requirements

**FR-001: Canonical Document**
The repository MUST contain `docs/seed-doc.md` as the sole canonical specification document.

**FR-002: No Content Duplication**
The site generation directory (`site/`) MUST NOT contain copies of canonical documents.
The site MUST read documents directly from their repository paths at build time.

**FR-003: Repository Map**
The repository MUST contain `AGENTS.md` that documents the repository structure, markdown authoring rules, and governance.

**FR-004: Static Site Generation**
The repository MUST include a static site generator that renders canonical documents.
The site MUST generate from repository source without requiring manual content authoring.

**FR-005: Pre-Build Validation**
The site build MUST fail if a canonical document is missing or malformed.
Validation MUST run before the site generation step.

**FR-006: Structure Validation**
The repository MUST include a script (`site/scripts/validate-structure.sh`) that validates SpecPubSpec conformance.
The script MUST be testable and return exit code 0 on success, non-zero on failure.

**FR-007: CI Integration**
The repository MUST include GitHub Actions workflows for:
- Site build validation on pull requests
- Site publishing on default branch pushes
- Structure and governance validation

**FR-008: Canonical Source Immutability**
Canonical documents (those read by agents and rendered by the site) MUST NOT be symlinks.

## Repository Structure

### Required Files

A SpecPubSpec-conformant repository MUST include:

```text
docs/
  seed-doc.md              # Canonical specification document
site/
  lib/
    content.ts             # Canonical document loader
  scripts/
    validate-content.mjs   # Pre-build content validation
    validate-structure.sh  # SpecPubSpec conformance validation
.github/
  workflows/
    publish-site.yml       # Site publishing workflow
    site-build-check.yml   # PR build validation workflow
AGENTS.md                  # Repository map and authoring rules
README.md                  # Entry point explaining dual-purpose nature
```

### Required Sections in docs/seed-doc.md

The canonical document MUST contain these sections:

- `## Core` - Core principles, requirements, and functional specifications
- `## Repository Structure` - Formal structure definition
- `## Version` - Semantic version of the specification

### Required Sections in AGENTS.md

The repository map MUST contain:

- `## Repository Map` - Description of directory structure and key files
- `## Markdown Authoring Rules` - Strict markdown rules for agent readability

### Validation Contract

The validation script `site/scripts/validate-structure.sh` MUST:

1. Check all required files exist
2. Check all required directories exist
3. Verify canonical documents are not symlinks
4. Verify required sections exist in `docs/seed-doc.md` and `AGENTS.md`
5. Verify `site/lib/content.ts` defines `CANONICAL_SOURCE_PATHS` and references `docs/seed-doc.md`
6. Verify no content duplication directories exist in `site/` (e.g., `site/content/`, `site/docs/`)
7. Return exit code 0 if conformant, non-zero otherwise

### Forbidden Patterns

- **Content duplication**: `site/content/` or `site/docs/` directories MUST NOT exist
- **Symlinks**: Canonical documents MUST NOT be symlinks
- **Multiple sources**: There MUST be exactly one copy of each canonical document

## Glossary

**Canonical Document**: The single source of truth for a specification, living at a fixed repository path.
In SpecPubSpec, this is `docs/seed-doc.md`.

**Dual-Purpose Repository**: A repository that serves both as machine-readable source for coding agents and human-browsable documentation.

**SpecPubSpec**: Agentic Specification Publication Specification.
The pattern defined by this specification for creating dual-purpose repositories.

**Single Source of Truth**: A document that exists in exactly one location, with no copies or duplicates.
Changes to this document are the only way to update its content.

**Agent-First Authoring**: Markdown authoring rules optimized for machine parsing while remaining human-readable.
One sentence per line, ATX headers only, no trailing whitespace.

**Surface Only What Survives**: The principle that transient working artifacts do not persist in the repository.
Only stable, shipped specifications remain visible.

## Version

This specification is at **version 1.0.0**, following [Semantic Versioning](https://github.com/semver/semver/blob/master/semver.md).

**1.0.0** (2026-07-24): Initial release of SpecPubSpec as a formal specification defining the dual-purpose repository pattern.

---

*End of specification.*
*This file is placed at `docs/seed-doc.md`, the sole canonical source the site renders at `/`.*
*See the repository `README.md` and `AGENTS.md` for the full repository map and workflow.*

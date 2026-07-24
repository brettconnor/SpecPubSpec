#!/usr/bin/env bash
# SpecPubSpec Structure Validation
#
# Validates that a repository conforms to the Agentic Specification Publication
# Specification (SpecPubSpec) structural requirements defined in docs/seed-doc.md.
# Exit code 0 if conformant, non-zero otherwise.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$REPO_ROOT"

fail=0

echo "[validate-structure] Validating SpecPubSpec structural conformance..."

# Required files for minimal SpecPubSpec conformance
REQUIRED_FILES=(
  "docs/seed-doc.md"
  "AGENTS.md"
  "README.md"
  "site/lib/content.ts"
  "site/scripts/validate-content.mjs"
  ".github/workflows/publish-site.yml"
  ".github/workflows/site-build-check.yml"
  "QUICKSTART.md"
  "scripts/sync-readme.sh"
)

# Files that must be executable (REQ-030)
REQUIRED_EXECUTABLE_FILES=(
  "scripts/sync-readme.sh"
  "site/scripts/validate-structure.sh"
)

# Required directories
REQUIRED_DIRS=(
  "docs"
  "site"
  "site/lib"
  "site/scripts"
  ".github"
  ".github/workflows"
)

# Files that must not be symlinks (canonical documents)
NO_SYMLINK_FILES=(
  "docs/seed-doc.md"
  "AGENTS.md"
)

# Validate required directories exist
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "FAIL: required directory missing: $dir" >&2
    fail=1
  fi
done

# Validate required files exist
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -e "$file" ]; then
    echo "FAIL: required file missing: $file" >&2
    fail=1
  fi
done

# Validate canonical documents are not symlinks
for file in "${NO_SYMLINK_FILES[@]}"; do
  if [ -L "$file" ]; then
    echo "FAIL: canonical document must not be symlink: $file" >&2
    fail=1
  fi
done

# Validate required scripts are executable (REQ-030)
for file in "${REQUIRED_EXECUTABLE_FILES[@]}"; do
  if [ -e "$file" ] && [ ! -x "$file" ]; then
    echo "FAIL: required script is not executable: $file" >&2
    fail=1
  fi
done

# Validate README.md has zero drift from docs/seed-doc.md (REQ-029, REQ-031)
if [ -f scripts/sync-readme.sh ] && [ -f README.md ]; then
  tmp_readme="$(mktemp)"
  if scripts/sync-readme.sh --target-path "$tmp_readme" >/dev/null; then
    if ! diff -q README.md "$tmp_readme" >/dev/null; then
      echo "FAIL: README.md has drifted from docs/seed-doc.md; run scripts/sync-readme.sh" >&2
      fail=1
    fi
  else
    echo "FAIL: scripts/sync-readme.sh failed to run" >&2
    fail=1
  fi
  rm -f "$tmp_readme"
fi

# Validate docs/seed-doc.md has required sections
if [ -f docs/seed-doc.md ]; then
  for section in "## Core" "## Repository Structure" "## Version"; do
    if ! grep -qF "$section" docs/seed-doc.md; then
      echo "FAIL: docs/seed-doc.md missing required section: $section" >&2
      fail=1
    fi
  done
else
  echo "FAIL: canonical document docs/seed-doc.md does not exist" >&2
  fail=1
fi

# Validate AGENTS.md has required sections
if [ -f AGENTS.md ]; then
  for section in "## Repository Map" "## Markdown Authoring Rules"; do
    if ! grep -qF "$section" AGENTS.md; then
      echo "FAIL: AGENTS.md missing required section: $section" >&2
      fail=1
    fi
  done
else
  echo "FAIL: AGENTS.md does not exist" >&2
  fail=1
fi

# Validate site/lib/content.ts defines canonical source paths
if [ -f site/lib/content.ts ]; then
  if ! grep -q "CANONICAL_SOURCE_PATHS" site/lib/content.ts; then
    echo "FAIL: site/lib/content.ts must define CANONICAL_SOURCE_PATHS" >&2
    fail=1
  fi
  if ! grep -q "docs/seed-doc.md" site/lib/content.ts; then
    echo "FAIL: site/lib/content.ts must reference docs/seed-doc.md" >&2
    fail=1
  fi
fi

# Validate no content duplication in site/ (forbidden pattern)
if [ -d site/content ]; then
  echo "FAIL: site/content/ directory exists; content must not be copied into site/" >&2
  fail=1
fi

if [ -d site/docs ]; then
  echo "FAIL: site/docs/ directory exists; content must not be copied into site/" >&2
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "[validate-structure] ✓ Repository conforms to SpecPubSpec structural requirements"
  exit 0
else
  echo "[validate-structure] ✗ Repository does not conform to SpecPubSpec" >&2
  exit 1
fi

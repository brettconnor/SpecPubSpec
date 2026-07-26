#!/usr/bin/env bash
# SpecPubSpec Structure Validation
#
# Validates that a repository conforms to the Agentic Specification Publication
# Specification (SpecPubSpec) structural requirements defined in docs/seed-doc.md.
# Exit code 0 if conformant, non-zero otherwise.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$REPO_ROOT"

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
  ".github/CODEOWNERS"
  ".github/workflows/governance-check.yml"
  "scripts/validate-structure.sh"
  "site/package.json"
  "site/next.config.mjs"
  "site/tsconfig.json"
  "site/app/layout.tsx"
  "site/app/page.tsx"
  "site/app/globals.css"
  "site/components/MarkdownPage.tsx"
  "site/components/DownloadButton.tsx"
  "site/package-lock.json"
  "site/scripts/check-links.mjs"
  "site/app/favicon.ico"
  "site/.eslintrc.json"
  "scripts/audit-repo.sh"
)

# Files that must be executable (REQ-035, REQ-017)
REQUIRED_EXECUTABLE_FILES=(
  "scripts/sync-readme.sh"
  "scripts/validate-structure.sh"
  "scripts/audit-repo.sh"
)

# Required directories
REQUIRED_DIRS=(
  "docs"
  "site"
  "site/lib"
  "site/scripts"
  ".github"
  ".github/workflows"
  "scripts"
  "site/app"
  "site/components"
)

# Files that must not be symlinks (canonical documents)
NO_SYMLINK_FILES=(
  "docs/seed-doc.md"
  "AGENTS.md"
  "README.md"
)

# Everything below is wrapped in main() so this file can be safely `source`d
# (e.g. by scripts/audit-repo.sh, to reuse REQUIRED_FILES/REQUIRED_DIRS/
# REQUIRED_EXECUTABLE_FILES as real bash arrays instead of parsing this
# file's text) without running the validation pass or triggering the exit
# at the bottom. The guard below only invokes main when this script is
# executed directly, not when it's sourced.
main() {
fail=0

echo "[validate-structure] Validating SpecPubSpec structural conformance..."

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

# Validate required scripts are executable (REQ-035)
for file in "${REQUIRED_EXECUTABLE_FILES[@]}"; do
  if [ -e "$file" ] && [ ! -x "$file" ]; then
    echo "FAIL: required script is not executable: $file" >&2
    fail=1
  fi
done

# Validate README.md has zero drift from docs/seed-doc.md (REQ-034, REQ-036)
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

# Validate QUICKSTART.md has required sections (REQ-033)
if [ -f QUICKSTART.md ]; then
  if ! grep -qF "## Bootstrapping Your Own Spec" QUICKSTART.md; then
    echo "FAIL: QUICKSTART.md missing required section: ## Bootstrapping Your Own Spec" >&2
    fail=1
  fi
else
  echo "FAIL: QUICKSTART.md does not exist" >&2
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

# Validate site generator core artifacts wire together (REQ-008 through REQ-011)
if [ -f site/package.json ]; then
  if ! grep -q '"build"' site/package.json; then
    echo "FAIL: site/package.json must define a build script" >&2
    fail=1
  fi
fi

if [ -f site/app/layout.tsx ]; then
  if ! grep -q "globals.css" site/app/layout.tsx; then
    echo "FAIL: site/app/layout.tsx must import globals.css" >&2
    fail=1
  fi
fi

if [ -f site/app/page.tsx ]; then
  if ! grep -q "MarkdownPage" site/app/page.tsx; then
    echo "FAIL: site/app/page.tsx must import/use MarkdownPage" >&2
    fail=1
  fi
  if ! grep -q "DownloadButton" site/app/page.tsx; then
    echo "FAIL: site/app/page.tsx must import/use DownloadButton" >&2
    fail=1
  fi
fi

# Validate content validation runs before site generation, not merely that a
# build script happens to exist (REQ-019). Extracts the literal "build" script
# value from package.json and checks that a validate-content invocation
# appears textually before "next build" within it.
if [ -f site/package.json ]; then
  build_script="$(grep -o '"build"[[:space:]]*:[[:space:]]*"[^"]*"' site/package.json | sed -E 's/.*: *"(.*)"/\1/')"
  if [[ "$build_script" != *"next build"* ]]; then
    echo "FAIL: site/package.json's build script must invoke next build" >&2
    fail=1
  elif [[ "$build_script" != *"validate-content"* ]]; then
    echo "FAIL: site/package.json's build script must invoke validate-content.mjs before next build" >&2
    fail=1
  else
    before_next_build="${build_script%%next build*}"
    if [[ "$before_next_build" != *"validate-content"* ]]; then
      echo "FAIL: site/package.json's build script must run validate-content.mjs before next build, not after" >&2
      fail=1
    fi
  fi
fi

# Validate publish-site.yml triggers on pushes to main (REQ-024)
if [ -f .github/workflows/publish-site.yml ]; then
  if ! grep -q "^  push:" .github/workflows/publish-site.yml; then
    echo "FAIL: .github/workflows/publish-site.yml must trigger on push" >&2
    fail=1
  elif ! grep -A5 "^  push:" .github/workflows/publish-site.yml | grep -q "main"; then
    echo "FAIL: .github/workflows/publish-site.yml's push trigger must target the main branch" >&2
    fail=1
  fi
fi

# Validate site-build-check.yml triggers on pull_request and never deploys (REQ-026)
if [ -f .github/workflows/site-build-check.yml ]; then
  if ! grep -q "pull_request:" .github/workflows/site-build-check.yml; then
    echo "FAIL: .github/workflows/site-build-check.yml must trigger on pull_request" >&2
    fail=1
  fi
  if grep -qiE "deploy-pages|actions/deploy" .github/workflows/site-build-check.yml; then
    echo "FAIL: .github/workflows/site-build-check.yml must not contain a deployment step" >&2
    fail=1
  fi
fi

# Validate CODEOWNERS contains at least one non-comment ownership rule (REQ-037)
if [ -f .github/CODEOWNERS ]; then
  if ! grep -vE '^[[:space:]]*(#.*)?$' .github/CODEOWNERS | grep -q .; then
    echo "FAIL: .github/CODEOWNERS must contain at least one non-comment ownership rule" >&2
    fail=1
  fi
fi

# Validate governance-check.yml dogfoods this specification's own conformance (REQ-038)
if [ -f .github/workflows/governance-check.yml ]; then
  if ! grep -q "validate-structure.sh" .github/workflows/governance-check.yml; then
    echo "FAIL: .github/workflows/governance-check.yml must invoke scripts/validate-structure.sh" >&2
    fail=1
  fi
  if ! grep -q "^  push:" .github/workflows/governance-check.yml; then
    echo "FAIL: .github/workflows/governance-check.yml must trigger on push" >&2
    fail=1
  fi
  if ! grep -q "^  pull_request:" .github/workflows/governance-check.yml; then
    echo "FAIL: .github/workflows/governance-check.yml must trigger on pull_request" >&2
    fail=1
  fi
fi

if [ "$fail" -eq 0 ]; then
  echo "[validate-structure] ✓ Repository conforms to SpecPubSpec structural requirements"
  return 0
else
  echo "[validate-structure] ✗ Repository does not conform to SpecPubSpec" >&2
  return 1
fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main
  exit $?
fi

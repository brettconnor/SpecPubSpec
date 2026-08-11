#!/usr/bin/env bash
# SpecPubSpec Repository Audit
#
# Complements scripts/validate-structure.sh. Where that script asks "does every
# required file/dir exist?", this script asks the reverse question: "does every
# file/dir that exists on disk have a reason to be there?"
#
# A path is accounted for if it is either:
#   1. Listed in scripts/validate-structure.sh's REQUIRED_FILES or REQUIRED_DIRS
#      arrays, or
#   2. Listed in this script's own EXEMPT_PATHS array (repo-hygiene files
#      explicitly ruled out of SpecPubSpec's scope: LICENSE, CODE_OF_CONDUCT.md,
#      CONTRIBUTING.md, SECURITY.md, and .gitignore files).
#
# Any other file or directory found on disk is unaccounted-for drift and fails
# the audit. Exit code 0 if every path is accounted for, non-zero otherwise.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$REPO_ROOT"

VALIDATE_SCRIPT="scripts/validate-structure.sh"
fail=0

echo "[audit-repo] Auditing that every file/dir on disk is accounted for..."

if [ ! -f "$VALIDATE_SCRIPT" ]; then
  echo "FAIL: $VALIDATE_SCRIPT does not exist; cannot cross-reference required paths" >&2
  exit 1
fi

# Paths explicitly ruled out of SpecPubSpec's scope (repo hygiene, not the
# dual-purpose spec/site model).
EXEMPT_PATHS=(
  ".gitignore"
  "site/.gitignore"
  "LICENSE"
  "CODE_OF_CONDUCT.md"
  "CONTRIBUTING.md"
  "SECURITY.md"
)

# Extract REQUIRED_FILES, REQUIRED_DIRS, and REQUIRED_EXECUTABLE_FILES by
# sourcing validate-structure.sh directly (as real bash arrays, not by
# parsing its source text with sed/grep). This is safe because
# validate-structure.sh wraps its entire validation pass in a main()
# function guarded by a `[ "${BASH_SOURCE[0]}" = "${0}" ]` check: sourcing it
# here only defines the arrays (and the main function, which we never call),
# it does not run the validation pass or exit this script.
# shellcheck disable=SC1091
source "$VALIDATE_SCRIPT"

if [ "${#REQUIRED_FILES[@]}" -eq 0 ] || [ "${#REQUIRED_DIRS[@]}" -eq 0 ]; then
  echo "FAIL: REQUIRED_FILES/REQUIRED_DIRS were empty after sourcing $VALIDATE_SCRIPT" >&2
  exit 1
fi

is_accounted_for() {
  local path="$1"
  local candidate
  for candidate in "${REQUIRED_FILES[@]}" "${REQUIRED_DIRS[@]}" "${EXEMPT_PATHS[@]}"; do
    if [ "$path" = "$candidate" ]; then
      return 0
    fi
  done
  return 1
}

# Enumerate every file and directory on disk, excluding VCS metadata and
# generated build output (never checked in; irrelevant to source-tree audit).
unaccounted=()
while IFS= read -r -d '' path; do
  rel="${path#./}"
  [ "$rel" = "." ] && continue
  if ! is_accounted_for "$rel"; then
    unaccounted+=("$rel")
  fi
done < <(find . \
  \( -path ./.git -o -path ./node_modules -o -path ./site/node_modules \
     -o -path ./site/.next -o -path ./site/out \
     -o -path ./site/next-env.d.ts \) -prune \
  -o -print0)

if [ "${#unaccounted[@]}" -gt 0 ]; then
  echo "FAIL: the following paths are not accounted for in $VALIDATE_SCRIPT's REQUIRED_FILES/REQUIRED_DIRS, nor in this script's EXEMPT_PATHS:" >&2
  for path in "${unaccounted[@]}"; do
    echo "  - $path" >&2
  done
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "[audit-repo] ✓ Every file and directory on disk is accounted for"
  exit 0
else
  echo "[audit-repo] ✗ Unaccounted-for paths found" >&2
  exit 1
fi

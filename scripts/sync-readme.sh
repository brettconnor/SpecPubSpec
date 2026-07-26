#!/usr/bin/env bash
# Exit immediately on errors, undefined variables, or pipeline failures.
set -euo pipefail

# Find this script's folder so path lookups work from any current directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the repository root as one level above this script folder.
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Single source of truth for the canonical document's repository-relative
# path: SPEC_PATH, defined once in scripts/validate-structure.sh (sourced
# here, the same way scripts/audit-repo.sh reuses that script's arrays). A
# fork/clone renames its canonical document by editing that one variable.
source "$SCRIPT_DIR/validate-structure.sh"

# Start with default runtime options that callers can override with flags.
TARGET_PATH="$REPO_ROOT/README.md"

# Show help text describing what this script does and how to use it.
usage() {
  cat <<'EOF'
Usage: scripts/sync-readme.sh [options]

Purpose:
  Regenerate README.md as a byte-for-byte mirror of the canonical document
  named in scripts/validate-structure.sh's SPEC_PATH variable (docs/seed-doc.md
  by default), so the canonical document is reinforced as the source of truth
  on the repo's default landing page, with no risk of manual drift between
  the two files.

Options:
  --target-path <path>   Write the generated file here instead of README.md.
                          Used by governance-check.yml to render to a
                          temporary file for a drift comparison without
                          touching the checked-in README.md.
  -h, --help              Show this help message and exit.

Output:
  Overwrites the target file with a generated-file banner followed by the
  verbatim content of the canonical document (see SPEC_PATH in
  scripts/validate-structure.sh).
EOF
}

# Print user-facing messages with the script name prefix.
log() {
  printf '[%s] %s\n' "$(basename "$0")" "$*"
}

# Print an error and stop immediately.
fail() {
  log "ERROR: $*" >&2
  exit 1
}

# Ensure a required file exists before continuing.
require_file() {
  local file_path="$1"
  [[ -f "$file_path" ]] || fail "Required file not found: $file_path"
}

# Ensure a required directory exists before continuing.
require_dir() {
  local dir_path="$1"
  [[ -d "$dir_path" ]] || fail "Required directory not found: $dir_path"
}

# Read command-line options and update script settings.
parse_args() {
  while (($# > 0)); do
    case "$1" in
      --target-path)
        (($# >= 2)) || fail "Missing value for --target-path"
        [[ -n "$2" ]] || fail "--target-path must not be empty"
        TARGET_PATH="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
  done
}

# Run preflight validation checks before script-specific logic.
validate_environment() {
  require_file "$REPO_ROOT/$SPEC_PATH"
  # Validate the target's parent directory exists so writes fail fast with a
  # clear error instead of an opaque redirection failure.
  require_dir "$(dirname "$TARGET_PATH")"
}

# Run the script lifecycle and print a human-readable summary at the end.
main() {
  # Apply any command-line options first.
  parse_args "$@"
  validate_environment

  local canonical_source_file="$REPO_ROOT/$SPEC_PATH"

  # Re-verify the canonical source immediately before reading it, minimizing
  # the window between the preflight check and the actual read.
  require_file "$canonical_source_file"

  {
    echo "<!-- GENERATED FILE: do not edit directly. -->"
    echo "<!-- Source of truth: $SPEC_PATH -->"
    echo "<!-- Regenerate with: scripts/sync-readme.sh -->"
    echo "<!-- Repository orientation, build, and contribution instructions: QUICKSTART.md -->"
    echo
    cat "$canonical_source_file"
  } > "$TARGET_PATH"

  log "Regenerated: $TARGET_PATH (from $SPEC_PATH)"
}

main "$@"

#!/usr/bin/env node
// Pre-build content-validation gate (FR-007, T006).
//
// Fails the build with a non-zero exit code -- and a clear message naming
// the offending file -- if any canonical source document is missing or
// cannot be parsed as markdown/frontmatter. This runs *before* `next build`
// (wired into package.json's `build` script, T007) so a broken canonical
// document never reaches a partially-built or published state (Seed Doc
// Principle IV -- Persist Atomically).

import fs from 'node:fs';
import path from 'node:path';
import matter from 'gray-matter';

const REPO_ROOT = path.resolve(process.cwd(), '..');

// Single source of truth for the canonical document's repository-relative
// path: the SPEC_PATH variable defined once in scripts/validate-structure.sh
// (see site/lib/content.ts, which parses the same file the same way). A
// fork/clone renames its canonical document by editing that one variable
// instead of this literal array.
function readSpecPath() {
  const scriptPath = path.join(REPO_ROOT, 'scripts/validate-structure.sh');
  const script = fs.readFileSync(scriptPath, 'utf-8');
  const match = script.match(/^SPEC_PATH="([^"]+)"/m);
  if (!match) {
    throw new Error(`Could not find SPEC_PATH="..." in ${scriptPath}`);
  }
  return match[1];
}

const CANONICAL_SOURCE_PATHS = [
  readSpecPath(),
];

let hasFailure = false;

for (const relativePath of CANONICAL_SOURCE_PATHS) {
  const absolutePath = path.join(REPO_ROOT, relativePath);

  if (!fs.existsSync(absolutePath)) {
    console.error(`[validate-content] MISSING: ${relativePath} does not exist at ${absolutePath}`);
    hasFailure = true;
    continue;
  }

  let raw;
  try {
    raw = fs.readFileSync(absolutePath, 'utf-8');
  } catch (err) {
    console.error(`[validate-content] MISSING: ${relativePath} could not be read (${err.message})`);
    hasFailure = true;
    continue;
  }

  try {
    matter(raw);
    console.log(`[validate-content] valid: ${relativePath}`);
  } catch (err) {
    console.error(`[validate-content] MALFORMED: ${relativePath} failed to parse (${err.message})`);
    hasFailure = true;
  }
}

if (hasFailure) {
  console.error('[validate-content] one or more canonical source documents failed validation; aborting build.');
  process.exit(1);
}

console.log('[validate-content] all canonical source documents valid.');

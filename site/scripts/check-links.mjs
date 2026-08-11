#!/usr/bin/env node
// Static link checker (T021).
//
// Scans the exported HTML in site/out/ for internal (same-origin, path-only)
// links and fails if any resolve to a page that was not actually generated
// by the build. This is the buildable answer to spec.md's Edge Case:
// "How does the system handle broken internal links between rendered
// pages? ... The build SHOULD warn or fail on broken internal
// cross-references." Wired into the PR build-check workflow (T020), not
// the publish deploy, so a broken link blocks merge rather than blocking
// an already-approved deploy.

import fs from 'node:fs';
import path from 'node:path';

const OUT_DIR = path.resolve(process.cwd(), 'out');

if (!fs.existsSync(OUT_DIR)) {
  console.error(`[check-links] out/ directory not found at ${OUT_DIR}; run "npm run build" first.`);
  process.exit(1);
}

function collectHtmlFiles(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  return entries.flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) return collectHtmlFiles(fullPath);
    return entry.name.endsWith('.html') ? [fullPath] : [];
  });
}

function routeExists(hrefPath) {
  const cleanPath = hrefPath.split('#')[0].split('?')[0];

  // A direct static asset (favicon.ico, images, /_next/... chunks already
  // filtered out above) resolves as-is under out/.
  const directAsset = path.join(OUT_DIR, cleanPath);
  if (fs.existsSync(directAsset) && fs.statSync(directAsset).isFile()) {
    return true;
  }

  const normalized = cleanPath === '/' ? '/index' : cleanPath.replace(/\/$/, '');
  const candidates = [
    path.join(OUT_DIR, `${normalized}.html`),
    path.join(OUT_DIR, normalized, 'index.html'),
  ];
  return candidates.some((candidate) => fs.existsSync(candidate));
}

const htmlFiles = collectHtmlFiles(OUT_DIR);
const hrefPattern = /href="(\/[^"#?]*)/g;
let brokenLinkCount = 0;

for (const filePath of htmlFiles) {
  const html = fs.readFileSync(filePath, 'utf-8');
  let match;
  while ((match = hrefPattern.exec(html)) !== null) {
    const hrefPath = match[1];
    if (hrefPath.startsWith('/_next/')) continue;
    if (!routeExists(hrefPath)) {
      console.error(`[check-links] BROKEN: ${path.relative(OUT_DIR, filePath)} links to "${hrefPath}", which was not generated.`);
      brokenLinkCount += 1;
    }
  }
}

if (brokenLinkCount > 0) {
  console.error(`[check-links] ${brokenLinkCount} broken internal link(s) found; failing the check.`);
  process.exit(1);
}

console.log(`[check-links] ${htmlFiles.length} exported page(s) scanned, no broken internal links.`);

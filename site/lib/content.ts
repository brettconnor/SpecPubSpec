import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import matter from 'gray-matter';
import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import remarkRehype from 'remark-rehype';
import rehypeStringify from 'rehype-stringify';

/**
 * Repository root, one level up from the `site/` Next.js project (this file
 * lives at site/lib/content.ts). Canonical documents are read directly from
 * their existing repo paths here -- never copied into site/content/ -- so
 * there is exactly one copy of every canonical document (FR-002, FR-003).
 */
const REPO_ROOT = path.resolve(process.cwd(), '..');

export type ValidationState = 'valid' | 'missing' | 'malformed';

export interface CanonicalDocument {
  sourcePath: string;
  title: string;
  html: string;
  rawMarkdown: string;
  lastModified: string | null;
  validationState: ValidationState;
}

/**
 * Route -> canonical document map backing contracts/routes.md.
 * Keys are repo-relative source paths (data-model.md `source_path` field).
 */
export const CANONICAL_SOURCE_PATHS = {
  seedDoc: 'docs/seed-doc.md',
} as const;

function resolveRepoPath(relativePath: string): string {
  return path.join(REPO_ROOT, relativePath);
}

/**
 * Returns the ISO commit date of the most recent change to `relativePath`,
 * or null if git history is unavailable (e.g. a shallow clone with no log).
 */
function getLastModified(relativePath: string): string | null {
  try {
    const output = execFileSync(
      'git',
      ['log', '-1', '--format=%cI', '--', relativePath],
      { cwd: REPO_ROOT, encoding: 'utf-8' }
    ).trim();
    return output.length > 0 ? output : null;
  } catch {
    return null;
  }
}

function extractFirstH1(markdown: string): string | null {
  const match = markdown.match(/^#\s+(.+)$/m);
  return match ? match[1].trim() : null;
}

/**
 * Removes the first top-level (`# `) heading line from the source markdown,
 * if present, so the rendered `html` body doesn't duplicate the `title`
 * MarkdownPage already renders in its own `<h1>`.
 */
function stripFirstH1(markdown: string): string {
  return markdown.replace(/^#\s+.+\n?/m, '');
}

async function renderMarkdown(markdown: string): Promise<string> {
  const file = await unified()
    .use(remarkParse)
    .use(remarkGfm)
    .use(remarkRehype)
    .use(rehypeStringify)
    .process(markdown);
  return String(file);
}

/**
 * Loads and validates one canonical document by its repo-relative path.
 * Sets `validationState` to `missing` if the file cannot be read, or
 * `malformed` if it cannot be parsed as markdown/frontmatter (FR-007).
 * This is the same logic `scripts/validate-content.mjs` runs standalone
 * before `next build`, kept in sync so page rendering and the pre-build
 * gate never disagree about what counts as valid.
 */
export async function loadCanonicalDocument(
  relativePath: string
): Promise<CanonicalDocument> {
  const absolutePath = resolveRepoPath(relativePath);

  let raw: string;
  try {
    raw = fs.readFileSync(absolutePath, 'utf-8');
  } catch {
    return {
      sourcePath: relativePath,
      title: relativePath,
      html: '',
      rawMarkdown: '',
      lastModified: null,
      validationState: 'missing',
    };
  }

  try {
    const { content } = matter(raw);
    const title = extractFirstH1(content) ?? relativePath;
    const contentWithoutH1 = stripFirstH1(content);
    const html = await renderMarkdown(content);
    return {
      sourcePath: relativePath,
      title,
      html,
      rawMarkdown: contentWithoutH1,
      lastModified: getLastModified(relativePath),
      validationState: 'valid',
    };
  } catch {
    return {
      sourcePath: relativePath,
      title: relativePath,
      html: '',
      rawMarkdown: '',
      lastModified: getLastModified(relativePath),
      validationState: 'malformed',
    };
  }
}

export async function loadSeedDoc(): Promise<CanonicalDocument> {
  return loadCanonicalDocument(CANONICAL_SOURCE_PATHS.seedDoc);
}

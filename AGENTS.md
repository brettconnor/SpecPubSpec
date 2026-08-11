# AGENTS.md

**Purpose**: this repository is a dual-purpose specification and documentation project, modeled on [agents.md](https://github.com/agentsmd/agents.md).
It is simultaneously:

1. **A self-hosting website** — a statically-generated site (see `site/`) that renders this repo's canonical markdown documents for human readers.
2. **The source of truth for specification** — the same markdown files the site renders are also what coding agents (and humans) read directly from the repo to understand governing rules, requirements, and design.

There is exactly one copy of every canonical document; the website is a rendering of the repo, never a parallel content store.

## Repository Map

- `docs/seed-doc.md` — the sole canonical document: the seed specification document that projects adapt as their source of truth.
  Its repository-relative path is a single value, `SPEC_PATH` in `scripts/validate-structure.sh`, read by `scripts/sync-readme.sh`, `site/lib/content.ts`, and `site/scripts/validate-content.mjs`, so renaming the canonical document requires editing only that one variable.
  Read this first: it is the baseline guidance this repository renders and validates.
- `README.md` — a **generated, byte-for-byte mirror** of `docs/seed-doc.md`, produced by `scripts/sync-readme.sh` and drift-checked in `.github/workflows/governance-check.yml`.
  It exists to reinforce the canonical document as the source of truth on the repo's default landing page.
  Never hand-edit `README.md`; edit `docs/seed-doc.md` and re-run `scripts/sync-readme.sh`.
- `QUICKSTART.md` — the actual repository orientation guide: what this repo is, how to build the site, and how to contribute.
  Read this for anything README.md would normally cover.
- `site/` — the Next.js static site that renders the canonical document as one flowing page at `/`.
  See `QUICKSTART.md`'s Website section for build instructions; it reads the canonical document above directly, with no content copied into `site/`.

## Markdown Authoring Rules for Agents

Every markdown file an agent creates or edits in this repository — specs, plans, research, the seed doc, this file — MUST follow these rules.
They keep documents both human-scannable and cheap for agents to read back into context:

1. **One sentence per line.**
   Never wrap a sentence across multiple lines, and never place two sentences on the same line.
   This makes diffs readable at sentence granularity and avoids re-flow noise on unrelated edits.
  Exception: `README.md` is a generated mirror of `docs/seed-doc.md` (see the Repository Map above); never hand-edit it or reflow it directly, regenerate it with `scripts/sync-readme.sh` instead.
2. **ATX headers only** (`#`, `##`, `###`, ...).
   No setext (`===`/`---` underline) headers.
3. **Fenced code blocks always carry a language tag** (` ```bash `, ` ```text `, ` ```yaml `, etc.), never a bare ` ``` `.
4. **Cross-references use repository-relative paths** (e.g. `docs/seed-doc.md`), never absolute filesystem paths (`/home/...`, `/Users/...`) and never paths that leak the local machine or username.
5. **No trailing whitespace**, and every file **ends with exactly one newline**.
6. **No symlinks** for any governed document (seed doc, specs, plans, this file) — always a real file, so the content is unambiguous to readers and to the site build.
7. Before finishing any markdown edit, re-read the diff for wrapped or run-on paragraphs and split them; this is the most common defect and is easy to introduce silently when reflowing prose.

## Canonical Document & Governance Notes

- Amending `docs/seed-doc.md` requires running `scripts/sync-readme.sh` afterward so `README.md` doesn't drift.
- The structural section markers checked by `scripts/validate-structure.sh` (`# Seed Doc`, `## Core`, `## Version`) MUST be preserved; if a rewrite ever renames or removes one of these headings, update the matching literal string in `scripts/validate-structure.sh`'s section check in the same change.

## PR Instructions

- **Security**: never commit real credentials, tokens, or SSH keys.
  Use placeholders and document any required environment variables.
- **Traceability**: PRs that touch `docs/seed-doc.md` should identify which requirement(s) or section the change affects, and should run `scripts/sync-readme.sh` so `README.md` doesn't drift.

## Contribution Conventions

- **Backward compatibility**: do not change the meaning of an existing canonical document without a clear rationale in the PR description; formatting-only fixes (e.g. markdown reflow) should say so explicitly so reviewers don't look for a content change that isn't there.

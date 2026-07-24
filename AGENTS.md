# AGENTS.md

**Purpose**: this repository is a dual-purpose specification and documentation project, modeled on [agents.md](https://github.com/agentsmd/agents.md).
It is simultaneously:

1. **A self-hosting website** — a statically-generated site (see `site/`) that renders this repo's canonical markdown documents for human readers.
2. **The source of truth for specification** — the same markdown files the site renders are also what coding agents (and humans) read directly from the repo to understand governing rules, requirements, and design.

There is exactly one copy of every canonical document; the website is a rendering of the repo, never a parallel content store.

## Repository Map

- `docs/seed-doc.md` — the sole canonical document: the SpecPubSpec normative specification (REQ-001 through REQ-031; see its own `## Version` section for the current version number, not hardcoded here to avoid this file drifting out of sync).
  Read this first: it states the non-negotiable principles and normative requirements every change in this repo must satisfy.
- `README.md` — a **generated, byte-for-byte mirror** of `docs/seed-doc.md`, produced by `scripts/sync-readme.sh` and drift-checked in `.github/workflows/governance-check.yml`.
  It exists to reinforce the canonical document as the source of truth on the repo's default landing page.
  Never hand-edit `README.md`; edit `docs/seed-doc.md` and re-run `scripts/sync-readme.sh`.
- `QUICKSTART.md` — the actual repository orientation guide: what this repo is, how to build the site, and how to contribute.
  Read this for anything README.md would normally cover.
- `.specify/` — spec-kit tooling (`specify-cli`), templates, and scripts that drive the `/speckit.*` workflow (`specify`, `plan`, `tasks`, ...).
  This directory does not currently exist; it was removed in the specpubspec-easy cleanup once feature `001-dual-purpose-spec-site` shipped (see Dev Environment Tips below), and reappears only if `specify init` is re-run for a future feature.
- `specs/<NNN>-<short-name>/` — created on demand by `/speckit.specify` for a feature in progress, each containing `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, and `contracts/`.
  This directory does not currently exist; it reappears only while a feature is being planned, and its content is retired once the feature ships (see the seed doc's Surface Only What Survives principle).
- `site/` — the Next.js static site that renders the canonical document as one flowing page at `/`.
  See `site/README.md` for build instructions; it reads the canonical document above directly, with no content copied into `site/`.

## Dev Environment Tips

- **spec-kit CLI**: installed via `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`.
  `.github/agents/`, `.github/prompts/`, and `.specify/` (the generated `/speckit.*` command stubs and the CLI tooling itself) were all removed in the specpubspec-easy cleanup once feature `001-dual-purpose-spec-site` shipped.
  Run `specify init --here --force --integration copilot` to regenerate `.github/agents/` and `.github/prompts/` only if the `/speckit.*` workflow is needed again for a future feature.
- **Site build**: Node.js 20 LTS; see `site/README.md` for the exact install/build/verify commands.
- **README sync**: after editing `docs/seed-doc.md`, run `scripts/sync-readme.sh` to regenerate `README.md` before committing; `governance-check.yml` fails the build if the two have drifted.

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

## Seed Doc & Governance Notes

- Amending `docs/seed-doc.md` requires: documenting the scenario that motivates the change (or that a principle is out of scope for anything this repo produces), a version bump per its own Versioning policy, and an updated Sync Impact Report at the top of the file.
  See the seed doc's own Governance section for the full contract.
- A change to the seed doc at MINOR or above requires re-validating the downstream artifacts table in that same Governance section (specs, README, any generated plan/tasks) and recording the result.

## PR Instructions

- **Security**: never commit real credentials, tokens, or SSH keys.
  Use placeholders and document any required environment variables.
- **Traceability**: PRs that touch `docs/seed-doc.md` should identify which functional requirement(s) or principle(s) the change affects, and should run `scripts/sync-readme.sh` so `README.md` doesn't drift.

## Contribution Conventions

- **Backward compatibility**: do not change the meaning of an existing canonical document without a clear rationale in the PR description; formatting-only fixes (e.g. markdown reflow) should say so explicitly so reviewers don't look for a content change that isn't there.
- Follow the spec-kit workflow order (`/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → ...) rather than hand-authoring `plan.md`/`tasks.md` content out of sequence.

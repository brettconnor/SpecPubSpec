# site/

This is the static, self-hosted website for this repository (`spechub`), built with Next.js 14 (App Router, `output: 'export'`).

## What this is

The site renders one canonical document directly from its existing repo-relative path at build time, via `lib/content.ts`:

- `docs/seed-doc.md` → `/`

This single file folds the seed doc, specification, and glossary together as sections of one document.
No content is copied into `site/`.
The site is regenerated from repository source on every build, with no manual content-authoring step (FR-003).
Editing the canonical file above and re-running `npm run build` is the only way to change what this page shows.

## Build

```bash
npm install
npm run build
```

`npm run build` first runs `scripts/validate-content.mjs`, which fails the build if a canonical source file is missing or cannot be parsed (FR-007), then runs `next build` to produce the static export in `out/`.

## Local preview

```bash
npx serve out
```

## Contributing

Do not add markdown content directly under `site/`.
Edit the canonical source files at their repository paths instead, then rebuild.
See the repository root `AGENTS.md` for the full markdown-authoring rules that apply to any new prose file added here (e.g. this README).
A pull request that edits `docs/seed-doc.md` MUST include an updated Sync Impact Report, per `AGENTS.md`'s Seed Doc & Governance Notes and the seed doc's own Governance section.

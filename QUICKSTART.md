# Quickstart

This is the repository orientation guide: what this repo is, how to build the site, and how to contribute.

`README.md` at the repo root is a **generated, byte-for-byte mirror** of `docs/seed-doc.md`.
It exists to reinforce the canonical document as the source of truth on the repo's default landing page; read this file instead for orientation, build instructions, and contribution guidance.

`specpubspec` is a dual-purpose specification and documentation repository for the Agentic Specification Publication Specification.
The same canonical markdown files are simultaneously:

- **The source of truth** that coding agents and humans read directly from the repo to understand governing rules, requirements, and design.
- **A self-hosted website** that renders those same files for browsing, with no separate copy to keep in sync.

There is exactly one copy of every canonical document; the website is a rendering of the repo, never a parallel content store.

## Canonical document

| Document | Path | Rendered at |
|---|---|---|
| Seed Doc (with Core and Glossary sections) | [`docs/seed-doc.md`](docs/seed-doc.md) | `/` |

Read `AGENTS.md` for the full repository map, markdown authoring rules, and governance notes that apply when editing this file.

## README.md anti-drift mechanism

`README.md` is a generated mirror of `docs/seed-doc.md`, not a hand-maintained copy:

- `scripts/sync-readme.sh` regenerates `README.md` from `docs/seed-doc.md`.
- `.github/workflows/governance-check.yml` fails the build if `README.md` has drifted from what that script would produce.
- Never hand-edit `README.md`.
  Edit `docs/seed-doc.md`, then run `scripts/sync-readme.sh` to regenerate `README.md` before committing.

## Website

This repository also includes a self-hosted static site (`site/`, Next.js 14 App Router) that renders the canonical documents above as browsable locally or centrally hosted website.

It reads the documents directly from their repository paths at build time — nothing is copied into `site/`, so the rendered pages can never drift from the source.

### Running the site locally

```bash
cd site
npm install
npm run build
npx serve out
```

Then open your browser to the address `serve` prints (typically `http://localhost:3000`).

Do not add markdown content directly under `site/`; edit the canonical source files at their repository paths instead (e.g. `docs/seed-doc.md`), then rebuild.
See `.github/workflows/site-build-check.yml` / `publish-site.yml` for how the site is checked and published in CI.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to report issues and submit pull requests, and [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) for our community standards.
Any pull request that edits `docs/seed-doc.md` should add a row to that document's own `## Version` history table describing the change, per `AGENTS.md`'s Seed Doc & Governance Notes, and should run `scripts/sync-readme.sh` to keep `README.md` in sync.

## Security

See [`SECURITY.md`](SECURITY.md) for how to report a security issue.

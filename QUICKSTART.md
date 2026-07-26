# Quickstart

This is the repository orientation guide: what this repo is, how to build the site, and how to contribute.

`README.md` at the repo root is a **generated, byte-for-byte mirror** of `docs/seed-doc.md`.
It exists to reinforce the canonical document as the source of truth on the repo's default landing page; read this file instead for orientation, build instructions, and contribution guidance.

`specpubspec` is a dual-purpose specification and documentation repository for the Agentic Specification Publication Specification.
The same canonical markdown files are simultaneously:

- **The source of truth** that coding agents and humans read directly from the repo to understand governing rules, requirements, and design.
- **A self-hosted website** that renders those same files for browsing, with no separate copy to keep in sync.

There is exactly one copy of every canonical document; the website is a rendering of the repo, never a parallel content store.

## Bootstrapping Your Own Spec

Forking or cloning this repo to publish your own atomic specification (any domain, not necessarily about SpecPubSpec itself)? This repo's own `docs/seed-doc.md` currently *is* the SpecPubSpec specification (it dogfoods itself), but nothing about the tooling requires that. `scripts/validate-structure.sh` only checks that `docs/seed-doc.md` contains `## Core`, `## Repository Structure`, and `## Version` section headers — it is domain-agnostic and never checks for specific `REQ-NNN` numbers or content. To publish your own spec:

1. **Prerequisites**: git, Node.js 20 LTS, and npm.
2. **Replace the canonical content**: rewrite `docs/seed-doc.md` with your own specification, keeping the `## Core`, `## Repository Structure`, and `## Version` headers (any content under them is yours to define; you do not need to keep this repo's REQ-001 through REQ-038, which describe SpecPubSpec's own dogfooding, not your domain).
3. **Rename the section headers if they don't fit your domain**: `## Core`/`## Repository Structure`/`## Version` are this repo's own naming choice, not a fixed requirement of the tooling. If your specification calls for different section names, you may rename them — but you must also update the matching literal strings in the `for section in "## Core" "## Repository Structure" "## Version"` check inside `scripts/validate-structure.sh` (search for "Validate docs/seed-doc.md has required sections"), or the build will fail looking for headers that no longer exist.
4. **Leave REQ-016 and REQ-033's checks alone**: the required-directories check (`scripts/`, `site/app/`, `site/components/`) and the requirement that `QUICKSTART.md` contain this Bootstrapping section govern the site-generator scaffold and this onboarding doc itself, not your spec's subject matter — they apply unchanged regardless of your domain.
5. **Review `scripts/audit-repo.sh`'s `EXEMPT_PATHS`**: this reverse-audit script (REQ-017) fails the build if any file or directory on disk isn't either required by `validate-structure.sh` or listed in `audit-repo.sh`'s own `EXEMPT_PATHS` array (currently `.gitignore`, `site/.gitignore`, `LICENSE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md` — hygiene files out of SpecPubSpec's scope). If you add, remove, or rename repo-hygiene files (e.g. add a `CHANGELOG.md`, `NOTICE`, or `.github/ISSUE_TEMPLATE/`), update `EXEMPT_PATHS` to match, or `governance-check.yml` will fail on files it doesn't recognize.
6. **Set code review ownership**: edit `.github/CODEOWNERS`, replacing the existing handle with your own GitHub username or team.
7. **Confirm your default branch**: `.github/workflows/publish-site.yml` deploys on push to `main`; rename that trigger if your repository's default branch is named differently.
8. **Enable GitHub Pages**: in your repository's Settings → Pages, set Source to "GitHub Actions" (a one-time manual step; without it, `publish-site.yml`'s deploy job has nothing to publish to).
9. **Regenerate and validate**: run `scripts/sync-readme.sh` to regenerate `README.md`, then `scripts/validate-structure.sh` and `scripts/audit-repo.sh` to confirm conformance before committing.
10. **Preview locally**, then push to your default branch to trigger `publish-site.yml` — see the Website section below for build/preview commands.

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

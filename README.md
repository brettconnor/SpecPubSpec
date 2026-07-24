seed-doc.md

This site's duel-purpose renders this repository's canonical document directly from its markdown source.

`spechub` is a dual-purpose specification and documentation repository.
The same canonical markdown files are simultaneously:

- **The source of truth** that coding agents and humans read directly from the repo to understand governing rules, requirements, and design.
- **A self-hosted website** that renders those same files for browsing, with no separate copy to keep in sync.

There is exactly one copy of every canonical document; the website is a rendering of the repo, never a parallel content store.

## Canonical document

| Document | Path | Rendered at |
|---|---|---|
| Seed Doc (with Core and Glossary sections) | [`docs/seed-doc.md`](docs/seed-doc.md) | `/` |

Read `AGENTS.md` for the full repository map, markdown authoring rules, and governance notes that apply when editing this file.

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

See [`site/README.md`](site/README.md) for the full build/preview workflow, and `.github/workflows/site-build-check.yml` / `publish-site.yml` for how the site is checked and published in CI.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to report issues and submit pull requests, and [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) for our community standards.
Any pull request that edits `docs/seed-doc.md` must include an updated Sync Impact Report, per `AGENTS.md`'s Seed Doc & Governance Notes.

## Security

See [`SECURITY.md`](SECURITY.md) for how to report a security issue.

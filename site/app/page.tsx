import MarkdownPage from '../components/MarkdownPage';
import DownloadButton from '../components/DownloadButton';
import { loadSeedDoc } from '../lib/content';

/**
 * Single-page site: an intro blurb followed by the one canonical document
 * (the seed doc, folding specification and glossary into a single file)
 * rendered as one flowing document. Nothing here is a separate copy: the
 * body is a rendering of a file that also lives in the repository and that
 * both humans and coding agents read directly.
 */
export default async function HomePage() {
  const seedDoc = await loadSeedDoc();

  return (
    <main className="page-content">
      <DownloadButton 
        content={seedDoc.rawMarkdown}
        filename="seed-doc.md"
      />
      <MarkdownPage
        html={seedDoc.html}
        sourcePath={seedDoc.sourcePath}
        lastModified={seedDoc.lastModified}
      />
    </main>
  );
}

'use client';

interface MarkdownPageProps {
  html: string;
  sourcePath: string;
  lastModified: string | null;
}

/**
 * Shared markdown-to-HTML document renderer.
 * Renders one canonical document as the page body, exposing its
 * `sourcePath` in the footer so a reader can go straight to the
 * authoritative markdown in the repository (Traceability).
 */

export default function MarkdownPage({
  html,
  sourcePath,
  lastModified,
}: MarkdownPageProps) {
  return (
    <section className="page-section">
      <div dangerouslySetInnerHTML={{ __html: html }} />
      <p className="page-footer">
        Source: <code>{sourcePath}</code>
        {lastModified ? ` (last modified ${lastModified})` : ''}
      </p>
    </section>
  );
}

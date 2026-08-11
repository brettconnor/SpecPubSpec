'use client';

interface DownloadButtonProps {
  content: string;
  filename: string;
}

export default function DownloadButton({ content, filename }: DownloadButtonProps) {
  const handleDownload = () => {
    const blob = new Blob([content], { type: 'text/markdown' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  return (
    <button
      onClick={handleDownload}
      style={{
        position: 'fixed',
        top: '1rem',
        right: '1rem',
        background: 'var(--foreground)',
        color: 'var(--background)',
        border: 'none',
        padding: '0.5rem 1rem',
        borderRadius: '0.375rem',
        cursor: 'pointer',
        fontSize: '0.875rem',
        fontWeight: '500',
        zIndex: 1000,
      }}
    >
      ↓ Download MD
    </button>
  );
}

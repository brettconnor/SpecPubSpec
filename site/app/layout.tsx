import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'SpecPubSpec',
  description:
    'A static rendering of this repository\'s canonical seed doc, specification, and glossary.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

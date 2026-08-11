import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Seed Doc',
  description:
    'A static rendering of this repository\'s canonical specification document.',
  icons: {
    icon: '/favicon.ico',
  },
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

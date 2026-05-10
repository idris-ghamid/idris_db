import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { ThemeProvider } from "next-themes";
import "./globals.css";
import { Toaster } from "@/components/ui/toaster";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Idris DB — The Fastest NoSQL Database for Flutter",
  description: "High-performance NoSQL database for Flutter with exclusive developer tools. Enhanced error messages, smart logging, query analyzer, and Arabic support. Built by IDRISIUM Corp.",
  keywords: ["idris_db", "Flutter", "NoSQL", "database", "Isar", "offline-first", "IDRISIUM", "Idris Ghamid", "query analyzer", "Arabic support"],
  authors: [{ name: "Idris Ghamid", url: "https://github.com/IDRISIUMCorp" }],
  icons: {
    icon: "/db-icon.png",
  },
  openGraph: {
    title: "Idris DB — The Fastest NoSQL Database for Flutter",
    description: "High-performance NoSQL database with exclusive developer tools. Built by IDRISIUM Corp.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased bg-background text-foreground`}
      >
        <ThemeProvider attribute="class" defaultTheme="dark" enableSystem>
          <script
            type="application/ld+json"
            dangerouslySetInnerHTML={{
              __html: JSON.stringify({
                "@context": "https://schema.org",
                "@type": "SoftwareSourceCode",
                "name": "idris_db",
                "version": "1.0.5",
                "description": "High-performance NoSQL database for Flutter with exclusive developer tools. Enhanced error messages, smart logging, query analyzer, and Arabic support.",
                "programmingLanguage": "Dart",
                "url": "https://pub.dev/packages/idris_db",
                "codeRepository": "https://github.com/idris-ghamid/idris_db",
                "license": "https://www.apache.org/licenses/LICENSE-2.0",
                "author": {
                  "@type": "Person",
                  "name": "Idris Ghamid",
                  "url": "https://github.com/IDRISIUMCorp"
                },
                "funder": {
                  "@type": "Organization",
                  "name": "IDRISIUM Corp"
                }
              })
            }}
          />
          {children}
          <Toaster />
        </ThemeProvider>
      </body>
    </html>
  );
}

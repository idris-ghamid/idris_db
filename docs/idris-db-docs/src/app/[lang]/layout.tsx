import 'fumadocs-ui/style.css';
import { RootProvider } from 'fumadocs-ui/provider/next';
import { Inter } from 'next/font/google';
import { defineI18nUI } from 'fumadocs-ui/i18n';
import { i18n } from '../../lib/i18n';
import type { ReactNode } from 'react';
import type { Metadata } from 'next';

const inter = Inter({
  subsets: ['latin'],
});

export const metadata: Metadata = {
  title: {
    default: 'idris DB - The Fastest NoSQL Database for Flutter',
    template: '%s | idris DB',
  },
  description: 'idris DB is an enhanced, ultra-fast NoSQL database for Flutter and Dart applications - Built by IDRISIUM Corp',
  keywords: [
    'idris db',
    'idris db flutter',
    'idrisium corp',
    'isar',
    'isar plus',
    'flutter database',
    'dart database',
    'nosql database',
    'mobile database',
    'local storage',
    'flutter storage',
    'embedded database',
    'cross-platform database',
    'arabic database',
  ],
  metadataBase: new URL('https://idris-db-docs.vercel.app'),
  openGraph: {
    title: 'idris DB - The Fastest NoSQL Database for Flutter',
    description: 'idris DB is an enhanced, ultra-fast NoSQL database for Flutter and Dart applications',
    url: 'https://idris-db-docs.vercel.app',
    siteName: 'idris DB',
    locale: 'en_US',
    type: 'website',
    images: [{
      url: 'https://raw.githubusercontent.com/idris-ghamid/idris_db/main/assets/logo.png',
      width: 1200,
      height: 630,
      alt: 'idris DB - The Fastest NoSQL Database for Flutter',
    }],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'idris DB - The Fastest NoSQL Database for Flutter',
    description: 'idris DB is an enhanced, ultra-fast NoSQL database for Flutter and Dart applications',
    images: ['https://raw.githubusercontent.com/idris-ghamid/idris_db/main/assets/logo.png'],
  },
  icons: {
    icon: [
      { url: '/favicon.ico', sizes: 'any' },
      { url: '/logo.png', sizes: '160x160', type: 'image/png' },
    ],
    apple: [
      { url: '/logo.png', sizes: '160x160', type: 'image/png' },
    ],
  },
};

const { provider } = defineI18nUI(i18n, {
  translations: {
    en: {
      displayName: 'English',
      toc: 'Table of Contents',
      search: 'Search in Documents',
      lastUpdate: 'Last Update',
      searchNoResult: 'No results found',
      previousPage: 'Previous Page',
      nextPage: 'Next Page',
      chooseLanguage: 'Choose Language',
    },
    tr: {
      displayName: 'Türkçe',
      toc: 'İçindekiler',
      search: 'Dokümanlarda Ara',
      lastUpdate: 'Son Güncelleme',
      searchNoResult: 'Sonuç bulunamadı',
      previousPage: 'Önceki Sayfa',
      nextPage: 'Sonraki Sayfa',
      chooseLanguage: 'Dil Seçin',
    },
    ar: {
      displayName: 'العربية',
      toc: 'محتويات الصفحة',
      search: 'بحث في التوثيق',
      lastUpdate: 'آخر تحديث',
      searchNoResult: 'لا توجد نتائج',
      previousPage: 'الصفحة السابقة',
      nextPage: 'الصفحة التالية',
      chooseLanguage: 'اختر اللغة',
    },
  },
});

export default async function Layout({
  params,
  children,
}: {
  params: Promise<{ lang: string }>;
  children: ReactNode;
}) {
  const { lang } = await params;

  const websiteSchema = {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'idris DB',
    description: 'Ultra-fast, easy-to-use database for Flutter and Dart applications',
    url: 'https://idris-db-docs.vercel.app',
    potentialAction: {
      '@type': 'SearchAction',
      target: {
        '@type': 'EntryPoint',
        urlTemplate: `https://idris-db-docs.vercel.app/${lang}/docs?search={search_term_string}`,
      },
      'query-input': 'required name=search_term_string',
    },
  };

  const organizationSchema = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'IDRISIUM Corp',
    url: 'https://idrisium.linkpc.net',
    logo: 'https://raw.githubusercontent.com/idris-ghamid/idris_db/main/assets/logo.png',
    sameAs: [
      'https://github.com/idris-ghamid/idris_db',
    ],
  };

  return (
    <html lang={lang} className={inter.className} suppressHydrationWarning>
      <head suppressHydrationWarning>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(websiteSchema) }}
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationSchema) }}
        />
      </head>
      <body
        style={{
          display: 'flex',
          flexDirection: 'column',
          minHeight: '100vh',
        }}
        suppressHydrationWarning
      >
        <RootProvider i18n={provider(lang)}>{children}</RootProvider>
      </body>
    </html>
  );
}

import { RootProvider } from 'fumadocs-ui/provider/next';
import { defineI18nUI } from 'fumadocs-ui/i18n';
import { i18n } from '../../lib/i18n';
import type { ReactNode } from 'react';

const { provider } = defineI18nUI(i18n, {
  translations: {
    en: {
      displayName: 'English',
      search: 'Search Docs',
      toc: 'On this page',
    },
    ar: {
      displayName: 'العربية',
      search: 'بحث في المستندات',
      toc: 'في هذه الصفحة',
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

  return (
    <RootProvider i18n={provider(lang)}>
      {children}
    </RootProvider>
  );
}

export function generateStaticParams() {
  return i18n.languages.map((lang) => ({ lang }));
}

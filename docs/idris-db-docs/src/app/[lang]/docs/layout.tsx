import { DocsLayout } from 'fumadocs-ui/layouts/docs';
import { source } from '../../../lib/source';
import type { ReactNode } from 'react';
import { PackageIcon } from 'lucide-react';

export default async function Layout({
  params,
  children,
}: {
  params: Promise<{ lang: string }>;
  children: ReactNode;
}) {
  const { lang } = await params;

  return (
    <DocsLayout
      tree={source.pageTree[lang]}
      nav={{
        title: (
          <div className="flex items-center gap-2">
            <img src="/logo.png" alt="Logo" className="w-8 h-8" />
            <span className="font-bold text-xl">idris DB</span>
          </div>
        ),
      }}
      links={[
        {
          icon: <PackageIcon />,
          text: 'Pub.dev',
          url: 'https://pub.dev/packages/idris_db',
        },
      ]}
    >
      {children}
    </DocsLayout>
  );
}

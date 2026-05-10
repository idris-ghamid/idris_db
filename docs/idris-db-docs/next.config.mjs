import { createMDX } from 'fumadocs-mdx/next';

const withMDX = createMDX();

/** @type {import('next').NextConfig} */
const config = {
  reactStrictMode: true,
  experimental: {
    turbo: {
      resolveAlias: {
        '@/*': './*',
        'fumadocs-mdx:collections/*': './.source/*',
      },
    },
  },
  // For newer Next.js versions where it might have moved out of experimental
  turbopack: {
    resolveAlias: {
      '@/*': './*',
      'fumadocs-mdx:collections/*': './.source/*',
    },
  },
  async rewrites() {
    return [
      {
        source: '/:lang/docs/:path*.mdx',
        destination: '/:lang/llms.mdx/:path*',
      },
    ];
  },
};

export default withMDX(config);

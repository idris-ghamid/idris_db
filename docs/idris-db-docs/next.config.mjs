import { createMDX } from 'fumadocs-mdx/next';

const withMDX = createMDX();

/** @type {import('next').NextConfig} */
const config = {
  reactStrictMode: true,
  experimental: {
    turbo: {
      resolveAlias: {
        '@/*': './src/*',
        'fumadocs-mdx:collections/*': './.source/*',
      },
    },
  },
  turbopack: {
    resolveAlias: {
      '@/*': './src/*',
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

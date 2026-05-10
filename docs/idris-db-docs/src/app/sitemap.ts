import { MetadataRoute } from 'next';
import { source } from '../lib/source';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
    const baseUrl = 'https://idris-db-docs.vercel.app';
    const languages = ['en', 'tr', 'ar'];

    const urls: MetadataRoute.Sitemap = [
        {
            url: baseUrl,
            lastModified: new Date(),
            changeFrequency: 'monthly',
            priority: 1,
        },
    ];

    // Add home pages for each language
    languages.forEach((lang) => {
        urls.push({
            url: `${baseUrl}/${lang}`,
            lastModified: new Date(),
            changeFrequency: 'monthly',
            priority: 0.9,
        });
    });

    // Add all documentation pages
    languages.forEach((lang) => {
        const pages = source.getPages(lang);
        pages.forEach((page) => {
            let pageUrl = page.url;
            // Ensure the URL is correctly formatted with the language prefix
            if (!pageUrl.startsWith(`/${lang}`)) {
                pageUrl = `/${lang}${pageUrl.startsWith('/') ? '' : '/'}${pageUrl}`;
            }
            urls.push({
                url: `${baseUrl}${pageUrl}`,
                lastModified: new Date(page.data.lastModified ?? new Date()),
                changeFrequency: 'weekly',
                priority: 0.8,
            });
        });
    });

    return urls;
}

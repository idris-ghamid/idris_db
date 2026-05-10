import { getPubVersion } from '@/lib/pub-dev';

// Cache versions at build time
let versionsCache: Record<string, string> | null = null;

export async function getVersions() {
    if (versionsCache) return versionsCache;

    const packages = [
        'idris_db',
        'idris_db_flutter_libs',
        'path_provider',
        'build_runner',
    ];

    const results = await Promise.all(
        packages.map(async (pkg) => ({
            pkg,
            version: await getPubVersion(pkg),
        })),
    );

    versionsCache = results.reduce<Record<string, string>>((acc, { pkg, version }) => {
        acc[pkg] = `^${version}`;
        return acc;
    }, {});

    return versionsCache;
}

// Pre-export for easy use in MDX
export const versions = await getVersions();

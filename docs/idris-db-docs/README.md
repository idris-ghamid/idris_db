# 📚 Idris DB Documentation Website

**Official documentation website for Idris DB - The Fastest NoSQL Database for Flutter**

Built with Next.js 16 + Fumadocs | Deployed on Vercel

🌐 **Live Site:** [idris-db-docs.vercel.app](https://idris-db-docs.vercel.app) *(update with your actual URL)*

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ or 20+ (recommended)
- npm, yarn, or pnpm

### Installation

```bash
# Navigate to docs folder
cd docs/idris-db-docs

# Install dependencies
npm install
# or
yarn install
# or
pnpm install
```

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build & Production

```bash
# Build for production
npm run build

# Start production server
npm start
```

---

## 📦 Vercel Deployment

### Automatic Deployment (Recommended)

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Update documentation"
   git push origin main
   ```

2. **Import in Vercel:**
   - Go to [vercel.com](https://vercel.com)
   - Click "Add New Project"
   - Import your GitHub repository
   - **Root Directory:** Set to `docs/idris-db-docs`
   - **Framework Preset:** Next.js
   - **Build Command:** `npm run build` (auto-detected)
   - **Output Directory:** `.next` (auto-detected)
   - Click "Deploy"

3. **Configure Custom Domain (Optional):**
   - Go to Project Settings → Domains
   - Add your custom domain
   - Update DNS records as instructed

### Manual Deployment

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd docs/idris-db-docs
vercel

# Deploy to production
vercel --prod
```

### Vercel Configuration

The project includes `vercel.json` (if needed):

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "installCommand": "npm install"
}
```

---

## 📁 Project Structure

```
idris-db-docs/
├── app/                    # Next.js 16 app directory
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Home page
│   └── [lang]/            # Internationalization
├── components/             # React components
│   ├── ui/                # UI components
│   └── layout/            # Layout components
├── content/
│   └── docs/              # Documentation content (MDX)
│       ├── index.mdx      # Home page
│       ├── quickstart.mdx # Quick start guide
│       ├── crud.mdx       # CRUD operations
│       ├── queries.mdx    # Queries guide
│       ├── indexes.mdx    # Indexes guide
│       ├── schema.mdx     # Schema guide
│       ├── transactions.mdx
│       ├── watchers.mdx
│       ├── relationships.mdx
│       ├── encryption.mdx
│       ├── backup.mdx
│       ├── faq.mdx
│       ├── limitations.mdx
│       └── recipes/       # Advanced guides
│           ├── full_text_search.mdx
│           ├── data_migration.mdx
│           ├── multi_isolate.mdx
│           ├── string_ids.mdx
│           ├── migrate_from_isar3.mdx
│           └── spm-migration.mdx
├── lib/                   # Utility functions
│   └── source.ts          # Fumadocs source config
├── public/                # Static assets
│   ├── isar.svg          # Logo
│   └── favicon.ico       # Favicon
├── next.config.mjs        # Next.js configuration
├── source.config.ts       # Fumadocs configuration
├── tailwind.config.js     # Tailwind CSS config
├── tsconfig.json          # TypeScript config
└── package.json           # Dependencies
```

---

## 🎨 Customization

### Branding
- **Logo:** `public/isar.svg` (update with Idris DB logo)
- **Favicon:** `public/favicon.ico`
- **Colors:** Edit `tailwind.config.js` or use CSS variables
- **Theme:** Sage green (#73877B) + Charcoal (#212529)

### Content Management

All documentation is written in MDX (Markdown + JSX) in `content/docs/`.

**To add a new page:**

1. Create `content/docs/your-page.mdx`:
   ```mdx
   ---
   title: Your Page Title
   description: Your page description
   icon: BookOpen
   ---

   # Your Content Here

   Write your documentation using Markdown.
   ```

2. Update `content/docs/meta.json` to add to navigation:
   ```json
   {
     "title": "Documentation",
     "pages": [
       "index",
       "quickstart",
       "your-page"
     ]
   }
   ```

3. The page will be available at `/docs/your-page`

### Internationalization

Currently supports:
- **English** (default)
- **Turkish** (.tr.mdx files)

**To add Arabic support:**

1. Create `.ar.mdx` files for each page:
   ```
   content/docs/index.ar.mdx
   content/docs/quickstart.ar.mdx
   ```

2. Update `source.config.ts`:
   ```typescript
   export const source = loader({
     languages: ['en', 'tr', 'ar'],
     // ...
   });
   ```

3. Add Arabic translations to `meta.ar.json` files

---

## 🔧 Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Next.js** | 16.0+ | React framework |
| **Fumadocs** | 16.8+ | Documentation framework |
| **Tailwind CSS** | 4.1+ | Styling |
| **Orama** | 3.1+ | Search functionality |
| **TypeScript** | 5.9+ | Type safety |
| **React** | 19.2+ | UI library |

---

## 🐛 Troubleshooting

### Vercel Build Errors

**Error: "Cannot find module"**
- Solution: Make sure `Root Directory` is set to `docs/idris-db-docs` in Vercel settings

**Error: "Build failed"**
- Check Node.js version (use 18+ or 20+)
- Run `npm run build` locally to test
- Check build logs in Vercel dashboard

**Error: "Module not found: Can't resolve"**
- Run `npm install` to ensure all dependencies are installed
- Check `package.json` for missing dependencies

### Local Development Issues

**Port already in use:**
```bash
# Kill process on port 3000
npx kill-port 3000

# Or use different port
npm run dev -- -p 3001
```

**Build errors:**
```bash
# Clear cache and rebuild
rm -rf .next
npm run build
```

---

## 📝 Content Roadmap

### ✅ Completed
- [x] Basic documentation structure
- [x] Rebranded to Idris DB
- [x] Added 4 exclusive features to homepage
- [x] Updated copyright to IDRISIUM Corp

### 🚧 In Progress
- [ ] Update all "Isar" references to "Idris DB" throughout docs
- [ ] Add dedicated pages for 4 exclusive features
- [ ] Add Arabic language support (.ar.mdx files)

### 📋 Planned

#### High Priority
- [ ] **Feature Documentation:**
  - [ ] Enhanced Error Messages guide
  - [ ] Smart Logging System guide
  - [ ] Query Performance Analyzer guide
  - [ ] Arabic Support guide
- [ ] **Migration Guides:**
  - [ ] From Isar to Idris DB
  - [ ] From Hive to Idris DB
  - [ ] From SQLite to Idris DB
- [ ] **API Reference:**
  - [ ] Complete API documentation
  - [ ] Code examples for all methods
  - [ ] Interactive API explorer

#### Medium Priority
- [ ] Video tutorials
- [ ] Interactive code playground
- [ ] Performance benchmarks page
- [ ] Community showcase
- [ ] Blog section for updates
- [ ] Changelog page

#### Low Priority
- [ ] Dark mode improvements
- [ ] Version selector (v1.0, v1.1, etc.)
- [ ] PDF export functionality
- [ ] Offline documentation
- [ ] Search improvements

---

## 🤝 Contributing

We welcome contributions to improve the documentation!

### How to Contribute

1. **Fork the repository**
2. **Create a branch:**
   ```bash
   git checkout -b docs/improve-quickstart
   ```
3. **Make your changes** in `content/docs/`
4. **Test locally:**
   ```bash
   npm run dev
   ```
5. **Commit and push:**
   ```bash
   git add .
   git commit -m "docs: improve quickstart guide"
   git push origin docs/improve-quickstart
   ```
6. **Create a Pull Request**

### Writing Guidelines

- Use clear, concise language
- Include code examples
- Add screenshots where helpful
- Follow existing formatting
- Test all code examples
- Update meta.json if adding new pages

---

## 📊 Analytics & Monitoring

### Vercel Analytics

Enable analytics in Vercel dashboard:
1. Go to Project Settings → Analytics
2. Enable Web Analytics
3. View metrics in Analytics tab

### Performance Monitoring

- **Lighthouse Score:** Aim for 90+ in all categories
- **Core Web Vitals:** Monitor LCP, FID, CLS
- **Build Time:** Optimize for <2 minutes

---

## 🔐 Environment Variables

No environment variables required for basic deployment.

For advanced features, add in Vercel dashboard:

```env
# Optional: Analytics
NEXT_PUBLIC_ANALYTICS_ID=your_analytics_id

# Optional: Search API
NEXT_PUBLIC_SEARCH_API_KEY=your_search_key
```

---

## 📞 Support & Contact

### For Documentation Issues
- **GitHub Issues:** [github.com/idris-ghamid/idris_db/issues](https://github.com/idris-ghamid/idris_db/issues)
- **Discussions:** [github.com/idris-ghamid/idris_db/discussions](https://github.com/idris-ghamid/idris_db/discussions)

### For General Questions
- **Email:** idris.ghamid@gmail.com
- **Telegram:** [@IDRV72](https://t.me/IDRV72)

---

## 👤 Author

**Idris Ghamid** (إدريس غامد)  
**Founder & Software Architect, IDRISIUM Corp**

- 🌐 Website: [idrisium.linkpc.net](http://idrisium.linkpc.net)
- 💼 LinkedIn: [linkedin.com/in/idris-ghamid](https://www.linkedin.com/in/idris-ghamid)
- 🐙 GitHub: [@idris-ghamid](https://github.com/idris-ghamid)
- 📱 Telegram: [@IDRV72](https://t.me/IDRV72)
- 📧 Email: idris.ghamid@gmail.com

### Social Media
- [Instagram](https://www.instagram.com/idris.ghamid)
- [X/Twitter](https://x.com/IdrisGhamid)
- [TikTok](https://www.tiktok.com/@idris.ghamid)

---

## 📄 License

Apache License 2.0

See [LICENSE](../../LICENSE) file for details.

---

## 🙏 Acknowledgments

Built on top of excellent open-source projects:
- **Isar Plus** by Ahmet Aydın
- **Isar** by Simon Choi
- **Fumadocs** by Fuma Nama
- **Next.js** by Vercel

---

**Built with ❤️ by IDRISIUM Corp**

*Making Flutter development faster and easier, one database at a time.*

---

## 📈 Version History

- **v1.0.0** (May 9, 2026) - Initial documentation site
  - Rebranded from Isar Plus to Idris DB
  - Added 4 exclusive features
  - Updated branding to IDRISIUM Corp
  - Deployed on Vercel

---

**Last Updated:** May 9, 2026

# 📚 Idris DB Documentation Website

**Official documentation website for Idris DB**

Built with Next.js 16 + Fumadocs

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn

### Installation

```bash
cd docs/idris-db-docs
npm install
```

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build

```bash
npm run build
npm start
```

---

## 📁 Project Structure

```
isar-plus-docs/
├── app/                    # Next.js app directory
├── components/             # React components
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
├── public/                # Static assets
├── next.config.mjs        # Next.js configuration
├── source.config.ts       # Fumadocs configuration
└── package.json

```

---

## 🎨 Customization

### Branding
- Logo: `public/isar.svg`
- Favicon: `public/favicon.ico`
- Colors: Edit `tailwind.config.js`

### Content
All documentation is in `content/docs/` as MDX files.

To add a new page:
1. Create `content/docs/your-page.mdx`
2. Add frontmatter:
   ```mdx
   ---
   title: Your Page Title
   description: Your page description
   ---
   ```
3. Update `content/docs/meta.json` to add to navigation

### Languages
Currently supports:
- English (default)
- Turkish (.tr.mdx files)

To add a new language:
1. Create `.{lang}.mdx` files
2. Update `source.config.ts`

---

## 📦 Deployment

### Vercel (Recommended)
1. Push to GitHub
2. Import project in Vercel
3. Deploy automatically

### Other Platforms
```bash
npm run build
npm start
```

Deploy the `.next` folder to your hosting provider.

---

## 🔧 Technologies

- **Framework:** Next.js 16
- **Documentation:** Fumadocs
- **Styling:** Tailwind CSS 4
- **Search:** Orama
- **Language:** TypeScript

---

## 📝 TODO

### High Priority
- [ ] Add Arabic language support (.ar.mdx files)
- [ ] Add pages for 4 exclusive features:
  - [ ] Enhanced Error Messages
  - [ ] Smart Logging System
  - [ ] Query Performance Analyzer
  - [ ] Arabic Support
- [ ] Update all "Isar" references to "Idris DB"
- [ ] Add IDRISIUM Corp branding throughout

### Medium Priority
- [ ] Add code examples for new features
- [ ] Add API reference section
- [ ] Add migration guide from Isar/Hive
- [ ] Add video tutorials
- [ ] Add interactive examples

### Low Priority
- [ ] Add dark mode toggle
- [ ] Add version selector
- [ ] Add changelog page
- [ ] Add community section
- [ ] Add blog section

---

## 👤 Author

**Idris Ghamid** (إدريس غامد)  
**IDRISIUM Corp**

- Email: idris.ghamid@gmail.com
- GitHub: [@idris-ghamid](https://github.com/idris-ghamid)
- Telegram: [@IDRV72](https://t.me/IDRV72)
- Website: [idrisium.linkpc.net](http://idrisium.linkpc.net)

---

## 📄 License

Apache License 2.0

---

**Built with ❤️ by IDRISIUM Corp**

*Making Flutter development faster and easier, one database at a time.*

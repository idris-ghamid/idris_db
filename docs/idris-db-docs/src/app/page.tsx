'use client'

import React, { useState, useEffect, useRef, useCallback } from 'react'
import Link from 'next/link'
import { useTheme } from 'next-themes'
import { motion, useInView, AnimatePresence } from 'framer-motion'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism'

import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Separator } from '@/components/ui/separator'
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
  SheetTrigger,
} from '@/components/ui/sheet'
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion'

import {
  Zap,
  Shield,
  Monitor,
  Search,
  WifiOff,
  Settings,
  Repeat,
  Radio,
  BarChart3,
  AlertTriangle,
  FileText,
  Languages,
  Copy,
  Check,
  Sun,
  Moon,
  Menu,
  Package,
  Terminal,
  ArrowRight,
  ExternalLink,
  Github,
  Linkedin,
  Instagram,
  Twitter,
  Mail,
  Globe,
  Rocket,
  ChevronRight,
  ChevronUp,
  Database,
  Code2,
  Layers,
  Eye,
  Bug,
  Sparkles,
  TrendingUp,
  MessageCircle,
  Star,
  Users,
  Smartphone,
  ShoppingCart,
  ClipboardList,
  Command,
  BookOpen,
  Trophy,
  ArrowUp,
  X,
  Target,
  Clock,
  Heart,
  Lock,
  KeyRound,
  ShieldCheck,
  Download,
  Activity,
  Play,
} from 'lucide-react'

/* ═══════════════════════════════════════════════════════════
   ANIMATION HELPERS
   ═══════════════════════════════════════════════════════════ */

function FadeInSection({ children, className = '', delay = 0 }: { children: React.ReactNode; className?: string; delay?: number }) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-60px' })
  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 30 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 30 }}
      transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1], delay }}
      className={className}
    >
      {children}
    </motion.div>
  )
}

function StaggerContainer({ children, className = '' }: { children: React.ReactNode; className?: string }) {
  return (
    <motion.div
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: '-60px' }}
      variants={{
        hidden: {},
        visible: { transition: { staggerChildren: 0.08 } },
      }}
      className={className}
    >
      {children}
    </motion.div>
  )
}

const staggerChild = {
  hidden: { opacity: 0, y: 24 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5, ease: [0.22, 1, 0.36, 1] } },
}

/* ─── Animated Counter ─── */

function AnimatedCounter({ target, suffix = '' }: { target: number; suffix?: string }) {
  const [count, setCount] = useState(0)
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  useEffect(() => {
    if (!isInView) return
    let start = 0
    const duration = 2000
    const increment = target / (duration / 16)
    const timer = setInterval(() => {
      start += increment
      if (start >= target) {
        setCount(target)
        clearInterval(timer)
      } else {
        setCount(Math.floor(start))
      }
    }, 16)
    return () => clearInterval(timer)
  }, [isInView, target])

  return <span ref={ref}>{count}{suffix}</span>
}

/* ─── Copy Button ─── */

function CopyButton({ text }: { text: string }) {
  const [copied, setCopied] = useState(false)
  const handleCopy = useCallback(async () => {
    await navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }, [text])
  return (
    <button
      onClick={handleCopy}
      className="absolute top-3 right-3 p-1.5 rounded-md bg-white/10 hover:bg-white/20 transition-colors text-muted-foreground hover:text-foreground"
      aria-label="Copy"
    >
      {copied ? <Check className="size-4 text-green-400" /> : <Copy className="size-4" />}
    </button>
  )
}

/* ─── Code Block ─── */

function CodeBlock({ code, language = 'typescript', showCopy = true, filename }: { code: string; language?: string; showCopy?: boolean; filename?: string }) {
  return (
    <div className="relative rounded-xl border border-border/50 bg-[#1e1e1e] overflow-hidden group">
      {filename && (
        <div className="flex items-center justify-between px-4 py-2 bg-white/5 border-b border-white/10">
          <div className="flex items-center gap-2">
            <div className="flex gap-1.5">
              <div className="w-3 h-3 rounded-full bg-red-500/70" />
              <div className="w-3 h-3 rounded-full bg-yellow-500/70" />
              <div className="w-3 h-3 rounded-full bg-green-500/70" />
            </div>
            <span className="text-xs text-gray-500 ml-2 font-mono">{filename}</span>
          </div>
          {showCopy && <CopyButton text={code} />}
        </div>
      )}
      {!filename && showCopy && <CopyButton text={code} />}
      <SyntaxHighlighter
        language={language}
        style={vscDarkPlus}
        customStyle={{
          margin: 0,
          padding: '1.25rem',
          background: 'transparent',
          fontSize: '0.8125rem',
          lineHeight: '1.7',
        }}
        theme={{ plain: {}, styles: [] }}
      >
        {code}
      </SyntaxHighlighter>
    </div>
  )
}

/* ─── Section Heading ─── */

function SectionHeading({ badge, title, description }: { badge?: string; title: string; description?: string }) {
  return (
    <div className="text-center max-w-2xl mx-auto mb-12 md:mb-16">
      {badge && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.4 }}
        >
          <Badge variant="secondary" className="mb-4 px-3 py-1 text-xs font-medium tracking-wide uppercase">
            {badge}
          </Badge>
        </motion.div>
      )}
      <motion.h2
        initial={{ opacity: 0, y: 15 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.5, delay: 0.1 }}
        className="text-3xl md:text-4xl font-bold tracking-tight mb-2"
      >
        {title}
      </motion.h2>
      <div className="section-underline" />
      {description && (
        <motion.p
          initial={{ opacity: 0, y: 10 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="text-muted-foreground text-base md:text-lg leading-relaxed mt-4"
        >
          {description}
        </motion.p>
      )}
    </div>
  )
}

/* ─── Tilt Card (JS-driven 3D) ─── */
function TiltCard({ children, className = '' }: { children: React.ReactNode; className?: string }) {
  const cardRef = useRef<HTMLDivElement>(null)
  const [tilt, setTilt] = useState({ x: 0, y: 0 })
  const [isHovered, setIsHovered] = useState(false)

  const handleMouseMove = useCallback((e: React.MouseEvent<HTMLDivElement>) => {
    if (!cardRef.current) return
    const rect = cardRef.current.getBoundingClientRect()
    const x = (e.clientX - rect.left) / rect.width
    const y = (e.clientY - rect.top) / rect.height
    setTilt({ x: (y - 0.5) * 15, y: (x - 0.5) * 15 })
  }, [])

  const handleMouseLeave = useCallback(() => {
    setIsHovered(false)
    setTilt({ x: 0, y: 0 })
  }, [])

  return (
    <div
      ref={cardRef}
      onMouseEnter={() => setIsHovered(true)}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className={`tilt-card ${className}`}
      style={{
        transform: isHovered ? `perspective(800px) rotateX(${tilt.y}deg) rotateY(${tilt.x}deg) scale3d(1.02)` : 'perspective(800px) rotateX(0deg) rotateY(0deg) scale3d(1)',
        transition: 'transform 0.15s ease-out',
      }}
    >
      {children}
    </div>
  )
}

/* ─── Nav Links ─── */

const navLinks = [
  { label: 'Features', href: '#features' },
  { label: 'Quick Start', href: '#quickstart' },
  { label: 'Playground', href: '#playground' },
  { label: 'Use Cases', href: '#usecases' },
  { label: 'Benchmarks', href: '#benchmarks' },
  { label: 'Compare', href: '#compare' },
  { label: 'Migration', href: '#migration' },
  { label: 'Roadmap', href: '#roadmap' },
  { label: 'FAQ', href: '#faq' },
  { label: 'API', href: '#api' },
  { label: 'Tech Stack', href: '#techstack' },
  { label: 'Showcase', href: '#showcase' },
  { label: 'About', href: '#about' },
]

/* ═══════════════════════════════════════════════════════════
   MARQUEE ITEMS
   ═══════════════════════════════════════════════════════════ */

const marqueeItems = [
  'Flutter Favorite',
  'NoSQL',
  'Offline First',
  'Cross Platform',
  'Type Safe',
  'Lightning Fast',
  'Open Source',
  'Developer Tools',
  'Query Analyzer',
  'Arabic Support',
  'ACID Transactions',
  'Smart Logging',
]

/* ═══════════════════════════════════════════════════════════
   DART CODE EXAMPLES
   ═══════════════════════════════════════════════════════════ */

const installCode = `dependencies:
  idris_db: ^1.0.5

dev_dependencies:
  idris_db_generator: ^1.0.5
  build_runner: ^2.4.0`

const modelCode = `import 'package:idris_db/idris_db.dart';
part 'user.g.dart';

@collection
class User {
  Id? id;

  @Index()
  late String name;

  late int age;

  @Index()
  late String email;
}`

const openDbCode = `// Open the database
final idrisDb = await IdrisDb.open([UserSchema]);`

const generateCode = `// Run code generation
dart run build_runner build`

const createCode = `// Create a new user
final user = User()
  ..name = 'Idris Ghamid'
  ..age = 25
  ..email = 'idris.ghamid@gmail.com';

// Write to database within a transaction
await idrisDb.writeTxn(() async {
  await idrisDb.users.put(user);
});`

const readCode = `// Read all users
final users = await idrisDb.users.where().findAll();

// Read with filter
final adults = await idrisDb.users
    .filter()
    .ageGreaterThan(18)
    .findAll();

// Read single user
final user = await idrisDb.users.get(id);`

const updateCode = `// Update an existing user
await idrisDb.writeTxn(() async {
  user.age = 26;
  user.name = 'Idris Ghamid Updated';
  await idrisDb.users.put(user);
});`

const deleteCode = `// Delete a single user
await idrisDb.writeTxn(() async {
  await idrisDb.users.delete(user.id!);
});

// Delete all users
await idrisDb.writeTxn(() async {
  await idrisDb.users.clear();
});`

const analyzerCode = `final analyzer = QueryAnalyzer(idrisDb);
final analysis = await analyzer.analyze(() {
  return idrisDb.users
      .filter()
      .ageGreaterThan(18)
      .findAll();
});

// Access analysis results
print(analysis.executionTime);
print(analysis.suggestions);
print(analysis.indexRecommendations);`

const arabicCode = `// Switch to Arabic
IdrisDbEnhancedError.language = 'ar';

// Error messages now appear in Arabic
// ❌ خطأ Idris DB [COLLECTION_NOT_FOUND]
// المجموعة "User" غير موجودة في قاعدة البيانات

// Switch back to English
IdrisDbEnhancedError.language = 'en';`

/* ═══════════════════════════════════════════════════════════
   DATA ARRAYS
   ═══════════════════════════════════════════════════════════ */

const features = [
  { icon: Zap, title: 'Blazing Fast', description: '10x faster than Hive with sub-millisecond queries. Optimized batch operations for maximum throughput.' },
  { icon: Shield, title: 'Type Safe', description: 'Full Dart type safety with code generation. Catch errors at compile time, not runtime.' },
  { icon: Monitor, title: 'Cross Platform', description: 'Works seamlessly on Android, iOS, Web, macOS, Windows, and Linux from a single codebase.' },
  { icon: Search, title: 'Advanced Queries', description: 'Powerful indexes, filters, compound queries, sorting, and full-text search capabilities.' },
  { icon: WifiOff, title: 'Offline First', description: '100% offline operation with no server required. Your data lives on the device.' },
  { icon: Settings, title: 'Zero Config', description: 'No setup, no configuration, no boilerplate. Import, define your model, and start coding.' },
  { icon: Repeat, title: 'ACID Transactions', description: 'Full transaction support ensuring data integrity. Atomic commits and rollbacks.' },
  { icon: Radio, title: 'Real-time Watchers', description: 'Watch collections for changes and react instantly with real-time data update streams.' },
  { icon: BarChart3, title: 'Query Analyzer', description: 'Smart query analysis with performance metrics, index suggestions, and optimization tips.' },
  { icon: AlertTriangle, title: 'Enhanced Errors', description: 'Clear, actionable error messages with hints and suggested solutions. No more guessing.' },
  { icon: FileText, title: 'Smart Logging', description: 'Multi-level logging system with query tracking, transaction logs, and performance monitoring.' },
  { icon: Languages, title: 'Arabic Support', description: 'Full bilingual support with English and Arabic error messages, docs, and developer guidance.' },
]

const useCases = [
  { icon: MessageCircle, title: 'Chat Applications', description: 'Store messages, conversations, and user profiles with real-time sync. Perfect for messaging apps with offline support.', tags: ['Real-time', 'Offline', 'Encryption'], gradient: 'from-emerald-500/10 to-teal-500/5' },
  { icon: ShoppingCart, title: 'E-Commerce', description: 'Manage products, cart items, orders, and user preferences locally. Instant loading and smooth checkout experience.', tags: ['Fast Lookup', 'Indexing', 'Transactions'], gradient: 'from-amber-500/10 to-orange-500/5' },
  { icon: ClipboardList, title: 'Task Management', description: 'Organize tasks, projects, and notes with powerful queries and sorting. Filter by status, date, or priority instantly.', tags: ['Filtering', 'Sorting', 'Batch Ops'], gradient: 'from-rose-500/10 to-pink-500/5' },
  { icon: BookOpen, title: 'Note-Taking Apps', description: 'Rich text storage with full-text search capabilities. Auto-save, tags, and categories with sub-ms retrieval.', tags: ['Full-Text Search', 'Auto-Save', 'Tags'], gradient: 'from-violet-500/10 to-purple-500/5' },
  { icon: Users, title: 'Social Media', description: 'Cache user profiles, feeds, and interactions locally. Reduce API calls and provide instant content loading.', tags: ['Caching', 'Watchers', 'Profiles'], gradient: 'from-sky-500/10 to-blue-500/5' },
  { icon: Smartphone, title: 'Fitness & Health', description: 'Track workouts, nutrition, and health metrics with precise time-series data storage and fast aggregations.', tags: ['Time-Series', 'Aggregation', 'Privacy'], gradient: 'from-lime-500/10 to-green-500/5' },
]

const benchmarks = [
  {
    category: 'Write (1,000 docs)',
    icon: Database,
    data: [
      { name: 'Idris DB', value: 98, color: 'bg-primary' },
      { name: 'Hive', value: 35, color: 'bg-muted-foreground/40' },
      { name: 'SQLite', value: 52, color: 'bg-muted-foreground/40' },
      { name: 'ObjectBox', value: 72, color: 'bg-muted-foreground/40' },
    ],
  },
  {
    category: 'Read (1,000 docs)',
    icon: Eye,
    data: [
      { name: 'Idris DB', value: 95, color: 'bg-primary' },
      { name: 'Hive', value: 30, color: 'bg-muted-foreground/40' },
      { name: 'SQLite', value: 55, color: 'bg-muted-foreground/40' },
      { name: 'ObjectBox', value: 68, color: 'bg-muted-foreground/40' },
    ],
  },
  {
    category: 'Update (1,000 docs)',
    icon: Layers,
    data: [
      { name: 'Idris DB', value: 96, color: 'bg-primary' },
      { name: 'Hive', value: 38, color: 'bg-muted-foreground/40' },
      { name: 'SQLite', value: 48, color: 'bg-muted-foreground/40' },
      { name: 'ObjectBox', value: 70, color: 'bg-muted-foreground/40' },
    ],
  },
  {
    category: 'Delete (1,000 docs)',
    icon: FileText,
    data: [
      { name: 'Idris DB', value: 94, color: 'bg-primary' },
      { name: 'Hive', value: 42, color: 'bg-muted-foreground/40' },
      { name: 'SQLite', value: 58, color: 'bg-muted-foreground/40' },
      { name: 'ObjectBox', value: 65, color: 'bg-muted-foreground/40' },
    ],
  },
  {
    category: 'Batch Insert',
    icon: Zap,
    data: [
      { name: 'Idris DB', value: 97, color: 'bg-primary' },
      { name: 'Hive', value: 40, color: 'bg-muted-foreground/40' },
      { name: 'SQLite', value: 50, color: 'bg-muted-foreground/40' },
      { name: 'ObjectBox', value: 75, color: 'bg-muted-foreground/40' },
    ],
  },
]

const comparisons = [
  { feature: 'Performance', idris: '★★★★★', hive: '★★★☆☆', sqlite: '★★★☆☆', objectbox: '★★★★☆' },
  { feature: 'Type Safety', idris: true, hive: false, sqlite: false, objectbox: true },
  { feature: 'Code Generation', idris: true, hive: false, sqlite: false, objectbox: true },
  { feature: 'Offline First', idris: true, hive: true, sqlite: true, objectbox: true },
  { feature: 'ACID Transactions', idris: true, hive: false, sqlite: true, objectbox: true },
  { feature: 'Full-Text Search', idris: true, hive: false, sqlite: true, objectbox: false },
  { feature: 'Real-time Watchers', idris: true, hive: false, sqlite: false, objectbox: false },
  { feature: 'Query Analyzer', idris: true, hive: false, sqlite: false, objectbox: false },
  { feature: 'Arabic Support', idris: true, hive: false, sqlite: false, objectbox: false },
  { feature: 'Enhanced Errors', idris: true, hive: false, sqlite: false, objectbox: false },
  { feature: 'Smart Logging', idris: true, hive: false, sqlite: false, objectbox: false },
  { feature: 'Cross Platform', idris: 'All 6', hive: 'All 6', sqlite: 'All 6', objectbox: '5/6' },
]

const migrationSteps = [
  {
    step: 1,
    title: 'Update pubspec.yaml',
    description: 'Replace Isar packages with Idris DB equivalents',
    isarCode: `dependencies:
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0  # Remove
  isar_generator: ^3.1.0      # → idris_db_generator`,
    idrisCode: `dependencies:
  idris_db: ^1.0.5

dev_dependencies:
  idris_db_generator: ^1.0.5
  build_runner: ^2.4.0`,
  },
  {
    step: 2,
    title: 'Update Imports',
    description: 'Swap Isar imports for Idris DB',
    isarCode: `import 'package:isar/isar.dart';
import 'package:isar/annotations.dart';`,
    idrisCode: `import 'package:idris_db/idris_db.dart';
// That's it! One import.`,
  },
  {
    step: 3,
    title: 'Open Database',
    description: 'Initialize Idris DB the same way you used Isar',
    isarCode: `final isar = await Isar.open(
  [UserSchema],
  directory: dir,
);`,
    idrisCode: `final idrisDb = await IdrisDb.open(
  [UserSchema],
);
// Optional: Enable Arabic error messages
IdrisDbEnhancedError.language = 'ar';`,
  },
  {
    step: 4,
    title: 'Done! Start Coding',
    description: 'Your existing code works. Plus you get new tools.',
    isarCode: `// Your existing Isar code works as-is
await isar.users.put(user);
final users = await isar.users.where()
    .findAll();`,
    idrisCode: `// Same API you already know + extras
await idrisDb.users.put(user);

// NEW: Query Analyzer
final analysis = await QueryAnalyzer(
  idrisDb,
).analyze(() => idrisDb.users.where()
    .findAll());
print(analysis.suggestions);`,
  },
]

const apiMethods = [
  {
    name: 'put()',
    category: 'Write',
    description: 'Insert or update a single object',
    signature: 'Future<Id> put(T object)',
    code: `await idrisDb.users.put(user);`,
  },
  {
    name: 'putAll()',
    category: 'Write',
    description: 'Insert or update multiple objects in a batch',
    signature: 'Future<List<Id>> putAll(List<T> objects)',
    code: `await idrisDb.users.putAll([user1, user2, user3]);`,
  },
  {
    name: 'get()',
    category: 'Read',
    description: 'Get a single object by its ID',
    signature: 'Future<T?> get(Id id)',
    code: `final user = await idrisDb.users.get(id);`,
  },
  {
    name: 'getAll()',
    category: 'Read',
    description: 'Get all objects in a collection',
    signature: 'Future<List<T>> where().findAll()',
    code: `final users = await idrisDb.users.where().findAll();`,
  },
  {
    name: 'delete()',
    category: 'Delete',
    description: 'Delete a single object by its ID',
    signature: 'Future<bool> delete(Id id)',
    code: `await idrisDb.users.delete(user.id!);`,
  },
  {
    name: 'where()',
    category: 'Query',
    description: 'Create a query builder for filtering',
    signature: 'QueryBuilder<T> where()',
    code: `final adults = await idrisDb.users
    .filter()
    .ageGreaterThan(18)
    .nameEqualTo('Idris')
    .sortByName()
    .findAll();`,
  },
  {
    name: 'watch()',
    category: 'Reactive',
    description: 'Watch a collection for real-time changes',
    signature: 'Stream<List<T>> watch()',
    code: `idrisDb.users.where().watch().listen((users) {
  print('Users changed: \${users.length}');
});`,
  },
  {
    name: 'writeTxn()',
    category: 'Transaction',
    description: 'Execute operations in an atomic transaction',
    signature: 'Future<T> writeTxn<T>(Future<T> fn())',
    code: `await idrisDb.writeTxn(() async {
  await idrisDb.users.put(user);
  await idrisDb.logs.put(log);
});`,
  },
]

const roadmapPhases = [
  {
    version: 'v1.0',
    status: 'Current',
    statusColor: 'bg-green-500',
    dotColor: 'bg-green-500',
    date: 'Released',
    features: [
      'Isar-powered NoSQL engine',
      'Full CRUD with type safety',
      'ACID transactions',
      'Advanced queries with indexes',
      'Real-time watchers',
      'Query Performance Analyzer',
      'Enhanced error messages (EN/AR)',
      'Smart logging system',
    ],
  },
  {
    version: 'v1.1',
    status: 'Q2 2025',
    statusColor: 'bg-yellow-500',
    dotColor: 'bg-yellow-500',
    date: 'Next',
    features: [
      'Data Validation Framework',
      'Backup & Restore tools',
      'Query result caching',
      'Real-time database stats',
      'Development mode with debugging',
    ],
  },
  {
    version: 'v1.5',
    status: 'Q3 2025',
    statusColor: 'bg-blue-500',
    dotColor: 'bg-blue-500',
    date: 'Planned',
    features: [
      'Export/Import tools (JSON & CSV)',
      'Visual database inspector',
      'Migration management system',
      'Encryption at rest',
    ],
  },
  {
    version: 'v2.0',
    status: 'Q4 2025',
    statusColor: 'bg-purple-500',
    dotColor: 'bg-purple-500',
    date: 'Planned',
    features: [
      'Cloud sync integration',
      'Multi-collection joins',
      'GraphQL adapter',
      'Desktop app for management',
    ],
  },
  {
    version: 'v3.0',
    status: '2026',
    statusColor: 'bg-muted-foreground/40',
    dotColor: 'bg-muted-foreground/40',
    date: 'Future',
    features: [
      'Distributed database support',
      'AI-powered query optimization',
      'Plugin ecosystem',
      'And 40+ more features',
    ],
  },
]

const changelog = [
  {
    version: 'v1.0.5',
    date: 'May 2025',
    type: 'Patch',
    typeColor: 'bg-green-500/10 text-green-600 dark:text-green-400 border-green-500/20',
    changes: [
      'Improved Query Analyzer accuracy',
      'Added Arabic auto-detection for device locale',
      'Fixed edge case in transaction rollback',
      'Updated documentation with new examples',
    ],
  },
  {
    version: 'v1.0.3',
    date: 'April 2025',
    type: 'Patch',
    typeColor: 'bg-green-500/10 text-green-600 dark:text-green-400 border-green-500/20',
    changes: [
      'Added multi-language logging support',
      'Fixed batch operation memory leak',
      'Enhanced code generation reliability',
    ],
  },
  {
    version: 'v1.0.2',
    date: 'April 2025',
    type: 'Minor',
    typeColor: 'bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/20',
    changes: [
      'New Query Analyzer feature',
      'Improved error hint suggestions',
      'Performance optimization for large collections',
    ],
  },
  {
    version: 'v1.0.0',
    date: 'March 2025',
    type: 'Major',
    typeColor: 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20',
    changes: [
      'Initial release',
      'Full Isar compatibility',
      'Enhanced error messages (EN/AR)',
      'Smart logging system',
      'Cross-platform support (6 platforms)',
    ],
  },
]


const faqs = [
  {
    q: 'What is Idris DB?',
    a: 'Idris DB is a high-performance NoSQL database package for Flutter and Dart, built on top of Isar. It includes exclusive developer tools like a Query Performance Analyzer, enhanced bilingual error messages (English & Arabic), smart logging, and a zero-config API.',
  },
  {
    q: 'How do I install Idris DB?',
    a: "Add idris_db to your pubspec.yaml dependencies and idris_db_generator to dev_dependencies. Run 'flutter pub get', define your models with @collection, run 'dart run build_runner build', and you're ready to go.",
  },
  {
    q: 'Is Idris DB free and open source?',
    a: "Yes! Idris DB is completely free and open source under the Apache 2.0 license. You can use it in personal and commercial projects without any restrictions.",
  },
  {
    q: 'Which platforms are supported?',
    a: 'Idris DB supports Android, iOS, Web, macOS, Windows, and Linux — all 6 major platforms from a single Dart codebase. No platform-specific code required.',
  },
  {
    q: 'Does Idris DB support Arabic out of the box?',
    a: "Yes! Simply set IdrisDbEnhancedError.language = 'ar' or let it auto-detect from the device locale. All error messages, hints, and suggested solutions will appear in Arabic.",
  },
  {
    q: 'Does Idris DB support encryption?',
    a: 'Idris DB inherits Isar\'s AES-256 encryption support. You can encrypt your entire database or individual collections with a single configuration option during database opening.',
  },
  {
    q: 'How do I migrate from Isar to Idris DB?',
    a: 'Migration is simple: replace Isar packages with Idris DB in pubspec.yaml, swap the import from "package:isar/isar.dart" to "package:idris_db/idris_db.dart", and run build_runner. Your existing schemas and data remain compatible.',
  },
  {
    q: 'How does Idris DB compare in performance?',
    a: 'Idris DB delivers performance on par with Isar (one of the fastest Flutter databases) and outperforms Hive, SQLite, and ObjectBox in most benchmarks. Check our Benchmarks section for detailed comparisons.',
  },
]

const socials = [
  { icon: Github, label: 'GitHub', href: 'https://github.com/idris-ghamid' },
  { icon: Linkedin, label: 'LinkedIn', href: 'https://www.linkedin.com/in/idris-ghamid' },
  { icon: Twitter, label: 'X / Twitter', href: 'https://x.com/IdrisGhamid' },
  { icon: Instagram, label: 'Instagram', href: 'https://www.instagram.com/idris.ghamid' },
  { icon: Mail, label: 'Email', href: 'mailto:idris.ghamid@gmail.com' },
]


/* ─── Security Features ─── */
const securityFeatures = [
  { icon: Lock, title: 'AES-256 Encryption', description: 'Industry-standard encryption for your entire database or individual collections. Your data stays private.', tag: 'Privacy' },
  { icon: KeyRound, title: 'Access Control', description: 'Secure database access with configurable permissions. Control who can read, write, and modify data.', tag: 'Control' },
  { icon: ShieldCheck, title: 'Data Integrity', description: 'ACID transactions guarantee your data is never corrupted. Atomic commits and rollbacks protect every operation.', tag: 'Reliability' },
  { icon: WifiOff, title: 'On-Device Storage', description: 'All data stays on the device. No server communication, no data leaks. Perfect for sensitive applications.', tag: 'Offline' },
  { icon: FileText, title: 'Audit Logging', description: 'Comprehensive logging tracks every database operation. Full transparency for compliance and debugging.', tag: 'Compliance' },
  { icon: Zap, title: 'Zero-Knowledge', description: 'Idris DB never phones home. No analytics, no tracking, no telemetry. Your data is truly yours.', tag: 'Trust' },
]

/* ─── Playground Examples ─── */
const playgroundExamples = [
  {
    title: 'Create & Query Users',
    description: 'Insert a user and query with filters',
    code: `final user = User()
  ..name = 'Idris Ghamid'
  ..age = 25
  ..email = 'idris@example.com';

await idrisDb.writeTxn(() async {
  await idrisDb.users.put(user);
});

final adults = await idrisDb.users
    .filter()
    .ageGreaterThan(18)
    .findAll();`,
    output: [
      { type: 'info', text: '$ idris_db playground' },
      { type: 'success', text: '✓ Transaction committed (0.12ms)' },
      { type: 'info', text: '✓ User inserted — id: 1' },
      { type: 'value', text: '→ Query returned 1 result in 0.08ms' },
      { type: 'info', text: '  User(id:1, name:"Idris Ghamid", age:25)' },
    ],
  },
  {
    title: 'Watch for Changes',
    description: 'Real-time reactive data streams',
    code: `idrisDb.users.where().watch().listen((users) {
  print('Users changed: \${users.length}');
  for (final user in users) {
    print('  - \${user.name} (age: \${user.age})');
  }
});`,
    output: [
      { type: 'info', text: '$ idris_db playground' },
      { type: 'success', text: '✓ Watcher active — listening for changes...' },
      { type: 'value', text: '→ Change detected!' },
      { type: 'info', text: '  Users changed: 2' },
      { type: 'info', text: '  - Idris Ghamid (age: 25)' },
      { type: 'info', text: '  - Sarah Chen (age: 28)' },
    ],
  },
  {
    title: 'Query Analyzer',
    description: 'Measure and optimize query performance',
    code: `final analyzer = QueryAnalyzer(idrisDb);
final analysis = await analyzer.analyze(() {
  return idrisDb.users
      .filter()
      .ageGreaterThan(18)
      .nameEqualTo('Idris')
      .findAll();
});

print(analysis.executionTime);
print(analysis.indexRecommendations);`,
    output: [
      { type: 'info', text: '$ idris_db playground' },
      { type: 'success', text: '⚡ Analysis complete' },
      { type: 'value', text: '  Execution time: 0.34ms (Excellent)' },
      { type: 'info', text: '  Index: age — HIT ✓' },
      { type: 'info', text: '  Records scanned: 1,247' },
      { type: 'value', text: '  💡 Suggestion: Add composite index (age, name)' },
    ],
  },
]


/* ─── Technology Stack Cards ─── */
const techStack = [
  { name: 'Flutter', icon: Smartphone, description: 'Built for Flutter — the most popular cross-platform framework' },
  { name: 'Dart', icon: Code2, description: 'Native Dart with type-safe code generation' },
  { name: 'Isar', icon: Database, description: 'Powered by Isar — the fastest Flutter database engine' },
  { name: 'Prisma', icon: Layers, description: 'Prisma-compatible code generation and modeling' },
  { name: 'Figma', icon: Target, description: 'Design-first with Figma integration support' },
  { name: 'VS Code', icon: Terminal, description: 'First-class VS Code extension for Idris DB' },
]



// Performance metrics
const perfMetrics = [
  { label: 'Lighthouse Score', value: 98, suffix: '/100', color: '#73877B' },
  { label: 'First Paint', value: 0.4, suffix: 's', color: '#8fa896' },
  { label: 'Bundle Size', value: 45, suffix: 'KB', color: '#a3b8aa' },
  { label: 'Query Speed', value: 0.02, suffix: 'ms', color: '#73877B' },
]

// Floating TOC sections
const tocSections = [
  { id: 'features', label: 'Features' },
  { id: 'quickstart', label: 'Quick Start' },
  { id: 'playground', label: 'Playground' },
  { id: 'benchmarks', label: 'Benchmarks' },
  { id: 'compare', label: 'Compare' },
  { id: 'api', label: 'API' },
  { id: 'videos', label: 'Videos' },
  { id: 'faq', label: 'FAQ' },
]

/* ═══════════════════════════════════════════════════════════
   MAIN PAGE COMPONENT
   ═══════════════════════════════════════════════════════════ */

export default function Home() {
  const { theme, setTheme } = useTheme()
  const [mobileOpen, setMobileOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)
  const [activeSection, setActiveSection] = useState('')
  const [scrollProgress, setScrollProgress] = useState(0)
  const [faqSearch, setFaqSearch] = useState('')
  const [activeApiMethod, setActiveApiMethod] = useState<string | null>(null)
  const [showBackToTop, setShowBackToTop] = useState(false)
  const [themeRotating, setThemeRotating] = useState(false)
  const [activePlayground, setActivePlayground] = useState(0)
  const [playgroundRunning, setPlaygroundRunning] = useState(false)
  const [playgroundOutput, setPlaygroundOutput] = useState<typeof playgroundExamples[0]['output']>([])
  const [cmdOpen, setCmdOpen] = useState(false)
  const [cmdSearch, setCmdSearch] = useState('')
  const [installCopied, setInstallCopied] = useState(false)
  const [cmdActiveIndex, setCmdActiveIndex] = useState(0)

  /* ─── Effects ─── */

  useEffect(() => {
    const onScroll = () => {
      setScrolled(window.scrollY > 20)
      setShowBackToTop(window.scrollY > 600)
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    const onScrollProgress = () => {
      const totalHeight = document.documentElement.scrollHeight - window.innerHeight
      setScrollProgress(totalHeight > 0 ? (window.scrollY / totalHeight) * 100 : 0)
    }
    window.addEventListener('scroll', onScrollProgress, { passive: true })
    return () => window.removeEventListener('scroll', onScrollProgress)
  }, [])

  useEffect(() => {
    const sectionIds = navLinks.map((l) => l.href.replace('#', ''))
    const observers: IntersectionObserver[] = []

    sectionIds.forEach((id) => {
      const el = document.getElementById(id)
      if (!el) return
      const observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) {
            setActiveSection(id)
          }
        },
        { rootMargin: '-40% 0px -55% 0px' }
      )
      observer.observe(el)
      observers.push(observer)
    })

    return () => observers.forEach((o) => o.disconnect())
  }, [])

  // Mouse spotlight effect
  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      document.documentElement.style.setProperty('--mouse-x', `${e.clientX}px`)
      document.documentElement.style.setProperty('--mouse-y', `${e.clientY}px`)
    }
    window.addEventListener('mousemove', handleMouseMove)
    return () => window.removeEventListener('mousemove', handleMouseMove)
  }, [])

  // Command Palette keyboard shortcut
  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setCmdOpen((prev) => !prev)
      }
      if (e.key === 'Escape') {
        setCmdOpen(false)
      }
    }
    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [])

  const scrollTo = useCallback((href: string) => {
    setMobileOpen(false)
    const el = document.querySelector(href)
    el?.scrollIntoView({ behavior: 'smooth' })
  }, [])

  const scrollToTop = useCallback(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }, [])

  const toggleTheme = useCallback(() => {
    setThemeRotating(true)
    setTheme(theme === 'dark' ? 'light' : 'dark')
    setTimeout(() => setThemeRotating(false), 500)
  }, [theme, setTheme])

  const copyInstallCommand = useCallback(() => {
    navigator.clipboard.writeText('idris_db: ^1.0.5')
    setInstallCopied(true)
    setTimeout(() => setInstallCopied(false), 2000)
  }, [])

  /* ═══════════════════════════════════════════════════════════
     SECTION 1: NAVIGATION
     ═══════════════════════════════════════════════════════════ */

  const Navigation = (
    <motion.header
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-background/80 backdrop-blur-xl border-b border-border/50 shadow-sm'
          : 'bg-transparent'
      }`}
    >
      <div className="scroll-progress" style={{ width: `${scrollProgress}%` }} />
      <nav className="max-w-7xl mx-auto flex items-center justify-between h-16 px-4 md:px-6">
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="relative">
            <img src="/db-icon.png" alt="Idris DB" className="size-8 rounded-md" />
            <div className="absolute -inset-1 rounded-md bg-primary/20 blur-sm opacity-0 group-hover:opacity-100 transition-opacity" />
          </div>
          <span className="font-semibold text-lg tracking-tight">
            Idris <span className="gradient-text">DB</span>
          </span>
        </Link>

        <div className="hidden lg:flex items-center gap-0.5">
          {navLinks.map((link) => {
            const isActive = activeSection === link.href.replace('#', '')
            return (
              <button
                key={link.href}
                onClick={() => scrollTo(link.href)}
                className={`px-2.5 py-2 text-sm transition-colors rounded-md hover:bg-muted/50 ${
                  isActive
                    ? 'text-foreground font-medium border-b-2 border-primary'
                    : 'text-muted-foreground hover:text-foreground border-b-2 border-transparent'
                }`}
              >
                {link.label}
              </button>
            )
          })}
        </div>

        <div className="flex items-center gap-2">
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            onClick={toggleTheme}
            className="size-9 rounded-lg flex items-center justify-center hover:bg-muted/50 transition-colors text-muted-foreground hover:text-foreground"
          >
            <motion.div
              animate={{ rotate: themeRotating ? 180 : 0 }}
              transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
            >
              <AnimatePresence mode="wait">
                {theme === 'dark' ? (
                  <motion.div key="sun" initial={{ opacity: 0, scale: 0.5 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.5 }} transition={{ duration: 0.2 }}>
                    <Sun className="size-4" />
                  </motion.div>
                ) : (
                  <motion.div key="moon" initial={{ opacity: 0, scale: 0.5 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.5 }} transition={{ duration: 0.2 }}>
                    <Moon className="size-4" />
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
            <span className="sr-only">Toggle theme</span>
          </motion.button>

          {/* Command Palette Trigger */}
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => setCmdOpen(true)}
            className="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs text-muted-foreground border border-border/50 hover:border-primary/30 hover:text-foreground transition-colors"
            aria-label="Open command palette"
          >
            <Search className="size-3" />
            <span>Search</span>
            <kbd className="cmd-kbd">⌘K</kbd>
          </motion.button>

          <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
            <SheetTrigger asChild>
              <button className="lg:hidden size-9 rounded-lg flex items-center justify-center hover:bg-muted/50 transition-colors text-muted-foreground">
                <Menu className="size-4" />
              </button>
            </SheetTrigger>
            <SheetContent side="right" className="w-72">
              <SheetHeader>
                <SheetTitle className="flex items-center gap-2">
                  <img src="/db-icon.png" alt="" className="size-6 rounded" />
                  Idris DB
                </SheetTitle>
                <SheetDescription>Navigation</SheetDescription>
              </SheetHeader>
              <div className="flex flex-col gap-1 px-4">
                {navLinks.map((link) => {
                  const isActive = activeSection === link.href.replace('#', '')
                  return (
                    <button
                      key={link.href}
                      onClick={() => scrollTo(link.href)}
                      className={`flex items-center gap-3 px-3 py-2.5 text-sm rounded-lg transition-colors ${
                        isActive
                          ? 'text-foreground bg-primary/10 font-medium'
                          : 'text-muted-foreground hover:text-foreground hover:bg-muted/50'
                      }`}
                    >
                      {link.label}
                    </button>
                  )
                })}
                <Separator className="my-3" />
                <Link
                  href="https://pub.dev/packages/idris_db"
                  target="_blank"
                  className="flex items-center gap-2 px-3 py-2.5 text-sm text-primary hover:underline"
                >
                  <Package className="size-4" /> pub.dev
                </Link>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </nav>
    </motion.header>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 2: HERO
     ═══════════════════════════════════════════════════════════ */

  const HeroSection = (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden pt-16 noise-overlay">
      <div className="absolute inset-0 hero-mesh" />
      <div className="absolute inset-0 hero-grid" />

      {/* Morphing blob */}
      <div className="absolute top-1/3 left-1/4 w-72 h-72 md:w-[500px] md:h-[500px] bg-primary/8 rounded-full morph-blob blur-3xl pointer-events-none" />

      {/* Floating orbs */}
      <div className="absolute top-1/4 left-[15%] size-48 md:size-72 rounded-full bg-primary/6 blur-3xl pointer-events-none orb-1" />
      <div className="absolute bottom-1/3 right-[10%] size-56 md:size-80 rounded-full bg-primary/5 blur-3xl pointer-events-none orb-2" />

      <div className="relative z-10 max-w-5xl mx-auto px-4 py-20 md:py-32 text-center">
        {/* Version badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
        >
          <Badge variant="secondary" className="mb-6 px-4 py-1.5 text-xs font-medium pulse-glow">
            <Sparkles className="size-3 mr-1.5" /> v1.0.5 — Query Analyzer &amp; Arabic Support
          </Badge>
        </motion.div>

        {/* H1 Title */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.1, ease: [0.22, 1, 0.36, 1] }}
          className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight leading-[1.1] mb-6"
        >
          The Developer-First
          <br />
          <span className="gradient-text">Database</span> for Flutter
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
          className="text-muted-foreground text-base md:text-lg lg:text-xl max-w-2xl mx-auto mb-8 leading-relaxed"
        >
          High-performance NoSQL database built on Isar with exclusive developer tools.
          Enhanced error messages, smart logging, query analyzer, and full Arabic support.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.3, ease: [0.22, 1, 0.36, 1] }}
          className="flex flex-col sm:flex-row items-center justify-center gap-3 mb-10"
        >
          <motion.div whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.97 }}>
            <Button size="lg" className="h-12 px-8 text-sm font-medium magnetic-btn" onClick={() => scrollTo('#quickstart')}>
              <Rocket className="size-4 mr-2" /> Get Started <ArrowRight className="size-4 ml-1.5" />
            </Button>
          </motion.div>
          <motion.div whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.97 }}>
            <Button variant="outline" size="lg" className="h-12 px-8 text-sm font-medium" asChild>
              <a href="https://pub.dev/packages/idris_db" target="_blank" rel="noopener noreferrer">
                <Package className="size-4 mr-2" /> View on pub.dev <ExternalLink className="size-3.5 ml-1.5" />
              </a>
            </Button>
          </motion.div>
        </motion.div>

        {/* Install Command */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.4, ease: [0.22, 1, 0.36, 1] }}
          className="max-w-lg mx-auto mb-12"
        >
          <div className="relative rounded-xl border border-border/50 bg-[#1e1e1e] overflow-hidden gradient-border-anim">
                <button
                  onClick={copyInstallCommand}
                  className="copy-btn-enhanced flex items-center gap-1.5 px-2.5 py-1.5 rounded-md text-xs text-muted-foreground hover:text-foreground transition-colors"
                  aria-label="Copy install command"
                >
                  {installCopied ? <Check className="size-3 text-primary" /> : <Copy className="size-3" />}
                  {installCopied ? 'Copied!' : 'Copy'}
                </button>
            <div className="px-5 py-3.5 font-mono text-sm text-gray-300">
              <span className="text-green-400">$</span> flutter pub add idris_db<span className="typing-cursor" />
            </div>
          </div>
        </motion.div>

        {/* Platform Pills */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.45, ease: [0.22, 1, 0.36, 1] }}
          className="flex flex-wrap items-center justify-center gap-2.5 mb-10"
        >
          {[
            { name: 'Android', icon: Smartphone },
            { name: 'iOS', icon: Smartphone },
            { name: 'Web', icon: Globe },
            { name: 'macOS', icon: Monitor },
            { name: 'Windows', icon: Monitor },
            { name: 'Linux', icon: Terminal },
          ].map((p) => (
            <motion.div
              key={p.name}
              whileHover={{ scale: 1.05, y: -2 }}
              className="px-3.5 py-1.5 rounded-full border border-border/50 bg-card/50 backdrop-blur-sm text-xs font-medium text-muted-foreground flex items-center gap-1.5 hover:border-primary/30 transition-colors"
            >
              <p.icon className="size-3" />
              {p.name}
            </motion.div>
          ))}
        </motion.div>

        {/* Animated Stats */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.5, ease: [0.22, 1, 0.36, 1] }}
          className="flex flex-wrap items-center justify-center gap-6 md:gap-10 mb-10"
        >
          {[
            { icon: Zap, value: 10, suffix: 'x', label: 'Faster' },
            { icon: Monitor, value: 6, suffix: '', label: 'Platforms' },
            { icon: WifiOff, value: 100, suffix: '%', label: 'Offline' },
            { icon: Shield, value: 100, suffix: '%', label: 'Type Safe' },
          ].map((stat) => (
            <div key={stat.label} className="stat-card flex items-center gap-2.5 text-sm text-muted-foreground px-4 py-2.5 rounded-xl bg-card/30 backdrop-blur-sm border border-border/30">
              <div className="size-8 rounded-lg bg-primary/10 flex items-center justify-center">
                <stat.icon className="size-4 text-primary" />
              </div>
              <div>
                <span className="font-bold text-foreground"><AnimatedCounter target={stat.value} suffix={stat.suffix} /></span>
                <span className="ml-1">{stat.label}</span>
              </div>
            </div>
          ))}
        </motion.div>

        {/* pub.dev Score Badges */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.6, ease: [0.22, 1, 0.36, 1] }}
          className="flex flex-wrap items-center justify-center gap-3"
        >
          {[
            { label: 'pub.dev', value: '100', color: 'bg-green-500/10 text-green-600 dark:text-green-400 border-green-500/20', icon: Trophy },
            { label: 'Likes', value: '42', color: 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-500/20', icon: Heart },
            { label: 'Popularity', value: '85%', color: 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20', icon: TrendingUp },
          ].map((badge) => (
            <div key={badge.label} className={`score-badge flex items-center gap-2 px-3.5 py-1.5 rounded-full border text-xs font-medium ${badge.color}`}>
              <badge.icon className="size-3" />
              <span>{badge.label}: {badge.value}</span>
            </div>
          ))}
        </motion.div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.2, duration: 0.8 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2 scroll-indicator"
      >
        <div className="w-6 h-10 rounded-full border-2 border-muted-foreground/25 flex items-start justify-center p-1.5">
          <div className="w-1.5 h-2.5 rounded-full bg-primary/60" />
        </div>
      </motion.div>

      {/* 8 Floating Particles */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[
          { left: '10%', top: '15%', size: 3, cls: 'float-slow stagger-1' },
          { left: '25%', top: '35%', size: 2, cls: 'float-medium stagger-2' },
          { left: '40%', top: '20%', size: 4, cls: 'float-fast stagger-3' },
          { left: '55%', top: '45%', size: 2, cls: 'float-slow stagger-4' },
          { left: '70%', top: '15%', size: 3, cls: 'float-medium stagger-5' },
          { left: '85%', top: '30%', size: 2, cls: 'float-fast stagger-6' },
          { left: '15%', top: '65%', size: 3, cls: 'float-medium stagger-7' },
          { left: '75%', top: '60%', size: 2, cls: 'float-slow stagger-8' },
        ].map((p, i) => (
          <div
            key={i}
            className={`absolute rounded-full bg-primary/25 ${p.cls}`}
            style={{
              left: p.left,
              top: p.top,
              width: `${p.size}px`,
              height: `${p.size}px`,
            }}
          />
        ))}
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 3: MARQUEE TRUST STRIP
     ═══════════════════════════════════════════════════════════ */

  const MarqueeSection = (
    <section className="relative py-6 overflow-hidden border-y border-border/30 bg-muted/20">
      <div className="absolute inset-0 overflow-hidden">
        <div className="marquee flex whitespace-nowrap">
          {[...marqueeItems, ...marqueeItems].map((item, i) => (
            <span key={i} className="inline-flex items-center gap-2 mx-4 md:mx-6 text-sm font-medium text-muted-foreground">
              <span className="size-1.5 rounded-full bg-primary/60" />
              {item}
            </span>
          ))}
        </div>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 4: FEATURES
     ═══════════════════════════════════════════════════════════ */

  const FeaturesSection = (
    <section id="features" className="py-24 md:py-32 section-bg-warm">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Features"
            title="Everything You Need"
            description="Built on Isar with exclusive enhancements — Idris DB gives you more than just a database. Developer tools that actually help you build better."
          />
        </FadeInSection>

        <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-5">
          {features.map((feature) => (
            <motion.div key={feature.title} variants={staggerChild}>
              <Card className="feature-card-3d shimmer h-full border-border/50 hover:border-primary/30 bg-card/50 backdrop-blur-sm gradient-border-anim breathing-card">
                <CardContent className="pt-6">
                  <div className="size-11 rounded-xl bg-primary/10 flex items-center justify-center mb-4 icon-glow-ring">
                    <feature.icon className="size-5 text-primary" />
                  </div>
                  <h3 className="font-semibold text-base mb-2">{feature.title}</h3>
                  <p className="text-muted-foreground text-sm leading-relaxed">{feature.description}</p>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </StaggerContainer>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 5: WHY IDRIS DB
     ═══════════════════════════════════════════════════════════ */

  const whyCards = [
    {
      icon: Bug,
      title: 'Errors You Can Fix',
      description: 'Every error message includes the exact problem, a clear hint, and a copy-paste solution. In both English and Arabic.',
      gradient: 'from-primary/80 to-primary/20',
    },
    {
      icon: TrendingUp,
      title: 'Queries You Can Optimize',
      description: 'The built-in Query Analyzer measures performance, detects missing indexes, and suggests specific optimizations.',
      gradient: 'from-primary/60 to-primary/20',
    },
    {
      icon: Languages,
      title: 'Arabic, By Default',
      description: 'The first Flutter database with full Arabic error messages. Auto-detects device locale and switches languages seamlessly.',
      gradient: 'from-primary/40 to-primary/20',
    },
  ]

  const WhySection = (
    <section className="py-24 md:py-32 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Why Idris DB?"
            title="Not Just Another Database"
            description="We didn't just fork Isar. We reimagined what a developer-first database experience should look like."
          />
        </FadeInSection>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {whyCards.map((card, i) => (
            <FadeInSection key={card.title} delay={i * 0.1}>
              <motion.div
                whileHover={{ y: -6 }}
                transition={{ duration: 0.3 }}
              >
                <Card className="h-full border-border/50 hover:border-primary/30 glass-premium overflow-hidden group card-reveal">
                  <div className={`h-1 bg-gradient-to-r ${card.gradient}`} />
                  <CardContent className="pt-6">
                    <div className="size-14 rounded-2xl bg-primary/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform duration-300">
                      <card.icon className="size-7 text-primary" />
                    </div>
                    <h3 className="font-semibold text-lg mb-2">{card.title}</h3>
                    <p className="text-muted-foreground text-sm leading-relaxed">{card.description}</p>
                  </CardContent>
                </Card>
              </motion.div>
            </FadeInSection>
          ))}
        </div>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 6: QUICK START
     ═══════════════════════════════════════════════════════════ */

  const QuickStartSection = (
    <section id="quickstart" className="py-24 md:py-32 bg-muted/30 section-bg-cool">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Quick Start"
            title="Up and Running in Minutes"
            description="From installation to your first query — Idris DB gets you building faster than any other Flutter database solution."
          />
        </FadeInSection>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12">
          {/* Left: Timeline */}
          <FadeInSection delay={0.1}>
            <div className="space-y-6">
              <h3 className="text-xl font-semibold mb-6 flex items-center gap-2">
                <Terminal className="size-5 text-primary" /> Installation
              </h3>

              {[
                { num: 1, title: 'Add to pubspec.yaml', code: installCode, lang: 'yaml', filename: 'pubspec.yaml' },
                { num: 2, title: 'Install dependencies', code: 'flutter pub get', lang: 'bash', filename: undefined },
                { num: 3, title: 'Define your model', code: modelCode, filename: 'user.dart' },
                { num: 4, title: 'Generate & open database', code: null, filename: undefined },
              ].map((step, idx) => (
                <div key={step.num} className="flex gap-4">
                  <div className="flex flex-col items-center">
                    <motion.div
                      whileInView={{ scale: [0.8, 1] }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.3, delay: idx * 0.1 }}
                      className="size-9 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm font-bold shrink-0 pulse-glow"
                    >
                      {step.num}
                    </motion.div>
                    {idx < 3 && <div className="w-px flex-1 bg-gradient-to-b from-primary/50 to-transparent mt-2" />}
                  </div>
                  <div className={idx < 3 ? 'pb-6' : ''}>
                    <h4 className="font-medium mb-2">{step.title}</h4>
                    {step.code && (
                      <CodeBlock code={step.code} language={step.lang} filename={step.filename} />
                    )}
                    {!step.code && step.num === 4 && (
                      <div className="space-y-3">
                        <CodeBlock code={generateCode} language="bash" filename="terminal" />
                        <CodeBlock code={openDbCode} filename="main.dart" />
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </FadeInSection>

          {/* Right: CRUD Tabs */}
          <FadeInSection delay={0.2}>
            <div className="sticky top-24">
              <h3 className="text-xl font-semibold mb-6 flex items-center gap-2">
                <Code2 className="size-5 text-primary" /> CRUD Operations
              </h3>
              <Tabs defaultValue="create" className="w-full">
                <TabsList className="w-full grid grid-cols-4">
                  {['create', 'read', 'update', 'delete'].map((val) => (
                    <TabsTrigger key={val} value={val} className="tab-glow capitalize">{val}</TabsTrigger>
                  ))}
                </TabsList>
                <TabsContent value="create">
                  <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }}>
                    <CodeBlock code={createCode} filename="create_user.dart" />
                  </motion.div>
                </TabsContent>
                <TabsContent value="read">
                  <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }}>
                    <CodeBlock code={readCode} filename="read_user.dart" />
                  </motion.div>
                </TabsContent>
                <TabsContent value="update">
                  <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }}>
                    <CodeBlock code={updateCode} filename="update_user.dart" />
                  </motion.div>
                </TabsContent>
                <TabsContent value="delete">
                  <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }}>
                    <CodeBlock code={deleteCode} filename="delete_user.dart" />
                  </motion.div>
                </TabsContent>
              </Tabs>
            </div>
          </FadeInSection>
        </div>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 7: QUERY ANALYZER
     ═══════════════════════════════════════════════════════════ */

  const QueryAnalyzerSection = (
    <section className="py-24 md:py-32 bg-muted/30 dot-pattern">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Developer Tools"
            title="Query Performance Analyzer"
            description="Understand your queries. The built-in analyzer measures execution time, detects missing indexes, and provides actionable optimization suggestions."
          />
        </FadeInSection>

        <FadeInSection delay={0.1}>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <CodeBlock code={analyzerCode} filename="analyzer_example.dart" />

            <div className="rounded-xl border border-border/50 bg-card/50 backdrop-blur-sm p-6 space-y-4">
              <div className="flex items-center gap-2 mb-2">
                <BarChart3 className="size-5 text-primary" />
                <h3 className="font-semibold">Analysis Output</h3>
              </div>

              {[
                { icon: '⚡', title: 'Execution Time', desc: '0.34ms — Excellent performance', bg: 'bg-muted/50' },
                { icon: '📊', title: 'Query Complexity', desc: 'O(n) linear scan — 1,247 records scanned', bg: 'bg-muted/50' },
                { icon: '✅', title: 'Index Used', desc: 'age index hit — 0 full scans required', bg: 'bg-green-500/5 border border-green-500/20', titleColor: 'text-green-600 dark:text-green-400' },
                { icon: '💡', title: 'Suggestion', desc: 'Consider adding a composite index on (age, name) for this filter pattern.', bg: 'bg-yellow-500/5 border border-yellow-500/20', titleColor: 'text-yellow-600 dark:text-yellow-400' },
                { icon: '🔧', title: 'Index Recommendation', desc: 'Add @Index(composite: [CompositeIndex(\'age\')]) to the User model for 3x faster lookups.', bg: 'bg-muted/50' },
              ].map((item) => (
                <motion.div
                  key={item.title}
                  whileHover={{ x: 4 }}
                  className={`flex items-start gap-3 p-3 rounded-lg ${item.bg} transition-all duration-200 cursor-default`}
                >
                  <span className="text-lg">{item.icon}</span>
                  <div>
                    <p className={`text-sm font-medium ${item.titleColor || ''}`}>{item.title}</p>
                    <p className="text-xs text-muted-foreground">{item.desc}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 8: ARABIC SUPPORT
     ═══════════════════════════════════════════════════════════ */

  const ArabicSection = (
    <section className="py-24 md:py-32">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="العربية"
            title="Full Bilingual Support"
            description="Idris DB is the first Flutter database package to offer complete Arabic language support for error messages, logs, and developer guidance."
          />
        </FadeInSection>

        <FadeInSection delay={0.1}>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
            <div className="space-y-4">
              <div className="flex items-center gap-2 text-sm text-muted-foreground mb-2">
                <Code2 className="size-4" /> Language Switching
              </div>
              <CodeBlock code={arabicCode} filename="i18n_setup.dart" />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <motion.div whileHover={{ y: -4 }} transition={{ duration: 0.2 }}>
                <div className="rounded-xl border border-border/50 bg-card/50 backdrop-blur-sm p-5 text-center h-full">
                  <div className="text-xs uppercase tracking-wider text-muted-foreground mb-3 font-medium">English</div>
                  <div className="p-3 rounded-lg bg-red-500/5 border border-red-500/10 font-mono text-xs text-left">
                    <p className="text-red-500 font-semibold">❌ Idris DB Error</p>
                    <p className="text-muted-foreground mt-1">[COLLECTION_NOT_FOUND]</p>
                    <p className="mt-1">Collection &quot;User&quot; does not exist in the database.</p>
                  </div>
                </div>
              </motion.div>
              <motion.div whileHover={{ y: -4 }} transition={{ duration: 0.2 }}>
                <div className="rounded-xl border border-border/50 bg-card/50 backdrop-blur-sm p-5 text-center h-full">
                  <div className="text-xs uppercase tracking-wider text-muted-foreground mb-3 font-medium" dir="rtl">العربية</div>
                  <div className="p-3 rounded-lg bg-red-500/5 border border-red-500/10 font-mono text-xs text-right" dir="rtl">
                    <p className="text-red-500 font-semibold">❌ خطأ Idris DB</p>
                    <p className="text-muted-foreground mt-1">[COLLECTION_NOT_FOUND]</p>
                    <p className="mt-1">المجموعة &quot;User&quot; غير موجودة في قاعدة البيانات.</p>
                  </div>
                </div>
              </motion.div>
            </div>
          </div>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 9: BENCHMARKS
     ═══════════════════════════════════════════════════════════ */

  function BenchmarkBar({ name, value, isIdris }: { name: string; value: number; isIdris: boolean }) {
    const ref = useRef(null)
    const isInView = useInView(ref, { once: true, margin: '-40px' })

    return (
      <div ref={ref} className="flex items-center gap-3">
        <span className="text-xs text-muted-foreground w-20 shrink-0 text-right">{name}</span>
        <div className="flex-1 h-4 rounded-full bg-muted/50 overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={isInView ? { width: `${value}%` } : { width: 0 }}
            transition={{ duration: 1.2, ease: [0.22, 1, 0.36, 1], delay: 0.2 }}
            className={`h-full rounded-full benchmark-bar ${isIdris ? 'bg-primary' : 'bg-muted-foreground/30'}`}
          />
        </div>
        <span className={`text-xs font-mono w-10 ${isIdris ? 'text-primary font-bold' : 'text-muted-foreground'}`}>{value}%</span>
      </div>
    )
  }

  const BenchmarksSection = (
    <section id="benchmarks" className="py-24 md:py-32 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Performance"
            title="Performance That Speaks"
            description="Measured across real-world Flutter applications. Idris DB consistently delivers the fastest operations across all categories."
          />
        </FadeInSection>

        <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {benchmarks.map((bench) => (
            <motion.div key={bench.category} variants={staggerChild}>
              <Card className="card-spotlight border-border/50 bg-card/50 backdrop-blur-sm h-full">
                <CardContent className="pt-6">
                  <div className="flex items-center gap-2.5 mb-5">
                    <div className="size-9 rounded-lg bg-primary/10 flex items-center justify-center">
                      <bench.icon className="size-4 text-primary" />
                    </div>
                    <h3 className="font-semibold text-sm">{bench.category}</h3>
                  </div>
                  <div className="space-y-3">
                    {bench.data.map((item) => (
                      <BenchmarkBar key={item.name} name={item.name} value={item.value} isIdris={item.name === 'Idris DB'} />
                    ))}
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </StaggerContainer>

        <FadeInSection delay={0.3}>
          <p className="text-center text-xs text-muted-foreground mt-8">
            * Benchmark scores represent relative performance. Higher is better. Measured on Pixel 7 with 10,000 records.
          </p>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 10: USE CASES
     ═══════════════════════════════════════════════════════════ */

  const UseCasesSection = (
    <section id="usecases" className="py-24 md:py-32">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Use Cases"
            title="Built for Real Apps"
            description="From chat apps to e-commerce — Idris DB powers the data layer for any Flutter application."
          />
        </FadeInSection>

        <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {useCases.map((useCase) => (
            <motion.div key={useCase.title} variants={staggerChild}>
              <TiltCard>
                <Card className="usecase-card h-full border-border/50 bg-card/50 backdrop-blur-sm overflow-hidden group">
                <div className={`h-1.5 bg-gradient-to-r ${useCase.gradient}`} />
                <CardContent className="pt-6">
                  <div className="size-12 rounded-xl bg-primary/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform duration-300">
                    <useCase.icon className="size-6 text-primary" />
                  </div>
                  <h3 className="font-semibold text-lg mb-2">{useCase.title}</h3>
                  <p className="text-muted-foreground text-sm leading-relaxed mb-4">{useCase.description}</p>
                  <div className="flex flex-wrap gap-2">
                    {useCase.tags.map((tag) => (
                      <span key={tag} className="px-2.5 py-0.5 rounded-full bg-primary/5 text-[10px] font-medium text-primary border border-primary/10">
                        {tag}
                      </span>
                    ))}
                  </div>
                </CardContent>
              </Card>
              </TiltCard>
            </motion.div>
          ))}
        </StaggerContainer>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 11: COMPARISON TABLE
     ═══════════════════════════════════════════════════════════ */

  const ComparisonSection = (
    <section id="compare" className="py-24 md:py-32 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Compare"
            title="How Does Idris DB Stack Up?"
            description="A side-by-side feature comparison with popular Flutter database solutions."
          />
        </FadeInSection>

        <FadeInSection delay={0.1}>
          <div className="rounded-xl border border-border/50 bg-card/50 backdrop-blur-sm overflow-hidden">
            {/* Header */}
            <div className="grid grid-cols-5 text-xs font-semibold uppercase tracking-wider bg-muted/50 border-b border-border/50">
              <div className="p-4 text-muted-foreground">Feature</div>
              {[
                { name: 'Idris DB', highlight: true },
                { name: 'Hive', highlight: false },
                { name: 'SQLite', highlight: false },
                { name: 'ObjectBox', highlight: false },
              ].map((db) => (
                <div key={db.name} className={`p-4 text-center ${db.highlight ? 'bg-primary/5 text-primary' : 'text-muted-foreground'}`}>
                  {db.name}
                </div>
              ))}
            </div>
            {/* Rows */}
            <div className="divide-y divide-border/30">
              {comparisons.map((row, i) => (
                <motion.div
                  key={row.feature}
                  initial={{ opacity: 0 }}
                  whileInView={{ opacity: 1 }}
                  viewport={{ once: true }}
                  transition={{ delay: i * 0.03, duration: 0.3 }}
                  className="grid grid-cols-5 text-sm hover:bg-muted/30 transition-colors"
                >
                  <div className="p-3 md:p-4 font-medium text-foreground">{row.feature}</div>
                  {(['idris', 'hive', 'sqlite', 'objectbox'] as const).map((db) => {
                    const val = row[db]
                    const isIdris = db === 'idris'
                    return (
                      <div key={db} className={`p-3 md:p-4 text-center ${isIdris ? 'bg-primary/5 text-primary font-medium' : 'text-muted-foreground'}`}>
                        {typeof val === 'boolean' ? (
                          val ? <Check className="size-4 mx-auto text-green-500" /> : <X className="size-4 mx-auto text-muted-foreground/30" />
                        ) : (
                          <span className="text-xs">{val}</span>
                        )}
                      </div>
                    )
                  })}
                </motion.div>
              ))}
            </div>
          </div>
        </FadeInSection>

        <FadeInSection delay={0.2}>
          <p className="text-center text-xs text-muted-foreground mt-6">
            Comparison based on publicly available documentation as of 2025. Idris DB includes all Isar features plus exclusive enhancements.
          </p>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 12: MIGRATION GUIDE
     ═══════════════════════════════════════════════════════════ */

  const MigrationSection = (
    <section id="migration" className="py-24 md:py-32">
      <div className="max-w-6xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Migration"
            title="Migrate from Isar in Minutes"
            description="Migrate in under 5 minutes. Your existing schemas and data stay compatible. Just swap the package."
          />
        </FadeInSection>

        <div className="space-y-8">
          {migrationSteps.map((item, i) => (
            <FadeInSection key={item.step} delay={i * 0.1}>
              <Card className="migration-card border-border/50 bg-card/50 backdrop-blur-sm">
                <CardContent className="pt-6">
                  <div className="flex items-center gap-3 mb-5">
                    <div className="size-9 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm font-bold shrink-0">
                      {item.step}
                    </div>
                    <div>
                      <h3 className="font-semibold">{item.title}</h3>
                      <p className="text-xs text-muted-foreground">{item.description}</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-2 h-2 rounded-full bg-red-400" />
                        <span className="text-xs font-medium text-muted-foreground">Isar (Before)</span>
                      </div>
                      <CodeBlock code={item.isarCode} language="dart" showCopy={false} />
                    </div>
                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-2 h-2 rounded-full bg-green-400" />
                        <span className="text-xs font-medium text-primary">Idris DB (After)</span>
                      </div>
                      <CodeBlock code={item.idrisCode} language="dart" showCopy={false} />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </FadeInSection>
          ))}
        </div>

        <FadeInSection delay={0.5}>
          <div className="mt-8 text-center">
            <p className="text-sm text-muted-foreground">
              That&apos;s it! No data migration, no schema changes, no code rewrites.{' '}
              <span className="text-primary font-medium">Just swap and ship.</span>
            </p>
          </div>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 13: API EXPLORER
     ═══════════════════════════════════════════════════════════ */

  const APIExplorerSection = (
    <section id="api" className="py-24 md:py-32 bg-muted/30 dot-pattern">
      <div className="max-w-6xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="API Explorer"
            title="Methods at a Glance"
            description="Quick reference for the most commonly used Idris DB methods. Click any method to see the code."
          />
        </FadeInSection>

        <FadeInSection delay={0.1}>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {apiMethods.map((method) => (
              <motion.div
                key={method.name}
                layout
                className={`api-method-card rounded-xl border border-border/50 bg-card/50 backdrop-blur-sm p-5 cursor-pointer ${
                  activeApiMethod === method.name ? 'active' : ''
                }`}
                onClick={() => setActiveApiMethod(activeApiMethod === method.name ? null : method.name)}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <code className="text-sm font-bold text-primary">{method.name}</code>
                    <span className="px-2 py-0.5 rounded-full bg-primary/10 text-[10px] font-medium text-primary">{method.category}</span>
                  </div>
                  <motion.div
                    animate={{ rotate: activeApiMethod === method.name ? 180 : 0 }}
                    transition={{ duration: 0.2 }}
                  >
                    <ChevronUp className="size-4 text-muted-foreground" />
                  </motion.div>
                </div>
                <p className="text-xs text-muted-foreground mb-1">{method.description}</p>
                <p className="text-[10px] text-muted-foreground/60 font-mono">{method.signature}</p>
                <AnimatePresence>
                  {activeApiMethod === method.name && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      transition={{ duration: 0.2 }}
                      className="overflow-hidden"
                    >
                      <div className="mt-3">
                        <CodeBlock code={method.code} language="dart" showCopy={true} />
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            ))}
          </div>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 14: ROADMAP
     ═══════════════════════════════════════════════════════════ */

  const RoadmapSection = (
    <section id="roadmap" className="py-24 md:py-32">
      <div className="max-w-4xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Roadmap"
            title="What's Coming Next"
            description="Idris DB is actively developed with regular updates. Here's a look at our development timeline."
          />
        </FadeInSection>

        <div className="relative">
          <div className="absolute left-[1.125rem] md:left-1/2 top-0 bottom-0 w-px bg-gradient-to-b from-primary/50 via-primary/20 to-transparent" />

          <div className="space-y-10">
            {roadmapPhases.map((phase, i) => (
              <FadeInSection key={phase.version} delay={i * 0.1}>
                <div className={`relative flex flex-col md:flex-row gap-6 md:gap-12 ${i % 2 === 1 ? 'md:flex-row-reverse' : ''}`}>
                  <div className="absolute left-[0.5rem] md:left-1/2 md:-translate-x-1/2 top-1 z-10">
                    <div className={`size-5 rounded-full ${phase.dotColor} ring-4 ring-background`} />
                  </div>

                  <div className={`ml-12 md:ml-0 md:w-1/2 ${i % 2 === 1 ? 'md:text-left' : 'md:text-right'}`}>
                    <Card className="border-border/50 bg-card/50 backdrop-blur-sm hover:border-primary/30 transition-colors">
                      <CardContent className="pt-6">
                        <div className={`flex items-center gap-2 mb-3 ${i % 2 === 1 ? '' : 'md:justify-end'}`}>
                          <Badge className={`${phase.statusColor} text-white border-0 text-[10px] px-2 py-0`}>
                            {phase.status}
                          </Badge>
                          <span className="font-bold text-lg">{phase.version}</span>
                        </div>
                        <ul className="space-y-1.5">
                          {phase.features.map((f) => (
                            <li key={f} className="text-sm text-muted-foreground flex items-start gap-2">
                              <ChevronRight className="size-3.5 text-primary shrink-0 mt-0.5" />
                              {f}
                            </li>
                          ))}
                        </ul>
                      </CardContent>
                    </Card>
                  </div>

                  <div className="hidden md:block md:w-1/2" />
                </div>
              </FadeInSection>
            ))}
          </div>
        </div>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 15: CHANGELOG
     ═══════════════════════════════════════════════════════════ */

  const ChangelogSection = (
    <section className="py-24 md:py-32 bg-muted/30">
      <div className="max-w-3xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Changelog"
            title="Version History"
            description="Every improvement, every fix. Track the evolution of Idris DB."
          />
        </FadeInSection>

        <div className="space-y-4">
          {changelog.map((entry, i) => (
            <FadeInSection key={entry.version} delay={i * 0.08}>
              <Card className="changelog-entry border-border/50 bg-card/50">
                <CardContent className="pt-6">
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-3">
                      <span className="font-bold text-lg">{entry.version}</span>
                      <span className={`px-2 py-0.5 rounded-full text-[10px] font-medium border ${entry.typeColor}`}>
                        {entry.type}
                      </span>
                    </div>
                    <span className="text-xs text-muted-foreground">{entry.date}</span>
                  </div>
                  <ul className="space-y-1.5">
                    {entry.changes.map((change) => (
                      <li key={change} className="text-sm text-muted-foreground flex items-start gap-2">
                        <ChevronRight className="size-3.5 text-primary shrink-0 mt-0.5" />
                        {change}
                      </li>
                    ))}
                  </ul>
                </CardContent>
              </Card>
            </FadeInSection>
          ))}
        </div>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 18: FAQ
     ═══════════════════════════════════════════════════════════ */

  const filteredFaqs = faqs.filter((faq) =>
    faq.q.toLowerCase().includes(faqSearch.toLowerCase()) ||
    faq.a.toLowerCase().includes(faqSearch.toLowerCase())
  )

  const FAQSection = (
    <section id="faq" className="py-24 md:py-32">
      <div className="max-w-3xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="FAQ"
            title="Frequently Asked Questions"
            description="Everything you need to know about Idris DB. Can't find an answer? Reach out to us."
          />
        </FadeInSection>

        <FadeInSection delay={0.1}>
          <div className="relative mb-6">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
            <input
              type="text"
              placeholder="Search questions..."
              value={faqSearch}
              onChange={(e) => setFaqSearch(e.target.value)}
              className="faq-search w-full pl-10 pr-4 py-3 rounded-xl border border-border/50 bg-card/50 backdrop-blur-sm text-sm placeholder:text-muted-foreground/60 focus:outline-none"
            />
          </div>

          <Accordion type="single" collapsible className="space-y-3">
            {filteredFaqs.map((faq, i) => (
              <AccordionItem key={i} value={`faq-${i}`} className="border-border/50 rounded-xl px-6 data-[state=open]:bg-card/50 transition-colors">
                <AccordionTrigger className="text-sm font-medium text-left hover:no-underline">
                  {faq.q}
                </AccordionTrigger>
                <AccordionContent className="text-sm text-muted-foreground leading-relaxed">
                  {faq.a}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>

          {faqSearch && filteredFaqs.length === 0 && (
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-center text-sm text-muted-foreground py-8"
            >
              No questions found matching &quot;{faqSearch}&quot;
            </motion.p>
          )}
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 20: SECURITY & ENCRYPTION
     ═══════════════════════════════════════════════════════════ */

  const SecuritySection = (
    <section className="py-24 md:py-32 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Security"
            title="Your Data, Protected"
            description="Security is not an afterthought. Idris DB provides multiple layers of protection for your sensitive data."
          />
        </FadeInSection>

        {/* Hero security card */}
        <FadeInSection delay={0.1}>
          <div className="relative rounded-2xl border border-primary/20 bg-primary/5 p-8 md:p-10 mb-10 shield-glow overflow-hidden">
            <div className="absolute inset-0 hero-grid opacity-20 pointer-events-none" />
            <div className="absolute top-4 right-4 float-badge">
              <Badge variant="secondary" className="px-3 py-1 text-xs font-medium bg-primary/15 border border-primary/20">
                <Shield className="size-3 mr-1" /> Enterprise-Grade
              </Badge>
            </div>
            <div className="relative z-10 flex flex-col md:flex-row items-center gap-6">
              <div className="size-16 rounded-2xl bg-primary/10 flex items-center justify-center shrink-0">
                <Shield className="size-8 text-primary" />
              </div>
              <div className="text-center md:text-left">
                <h3 className="text-xl font-bold mb-2">AES-256 Encryption at Rest</h3>
                <p className="text-muted-foreground text-sm leading-relaxed max-w-xl">
                  Idris DB inherits Isar's full AES-256 encryption support. Encrypt your entire database
                  or individual collections with a single configuration option during database opening.
                  Your users' data never leaves the device unencrypted.
                </p>
              </div>
              <div className="shrink-0 hidden md:block">
                <CodeBlock
                  code={`// Enable encryption
final idrisDb = await IdrisDb.open(
  [UserSchema],
  encryptionKey: mySecretKey,
);`}
                  language="dart"
                />
              </div>
            </div>
          </div>
        </FadeInSection>

        {/* Security feature grid */}
        <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {securityFeatures.map((feat) => (
            <motion.div key={feat.title} variants={staggerChild}>
              <Card className="hover-lift h-full border-border/50 hover:border-primary/30 bg-card/50 backdrop-blur-sm">
                <CardContent className="pt-6">
                  <div className="flex items-start justify-between mb-4">
                    <div className="size-11 rounded-xl bg-primary/10 flex items-center justify-center">
                      <feat.icon className="size-5 text-primary" />
                    </div>
                    <Badge variant="outline" className="text-[10px] font-medium feature-tag cursor-default border-border/50 text-muted-foreground">
                      {feat.tag}
                    </Badge>
                  </div>
                  <h3 className="font-semibold text-base mb-2">{feat.title}</h3>
                  <p className="text-muted-foreground text-sm leading-relaxed">{feat.description}</p>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </StaggerContainer>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 21: INTERACTIVE PLAYGROUND
     ═══════════════════════════════════════════════════════════ */

  const runPlayground = useCallback((index: number) => {
    setPlaygroundRunning(true)
    setPlaygroundOutput([])
    const lines = playgroundExamples[index].output
    lines.forEach((line, i) => {
      setTimeout(() => {
        setPlaygroundOutput((prev) => [...prev, line])
        if (i === lines.length - 1) {
          setTimeout(() => setPlaygroundRunning(false), 300)
        }
      }, (i + 1) * 400)
    })
  }, [])

  const PlaygroundSection = (
    <section id="playground" className="py-24 md:py-32 grid-pattern">
      <div className="max-w-7xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Try It Live"
            title="Interactive Playground"
            description="See Idris DB in action. Select an example, hit run, and watch the output appear in real-time."
          />
        </FadeInSection>

        <FadeInSection delay={0.1}>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
            {/* Example Selector */}
            <div className="space-y-3">
              {playgroundExamples.map((ex, i) => (
                <motion.button
                  key={ex.title}
                  whileHover={{ x: 4 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => { setActivePlayground(i); setPlaygroundOutput([]); }}
                  className={`w-full text-left p-4 rounded-xl border transition-all duration-200 ${
                    activePlayground === i
                      ? 'border-primary/40 bg-primary/5 breathing-card'
                      : 'border-border/50 bg-card/50 hover:border-primary/20 hover:bg-muted/30'
                  }`}
                >
                  <div className="flex items-center gap-3 mb-1">
                    <div className={`size-8 rounded-lg flex items-center justify-center shrink-0 ${activePlayground === i ? 'bg-primary/15' : 'bg-muted/50'}`}>
                      <Play className={`size-3.5 ${activePlayground === i ? 'text-primary' : 'text-muted-foreground'}`} />
                    </div>
                    <div>
                      <h4 className={`text-sm font-medium ${activePlayground === i ? 'text-foreground' : 'text-muted-foreground'}`}>{ex.title}</h4>
                      <p className="text-xs text-muted-foreground/70">{ex.description}</p>
                    </div>
                  </div>
                </motion.button>
              ))}

              {/* Run Button */}
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => runPlayground(activePlayground)}
                disabled={playgroundRunning}
                className="w-full h-11 rounded-xl bg-primary text-primary-foreground font-medium text-sm flex items-center justify-center gap-2 hover:opacity-90 transition-opacity disabled:opacity-50 disabled:cursor-not-allowed magnetic-btn"
              >
                {playgroundRunning ? (
                  <>
                    <motion.div animate={{ rotate: 360 }} transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}>
                      <Terminal className="size-4" />
                    </motion.div>
                    Running...
                  </>
                ) : (
                  <>
                    <Play className="size-4" /> Run Code
                  </>
                )}
              </motion.button>
            </div>

            {/* Code + Output */}
            <div className="lg:col-span-2 space-y-4">
              {/* Code Block */}
              <div className="playground-terminal">
                <div className="terminal-header">
                  <div className="flex gap-1.5">
                    <div className="w-3 h-3 rounded-full bg-red-500/70" />
                    <div className="w-3 h-3 rounded-full bg-yellow-500/70" />
                    <div className="w-3 h-3 rounded-full bg-green-500/70" />
                  </div>
                  <span className="text-xs text-gray-500 ml-2 font-mono">{playgroundExamples[activePlayground].title.toLowerCase().replace(/\s+/g, '_')}.dart</span>
                  <CopyButton text={playgroundExamples[activePlayground].code} />
                </div>
                <div className="terminal-body">
                  <SyntaxHighlighter
                    language="dart"
                    style={vscDarkPlus}
                    customStyle={{ margin: 0, padding: 0, background: 'transparent', fontSize: '0.8125rem', lineHeight: '1.7' }}
                    theme={{ plain: {}, styles: [] }}
                  >
                    {playgroundExamples[activePlayground].code}
                  </SyntaxHighlighter>
                </div>
              </div>

              {/* Output Block */}
              <div className="playground-terminal">
                <div className="terminal-header">
                  <span className="text-xs text-gray-500 font-mono">Output</span>
                  <div className="ml-auto flex items-center gap-1.5">
                    <div className={`w-2 h-2 rounded-full ${playgroundRunning ? 'bg-green-500 animate-pulse' : playgroundOutput.length > 0 ? 'bg-green-500' : 'bg-gray-600'}`} />
                    <span className="text-[10px] text-gray-500 font-mono">{playgroundRunning ? 'running' : playgroundOutput.length > 0 ? 'done' : 'idle'}</span>
                  </div>
                </div>
                <div className="terminal-body min-h-[160px]">
                  {playgroundOutput.length === 0 && !playgroundRunning ? (
                    <div className="text-gray-600 text-sm py-4 text-center">
                      Click &quot;Run Code&quot; to see the output here...
                    </div>
                  ) : (
                    <div className="space-y-1">
                      {playgroundOutput.map((line, i) => (
                        <motion.div
                          key={i}
                          initial={{ opacity: 0, x: -8 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ duration: 0.2 }}
                          className={`output-line text-xs font-mono ${
                            line.type === 'success' ? 'output-success' :
                            line.type === 'value' ? 'output-value' : 'output-info'
                          }`}
                        >
                          {line.text}
                        </motion.div>
                      ))}
                      {playgroundRunning && (
                        <motion.span
                          animate={{ opacity: [1, 0] }}
                          transition={{ duration: 0.5, repeat: Infinity }}
                          className="inline-block w-2 h-4 bg-primary/60 ml-1"
                        />
                      )}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION: PERFORMANCE METRICS
     ═══════════════════════════════════════════════════════════ */

  const PerformanceSection = (
    <section className="py-16 md:py-20 bg-muted/30">
      <div className="max-w-5xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Performance"
            title="Built for Speed"
            description="Every millisecond counts. Idris DB is optimized for lightning-fast data operations."
          />
        </FadeInSection>

        <StaggerContainer className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {perfMetrics.map((metric) => {
            const percentage = Math.min(metric.value * (metric.suffix === 'KB' ? 1.2 : metric.suffix === 'ms' ? 500 : metric.suffix === 's' ? 100 : 1), 100)
            const circumference = 2 * Math.PI * 40
            const offset = circumference - (percentage / 100) * circumference
            return (
              <motion.div key={metric.label} variants={staggerChild} className="flex flex-col items-center gap-3">
                <div className="perf-ring relative">
                  <svg viewBox="0 0 96 96" className="w-full h-full -rotate-90">
                    <circle cx="48" cy="48" r="40" className="perf-ring-circle perf-ring-bg" />
                    <circle cx="48" cy="48" r="40" className="perf-ring-circle perf-ring-fill"
                      strokeDasharray={circumference}
                      strokeDashoffset={offset} />
                  </svg>
                  <div className="absolute inset-0 flex items-center justify-center">
                    <span className="text-lg font-bold text-primary">{metric.value}</span>
                  </div>
                </div>
                <span className="text-[10px] text-muted-foreground font-medium">{metric.label}</span>
                <span className="text-xs font-semibold">{metric.suffix}</span>
              </motion.div>
            )
          })}
        </StaggerContainer>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION: TECHNOLOGY STACK
     ═══════════════════════════════════════════════════════════ */

  const TechStackSection = (
    <section id="techstack" className="py-20 md:py-24 dot-grid-anim">
      <div className="max-w-6xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="Built With"
            title="Technology Stack"
            description="Idris DB integrates seamlessly with the tools you already know and love."
          />
        </FadeInSection>

        <StaggerContainer className="grid grid-cols-2 md:grid-cols-3 gap-4 md:gap-5">
          {techStack.map((tech) => (
            <motion.div key={tech.name} variants={staggerChild}>
              <TiltCard>
                <Card className="h-full border-border/40 bg-card/30 backdrop-blur-sm overflow-hidden">
                  <CardContent className="pt-5 pb-5 flex flex-col items-center text-center gap-2">
                    <div className="size-12 rounded-2xl bg-primary/10 flex items-center justify-center icon-glow-ring">
                      <tech.icon className="size-5 text-primary" />
                    </div>
                    <h3 className="font-semibold text-sm">{tech.name}</h3>
                    <p className="text-[11px] text-muted-foreground leading-relaxed">{tech.description}</p>
                  </CardContent>
                </Card>
              </TiltCard>
            </motion.div>
          ))}
        </StaggerContainer>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 23: CTA
     ═══════════════════════════════════════════════════════════ */

  const CTASection = (
    <section className="py-16 md:py-20">
      <div className="max-w-4xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <div className="relative rounded-2xl border border-primary/20 overflow-hidden border-rotate">
            <div className="absolute inset-0 bg-gradient-to-br from-primary/15 via-primary/5 to-transparent" />
            <div className="absolute inset-0 hero-grid opacity-30" />
            <div className="absolute inset-0 noise-overlay pointer-events-none" />
            <div className="relative z-10 p-8 md:p-12 text-center">
              <motion.div
                animate={{ y: [0, -5, 0] }}
                transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
              >
                <Rocket className="size-10 text-primary mx-auto mb-4" />
              </motion.div>
              <h2 className="text-2xl md:text-3xl font-bold mb-3 neon-text">Ready to Build Faster?</h2>
              <p className="text-muted-foreground mb-8 max-w-lg mx-auto">
                Join developers who are already building better Flutter apps with Idris DB. Installation takes less than a minute.
              </p>
              <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
                <motion.div whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.97 }}>
                  <Button size="lg" className="h-12 px-8 pulse-glow" asChild>
                    <a href="https://pub.dev/packages/idris_db" target="_blank" rel="noopener noreferrer">
                      <Rocket className="size-4 mr-2" /> Get Started <ExternalLink className="size-4 ml-1.5" />
                    </a>
                  </Button>
                </motion.div>
                <motion.div whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.97 }}>
                  <Button variant="outline" size="lg" className="h-12 px-8" asChild>
                    <a href="https://pub.dev/packages/idris_db" target="_blank" rel="noopener noreferrer">
                      <Package className="size-4 mr-2" /> View on pub.dev <ExternalLink className="size-4 ml-1.5" />
                    </a>
                  </Button>
                </motion.div>
              </div>
            </div>
          </div>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 24: ABOUT IDRISIUM
     ═══════════════════════════════════════════════════════════ */

  const AboutSection = (
    <section id="about" className="py-24 md:py-32 bg-muted/30">
      <div className="max-w-4xl mx-auto px-4 md:px-6">
        <FadeInSection>
          <SectionHeading
            badge="About"
            title="Built by IDRISIUM Corp"
            description="Idris DB is developed and maintained by Idris Ghamid under IDRISIUM Corp. We build developer tools that help Flutter developers ship faster and better."
          />
        </FadeInSection>

        <FadeInSection delay={0.1}>
          <Card className="border-border/50 bg-card/50 backdrop-blur-sm gradient-border-anim">
            <CardContent className="pt-8 pb-8 text-center">
              <div className="size-16 rounded-2xl bg-primary/10 flex items-center justify-center mx-auto mb-4">
                <img src="/db-icon.png" alt="IDRISIUM" className="size-10 rounded-lg" />
              </div>
              <h3 className="text-xl font-bold mb-2">IDRISIUM Corp</h3>
              <p className="text-muted-foreground text-sm max-w-md mx-auto mb-6 leading-relaxed">
                Empowering Flutter developers with high-quality, open-source tools.
                Built with ❤️ by Idris Ghamid.
              </p>

              <div className="flex items-center justify-center gap-3">
                {socials.map((social) => (
                  <motion.a
                    key={social.label}
                    href={social.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    whileHover={{ scale: 1.1, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    className="size-10 rounded-xl bg-muted/50 border border-border/50 flex items-center justify-center text-muted-foreground hover:text-primary hover:border-primary/30 hover:bg-primary/5 transition-colors"
                  >
                    <social.icon className="size-4" />
                    <span className="sr-only">{social.label}</span>
                  </motion.a>
                ))}
              </div>
            </CardContent>
          </Card>
        </FadeInSection>
      </div>
    </section>
  )

  /* ═══════════════════════════════════════════════════════════
     SECTION 25: FOOTER
     ═══════════════════════════════════════════════════════════ */

  const FooterSection = (
    <footer className="relative border-t border-border/30 bg-muted/20 footer-glow">
      <div className="max-w-7xl mx-auto px-4 md:px-6 py-12 md:py-16">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-10">
          {/* Product */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <img src="/db-icon.png" alt="" className="size-6 rounded" />
              <span className="font-semibold">Idris DB</span>
            </div>
            <ul className="space-y-2">
              {['Features', 'Quick Start', 'Benchmarks', 'Compare'].map((link) => (
                <li key={link}>
                  <button onClick={() => scrollTo(`#${link.toLowerCase().replace(' ', '').replace('quickstart', 'quickstart')}`)} className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                    {link}
                  </button>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h4 className="font-semibold text-sm mb-4">Resources</h4>
            <ul className="space-y-2">
              {[
                { label: 'pub.dev', href: 'https://pub.dev/packages/idris_db' },
                { label: 'API Reference', href: '#api' },
                { label: 'Migration Guide', href: '#migration' },
                { label: 'Roadmap', href: '#roadmap' },
              ].map((link) => (
                <li key={link.label}>
                  <button
                    onClick={() => {
                      if (link.href.startsWith('#')) scrollTo(link.href)
                      else window.open(link.href, '_blank')
                    }}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </button>
                </li>
              ))}
            </ul>
          </div>

          {/* Company */}
          <div>
            <h4 className="font-semibold text-sm mb-4">Company</h4>
            <ul className="space-y-2">
              {['About IDRISIUM', 'Blog', 'Careers', 'Contact'].map((link) => (
                <li key={link}>
                  <span className="text-sm text-muted-foreground hover:text-foreground transition-colors cursor-pointer">
                    {link}
                  </span>
                </li>
              ))}
            </ul>
          </div>

          {/* Connect */}
          <div>
            <h4 className="font-semibold text-sm mb-4">Connect</h4>
            <div className="grid grid-cols-3 gap-2">
              {socials.map((social) => (
                <a
                  key={social.label}
                  href={social.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="size-9 rounded-lg bg-muted/50 border border-border/30 flex items-center justify-center text-muted-foreground hover:text-primary hover:border-primary/30 transition-colors"
                >
                  <social.icon className="size-3.5" />
                </a>
              ))}
            </div>
          </div>
        </div>

        <div className="section-divider mb-6" />

        <div className="flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-muted-foreground">
          <p>&copy; {new Date().getFullYear()} IDRISIUM Corp. All rights reserved.</p>
          <p>Built with ❤️ by Idris Ghamid</p>
        </div>
      </div>
    </footer>
  )

  /* ═══════════════════════════════════════════════════════════
     COMMAND PALETTE (Cmd+K)
     ═══════════════════════════════════════════════════════════ */

  const cmdItems = [
    ...navLinks.map((link) => ({ label: link.label, action: () => { scrollTo(link.href); setCmdOpen(false) }, icon: null })),
    { label: 'Toggle Theme', action: () => { toggleTheme(); setCmdOpen(false) }, icon: Sun },
    { label: 'Copy Install Command', action: () => { copyInstallCommand(); setCmdOpen(false) }, icon: Copy },
  ]

  const filteredCmdItems = cmdItems.filter((item) =>
    item.label.toLowerCase().includes(cmdSearch.toLowerCase())
  )

  const CommandPalette = (
    <AnimatePresence>
      {cmdOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
          className="cmd-overlay"
          onClick={() => setCmdOpen(false)}
        >
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.98 }}
            transition={{ duration: 0.2 }}
            className="cmd-panel"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="cmd-input-wrapper">
              <Search className="size-4 text-muted-foreground" />
              <input
                className="cmd-input"
                placeholder="Search sections, commands..."
                value={cmdSearch}
                onChange={(e) => { setCmdSearch(e.target.value); setCmdActiveIndex(0) }}
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === 'ArrowDown') { e.preventDefault(); setCmdActiveIndex((prev) => Math.min(prev + 1, filteredCmdItems.length - 1)) }
                  if (e.key === 'ArrowUp') { e.preventDefault(); setCmdActiveIndex((prev) => Math.max(prev - 1, 0)) }
                  if (e.key === 'Enter' && filteredCmdItems[cmdActiveIndex]) { filteredCmdItems[cmdActiveIndex].action() }
                }}
              />
              <kbd className="cmd-kbd">ESC</kbd>
            </div>
            <div className="max-h-64 overflow-y-auto py-1">
              {filteredCmdItems.length === 0 ? (
                <div className="px-4 py-6 text-center text-sm text-muted-foreground">No results found.</div>
              ) : (
                filteredCmdItems.map((item, index) => (
                  <div
                    key={item.label}
                    className={`cmd-item ${index === cmdActiveIndex ? 'active' : ''}`}
                    onClick={item.action}
                    onMouseEnter={() => setCmdActiveIndex(index)}
                  >
                    {item.icon && <item.icon className="cmd-item-icon" />}
                    <span>{item.label}</span>
                    <kbd className="cmd-kbd">↵</kbd>
                  </div>
                ))
              )}
            </div>
            <div className="flex items-center gap-4 px-4 py-2 border-t border-border/30 text-[10px] text-muted-foreground">
              <span className="flex items-center gap-1"><kbd className="cmd-kbd">↑↓</kbd> Navigate</span>
              <span className="flex items-center gap-1"><kbd className="cmd-kbd">↵</kbd> Select</span>
              <span className="flex items-center gap-1"><kbd className="cmd-kbd">ESC</kbd> Close</span>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )

  /* ═══════════════════════════════════════════════════════════
     FLOATING TABLE OF CONTENTS
     ═══════════════════════════════════════════════════════════ */

  const FloatingTOC = (
    <nav className="floating-toc" aria-label="Section navigation">
      <div className="flex flex-col gap-3">
        {tocSections.map((section) => (
          <div key={section.id} className="relative">
            <button
              onClick={() => {
                const el = document.getElementById(section.id)
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
              }}
              className={`floating-toc-dot ${activeSection === section.id ? 'active' : ''}`}
              aria-label={`Jump to ${section.label}`}
            />
            <span className="floating-toc-label">{section.label}</span>
          </div>
        ))}
      </div>
    </nav>
  )

  /* ═══════════════════════════════════════════════════════════
     RENDER
     ═══════════════════════════════════════════════════════════ */

  return (
    <main className="relative page-enter">
      {Navigation}
      {CommandPalette}
      {FloatingTOC}
      {HeroSection}
      {MarqueeSection}
      {FeaturesSection}
      {WhySection}
      {QuickStartSection}
      {QueryAnalyzerSection}
      {ArabicSection}
      {BenchmarksSection}
      {UseCasesSection}
      {ComparisonSection}
      {MigrationSection}
      {APIExplorerSection}
      {RoadmapSection}
      {ChangelogSection}
      {SecuritySection}
      <div className="section-sep"><div className="sep-dot" /></div>
      {PlaygroundSection}
      <div className="section-sep"><div className="sep-dot" /></div>
      {PerformanceSection}
      <div className="section-sep"><div className="sep-dot" /></div>
      {TechStackSection}
      <div className="section-sep"><div className="sep-dot" /></div>
      {FAQSection}
      <div className="section-sep"><div className="sep-dot" /></div>
      {CTASection}
      {AboutSection}
      <div className="section-sep"><div className="sep-dot" /></div>
      {FooterSection}

      {/* Back to Top */}
      <AnimatePresence>
        {showBackToTop && (
          <motion.button
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.8 }}
            transition={{ duration: 0.2 }}
            onClick={scrollToTop}
            className="back-to-top-btn fixed bottom-6 right-6 z-40 size-11 rounded-full bg-primary text-primary-foreground flex items-center justify-center shadow-lg hover:shadow-xl"
            aria-label="Back to top"
          >
            <ArrowUp className="size-5" />
          </motion.button>
        )}
      </AnimatePresence>
    </main>
  )
}

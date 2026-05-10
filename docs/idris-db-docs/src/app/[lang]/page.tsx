import Link from 'next/link';
import { buttonVariants } from 'fumadocs-ui/components/ui/button';

export default async function HomePage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  const isAr = lang === 'ar';

  return (
    <main 
      className="flex flex-col items-center justify-center min-h-screen text-center px-4 bg-idrisium-charcoal text-white"
      dir={isAr ? 'rtl' : 'ltr'}
    >
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-from)_0%,_transparent_70%)] from-idrisium-accent/20 to-transparent pointer-events-none" />
      
      <img 
        src="/logo.png" 
        alt="Idris DB Logo" 
        className="w-48 h-48 mb-8 animate-in fade-in zoom-in duration-1000" 
      />
      
      <h1 className="text-6xl font-black mb-4 tracking-tight">
        {isAr ? 'إدريس دي بي' : 'idris DB'}
      </h1>
      
      <p className="text-2xl text-gray-400 max-w-2xl mb-12 font-medium">
        {isAr 
          ? 'أسرع قاعدة بيانات NoSQL لـ Flutter - مصممة للأداء العالي وتجربة مطور استثنائية.' 
          : 'The Fastest NoSQL Database for Flutter - Engineered for extreme performance and elite developer experience.'}
      </p>
      
      <div className="flex gap-4">
        <Link
          href={`/${lang}/docs`}
          className={buttonVariants({ 
            variant: 'primary', 
            className: 'text-xl px-12 py-8 rounded-2xl bg-idrisium-accent hover:bg-idrisium-accent/80 transition-all shadow-xl shadow-idrisium-accent/20' 
          })}
        >
          {isAr ? 'ابدأ الآن' : 'Get Started'}
        </Link>
        
        <Link
          href="https://github.com/idris-ghamid/idris_db"
          className={buttonVariants({ 
            variant: 'outline', 
            className: 'text-xl px-12 py-8 rounded-2xl border-white/20 hover:bg-white/5 transition-all' 
          })}
        >
          GitHub
        </Link>
      </div>
      
      <div className="mt-24 text-gray-500 font-medium">
        Built by IDRISIUM Corp | Idris Ghamid (إدريس غامد)
      </div>
    </main>
  );
}

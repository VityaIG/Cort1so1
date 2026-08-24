import { useState } from 'react';
import {
  Download,
  Smartphone,
  ExternalLink,
  ShieldCheck,
  Zap,
  Terminal,
  Cpu,
  Layers,
  Sparkles,
  Check,
  Copy,
  ChevronRight,
  Send,
  Code2,
  FolderGit2
} from 'lucide-react';

export default function App() {
  const [lang, setLang] = useState<'ru' | 'en'>('ru');
  const [copied, setCopied] = useState(false);

  const isRu = lang === 'ru';
  const latestReleaseUrl = "https://github.com/VityaIG/Cort1so1/releases/download/v1.3/Cort1so1.ipa";
  const trollStoreUrl = `apple-magnifier://install?url=${encodeURIComponent(latestReleaseUrl)}`;
  const githubRepoUrl = "https://github.com/VityaIG/Cort1so1";
  const telegramUrl = "https://t.me/VityaV";

  const handleCopyLink = () => {
    navigator.clipboard.writeText(latestReleaseUrl);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 antialiased selection:bg-blue-500 selection:text-white flex flex-col justify-between">
      {/* Top Navigation */}
      <header className="border-b border-slate-800 bg-slate-950 sticky top-0 z-40">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-blue-600 flex items-center justify-center shadow-lg shadow-blue-500/20">
              <div className="font-bold text-white text-lg tracking-tight">
                C
              </div>
            </div>
            <div>
              <span className="font-bold text-base tracking-tight text-white flex items-center gap-1.5">
                Cort1so1
                <span className="text-[10px] uppercase font-mono px-1.5 py-0.5 rounded bg-blue-500/20 text-blue-400 border border-blue-500/30">
                  v1.3 IPA
                </span>
              </span>
              <p className="text-[11px] text-slate-400 font-medium -mt-0.5">
                Native iOS Application (Swift & SwiftUI)
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            {/* Language Switch */}
            <div className="flex items-center bg-slate-900 border border-slate-800 rounded-full p-0.5">
              <button
                type="button"
                onClick={() => setLang('ru')}
                className={`px-2.5 py-1 text-xs font-semibold rounded-full transition-all ${
                  isRu ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                RU
              </button>
              <button
                type="button"
                onClick={() => setLang('en')}
                className={`px-2.5 py-1 text-xs font-semibold rounded-full transition-all ${
                  !isRu ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                EN
              </button>
            </div>

            <a
              href={githubRepoUrl}
              target="_blank"
              rel="noreferrer"
              className="hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-slate-900 border border-slate-800 text-xs font-medium text-slate-300 hover:text-white hover:border-slate-700 transition"
            >
              <FolderGit2 className="w-3.5 h-3.5" />
              GitHub
            </a>
          </div>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="max-w-5xl mx-auto px-4 sm:px-6 py-10 space-y-10 flex-1 w-full">
        {/* Hero Section */}
        <section className="text-center space-y-5 max-w-3xl mx-auto pt-4">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-semibold">
            <Smartphone className="w-3.5 h-3.5" />
            {isRu
              ? 'Обновление v1.3 — Терминал Cortisol & Оверлей статус-бара'
              : 'Update v1.3 — Cortisol Terminal & Dynamic Status Bar'}
          </div>

          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            {isRu ? 'Cort1so1 для iPhone и iPad' : 'Cort1so1 for iPhone & iPad'}
          </h1>

          <p className="text-slate-400 text-sm sm:text-base leading-relaxed max-w-2xl mx-auto">
            {isRu
              ? 'Полнофункциональная нативная системная утилита, симулятор джейлбрейка Dopamine / Cortisol, интерактивный Терминал, менеджер твиков Substrate и движок отката прошивок iOS, написанный на чистом Swift / SwiftUI.'
              : 'High-performance native iOS system utility, Dopamine & Cortisol jailbreak simulator, interactive Terminal subsystem, Substrate tweak manager, and IPSW restore engine built in Swift / SwiftUI.'}
          </p>

          {/* Action Buttons */}
          <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
            <a
              href={latestReleaseUrl}
              className="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl bg-blue-600 hover:bg-blue-500 active:scale-[0.98] text-white font-semibold text-sm shadow-xl shadow-blue-600/30 transition-all"
            >
              <Download className="w-4 h-4" />
              {isRu ? 'Скачать Cort1so1.ipa (v1.3)' : 'Download Cort1so1.ipa (v1.3)'}
            </a>

            <a
              href={trollStoreUrl}
              className="inline-flex items-center gap-2 px-5 py-3.5 rounded-2xl bg-slate-900 hover:bg-slate-800 border border-slate-800 text-slate-200 hover:text-white font-semibold text-sm transition-all"
            >
              <Zap className="w-4 h-4 text-amber-400" />
              {isRu ? 'Установить в TrollStore' : 'Direct TrollStore Install'}
            </a>

            <button
              type="button"
              onClick={handleCopyLink}
              className="inline-flex items-center gap-2 px-4 py-3.5 rounded-2xl bg-slate-900/60 hover:bg-slate-900 border border-slate-800 text-slate-400 hover:text-slate-200 text-sm font-medium transition-all"
            >
              {copied ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
              {copied ? (isRu ? 'Скопировано!' : 'Copied!') : (isRu ? 'Копировать URL' : 'Copy IPA Link')}
            </button>
          </div>
        </section>

        {/* Notice Card */}
        <section className="p-5 rounded-2xl bg-slate-900/50 border border-slate-800/80 max-w-3xl mx-auto flex items-start gap-4">
          <div className="w-10 h-10 rounded-xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400 shrink-0 mt-0.5">
            <ShieldCheck className="w-5 h-5" />
          </div>
          <div className="space-y-1">
            <h2 className="text-sm font-bold text-white">
              {isRu ? 'Отказ от веб-эмуляции' : 'Native Architecture Notice'}
            </h2>
            <p className="text-xs text-slate-400 leading-relaxed">
              {isRu
                ? 'Веб-версия была полностью удалена, так как весь функционал (анимации логотипа Apple, тактильный виброотклик Haptics, перехват launchd, работа с APFS и кастомный респринг SpringBoard) реализован нативно в кодовой базе Swift (Xcode) и предназначен исключительно для работы на реальных устройствах iOS.'
                : 'The web preview simulation has been deprecated. All features (Apple boot kinematics, CoreHaptics, SpringBoard respring overlays, APFS snapshot handling, and Dopamine logging) run as a compiled native iOS app built with Xcode.'}
            </p>
          </div>
        </section>

        {/* Installation Guides */}
        <section className="space-y-4 max-w-4xl mx-auto">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Smartphone className="w-4 h-4 text-blue-400" />
            {isRu ? 'Инструкции по установке IPA на iPhone / iPad' : 'How to Install IPA on iOS'}
          </h2>

          <div className="grid sm:grid-cols-3 gap-4">
            {/* TrollStore */}
            <div className="p-4 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2.5">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-amber-400 uppercase tracking-wider bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/20">
                  TrollStore
                </span>
                <span className="text-[10px] text-slate-500 font-semibold">{isRu ? 'Без переподписи' : 'Permanent'}</span>
              </div>
              <h3 className="text-sm font-bold text-white">
                {isRu ? '1. Через TrollStore' : '1. Via TrollStore'}
              </h3>
              <p className="text-xs text-slate-400 leading-relaxed">
                {isRu
                  ? 'Скачайте Cort1so1.ipa в Safari, нажмите «Поделиться» -> «Открыть в TrollStore» или воспользуйтесь кнопкой прямой установки.'
                  : 'Download Cort1so1.ipa in Safari, tap Share -> Open in TrollStore, or click Direct TrollStore Install button.'}
              </p>
            </div>

            {/* AltStore / SideStore */}
            <div className="p-4 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2.5">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-blue-400 uppercase tracking-wider bg-blue-500/10 px-2 py-0.5 rounded border border-blue-500/20">
                  AltStore / SideStore
                </span>
                <span className="text-[10px] text-slate-500 font-semibold">Apple ID</span>
              </div>
              <h3 className="text-sm font-bold text-white">
                {isRu ? '2. AltStore / SideStore' : '2. AltStore / SideStore'}
              </h3>
              <p className="text-xs text-slate-400 leading-relaxed">
                {isRu
                  ? 'Откройте AltStore на телефоне, вкладка «Мои приложения», нажмите «+» и выберите загруженный Cort1so1.ipa.'
                  : 'Open AltStore or SideStore on your device, navigate to My Apps, tap +, and select the downloaded Cort1so1.ipa.'}
              </p>
            </div>

            {/* Sideloadly / Scarlet */}
            <div className="p-4 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2.5">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-purple-400 uppercase tracking-wider bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">
                  Sideloadly / PC
                </span>
                <span className="text-[10px] text-slate-500 font-semibold">Mac & PC</span>
              </div>
              <h3 className="text-sm font-bold text-white">
                {isRu ? '3. Sideloadly & ПК' : '3. Sideloadly & Desktop'}
              </h3>
              <p className="text-xs text-slate-400 leading-relaxed">
                {isRu
                  ? 'Подключите iPhone к компьютеру через USB, перетащите Cort1so1.ipa в Sideloadly и нажмите Start для установки.'
                  : 'Connect iPhone to your PC or Mac, drag and drop Cort1so1.ipa into Sideloadly, and click Start.'}
              </p>
            </div>
          </div>
        </section>

        {/* Technical Specs Bento Grid */}
        <section className="space-y-4 max-w-4xl mx-auto">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Layers className="w-4 h-4 text-cyan-400" />
            {isRu ? 'Архитектура и характеристики релиза' : 'Technical Specifications'}
          </h2>

          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-3">
            <div className="p-3.5 rounded-xl bg-slate-900/70 border border-slate-800">
              <div className="flex items-center gap-2 text-slate-400 text-xs font-semibold">
                <Code2 className="w-3.5 h-3.5 text-blue-400" />
                <span>{isRu ? 'Язык' : 'Language'}</span>
              </div>
              <div className="text-sm font-bold text-white mt-1">Swift 5.9 / SwiftUI</div>
              <div className="text-[11px] text-slate-500 mt-0.5">Apple HIG Design System</div>
            </div>

            <div className="p-3.5 rounded-xl bg-slate-900/70 border border-slate-800">
              <div className="flex items-center gap-2 text-slate-400 text-xs font-semibold">
                <Cpu className="w-3.5 h-3.5 text-cyan-400" />
                <span>{isRu ? 'Архитектура' : 'Target Architecture'}</span>
              </div>
              <div className="text-sm font-bold text-white mt-1">arm64 / arm64e</div>
              <div className="text-[11px] text-slate-500 mt-0.5">A12 — A18 Pro, M1 — M4</div>
            </div>

            <div className="p-3.5 rounded-xl bg-slate-900/70 border border-slate-800">
              <div className="flex items-center gap-2 text-slate-400 text-xs font-semibold">
                <Terminal className="w-3.5 h-3.5 text-emerald-400" />
                <span>{isRu ? 'Совместимость' : 'Compatibility'}</span>
              </div>
              <div className="text-sm font-bold text-white mt-1">iOS 15.0 — 18.x+</div>
              <div className="text-[11px] text-slate-500 mt-0.5">iPhone, iPad & iPod touch</div>
            </div>

            <div className="p-3.5 rounded-xl bg-slate-900/70 border border-slate-800">
              <div className="flex items-center gap-2 text-slate-400 text-xs font-semibold">
                <Sparkles className="w-3.5 h-3.5 text-amber-400" />
                <span>{isRu ? 'Сборка CI/CD' : 'CI/CD Build'}</span>
              </div>
              <div className="text-sm font-bold text-white mt-1">Xcode 16 / GitHub Actions</div>
              <div className="text-[11px] text-slate-500 mt-0.5">Automated IPA Releases</div>
            </div>
          </div>
        </section>

        {/* Creator and Links */}
        <section className="p-5 rounded-2xl bg-slate-900 border border-slate-800 max-w-4xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-2xl bg-blue-600/20 border border-blue-500/30 flex items-center justify-center text-blue-400 font-bold text-base">
              В
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-bold text-white text-sm">Виктор (@VityaV)</h3>
                <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-blue-500/20 text-blue-400">
                  Автор проекта 🇷🇺
                </span>
              </div>
              <p className="text-xs text-slate-400">
                {isRu ? 'Связь и обновления в Telegram' : 'Contact and updates via Telegram'}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3 w-full sm:w-auto">
            <a
              href={telegramUrl}
              target="_blank"
              rel="noreferrer"
              className="flex-1 sm:flex-initial inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-sky-600 hover:bg-sky-500 text-white text-xs font-semibold transition"
            >
              <Send className="w-3.5 h-3.5" />
              Telegram @VityaV
            </a>
            <a
              href={githubRepoUrl}
              target="_blank"
              rel="noreferrer"
              className="flex-1 sm:flex-initial inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold transition"
            >
              GitHub Репозиторий
              <ChevronRight className="w-3.5 h-3.5" />
            </a>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-900 bg-slate-950 py-6 px-4 text-center text-xs text-slate-500">
        <div className="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-3">
          <p>© 2026 Cort1so1. Разработано для iOS сообщества.</p>
          <div className="flex items-center gap-4 text-slate-400">
            <a href={latestReleaseUrl} className="hover:text-blue-400 transition">
              Cort1so1.ipa
            </a>
            <a href={githubRepoUrl} className="hover:text-blue-400 transition">
              Исходный код
            </a>
            <a href={telegramUrl} className="hover:text-blue-400 transition">
              Telegram
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

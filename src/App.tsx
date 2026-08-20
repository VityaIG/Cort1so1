import React from 'react';
import { Download, ShieldCheck, Github, Send, Smartphone, Terminal, Cpu, CheckCircle2 } from 'lucide-react';

export default function App() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col items-center justify-center p-6 antialiased selection:bg-blue-500/30">
      {/* Background glow */}
      <div className="fixed inset-0 pointer-events-none bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-blue-900/20 via-slate-950 to-slate-950" />

      <main className="relative z-10 w-full max-w-xl bg-slate-900/80 border border-slate-800/80 rounded-3xl p-8 shadow-2xl backdrop-blur-xl">
        {/* App Header */}
        <div className="flex items-center gap-4 mb-6">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-blue-600 to-cyan-500 p-0.5 shadow-lg shadow-blue-500/20 flex items-center justify-center">
            <div className="w-full h-full bg-slate-950 rounded-[14px] flex items-center justify-center">
              <ShieldCheck className="w-8 h-8 text-blue-400" />
            </div>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold tracking-tight text-white">Cort1so1</h1>
              <span className="px-2.5 py-0.5 text-xs font-semibold rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">
                v1.0.5
              </span>
            </div>
            <p className="text-sm text-slate-400 mt-0.5">
              Нативное приложение для iOS (SwiftUI & HIG)
            </p>
          </div>
        </div>

        {/* Info Card */}
        <div className="bg-slate-950/60 border border-slate-800/60 rounded-2xl p-5 mb-6 space-y-3">
          <div className="flex items-center justify-between text-sm">
            <span className="text-slate-400 flex items-center gap-2">
              <Smartphone className="w-4 h-4 text-slate-500" />
              Платформа
            </span>
            <span className="font-medium text-slate-200">iOS 18.0 — 27.0+ (arm64e)</span>
          </div>

          <div className="flex items-center justify-between text-sm">
            <span className="text-slate-400 flex items-center gap-2">
              <Terminal className="w-4 h-4 text-slate-500" />
              Движок
            </span>
            <span className="font-medium text-slate-200">Dopamine Pipeline & HIG</span>
          </div>

          <div className="flex items-center justify-between text-sm">
            <span className="text-slate-400 flex items-center gap-2">
              <Cpu className="w-4 h-4 text-slate-500" />
              Создатель
            </span>
            <a
              href="https://t.me/VityaV"
              target="_blank"
              rel="noreferrer"
              className="font-medium text-[#229ED9] hover:underline flex items-center gap-1"
            >
              <Send className="w-3.5 h-3.5" />
              @VityaV 🇷🇺
            </a>
          </div>
        </div>

        {/* Feature Highlights */}
        <div className="space-y-2 mb-6 text-sm text-slate-300">
          <div className="flex items-center gap-2.5">
            <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Плавная анимация джейлбрейка в стиле Dopamine (с логами в карточке)</span>
          </div>
          <div className="flex items-center gap-2.5">
            <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Автоматическое определение системной версии iOS пользователя</span>
          </div>
          <div className="flex items-center gap-2.5">
            <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Каталог версий отката: 27.0 Beta 4, 26.6, 26.0, 18.7.1, 18.5</span>
          </div>
        </div>

        {/* Download & Links */}
        <div className="space-y-3">
          <a
            href="https://github.com/VityaIG/Cort1so1/releases/tag/v1.0.5"
            target="_blank"
            rel="noreferrer"
            className="w-full flex items-center justify-center gap-2 py-3.5 px-5 bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-500 hover:to-cyan-500 text-white font-semibold rounded-xl shadow-lg shadow-blue-500/25 transition-all active:scale-[0.99]"
          >
            <Download className="w-5 h-5" />
            Скачать Cort1so1.ipa (v1.0.5)
          </a>

          <a
            href="https://github.com/VityaIG/Cort1so1"
            target="_blank"
            rel="noreferrer"
            className="w-full flex items-center justify-center gap-2 py-3 px-5 bg-slate-800/80 hover:bg-slate-800 text-slate-300 hover:text-white text-sm font-medium rounded-xl border border-slate-700/60 transition-all"
          >
            <Github className="w-4 h-4" />
            Исходный код на GitHub (Xcode / Swift)
          </a>
        </div>

        {/* Sideload Instruction */}
        <p className="text-xs text-slate-500 text-center mt-6">
          Установка через TrollStore, AltStore, SideStore или Sideloadly.
        </p>
      </main>
    </div>
  );
}

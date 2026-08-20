import React, { useState, useEffect, useRef } from 'react';
import {
  Download,
  ShieldCheck,
  Github,
  Send,
  Smartphone,
  Terminal,
  Cpu,
  CheckCircle2,
  Moon,
  Globe,
  Settings,
  ArrowDownCircle,
  RotateCcw,
  Zap,
  Trash2,
  Clock,
  HardDrive,
  FileCode2,
  Key,
  ShieldAlert,
  Sliders,
  ExternalLink,
  ChevronRight
} from 'lucide-react';

interface Firmware {
  id: string;
  version: string;
  build: string;
  releaseDateRu: string;
  releaseDateEn: string;
  sizeGB: number;
  isSigned: boolean;
  isBeta: boolean;
  sha256: string;
}

const firmwares: Firmware[] = [
  { id: "ios27beta4", version: "27.0 Beta 4", build: "25A5316j", releaseDateRu: "15 августа 2026", releaseDateEn: "August 15, 2026", sizeGB: 7.2, isSigned: true, isBeta: true, sha256: "9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d" },
  { id: "ios266", version: "26.6", build: "24G77", releaseDateRu: "24 июля 2026", releaseDateEn: "July 24, 2026", sizeGB: 6.8, isSigned: true, isBeta: false, sha256: "1f2e3d4c5b6a7890abcdef1234567890" },
  { id: "ios260", version: "26.0", build: "24A348", releaseDateRu: "18 сентября 2025", releaseDateEn: "September 18, 2025", sizeGB: 6.5, isSigned: false, isBeta: false, sha256: "a1b2c3d4e5f6789012345678abcdef01" },
  { id: "ios1871", version: "18.7.1", build: "22H30", releaseDateRu: "12 мая 2025", releaseDateEn: "May 12, 2025", sizeGB: 5.9, isSigned: false, isBeta: false, sha256: "bcdef0123456789abcdef0123456789a" },
  { id: "ios185", version: "18.5", build: "22F72", releaseDateRu: "16 декабря 2024", releaseDateEn: "December 16, 2024", sizeGB: 5.4, isSigned: false, isBeta: false, sha256: "def0123456789abcdef0123456789abc" }
];

export default function App() {
  const [activeTab, setActiveTab] = useState<'main' | 'downgrade' | 'settings'>('main');
  const [appLanguage, setAppLanguage] = useState<'ru' | 'en'>('ru');
  const [isJailbroken, setIsJailbroken] = useState(false);
  const [selectedFirmware, setSelectedFirmware] = useState<Firmware>(firmwares[0]);
  
  // Settings
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [verboseLogs, setVerboseLogs] = useState(true);
  const [autoRespring, setAutoRespring] = useState(true);
  const [tweakInjection, setTweakInjection] = useState(true);
  const [safeMode, setSafeMode] = useState(false);

  // Downgrade Engine (60 seconds)
  const [isRestoring, setIsRestoring] = useState(false);
  const [elapsedSeconds, setElapsedSeconds] = useState(0);
  const [terminalLogs, setTerminalLogs] = useState<string[]>([]);
  const restoreIntervalRef = useRef<any>(null);

  // Jailbreak Process modal
  const [isJailbreakModalOpen, setIsJailbreakModalOpen] = useState(false);
  const [jbPhase, setJbPhase] = useState<'logging' | 'appleWhite' | 'blackScreen' | 'appleRed' | 'respring'>('logging');
  const [jbLogs, setJbLogs] = useState<string[]>([]);

  const isRu = appLanguage === 'ru';

  // 60-second Downgrade Engine
  const start60SecRestore = () => {
    setIsRestoring(true);
    setElapsedSeconds(0);
    setTerminalLogs([
      `[00:00] [Futurerestore v2.4.1] Initializing downgrade engine for iOS ${selectedFirmware.version}...`,
      `[00:01] [TSS] Handshake with gs.apple.com:443 established`
    ]);

    const startTime = Date.now();
    restoreIntervalRef.current = setInterval(() => {
      const now = Date.now();
      const elapsed = Math.min(60, (now - startTime) / 1000);
      setElapsedSeconds(elapsed);

      const sec = Math.floor(elapsed);
      const timeStr = `[00:${sec < 10 ? '0' + sec : sec}]`;

      if (sec === 5 && !terminalLogs.some(l => l.includes('ApTicket'))) {
        setTerminalLogs(prev => [...prev, `${timeStr} [ApTicket] Verifying Nonce 0x1111111111111111 generator: OK`]);
      } else if (sec === 12 && !terminalLogs.some(l => l.includes('Mounting DMG'))) {
        setTerminalLogs(prev => [...prev, `${timeStr} [APFS] Mounting DMG RootFS container: disk0s1s1`]);
      } else if (sec === 22 && !terminalLogs.some(l => l.includes('Cryptex1'))) {
        setTerminalLogs(prev => [...prev, `${timeStr} [Cryptex1] Verifying OS TrustCache and entitlements...`]);
      } else if (sec === 32 && !terminalLogs.some(l => l.includes('Secure Enclave'))) {
        setTerminalLogs(prev => [...prev, `${timeStr} [SEP] Sending signed Secure Enclave microcode to SEP chip...`]);
      } else if (sec === 44 && !terminalLogs.some(l => l.includes('root snapshot'))) {
        setTerminalLogs(prev => [...prev, `${timeStr} [APFS] Creating root snapshot com.apple.os.update-${selectedFirmware.build}`]);
      } else if (sec === 54 && !terminalLogs.some(l => l.includes('boot-args'))) {
        setTerminalLogs(prev => [...prev, `${timeStr} [NVRAM] Updating boot-args: rootless=1 cs_enforcement=1`]);
      }

      if (elapsed >= 60) {
        clearInterval(restoreIntervalRef.current);
        setIsRestoring(false);
        setElapsedSeconds(60);
        setTerminalLogs(prev => [...prev, `[01:00] [Done] Restore completed successfully in 60s! System ready.`]);
      }
    }, 100);
  };

  const cancelRestore = () => {
    if (restoreIntervalRef.current) clearInterval(restoreIntervalRef.current);
    setIsRestoring(false);
    setElapsedSeconds(0);
    setTerminalLogs(prev => [...prev, `[Terminated] Downgrade process cancelled by user.`]);
  };

  // Jailbreak sequence
  const startJailbreak = async () => {
    setIsJailbreakModalOpen(true);
    setJbPhase('logging');
    setJbLogs([]);

    const steps = isRu
      ? [
          "Инициализация Cort1so1",
          "Проверка совместимости устройства",
          "> Первая фаза готова",
          "Проверяем стабильность",
          "> Вторая фаза готова",
          "Проверка вероятности бутлупа…",
          "> Третья фаза готова"
        ]
      : [
          "Initializing Cort1so1",
          "Checking device compatibility",
          "> Phase one complete",
          "Checking stability",
          "> Phase two complete",
          "Checking bootloop probability…",
          "> Phase three complete"
        ];

    for (let i = 0; i < steps.length; i++) {
      await new Promise(r => setTimeout(r, steps[i].startsWith('>') ? 900 : 700));
      setJbLogs(prev => [...prev, steps[i]]);
    }

    await new Promise(r => setTimeout(r, 800));
    setJbPhase('appleWhite');
    await new Promise(r => setTimeout(r, 1200));
    setJbPhase('blackScreen');
    await new Promise(r => setTimeout(r, 1000)); // Exact 1 second black screen
    setJbPhase('appleRed');
    await new Promise(r => setTimeout(r, 1300));
    setJbPhase('respring');
    await new Promise(r => setTimeout(r, 2200));

    setIsJailbroken(true);
    setIsJailbreakModalOpen(false);
  };

  const progressRatio = Math.min(1, elapsedSeconds / 60);

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col items-center justify-start p-4 sm:p-6 antialiased">
      {/* Dynamic Background Glow */}
      <div className="fixed inset-0 pointer-events-none bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-blue-950/40 via-slate-950 to-slate-950" />

      {/* Main Container */}
      <div className="relative z-10 w-full max-w-xl flex flex-col items-center gap-6 my-auto">
        
        {/* Release & Download Header */}
        <div className="w-full bg-slate-900/90 border border-slate-800 rounded-3xl p-6 shadow-2xl backdrop-blur-xl flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3.5">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-blue-600 to-cyan-500 flex items-center justify-center shadow-lg shadow-blue-500/25">
              <ShieldCheck className="w-6 h-6 text-white" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-xl font-bold text-white tracking-tight">Cort1so1</h1>
                <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">
                  v1.0.5
                </span>
              </div>
              <p className="text-xs text-slate-400">iOS Native App (SwiftUI & HIG)</p>
            </div>
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto">
            <a
              href="https://github.com/VityaIG/Cort1so1/releases/tag/v1.0.5"
              target="_blank"
              rel="noreferrer"
              className="flex-1 sm:flex-none flex items-center justify-center gap-2 py-2.5 px-4 bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold rounded-xl shadow-md shadow-blue-600/30 transition-all active:scale-95"
            >
              <Download className="w-4 h-4" />
              Скачать IPA (v1.0.5)
            </a>
            <a
              href="https://t.me/VityaV"
              target="_blank"
              rel="noreferrer"
              className="flex items-center justify-center gap-1.5 py-2.5 px-3 bg-[#229ED9]/15 hover:bg-[#229ED9]/25 text-[#229ED9] text-xs font-medium rounded-xl border border-[#229ED9]/30 transition-all"
            >
              <Send className="w-3.5 h-3.5" />
              @VityaV
            </a>
          </div>
        </div>

        {/* Interactive iOS App Device Simulator Frame */}
        <div className="w-full bg-slate-900 border border-slate-800 rounded-[36px] p-3 shadow-2xl overflow-hidden flex flex-col">
          {/* iOS Dynamic Island / Top Bar */}
          <div className="flex items-center justify-between px-5 pt-3 pb-2 text-xs font-medium text-slate-400">
            <span>9:41</span>
            <div className="w-24 h-4 bg-black rounded-full mx-auto" />
            <div className="flex items-center gap-1.5 text-slate-300">
              <span className="text-[10px]">5G</span>
              <div className="w-4 h-2 border border-slate-400 rounded-sm p-0.5 flex items-center">
                <div className="w-full h-full bg-emerald-400 rounded-2xs" />
              </div>
            </div>
          </div>

          {/* App Header & Tabs */}
          <div className="px-4 pt-2 pb-3">
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-lg font-bold text-white tracking-tight">
                {activeTab === 'main' ? (isRu ? 'Основное' : 'Main') : activeTab === 'downgrade' ? (isRu ? 'Откат iOS' : 'iOS Downgrade') : (isRu ? 'Настройки' : 'Settings')}
              </h2>
              <button
                onClick={() => setAppLanguage(l => l === 'ru' ? 'en' : 'ru')}
                className="text-xs px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 flex items-center gap-1 transition-all"
              >
                <Globe className="w-3.5 h-3.5 text-blue-400" />
                {isRu ? 'Русский' : 'English'}
              </button>
            </div>

            {/* Tab Selector */}
            <div className="grid grid-cols-3 bg-slate-950 p-1 rounded-xl border border-slate-800/80 text-xs font-semibold">
              <button
                onClick={() => setActiveTab('main')}
                className={`py-2 rounded-lg transition-all ${activeTab === 'main' ? 'bg-blue-600 text-white shadow-md' : 'text-slate-400 hover:text-white'}`}
              >
                {isRu ? 'Основное' : 'Main'}
              </button>
              <button
                onClick={() => setActiveTab('downgrade')}
                className={`py-2 rounded-lg transition-all ${activeTab === 'downgrade' ? 'bg-blue-600 text-white shadow-md' : 'text-slate-400 hover:text-white'}`}
              >
                {isRu ? 'Откат iOS' : 'Downgrade'}
              </button>
              <button
                onClick={() => setActiveTab('settings')}
                className={`py-2 rounded-lg transition-all ${activeTab === 'settings' ? 'bg-blue-600 text-white shadow-md' : 'text-slate-400 hover:text-white'}`}
              >
                {isRu ? 'Настройки' : 'Settings'}
              </button>
            </div>
          </div>

          {/* Screen Content */}
          <div className="p-4 bg-slate-950/80 rounded-2xl border border-slate-800/60 min-h-[420px] flex flex-col justify-between">
            {/* 1. Main Tab */}
            {activeTab === 'main' && (
              <div className="space-y-4">
                {/* Status card */}
                <div className="bg-slate-900/90 border border-slate-800 rounded-2xl p-4 space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-semibold uppercase text-slate-400 tracking-wider">
                      {isRu ? 'Состояние' : 'Status'}
                    </span>
                    <span className={`text-xs font-bold px-2.5 py-0.5 rounded-full flex items-center gap-1.5 ${isJailbroken ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30' : 'bg-blue-500/15 text-blue-400 border border-blue-500/30'}`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${isJailbroken ? 'bg-emerald-400 animate-pulse' : 'bg-blue-400'}`} />
                      {isJailbroken ? (isRu ? 'Активирован' : 'Active') : (isRu ? 'Совместимо' : 'Compatible')}
                    </span>
                  </div>

                  <div className="flex items-center gap-3 pt-1">
                    <div className="w-10 h-10 rounded-xl bg-blue-600/15 border border-blue-500/20 flex items-center justify-center text-blue-400">
                      <Zap className="w-5 h-5" />
                    </div>
                    <div>
                      <h4 className="text-sm font-bold text-white">
                        {isJailbroken ? (isRu ? 'Джейлбрейк выполнен!' : 'Jailbreak Active!') : 'iOS 18.0 — Совместимо'}
                      </h4>
                      <p className="text-xs text-slate-400">
                        {isJailbroken ? (isRu ? 'Пакетный менеджер Sileo готов к работе.' : 'Sileo package manager ready.') : (isRu ? 'Система готова к запуску симуляции.' : 'System is ready to exploit.')}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Specs */}
                <div className="bg-slate-900/60 border border-slate-800/80 rounded-2xl p-3.5 space-y-2 text-xs">
                  <div className="flex justify-between text-slate-300">
                    <span className="text-slate-400">{isRu ? 'Ядро' : 'Kernel'}</span>
                    <span className="font-mono text-slate-200">{isJailbroken ? 'Rootless (tfp0)' : 'Готов к запуску'}</span>
                  </div>
                  <div className="flex justify-between text-slate-300">
                    <span className="text-slate-400">{isRu ? 'Архитектура' : 'Architecture'}</span>
                    <span className="font-mono text-blue-400">arm64e (PPL Bypass)</span>
                  </div>
                  <div className="flex justify-between text-slate-300">
                    <span className="text-slate-400">{isRu ? 'Эксплойт' : 'Exploit'}</span>
                    <span className="text-slate-200">PhysPuppet / LandCast</span>
                  </div>
                </div>

                {/* Jailbreak action button */}
                <div className="pt-2">
                  <button
                    onClick={startJailbreak}
                    className="w-full py-3.5 px-4 bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-500 hover:to-cyan-500 text-white font-bold rounded-xl shadow-lg shadow-blue-600/30 transition-all flex items-center justify-center gap-2 active:scale-[0.99]"
                  >
                    <Zap className="w-4 h-4 fill-white" />
                    {isJailbroken ? (isRu ? 'Повторить (Re-Jailbreak)' : 'Re-Jailbreak') : 'Jailbreak'}
                  </button>
                </div>
              </div>
            )}

            {/* 2. Downgrade Tab (60-second real-time engine) */}
            {activeTab === 'downgrade' && (
              <div className="space-y-4">
                {/* Target & Current Header */}
                <div className="bg-slate-900/90 border border-slate-800 rounded-2xl p-3.5 flex items-center justify-between text-xs">
                  <div>
                    <span className="text-slate-400 block text-[10px] uppercase font-semibold">{isRu ? 'Текущая' : 'Current'}</span>
                    <span className="font-bold text-slate-200">iPhone 16 Pro • iOS 18.2</span>
                  </div>
                  <div className="text-right">
                    <span className="text-slate-400 block text-[10px] uppercase font-semibold">{isRu ? 'Цель' : 'Target'}</span>
                    <span className="font-bold text-blue-400 font-mono">iOS {selectedFirmware.version}</span>
                  </div>
                </div>

                {/* Catalog Select */}
                <div className="space-y-1.5">
                  <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">
                    {isRu ? 'Каталог IPSW' : 'IPSW Catalog'}
                  </span>
                  <div className="space-y-1.5 max-h-36 overflow-y-auto pr-1">
                    {firmwares.map(fw => (
                      <button
                        key={fw.id}
                        disabled={isRestoring}
                        onClick={() => setSelectedFirmware(fw)}
                        className={`w-full flex items-center justify-between p-2.5 rounded-xl border text-xs text-left transition-all ${
                          selectedFirmware.id === fw.id
                            ? 'bg-blue-600/15 border-blue-500/40 text-white'
                            : 'bg-slate-900/60 border-slate-800/80 text-slate-300 hover:bg-slate-900'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <div className={`w-3.5 h-3.5 rounded-full border flex items-center justify-center ${selectedFirmware.id === fw.id ? 'border-blue-400 bg-blue-500' : 'border-slate-600'}`}>
                            {selectedFirmware.id === fw.id && <div className="w-1.5 h-1.5 bg-white rounded-full" />}
                          </div>
                          <div>
                            <span className="font-semibold">{fw.version}</span>
                            <span className="text-[10px] text-slate-400 block font-mono">{fw.build} • {fw.sizeGB} GB</span>
                          </div>
                        </div>
                        <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium ${fw.isSigned ? 'bg-emerald-500/15 text-emerald-400' : 'bg-amber-500/15 text-amber-400'}`}>
                          {fw.isSigned ? 'TSS Signed' : 'SHSH2'}
                        </span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* 60-Sec Real-Time Engine Card */}
                <div className="bg-slate-900/90 border border-slate-800 rounded-2xl p-4 space-y-3">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-bold text-slate-300 flex items-center gap-1.5">
                      <Clock className="w-3.5 h-3.5 text-blue-400" />
                      {isRu ? 'Процесс отката (Ровно 1 минута)' : 'Downgrade Process (Exact 1 min)'}
                    </span>
                    <span className="font-mono font-bold text-cyan-400">
                      {Math.floor((60 - elapsedSeconds) / 60)}:{Math.floor(60 - elapsedSeconds) % 60 < 10 ? '0' : ''}{Math.floor(60 - elapsedSeconds) % 60}
                    </span>
                  </div>

                  {/* Progress Bar */}
                  <div className="w-full bg-slate-950 rounded-full h-2 overflow-hidden border border-slate-800">
                    <div
                      className="bg-gradient-to-r from-blue-500 to-cyan-400 h-full transition-all duration-150"
                      style={{ width: `${progressRatio * 100}%` }}
                    />
                  </div>

                  <div className="flex justify-between text-[10px] text-slate-400 font-mono">
                    <span>{Math.round(progressRatio * 100)}% complete</span>
                    <span>{(progressRatio * selectedFirmware.sizeGB).toFixed(2)} / {selectedFirmware.sizeGB} GB</span>
                  </div>

                  {/* Terminal Log Output */}
                  {terminalLogs.length > 0 && (
                    <div className="bg-black/90 rounded-xl p-2 font-mono text-[10px] text-cyan-400/90 space-y-1 max-h-20 overflow-y-auto border border-slate-800/80">
                      {terminalLogs.slice(-3).map((l, i) => (
                        <div key={i} className="truncate">{l}</div>
                      ))}
                    </div>
                  )}

                  {/* Start / Stop Button */}
                  {isRestoring ? (
                    <button
                      onClick={cancelRestore}
                      className="w-full py-2.5 px-4 bg-amber-600/90 hover:bg-amber-600 text-white text-xs font-bold rounded-xl transition-all"
                    >
                      {isRu ? 'Прервать откат' : 'Cancel Downgrade'}
                    </button>
                  ) : (
                    <button
                      onClick={start60SecRestore}
                      className="w-full py-2.5 px-4 bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold rounded-xl shadow-md shadow-blue-600/20 transition-all"
                    >
                      {isRu ? `Начать откат на ${selectedFirmware.version} (1 мин)` : `Start Downgrade to ${selectedFirmware.version} (1 min)`}
                    </button>
                  )}
                </div>
              </div>
            )}

            {/* 3. Settings Tab */}
            {activeTab === 'settings' && (
              <div className="space-y-3.5 text-xs">
                {/* Developer Profile Header */}
                <div className="bg-slate-900/90 border border-slate-800 rounded-2xl p-3.5 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-[#229ED9]/15 border border-[#229ED9]/30 flex items-center justify-center text-[#229ED9]">
                      <Send className="w-5 h-5" />
                    </div>
                    <div>
                      <span className="text-[10px] text-slate-400 block">{isRu ? 'Создатель' : 'Creator'}</span>
                      <a href="https://t.me/VityaV" target="_blank" rel="noreferrer" className="font-bold text-white hover:text-[#229ED9] flex items-center gap-1">
                        @VityaV 🇷🇺
                        <ExternalLink className="w-3 h-3 text-[#229ED9]" />
                      </a>
                    </div>
                  </div>
                  <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">
                    Cort1so1 v1.0.5
                  </span>
                </div>

                {/* Toggles */}
                <div className="bg-slate-900/70 border border-slate-800 rounded-2xl p-3 space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-slate-300 flex items-center gap-2">
                      <Moon className="w-3.5 h-3.5 text-indigo-400" />
                      {isRu ? 'Темная тема' : 'Dark Mode'}
                    </span>
                    <input type="checkbox" checked={isDarkMode} onChange={e => setIsDarkMode(e.target.checked)} className="accent-blue-600" />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-slate-300 flex items-center gap-2">
                      <Terminal className="w-3.5 h-3.5 text-slate-400" />
                      {isRu ? 'Подробные логи' : 'Verbose Logs'}
                    </span>
                    <input type="checkbox" checked={verboseLogs} onChange={e => setVerboseLogs(e.target.checked)} className="accent-blue-600" />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-slate-300 flex items-center gap-2">
                      <RotateCcw className="w-3.5 h-3.5 text-emerald-400" />
                      {isRu ? 'Авто-респринг' : 'Auto Respring'}
                    </span>
                    <input type="checkbox" checked={autoRespring} onChange={e => setAutoRespring(e.target.checked)} className="accent-blue-600" />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-slate-300 flex items-center gap-2">
                      <Sliders className="w-3.5 h-3.5 text-amber-400" />
                      {isRu ? 'Инъекция твиков' : 'Tweak Injection'}
                    </span>
                    <input type="checkbox" checked={tweakInjection} onChange={e => setTweakInjection(e.target.checked)} className="accent-blue-600" />
                  </div>
                </div>

                {/* Reset / Remove Jailbreak */}
                <div className="bg-slate-900/70 border border-slate-800 rounded-2xl p-3">
                  <button
                    onClick={() => setIsJailbroken(false)}
                    className="w-full py-2.5 px-3 rounded-xl bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 font-semibold flex items-center justify-center gap-2 transition-all"
                  >
                    <Trash2 className="w-4 h-4" />
                    {isRu ? 'Убрать джейлбрейк (Restore RootFS)' : 'Remove Jailbreak (Restore RootFS)'}
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Sideload Instruction */}
        <p className="text-xs text-slate-500 text-center">
          Установка через TrollStore, AltStore, SideStore или Sideloadly.
        </p>
      </div>

      {/* Dopamine Jailbreak Fullscreen Modal */}
      {isJailbreakModalOpen && (
        <div className="fixed inset-0 z-50 bg-black flex flex-col justify-between p-6 antialiased animate-fadeIn">
          {jbPhase === 'logging' && (
            <div className="w-full max-w-md mx-auto my-auto bg-slate-900 border border-slate-800 rounded-3xl overflow-hidden shadow-2xl flex flex-col h-[460px]">
              {/* Dopamine Header */}
              <div className="flex items-center justify-between px-4 py-3 bg-slate-950 border-b border-slate-800">
                <div className="flex gap-1.5">
                  <div className="w-2.5 h-2.5 rounded-full bg-red-500" />
                  <div className="w-2.5 h-2.5 rounded-full bg-amber-500" />
                  <div className="w-2.5 h-2.5 rounded-full bg-emerald-500" />
                </div>
                <span className="font-mono text-xs font-bold text-white">Cort1so1</span>
                <span className="font-mono text-xs text-blue-400">[{jbLogs.length}/7]</span>
              </div>

              {/* Progress Line */}
              <div className="w-full bg-slate-950 h-1">
                <div
                  className="bg-gradient-to-r from-blue-500 to-cyan-400 h-full transition-all duration-300"
                  style={{ width: `${(jbLogs.length / 7) * 100}%` }}
                />
              </div>

              {/* Logs */}
              <div className="flex-1 p-5 overflow-y-auto space-y-3 font-mono text-xs">
                {jbLogs.map((log, idx) => {
                  const isSuccess = log.startsWith('>');
                  return (
                    <div
                      key={idx}
                      className={`flex items-start gap-2.5 animate-fadeIn ${
                        isSuccess ? 'text-emerald-400 font-semibold' : 'text-slate-200'
                      }`}
                    >
                      {isSuccess ? (
                        <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                      ) : (
                        <div className="w-1.5 h-1.5 rounded-full bg-blue-500 shrink-0 mt-1.5" />
                      )}
                      <span>{log}</span>
                    </div>
                  );
                })}
              </div>

              <div className="p-3 bg-slate-950 border-t border-slate-800 flex items-center justify-between text-xs text-slate-400">
                <span className="animate-pulse">{isRu ? 'Выполняется...' : 'Executing...'}</span>
                <span className="font-mono text-[10px]">iOS 18.0</span>
              </div>
            </div>
          )}

          {jbPhase === 'appleWhite' && (
            <div className="my-auto flex flex-col items-center justify-center animate-fadeIn">
              <svg className="w-24 h-24 fill-white" viewBox="0 0 170 170">
                <path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.35.13-9.16-1.9-14.42-6.08-3.69-3.04-7.69-7.82-12.01-14.34-6.3-9.5-11.17-20.2-14.61-32.09-3.44-11.89-5.16-23.01-5.16-33.37 0-14.7 3.65-26.69 10.96-35.97 7.31-9.28 16.55-14.07 27.72-14.38 4.35 0 9.49 1.13 15.42 3.39 5.93 2.26 10.05 3.44 12.37 3.55 2.1.11 6.39-1.12 12.87-3.7 6.48-2.58 11.97-3.69 16.48-3.35 12.01.86 21.65 5.56 28.91 14.09-10.4 6.31-15.49 15.11-15.28 26.4.21 8.82 3.64 16.14 10.28 21.96 6.64 5.82 14.54 9.17 23.7 10.05-2.26 6.88-5.14 14.4-8.64 22.56zM119.22 33.64c-.11-3.66.7-7.39 2.42-11.18 1.72-3.79 4.19-7.1 7.42-9.93 3.66-3.12 7.84-5.32 12.55-6.6 4.71-1.28 9.38-1.74 14.01-1.39.22 3.66-.64 7.42-2.58 11.29-1.94 3.87-4.48 7.18-7.63 9.93-3.44 3.01-7.66 5.25-12.65 6.72-4.99 1.47-9.51 1.86-13.54 1.16z" />
              </svg>
            </div>
          )}

          {jbPhase === 'blackScreen' && (
            <div className="my-auto" />
          )}

          {jbPhase === 'appleRed' && (
            <div className="my-auto flex flex-col items-center justify-center animate-fadeIn">
              <svg className="w-24 h-24 fill-red-500" viewBox="0 0 170 170">
                <path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.35.13-9.16-1.9-14.42-6.08-3.69-3.04-7.69-7.82-12.01-14.34-6.3-9.5-11.17-20.2-14.61-32.09-3.44-11.89-5.16-23.01-5.16-33.37 0-14.7 3.65-26.69 10.96-35.97 7.31-9.28 16.55-14.07 27.72-14.38 4.35 0 9.49 1.13 15.42 3.39 5.93 2.26 10.05 3.44 12.37 3.55 2.1.11 6.39-1.12 12.87-3.7 6.48-2.58 11.97-3.69 16.48-3.35 12.01.86 21.65 5.56 28.91 14.09-10.4 6.31-15.49 15.11-15.28 26.4.21 8.82 3.64 16.14 10.28 21.96 6.64 5.82 14.54 9.17 23.7 10.05-2.26 6.88-5.14 14.4-8.64 22.56zM119.22 33.64c-.11-3.66.7-7.39 2.42-11.18 1.72-3.79 4.19-7.1 7.42-9.93 3.66-3.12 7.84-5.32 12.55-6.6 4.71-1.28 9.38-1.74 14.01-1.39.22 3.66-.64 7.42-2.58 11.29-1.94 3.87-4.48 7.18-7.63 9.93-3.44 3.01-7.66 5.25-12.65 6.72-4.99 1.47-9.51 1.86-13.54 1.16z" />
              </svg>
            </div>
          )}

          {jbPhase === 'respring' && (
            <div className="my-auto flex flex-col items-center justify-center gap-4 animate-fadeIn">
              <div className="w-10 h-10 border-4 border-white/20 border-t-white rounded-full animate-spin" />
              <span className="font-mono text-xs text-white/80">{isRu ? 'Перезапуск SpringBoard...' : 'Restarting SpringBoard...'}</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

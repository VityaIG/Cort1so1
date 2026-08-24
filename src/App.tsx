import { useState, FormEvent } from 'react';
import {
  Download,
  Smartphone,
  ShieldCheck,
  Zap,
  Terminal,
  Cpu,
  Layers,
  Check,
  Copy,
  ChevronRight,
  Send,
  Code2,
  FolderGit2,
  Settings,
  Puzzle,
  ArrowDownCircle,
  Activity,
  CheckCircle2,
  Lock,
  Moon,
  Globe,
  Trash2,
  Star,
  RefreshCw,
  Box,
  Terminal as TerminalIcon
} from 'lucide-react';

export default function App() {
  const [lang, setLang] = useState<'ru' | 'en'>('ru');
  const [activeTab, setActiveTab] = useState<'status' | 'tweaks' | 'terminal' | 'downgrade' | 'settings'>('status');
  const [copied, setCopied] = useState(false);
  const [viewMode, setViewMode] = useState<'simulator' | 'download'>('simulator');

  // App Simulator State
  const [isJailbroken, setIsJailbroken] = useState(false);
  const [jailbreakProgress, setJailbreakProgress] = useState(0);
  const [isJailbreaking, setIsJailbreaking] = useState(false);
  const [batteryPercent, setBatteryPercent] = useState<number>(1000000);
  const [batteryColor, setBatteryColor] = useState<string>('orange');
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [verboseLogs, setVerboseLogs] = useState(true);
  const [tweakInjection, setTweakInjection] = useState(true);
  const [autoRespring, setAutoRespring] = useState(false);

  // Tweaks state
  const [tweaks, setTweaks] = useState([
    { id: 'substrate', name: 'Substrate SafeMode', desc: 'System crash protection hook', enabled: true },
    { id: 'shadow', name: 'Shadow Bypass', desc: 'Jailbreak detection bypass engine', enabled: true },
    { id: 'choicy', name: 'Choicy Daemon Tweak', desc: 'Process injection restriction', enabled: true },
    { id: 'statusbattery', name: 'Cortisol StatusBattery', desc: 'Custom battery overlay & >100% support', enabled: true },
    { id: 'appsync', name: 'AppSync Unified', desc: 'Unsigned IPA execution daemon', enabled: false }
  ]);

  // Terminal state
  const [terminalLogs, setTerminalLogs] = useState<string[]>([
    '[INIT] Cortisol Substrate Engine v1.3 loaded.',
    '[SYS] Status bar battery override active (24.5pt base compact pill).',
    '[READY] Type "help" or select a quick command chip.'
  ]);
  const [terminalInput, setTerminalInput] = useState('');

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

  const handleRunJailbreak = () => {
    if (isJailbreaking) return;
    setIsJailbreaking(true);
    setJailbreakProgress(0);

    let progress = 0;
    const interval = setInterval(() => {
      progress += 15;
      if (progress >= 100) {
        clearInterval(interval);
        setJailbreakProgress(100);
        setIsJailbreaking(false);
        setIsJailbroken(true);
      } else {
        setJailbreakProgress(progress);
      }
    }, 200);
  };

  const handleTerminalSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (!terminalInput.trim()) return;
    executeCommand(terminalInput.trim());
    setTerminalInput('');
  };

  const executeCommand = (cmd: string) => {
    const lower = cmd.toLowerCase();
    const newLogs = [...terminalLogs, `> ${cmd}`];

    if (lower.startsWith('setbattery ') || lower.startsWith('battery percentage set ')) {
      const parts = cmd.split(' ');
      const val = parseInt(parts[parts.length - 1]);
      if (!isNaN(val)) {
        setBatteryPercent(val);
        newLogs.push(`[BATTERY] Percentage updated to ${val}%`);
      } else {
        newLogs.push('[ERROR] Invalid percentage value.');
      }
    } else if (lower.startsWith('battery color set ')) {
      const color = cmd.split(' ').pop() || 'orange';
      setBatteryColor(color);
      newLogs.push(`[BATTERY] Accent color updated to ${color}`);
    } else if (lower === 'battery reset') {
      setBatteryPercent(100);
      setBatteryColor('orange');
      newLogs.push('[BATTERY] Reset to 100%');
    } else if (lower === 'help') {
      newLogs.push('Available commands:');
      newLogs.push('  setbattery <number>           - Set custom battery % (e.g. 1000000)');
      newLogs.push('  battery color set <color>     - Set accent color (orange, green, blue)');
      newLogs.push('  battery reset                 - Reset battery to default 100%');
      newLogs.push('  clear                         - Clear terminal screen');
    } else if (lower === 'clear') {
      setTerminalLogs([]);
      return;
    } else {
      newLogs.push(`[EXEC] Command "${cmd}" executed successfully.`);
    }

    setTerminalLogs(newLogs);
  };

  const toggleTweak = (id: string) => {
    setTweaks(tweaks.map(t => t.id === id ? { ...t, enabled: !t.enabled } : t));
  };

  return (
    <div className={`min-h-screen ${isDarkMode ? 'bg-slate-950 text-slate-100' : 'bg-slate-100 text-slate-900'} antialiased flex flex-col justify-between transition-colors`}>
      {/* Top Header */}
      <header className={`border-b ${isDarkMode ? 'border-slate-800 bg-slate-950' : 'border-slate-200 bg-white'} sticky top-0 z-40 backdrop-blur-md bg-opacity-90`}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-blue-600 flex items-center justify-center shadow-lg shadow-blue-500/20 text-white font-bold text-lg">
              C
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className={`font-bold text-base tracking-tight ${isDarkMode ? 'text-white' : 'text-slate-900'}`}>
                  Cort1so1
                </span>
                <span className="text-[10px] uppercase font-mono px-1.5 py-0.5 rounded bg-blue-500/20 text-blue-500 border border-blue-500/30">
                  v1.3 IPA
                </span>
              </div>
              <p className="text-[11px] text-slate-400 font-medium">
                Native iOS Simulator & IPA Installer
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            {/* Switch View Mode */}
            <div className={`flex items-center p-0.5 rounded-xl border ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-slate-200 border-slate-300'}`}>
              <button
                type="button"
                onClick={() => setViewMode('simulator')}
                className={`px-3 py-1 text-xs font-semibold rounded-lg transition-all ${
                  viewMode === 'simulator' ? 'bg-blue-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                {isRu ? 'Интерактивный симулятор iOS' : 'Interactive iOS Simulator'}
              </button>
              <button
                type="button"
                onClick={() => setViewMode('download')}
                className={`px-3 py-1 text-xs font-semibold rounded-lg transition-all ${
                  viewMode === 'download' ? 'bg-blue-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                {isRu ? 'Релиз & IPA' : 'Release & IPA'}
              </button>
            </div>

            {/* Language switch */}
            <div className={`flex items-center p-0.5 rounded-full border ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-slate-200 border-slate-300'}`}>
              <button
                type="button"
                onClick={() => setLang('ru')}
                className={`px-2.5 py-1 text-xs font-semibold rounded-full ${lang === 'ru' ? 'bg-blue-600 text-white' : 'text-slate-400'}`}
              >
                RU
              </button>
              <button
                type="button"
                onClick={() => setLang('en')}
                className={`px-2.5 py-1 text-xs font-semibold rounded-full ${lang === 'en' ? 'bg-blue-600 text-white' : 'text-slate-400'}`}
              >
                EN
              </button>
            </div>

            <a
              href={githubRepoUrl}
              target="_blank"
              rel="noreferrer"
              className={`hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full border text-xs font-medium transition ${
                isDarkMode ? 'bg-slate-900 border-slate-800 text-slate-300 hover:text-white' : 'bg-white border-slate-300 text-slate-700'
              }`}
            >
              <FolderGit2 className="w-3.5 h-3.5" />
              GitHub
            </a>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-6xl mx-auto px-4 sm:px-6 py-6 flex-1 w-full">
        {viewMode === 'simulator' ? (
          <div className="space-y-4">
            {/* Top Info Banner */}
            <div className={`p-4 rounded-2xl border flex flex-wrap items-center justify-between gap-3 ${
              isDarkMode ? 'bg-slate-900/60 border-slate-800' : 'bg-white border-slate-200 shadow-sm'
            }`}>
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-blue-500/10 border border-blue-500/30 flex items-center justify-center text-blue-500">
                  <Smartphone className="w-4 h-4" />
                </div>
                <div>
                  <h2 className="text-sm font-bold">
                    {isRu ? 'Нативный симулятор интерфейса iOS (Form / Inset Grouped Section)' : 'Native iOS Interface Simulator (Form / Inset Grouped Section)'}
                  </h2>
                  <p className="text-xs text-slate-400">
                    {isRu ? 'Переключайте вкладки снизу. Все элементы соответствуют нативному коду Swift v1.3.' : 'Switch tabs below. All elements match native Swift v1.3 codebase.'}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <a
                  href={latestReleaseUrl}
                  className="px-3 py-1.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold flex items-center gap-1.5 shadow"
                >
                  <Download className="w-3.5 h-3.5" />
                  {isRu ? 'Скачать .IPA (v1.3)' : 'Download .IPA (v1.3)'}
                </a>
              </div>
            </div>

            {/* iOS Device Screen Preview */}
            <div className="max-w-md mx-auto rounded-[38px] border-8 border-slate-800 bg-slate-900 shadow-2xl overflow-hidden flex flex-col h-[680px] relative">
              {/* Dynamic Native iOS Status Bar */}
              <div className="bg-black/95 text-white px-5 pt-3 pb-2 flex items-center justify-between text-xs font-semibold select-none z-30 shrink-0">
                <span className="font-mono text-[11px] tracking-tight">9:41</span>
                
                {/* Dynamic Notch / Island */}
                <div className="w-24 h-4 bg-black rounded-full flex items-center justify-center">
                  <div className="w-2.5 h-2.5 bg-slate-900 rounded-full"></div>
                </div>

                {/* Pixel-perfect iOS Battery Pill */}
                <div className="flex items-center gap-1.5">
                  <span className="text-[10px] text-slate-400 font-mono">5G</span>
                  <div 
                    className="h-[12px] rounded-[3.8px] bg-slate-700 relative overflow-hidden flex items-center px-1"
                    style={{
                      width: batteryPercent > 999 ? '56px' : '28.5px',
                    }}
                  >
                    <div 
                      className="absolute left-0 top-0 bottom-0 transition-all rounded-[3.8px]"
                      style={{
                        width: '100%',
                        backgroundColor: batteryColor === 'green' ? '#22c55e' : batteryColor === 'blue' ? '#3b82f6' : '#f97316'
                      }}
                    />
                    <span className="relative z-10 text-[9px] font-bold text-black font-mono leading-none mx-auto">
                      {batteryPercent}
                    </span>
                  </div>
                </div>
              </div>

              {/* View Screen Body (Native Form / Inset Grouped List) */}
              <div className={`flex-1 overflow-y-auto p-4 ${isDarkMode ? 'bg-black text-white' : 'bg-slate-100 text-slate-900'}`}>
                {/* TAB 1: STATUS / MAIN */}
                {activeTab === 'status' && (
                  <div className="space-y-4 text-sm">
                    {/* Header */}
                    <div className="text-center pt-2 pb-1">
                      <h1 className="text-xl font-extrabold tracking-tight">Cort1so1</h1>
                      <p className="text-xs text-slate-400">iOS Jailbreak & IPSW Utility</p>
                    </div>

                    {/* Section 1: System Status */}
                    <div className="space-y-1.5">
                      <div className="text-[11px] font-medium uppercase tracking-wider text-slate-400 px-3">
                        {isRu ? 'Статус системы' : 'System Status'}
                      </div>
                      <div className={`rounded-2xl border divide-y overflow-hidden ${isDarkMode ? 'bg-slate-900 border-slate-800 divide-slate-800' : 'bg-white border-slate-200 divide-slate-100'}`}>
                        <div className="p-3 flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <ShieldCheck className="w-4 h-4 text-blue-500" />
                            <span className="font-medium">{isRu ? 'Состояние ядра' : 'Kernel Status'}</span>
                          </div>
                          <span className="text-xs font-mono font-semibold text-emerald-500">
                            {isJailbroken ? 'JAILBROKEN' : 'READY'}
                          </span>
                        </div>
                        <div className="p-3 flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <Cpu className="w-4 h-4 text-amber-500" />
                            <span className="font-medium">{isRu ? 'Версия iOS' : 'iOS Version'}</span>
                          </div>
                          <span className="text-xs font-mono text-slate-400">16.5 (arm64e)</span>
                        </div>
                      </div>
                    </div>

                    {/* Section 2: Environment State */}
                    <div className="space-y-1.5">
                      <div className="text-[11px] font-medium uppercase tracking-wider text-slate-400 px-3">
                        {isRu ? 'Состояние среды' : 'Environment State'}
                      </div>
                      <div className={`rounded-2xl border p-4 space-y-3 ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'}`}>
                        <div className="flex items-center gap-3">
                          <div className={`w-10 h-10 rounded-xl flex items-center justify-center font-bold ${
                            isJailbroken ? 'bg-emerald-500/20 text-emerald-400' : 'bg-blue-500/20 text-blue-400'
                          }`}>
                            {isJailbroken ? <CheckCircle2 className="w-5 h-5" /> : <Lock className="w-5 h-5" />}
                          </div>
                          <div>
                            <div className="font-bold text-sm">
                              {isJailbroken ? (isRu ? 'Джейлбрейк активен' : 'Jailbreak Active') : (isRu ? 'Готов к джейлбрейку' : 'Ready for Jailbreak')}
                            </div>
                            <div className="text-xs text-slate-400">
                              {isJailbroken ? 'Procursus Bootstrap & Cort1so1 Substrate' : 'Supported: iOS 15.0 - 16.5'}
                            </div>
                          </div>
                        </div>

                        {isJailbreaking && (
                          <div className="space-y-1 pt-1">
                            <div className="flex justify-between text-xs text-slate-400 font-mono">
                              <span>Injecting patches...</span>
                              <span>{jailbreakProgress}%</span>
                            </div>
                            <div className="w-full h-1.5 bg-slate-800 rounded-full overflow-hidden">
                              <div 
                                className="h-full bg-blue-500 transition-all duration-300" 
                                style={{ width: `${jailbreakProgress}%` }}
                              />
                            </div>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Section 3: Actions */}
                    <div className="space-y-2.5">
                      <button
                        type="button"
                        onClick={handleRunJailbreak}
                        disabled={isJailbreaking}
                        className="w-full py-3.5 px-4 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-500 hover:to-blue-400 active:scale-[0.98] text-white font-bold text-sm shadow-lg shadow-blue-500/30 transition-all flex items-center justify-center gap-2 border border-blue-400/20"
                      >
                        <Zap className="w-4 h-4 fill-current" />
                        {isJailbreaking 
                          ? (isRu ? 'Выполняется...' : 'Executing...') 
                          : (isJailbroken ? (isRu ? 'Повторный джейлбрейк' : 'Re-Jailbreak') : (isRu ? 'Взломать iOS' : 'Jailbreak iOS'))}
                      </button>

                      <button
                        type="button"
                        onClick={() => {
                          setIsJailbroken(true);
                        }}
                        className="w-full py-3.5 px-4 rounded-xl bg-white hover:bg-slate-100 active:scale-[0.98] text-slate-900 font-bold text-sm shadow-md shadow-black/10 transition-all flex items-center justify-center gap-2 border border-slate-200"
                      >
                        <RefreshCw className="w-4 h-4 text-slate-900" />
                        {isRu ? 'Респринг SpringBoard' : 'Respring SpringBoard'}
                      </button>
                    </div>

                    {/* Section 4: Device Details */}
                    <div className="space-y-1.5">
                      <div className="text-[11px] font-medium uppercase tracking-wider text-slate-400 px-3">
                        {isRu ? 'Сведения об устройстве' : 'Device Information'}
                      </div>
                      <div className={`rounded-2xl border divide-y overflow-hidden ${isDarkMode ? 'bg-slate-900 border-slate-800 divide-slate-800' : 'bg-white border-slate-200 divide-slate-100'}`}>
                        <div className="p-3 flex justify-between text-xs">
                          <span className="text-slate-400">{isRu ? 'Модель' : 'Model'}</span>
                          <span className="font-medium">iPhone 14 Pro</span>
                        </div>
                        <div className="p-3 flex justify-between text-xs">
                          <span className="text-slate-400">{isRu ? 'Архитектура' : 'Architecture'}</span>
                          <span className="font-mono text-slate-400">arm64e</span>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                {/* TAB 2: TWEAKS */}
                {activeTab === 'tweaks' && (
                  <div className="space-y-4 text-sm">
                    <div className="pt-2 pb-1">
                      <h1 className="text-xl font-extrabold tracking-tight">{isRu ? 'Менеджер твиков' : 'Tweak Manager'}</h1>
                      <p className="text-xs text-slate-400">Substrate / Cydia Substrate Engine</p>
                    </div>

                    <div className="space-y-1.5">
                      <div className="text-[11px] font-medium uppercase tracking-wider text-slate-400 px-3">
                        {isRu ? 'Установленные твики' : 'Active Tweaks'}
                      </div>
                      <div className={`rounded-2xl border divide-y overflow-hidden ${isDarkMode ? 'bg-slate-900 border-slate-800 divide-slate-800' : 'bg-white border-slate-200 divide-slate-100'}`}>
                        {tweaks.map((tweak) => (
                          <div key={tweak.id} className="p-3 flex items-center justify-between">
                            <div className="space-y-0.5">
                              <div className="font-semibold text-xs flex items-center gap-1.5">
                                {tweak.name}
                                {tweak.id === 'statusbattery' && (
                                  <span className="text-[9px] bg-blue-500/20 text-blue-400 px-1.5 py-0.2 rounded font-mono">v1.3</span>
                                )}
                              </div>
                              <div className="text-[11px] text-slate-400">{tweak.desc}</div>
                            </div>

                            <button
                              type="button"
                              onClick={() => toggleTweak(tweak.id)}
                              className={`w-11 h-6 rounded-full transition-colors relative p-0.5 ${
                                tweak.enabled ? 'bg-emerald-500' : 'bg-slate-700'
                              }`}
                            >
                              <div className={`w-5 h-5 rounded-full bg-white transition-transform ${
                                tweak.enabled ? 'translate-x-5' : 'translate-x-0'
                              }`} />
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                )}

                {/* TAB 3: TERMINAL */}
                {activeTab === 'terminal' && (
                  <div className="space-y-3 text-xs font-mono h-full flex flex-col justify-between">
                    <div>
                      <div className="flex items-center justify-between pb-2 border-b border-slate-800">
                        <span className="text-emerald-400 font-bold flex items-center gap-1.5">
                          <TerminalIcon className="w-3.5 h-3.5" />
                          Cortisol Terminal v1.3
                        </span>
                        <span className="text-[10px] text-slate-500">root@iphone:~#</span>
                      </div>

                      {/* Log stream */}
                      <div className="space-y-1.5 py-3">
                        {terminalLogs.map((log, idx) => (
                          <div key={idx} className={log.startsWith('>') ? 'text-blue-400 font-bold' : log.startsWith('[ERROR]') ? 'text-rose-400' : 'text-slate-300'}>
                            {log}
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Quick Command Chips */}
                    <div className="space-y-2 pt-2 border-t border-slate-800">
                      <div className="flex flex-wrap gap-1.5">
                        <button
                          type="button"
                          onClick={() => executeCommand('setbattery 1000000')}
                          className="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-amber-300 rounded text-[10px] font-sans"
                        >
                          setbattery 1000000
                        </button>
                        <button
                          type="button"
                          onClick={() => executeCommand('battery color set green')}
                          className="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-emerald-300 rounded text-[10px] font-sans"
                        >
                          color green
                        </button>
                        <button
                          type="button"
                          onClick={() => executeCommand('battery reset')}
                          className="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded text-[10px] font-sans"
                        >
                          reset battery
                        </button>
                      </div>

                      <form onSubmit={handleTerminalSubmit} className="flex gap-2">
                        <input
                          type="text"
                          value={terminalInput}
                          onChange={(e) => setTerminalInput(e.target.value)}
                          placeholder="Type 'help' or command..."
                          className="flex-1 bg-slate-900 border border-slate-800 rounded px-2.5 py-1.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                        />
                        <button
                          type="submit"
                          className="px-3 py-1.5 bg-blue-600 hover:bg-blue-500 text-white font-sans font-bold rounded"
                        >
                          Run
                        </button>
                      </form>
                    </div>
                  </div>
                )}

                {/* TAB 4: DOWNGRADE */}
                {activeTab === 'downgrade' && (
                  <div className="space-y-4 text-sm">
                    <div className="pt-2 pb-1">
                      <h1 className="text-xl font-extrabold tracking-tight">{isRu ? 'Отказ прошивки IPSW' : 'IPSW Downgrade'}</h1>
                      <p className="text-xs text-slate-400">Futurerestore & SEP Compatibility Engine</p>
                    </div>

                    <div className="space-y-1.5">
                      <div className="text-[11px] font-medium uppercase tracking-wider text-slate-400 px-3">
                        {isRu ? 'Выбор цели IPSW' : 'Target Firmware'}
                      </div>
                      <div className={`rounded-2xl border p-3 space-y-3 ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'}`}>
                        <div className="flex items-center justify-between text-xs">
                          <span className="text-slate-400">Target Build</span>
                          <span className="font-mono text-blue-400 font-bold">iOS 14.3 (18C66)</span>
                        </div>
                        <div className="flex items-center justify-between text-xs">
                          <span className="text-slate-400">SEP / Baseband</span>
                          <span className="text-emerald-400 font-semibold">COMPATIBLE</span>
                        </div>

                        <button
                          type="button"
                          className="w-full py-2.5 rounded-xl bg-blue-600 text-white font-semibold text-xs shadow"
                        >
                          {isRu ? 'Запустить процесс ресторa' : 'Start Restore Engine'}
                        </button>
                      </div>
                    </div>
                  </div>
                )}

                {/* TAB 5: SETTINGS */}
                {activeTab === 'settings' && (
                  <div className="space-y-4 text-sm">
                    <div className="pt-2 pb-1">
                      <h1 className="text-xl font-extrabold tracking-tight">{isRu ? 'Настройки' : 'Settings'}</h1>
                      <p className="text-xs text-slate-400">System Preferences & Customization</p>
                    </div>

                    {/* Appearance Section */}
                    <div className="space-y-1.5">
                      <div className="text-[11px] font-medium uppercase tracking-wider text-slate-400 px-3">
                        {isRu ? 'Внешний вид' : 'Appearance'}
                      </div>
                      <div className={`rounded-2xl border divide-y overflow-hidden ${isDarkMode ? 'bg-slate-900 border-slate-800 divide-slate-800' : 'bg-white border-slate-200 divide-slate-100'}`}>
                        <div className="p-3 flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <Moon className="w-4 h-4 text-indigo-500" />
                            <span>{isRu ? 'Темное оформление' : 'Dark Theme'}</span>
                          </div>
                          <button
                            type="button"
                            onClick={() => setIsDarkMode(!isDarkMode)}
                            className={`w-11 h-6 rounded-full transition-colors relative p-0.5 ${
                              isDarkMode ? 'bg-blue-600' : 'bg-slate-400'
                            }`}
                          >
                            <div className={`w-5 h-5 rounded-full bg-white transition-transform ${
                              isDarkMode ? 'translate-x-5' : 'translate-x-0'
                            }`} />
                          </button>
                        </div>

                        <div className="p-3 flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <Globe className="w-4 h-4 text-blue-500" />
                            <span>{isRu ? 'Язык' : 'Language'}</span>
                          </div>
                          <span className="text-xs font-semibold text-slate-400">
                            {lang.toUpperCase()}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* About Section */}
                    <div className="space-y-1.5">
                      <div className="text-[11px] font-medium uppercase tracking-wider text-slate-400 px-3">
                        {isRu ? 'О программе' : 'About'}
                      </div>
                      <div className={`rounded-2xl border p-3 text-xs space-y-1 ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'}`}>
                        <div className="font-bold">Cort1so1 v1.3 (Build 26B101)</div>
                        <div className="text-slate-400">Developed by @VityaV for iOS Community.</div>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* iOS Bottom Tab Bar */}
              <div className="bg-black/95 text-slate-400 border-t border-slate-800 grid grid-cols-5 text-[10px] font-medium py-2 px-1 z-30 shrink-0">
                <button
                  type="button"
                  onClick={() => setActiveTab('status')}
                  className={`flex flex-col items-center gap-1 transition ${activeTab === 'status' ? 'text-blue-500 font-bold' : 'hover:text-slate-200'}`}
                >
                  <Activity className="w-4 h-4" />
                  <span>{isRu ? 'Статус' : 'Status'}</span>
                </button>

                <button
                  type="button"
                  onClick={() => setActiveTab('tweaks')}
                  className={`flex flex-col items-center gap-1 transition ${activeTab === 'tweaks' ? 'text-blue-500 font-bold' : 'hover:text-slate-200'}`}
                >
                  <Puzzle className="w-4 h-4" />
                  <span>{isRu ? 'Твики' : 'Tweaks'}</span>
                </button>

                <button
                  type="button"
                  onClick={() => setActiveTab('terminal')}
                  className={`flex flex-col items-center gap-1 transition ${activeTab === 'terminal' ? 'text-blue-500 font-bold' : 'hover:text-slate-200'}`}
                >
                  <TerminalIcon className="w-4 h-4" />
                  <span>{isRu ? 'Терминал' : 'Terminal'}</span>
                </button>

                <button
                  type="button"
                  onClick={() => setActiveTab('downgrade')}
                  className={`flex flex-col items-center gap-1 transition ${activeTab === 'downgrade' ? 'text-blue-500 font-bold' : 'hover:text-slate-200'}`}
                >
                  <ArrowDownCircle className="w-4 h-4" />
                  <span>{isRu ? 'Откат' : 'Downgrade'}</span>
                </button>

                <button
                  type="button"
                  onClick={() => setActiveTab('settings')}
                  className={`flex flex-col items-center gap-1 transition ${activeTab === 'settings' ? 'text-blue-500 font-bold' : 'hover:text-slate-200'}`}
                >
                  <Settings className="w-4 h-4" />
                  <span>{isRu ? 'Настройки' : 'Settings'}</span>
                </button>
              </div>
            </div>
          </div>
        ) : (
          /* Release & Download Details View */
          <div className="space-y-8 max-w-4xl mx-auto pt-4">
            <div className="text-center space-y-4">
              <span className="text-xs uppercase tracking-widest font-mono text-blue-500 font-bold bg-blue-500/10 border border-blue-500/20 px-3 py-1 rounded-full">
                Cort1so1 Release v1.3
              </span>
              <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight">
                {isRu ? 'Скачать файл установки Cort1so1.ipa' : 'Download Cort1so1.ipa Package'}
              </h1>
              <p className="text-slate-400 text-sm max-w-2xl mx-auto">
                {isRu
                  ? 'Официальный билд v1.3 соберите и установите прямо на ваше устройство iOS с помощью TrollStore или AltStore.'
                  : 'Official release v1.3 built directly for your iOS device via TrollStore, AltStore, SideStore or Sideloadly.'}
              </p>

              <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
                <a
                  href={latestReleaseUrl}
                  className="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm shadow-xl shadow-blue-600/30 transition-all"
                >
                  <Download className="w-4 h-4" />
                  {isRu ? 'Скачать Cort1so1.ipa (v1.3)' : 'Download Cort1so1.ipa (v1.3)'}
                </a>

                <a
                  href={trollStoreUrl}
                  className="inline-flex items-center gap-2 px-5 py-3.5 rounded-2xl bg-slate-900 border border-slate-800 text-slate-200 font-semibold text-sm transition-all"
                >
                  <Zap className="w-4 h-4 text-amber-400" />
                  {isRu ? 'Установить в TrollStore' : 'Install via TrollStore'}
                </a>
              </div>
            </div>

            <div className={`p-5 rounded-2xl border space-y-3 ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'}`}>
              <h3 className="font-bold text-sm">{isRu ? 'Что нового в v1.3:' : "What's New in v1.3:"}</h3>
              <ul className="text-xs text-slate-400 space-y-1.5 list-disc list-inside">
                <li>{isRu ? 'Снято ограничение в 100% на заряд батареи (поддержка 1 000 000% и любых чисел).' : 'Removed 100% battery percentage limit (supports 1,000,000% and any custom values).'}</li>
                <li>{isRu ? 'Компактная нативная иконка батареи iOS (базовая ширина 24.5pt) с инверсией текста.' : 'Pixel-perfect native iOS Status Bar overlay with compact 24.5pt battery icon and text inversion.'}</li>
                <li>{isRu ? 'Все 5 вкладок приложения переведены на единый нативный стиль iOS Form / Section.' : 'All 5 tabs updated to match native iOS Form / Section inset grouped design system.'}</li>
                <li>{isRu ? 'Интерактивный Cortisol Terminal с поддержкой быстрых команд.' : 'Cortisol Terminal tab with interactive command execution.'}</li>
              </ul>
            </div>
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className={`border-t ${isDarkMode ? 'border-slate-900 bg-slate-950 text-slate-500' : 'border-slate-200 bg-white text-slate-600'} py-4 px-4 text-center text-xs`}>
        <div className="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
          <p>© 2026 Cort1so1. Developed by @VityaV for iOS community.</p>
          <div className="flex items-center gap-4">
            <a href={latestReleaseUrl} className="hover:text-blue-500 transition">Cort1so1.ipa (v1.3)</a>
            <a href={githubRepoUrl} className="hover:text-blue-500 transition">GitHub</a>
            <a href={telegramUrl} className="hover:text-blue-500 transition">Telegram @VityaV</a>
          </div>
        </div>
      </footer>
    </div>
  );
}

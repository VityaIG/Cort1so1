import React, { useState, useEffect } from 'react';
import { 
  Shield, 
  Cpu, 
  Terminal, 
  RotateCcw, 
  Settings, 
  CheckCircle2, 
  Send, 
  Moon, 
  Sun, 
  Globe, 
  Trash2, 
  Download, 
  Info, 
  Box, 
  Layers,
  Sparkles,
  Check,
  Smartphone,
  Key,
  Lock,
  ArrowRight
} from 'lucide-react';

type Tab = 'main' | 'downgrade' | 'settings';
type JailbreakState = 'idle' | 'initializing' | 'streamingLogs' | 'respring' | 'completed';

interface PipelineStep {
  id: number;
  titleRu: string;
  titleEn: string;
  subtitleRu: string;
  subtitleEn: string;
}

const pipelineSteps: PipelineStep[] = [
  { id: 1, titleRu: "Инициализация среды", titleEn: "Initializing Environment", subtitleRu: "Проверка системных разрешений и песочницы...", subtitleEn: "Checking system sandbox and permissions..." },
  { id: 2, titleRu: "Поиск смещений ядра", titleEn: "Finding Kernel Offsets", subtitleRu: "Вычисление KASLR slide и структуры proc_t...", subtitleEn: "Calculating KASLR slide and proc_t structures..." },
  { id: 3, titleRu: "Обход защитных механизмов", titleEn: "Bypassing Mitigations", subtitleRu: "Патчинг проверок подписи AMFI и CoreTrust...", subtitleEn: "Patching AMFI and CoreTrust signature checks..." },
  { id: 4, titleRu: "Получение привилегий tfp0", titleEn: "Gaining tfp0 Privileges", subtitleRu: "Установка прав суперпользователя (root)...", subtitleEn: "Acquiring root privileges and kernel task port..." },
  { id: 5, titleRu: "Развертывание Bootstrap", titleEn: "Extracting Bootstrap", subtitleRu: "Развертывание Procursus и менеджеров пакетов...", subtitleEn: "Deploying Procursus bootstrap & Sileo package manager..." }
];

// Точные 5 версий согласно запросу
const sampleFirmwares = [
  {
    version: "27.0 Beta 4",
    build: "31A512",
    dateRu: "Июль 2026",
    dateEn: "July 2026",
    isSigned: true,
    isBeta: true,
    sizeGB: 7.4,
    sha256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4...",
    sepRu: "Совместим (Beta SEP)",
    sepEn: "Compatible (Beta SEP)"
  },
  {
    version: "26.6",
    build: "30G78",
    dateRu: "Август 2025",
    dateEn: "August 2025",
    isSigned: true,
    isBeta: false,
    sizeGB: 7.1,
    sha256: "8f434346648f6b96df89dda901c5176b10a6d83...",
    sepRu: "Совместим (Cryptex1 Match)",
    sepEn: "Compatible (Cryptex1 Match)"
  },
  {
    version: "26.0",
    build: "30A195",
    dateRu: "Сентябрь 2024",
    dateEn: "September 2024",
    isSigned: true,
    isBeta: false,
    sizeGB: 6.8,
    sha256: "ca978112ca1bbdcafac231b39a23dc4da786eff...",
    sepRu: "Совместим (Full TSS)",
    sepEn: "Compatible (Full TSS)"
  },
  {
    version: "18.7.1",
    build: "22H310",
    dateRu: "Октябрь 2024",
    dateEn: "October 2024",
    isSigned: false,
    isBeta: false,
    sizeGB: 6.4,
    sha256: "5e884898da28047151d0e56f8dc6292773603d0...",
    sepRu: "Требуются SHSH2 + Cryptex Fix",
    sepEn: "Requires SHSH2 + Cryptex Fix"
  },
  {
    version: "18.5",
    build: "22F76",
    dateRu: "Май 2024",
    dateEn: "May 2024",
    isSigned: false,
    isBeta: false,
    sizeGB: 6.1,
    sha256: "4b227777d4dd1fc61c6f884f48641d02b4d121d...",
    sepRu: "SHSH2 Futurerestore (Gaster)",
    sepEn: "SHSH2 Futurerestore (Gaster)"
  }
];

// Автоопределение версии iOS и устройства
function detectDeviceSystem() {
  if (typeof window === 'undefined') return { os: '18.5', device: 'iPhone' };
  const ua = navigator.userAgent;
  let os = '18.5';
  let device = 'iPhone';

  if (/iPad/.test(ua)) {
    device = 'iPad';
  } else if (/iPhone/.test(ua)) {
    device = 'iPhone';
  }

  const match = ua.match(/OS (\d+[._]\d+([._]\d+)?)/);
  if (match && match[1]) {
    os = match[1].replace(/_/g, '.');
  }

  return { os, device };
}

export default function App() {
  const [activeTab, setActiveTab] = useState<Tab>('main');
  const [lang, setLang] = useState<'ru' | 'en'>(() => {
    return (localStorage.getItem('appLanguage') as 'ru' | 'en') || 'ru';
  });
  const [isDarkMode, setIsDarkMode] = useState<boolean>(() => {
    return localStorage.getItem('isDarkMode') !== 'false';
  });
  const [isJailbroken, setIsJailbroken] = useState<boolean>(() => {
    return localStorage.getItem('isJailbroken') === 'true';
  });
  
  const [jbState, setJbState] = useState<JailbreakState>(() => {
    return localStorage.getItem('isJailbroken') === 'true' ? 'completed' : 'idle';
  });

  const [deviceInfo] = useState(() => detectDeviceSystem());

  const [currentStep, setCurrentStep] = useState(0);
  const [executionMode, setExecutionMode] = useState(0);
  const [liveLogs, setLiveLogs] = useState<string[]>([]);
  const [showRemoveModal, setShowRemoveModal] = useState(false);

  // Downgrade states (Reimagined)
  const [selectedFw, setSelectedFw] = useState(sampleFirmwares[0]);
  const [keepUserData, setKeepUserData] = useState(true);
  const [verifySep, setVerifySep] = useState(true);
  const [autoNonce, setAutoNonce] = useState(true);

  const [isRestoringFw, setIsRestoringFw] = useState(false);
  const [restoreProgress, setRestoreProgress] = useState(0);
  const [restoreStage, setRestoreStage] = useState(0);
  const [restoreLogs, setRestoreLogs] = useState<string[]>([]);
  const [restoreComplete, setRestoreComplete] = useState(false);

  useEffect(() => {
    localStorage.setItem('appLanguage', lang);
  }, [lang]);

  useEffect(() => {
    localStorage.setItem('isDarkMode', String(isDarkMode));
  }, [isDarkMode]);

  useEffect(() => {
    localStorage.setItem('isJailbroken', String(isJailbroken));
  }, [isJailbroken]);

  // Start Dopamine sequence
  const startDopamineJailbreak = () => {
    setJbState('initializing');
    setCurrentStep(0);
    setLiveLogs([
      '[+] Initializing Cort1so1 Dopamine exploit engine...',
      `[*] Target: iOS ${deviceInfo.os} (arm64e)`
    ]);

    let step = 0;
    const interval = setInterval(() => {
      if (step < pipelineSteps.length - 1) {
        step++;
        setCurrentStep(step);
        setLiveLogs(prev => [...prev, `[*] Step ${step + 1}: ${lang === 'ru' ? pipelineSteps[step].titleRu : pipelineSteps[step].titleEn}`]);
      } else {
        clearInterval(interval);
        setJbState('streamingLogs');
        
        setTimeout(() => {
          setJbState('respring');
          setTimeout(() => {
            setIsJailbroken(true);
            setJbState('completed');
          }, 2400);
        }, 1800);
      }
    }, 800);
  };

  const removeJailbreak = () => {
    setIsJailbroken(false);
    setJbState('idle');
    setShowRemoveModal(false);
  };

  // Reimagined Flashing Downgrade Sequence
  const startFlashing = () => {
    setIsRestoringFw(true);
    setRestoreProgress(0);
    setRestoreStage(0);
    setRestoreComplete(false);
    setRestoreLogs([
      `[TSS] Handshake with gs.apple.com for ${selectedFw.version}...`,
      `[Futurerestore] Initializing BuildManifest: ${selectedFw.build}`
    ]);

    const intv = setInterval(() => {
      setRestoreProgress(prev => {
        if (prev >= 1) {
          clearInterval(intv);
          setIsRestoringFw(false);
          setRestoreComplete(true);
          return 1;
        }

        const next = prev + 0.05;
        if (next > 0.25 && next < 0.5) {
          setRestoreStage(1);
          if (!restoreLogs.includes('[APFS] Unpacking DMG root filesystem snapshot')) {
            setRestoreLogs(p => [...p, '[APFS] Unpacking DMG root filesystem snapshot']);
          }
        } else if (next >= 0.5 && next < 0.75) {
          setRestoreStage(2);
          if (!restoreLogs.includes('[SEP] Microcode validation: Cryptex match OK')) {
            setRestoreLogs(p => [...p, '[SEP] Microcode validation: Cryptex match OK']);
          }
        } else if (next >= 0.75 && next < 0.95) {
          setRestoreStage(3);
          if (!restoreLogs.includes('[Snapshot] Writing com.apple.os.update image')) {
            setRestoreLogs(p => [...p, '[Snapshot] Writing com.apple.os.update image']);
          }
        } else if (next >= 0.95) {
          setRestoreStage(4);
          setRestoreLogs(p => [...p, '[Done] Flashing finished. NVRAM updated!']);
        }

        return next;
      });
    }, 180);
  };

  const isRu = lang === 'ru';

  const restoreStageTitlesRu = [
    'Проверка подписи TSS / SHSH2',
    'Распаковка RootFS & Cryptex1',
    'Прошивка SEP & Baseband',
    'Запись APFS Snapshot',
    'Финализация и NVRAM'
  ];

  const restoreStageTitlesEn = [
    'Validating TSS / SHSH2 Tickets',
    'Extracting RootFS & Cryptex1',
    'Flashing SEP & Baseband',
    'Writing APFS Snapshot',
    'Finalizing & NVRAM Update'
  ];

  return (
    <div className={`min-h-screen font-sans transition-colors duration-200 ${isDarkMode ? 'bg-[#000000] text-white' : 'bg-[#F2F2F7] text-[#1C1C1E]'}`}>
      
      {/* Simulation Respring Overlay */}
      {jbState === 'respring' && (
        <div className="fixed inset-0 z-50 bg-black flex flex-col items-center justify-center space-y-6">
          <div className="w-12 h-12 border-4 border-white/20 border-t-white rounded-full animate-spin" />
          <p className="text-white/80 font-mono text-sm tracking-wide">
            {isRu ? 'Перезапуск SpringBoard...' : 'Restarting SpringBoard...'}
          </p>
        </div>
      )}

      {/* Terminal Log Stream Overlay */}
      {jbState === 'streamingLogs' && (
        <div className="fixed inset-0 z-40 bg-black flex flex-col p-6 font-mono text-xs text-green-400 overflow-hidden">
          <div className="flex items-center justify-between pb-4 border-b border-white/10 mb-4">
            <div className="flex space-x-2">
              <span className="w-3 h-3 rounded-full bg-red-500/80" />
              <span className="w-3 h-3 rounded-full bg-yellow-500/80" />
              <span className="w-3 h-3 rounded-full bg-green-500/80" />
            </div>
            <span className="text-white/70 font-semibold">CORT1SO1 EXPLOIT ENGINE — iOS {deviceInfo.os}</span>
            <span className="animate-pulse">● EXPLOITING</span>
          </div>
          <div className="flex-1 space-y-1.5 overflow-y-auto">
            <p className="text-white">[+] System version detected: iOS {deviceInfo.os}</p>
            <p className="text-green-400">[+] PhysPuppet memory primitive acquired</p>
            <p className="text-white">[*] Overwriting proc_t credentials (tfp0)</p>
            <p className="text-green-400">[+] AMFI & CoreTrust patch applied</p>
            <p className="text-white">[*] Mounting /private/preboot/rootfs as r/w</p>
            <p className="text-green-400">[+] Unpacking Procursus bootstrap</p>
            <p className="text-cyan-400">[+] Injecting ElleKit tweak loader & Sileo v2.6</p>
            <p className="text-white font-bold animate-pulse">[+] Handing off to launchd daemon...</p>
          </div>
        </div>
      )}

      {/* Device Frame / Main Container */}
      <div className="max-w-md mx-auto min-h-screen flex flex-col pb-20 pt-4 px-4">
        
        {/* Navigation Bar */}
        <header className="py-3 px-2 flex items-center justify-between border-b border-black/5 dark:border-white/10 mb-4">
          <div className="flex items-center space-x-2">
            <div className="w-7 h-7 rounded-lg bg-black dark:bg-white flex items-center justify-center text-white dark:text-black font-bold text-sm">
              C
            </div>
            <h1 className="text-xl font-bold tracking-tight">Cort1so1</h1>
          </div>
          <span className="text-xs px-2.5 py-1 rounded-full bg-blue-500/10 text-blue-500 font-semibold">
            v1.0.6
          </span>
        </header>

        {/* Tab Content */}
        <main className="flex-1 space-y-4">
          
          {/* TAB 1: MAIN */}
          {activeTab === 'main' && (
            <div className="space-y-4">
              {/* Segmented Mode Selector */}
              <div className="flex p-1 rounded-xl bg-black/5 dark:bg-white/10 text-xs font-semibold">
                {['Rootless', isRu ? 'Стандарт' : 'Standard', isRu ? 'Эксперт' : 'Expert'].map((mode, idx) => (
                  <button
                    key={mode}
                    onClick={() => setExecutionMode(idx)}
                    className={`flex-1 py-1.5 rounded-lg transition-all ${executionMode === idx ? 'bg-white dark:bg-[#2C2C2E] shadow-sm text-blue-500' : 'text-zinc-500'}`}
                  >
                    {mode}
                  </button>
                ))}
              </div>

              {/* System Status Card */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-2">
                    <Shield className="w-5 h-5 text-blue-500" />
                    <span className="font-semibold text-sm">{isRu ? 'Состояние' : 'Status'}</span>
                  </div>
                  <div className={`flex items-center space-x-1.5 px-2.5 py-1 rounded-full text-xs font-semibold ${
                    jbState === 'completed' || isJailbroken ? 'bg-green-500/10 text-green-500' : 'bg-blue-500/10 text-blue-500'
                  }`}>
                    <span className={`w-2 h-2 rounded-full ${jbState === 'completed' || isJailbroken ? 'bg-green-500' : 'bg-blue-500'}`} />
                    <span>{jbState === 'completed' || isJailbroken ? (isRu ? 'Активирован' : 'Active') : (isRu ? 'Совместимо' : 'Compatible')}</span>
                  </div>
                </div>

                <hr className="border-black/5 dark:border-white/5" />

                <div className="flex justify-between text-xs text-zinc-500 dark:text-zinc-400">
                  <span className="flex items-center space-x-1.5"><Cpu className="w-4 h-4" /> <span>{isRu ? 'Ядро' : 'Kernel'}</span></span>
                  <span className="font-medium">{jbState === 'completed' || isJailbroken ? 'Rootless (tfp0)' : (isRu ? 'Готов к запуску' : 'Ready')}</span>
                </div>
                <div className="flex justify-between text-xs text-zinc-500 dark:text-zinc-400">
                  <span className="flex items-center space-x-1.5"><Layers className="w-4 h-4" /> <span>{isRu ? 'Архитектура' : 'Architecture'}</span></span>
                  <span className="font-medium">arm64e (PPL Bypass)</span>
                </div>
              </div>

              {/* Dopamine Pipeline Card */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm`}>
                {jbState === 'initializing' ? (
                  <div className="space-y-3 py-1">
                    <div className="flex items-center justify-between text-xs">
                      <div className="flex space-x-1.5">
                        <span className="w-2 h-2 rounded-full bg-red-500" />
                        <span className="w-2 h-2 rounded-full bg-yellow-500" />
                        <span className="w-2 h-2 rounded-full bg-green-500" />
                      </div>
                      <span className="font-mono text-blue-500 font-bold">[{currentStep + 1}/{pipelineSteps.length}]</span>
                    </div>

                    <div className="text-center space-y-1">
                      <h4 className="font-bold text-sm">
                        {isRu ? pipelineSteps[currentStep].titleRu : pipelineSteps[currentStep].titleEn}
                      </h4>
                      <p className="text-xs text-zinc-500">
                        {isRu ? pipelineSteps[currentStep].subtitleRu : pipelineSteps[currentStep].subtitleEn}
                      </p>
                    </div>

                    {/* Dopamine Gradient Animated Bar */}
                    <div className="space-y-1">
                      <div className="w-full h-2 bg-blue-500/15 rounded-full overflow-hidden">
                        <div 
                          className="h-full bg-gradient-to-r from-blue-500 to-cyan-400 rounded-full transition-all duration-300"
                          style={{ width: `${((currentStep + 1) / pipelineSteps.length) * 100}%` }}
                        />
                      </div>
                      <div className="flex justify-between text-[11px] text-zinc-500">
                        <span>{isRu ? 'Этап' : 'Step'} {currentStep + 1} {isRu ? 'из' : 'of'} {pipelineSteps.length}</span>
                        <span className="font-bold text-blue-500">{Math.round(((currentStep + 1) / pipelineSteps.length) * 100)}%</span>
                      </div>
                    </div>

                    {liveLogs.length > 0 && (
                      <div className="p-2.5 rounded-lg bg-black/90 text-green-400 font-mono text-[11px] space-y-1">
                        {liveLogs.slice(-2).map((log, idx) => (
                          <p key={idx} className="truncate">{log}</p>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (jbState === 'completed' || isJailbroken) ? (
                  <div className="space-y-3 py-1">
                    <div className="flex items-center space-x-3">
                      <CheckCircle2 className="w-8 h-8 text-green-500" />
                      <div>
                        <h4 className="font-bold text-sm">{isRu ? 'Джейлбрейк выполнен!' : 'Jailbroken!'}</h4>
                        <p className="text-xs text-zinc-500">{isRu ? 'Пакетный менеджер Sileo готов к работе.' : 'Sileo package manager is ready.'}</p>
                      </div>
                    </div>
                    <hr className="border-black/5 dark:border-white/5" />
                    <div className="flex justify-between text-[11px] text-zinc-500">
                      <span className="flex items-center space-x-1"><Box className="w-3.5 h-3.5" /> <span>Procursus</span></span>
                      <span>Sileo v2.6</span>
                      <span className="text-green-500 font-semibold">tfp0: OK</span>
                    </div>
                  </div>
                ) : (
                  <div className="flex items-center space-x-3 py-1">
                    <Shield className="w-8 h-8 text-blue-500" />
                    <div>
                      {/* ДИНАМИЧЕСКИЙ ЗАГОЛОВОК ДЛЯ ТЕКУЩЕЙ IOS ПОЛЬЗОВАТЕЛЯ */}
                      <h4 className="font-bold text-sm">iOS {deviceInfo.os} — {isRu ? 'Совместимо' : 'Compatible'}</h4>
                      <p className="text-xs text-zinc-500">{isRu ? 'Система готова к запуску симуляции.' : 'System is ready to begin exploitation.'}</p>
                    </div>
                  </div>
                )}
              </div>

              {/* Action Buttons */}
              <div className="space-y-2 pt-2">
                <button
                  onClick={startDopamineJailbreak}
                  disabled={jbState === 'initializing' || jbState === 'streamingLogs' || jbState === 'respring'}
                  className="w-full py-3.5 px-4 bg-blue-600 hover:bg-blue-500 active:scale-[0.99] text-white font-bold rounded-xl transition-all shadow-md flex items-center justify-center space-x-2"
                >
                  <Sparkles className="w-4 h-4" />
                  <span>
                    {jbState === 'completed' || isJailbroken 
                      ? (isRu ? 'Повторить (Re-Jailbreak)' : 'Re-Jailbreak') 
                      : 'Jailbreak'}
                  </span>
                </button>

                {(jbState === 'completed' || isJailbroken) && (
                  <button
                    onClick={() => {
                      setJbState('respring');
                      setTimeout(() => setJbState('completed'), 2400);
                    }}
                    className="w-full py-2.5 px-4 bg-black/5 dark:bg-white/10 hover:bg-black/10 dark:hover:bg-white/15 text-blue-500 font-semibold rounded-xl text-sm transition-all flex items-center justify-center space-x-2"
                  >
                    <RotateCcw className="w-4 h-4" />
                    <span>{isRu ? 'Респринг' : 'Respring'}</span>
                  </button>
                )}
              </div>
            </div>
          )}

          {/* TAB 2: DOWNGRADE (ПОЛНОСТЬЮ ОБНОВЛЕННЫЙ ЭКРАН) */}
          {activeTab === 'downgrade' && (
            <div className="space-y-4">
              
              {/* Header: Current Device and OS */}
              <div className={`p-3.5 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm flex items-center justify-between`}>
                <div className="flex items-center space-x-3">
                  <div className="w-9 h-9 rounded-full bg-blue-500/10 flex items-center justify-center text-blue-500">
                    <Smartphone className="w-5 h-5" />
                  </div>
                  <div>
                    <div className="font-semibold text-xs">{deviceInfo.device}</div>
                    <div className="text-[11px] text-zinc-500">{isRu ? 'Текущая' : 'Current'}: iOS {deviceInfo.os} • arm64e</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-[10px] uppercase font-bold text-zinc-400">{isRu ? 'Цель' : 'Target'}</div>
                  <div className="text-xs font-bold text-blue-500">{selectedFw.version}</div>
                </div>
              </div>

              {/* 5 Firmware Selection Cards */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                <div className="flex justify-between items-center">
                  <span className="text-xs font-bold text-zinc-500 uppercase tracking-wider block">
                    {isRu ? 'Каталог версий IPSW' : 'IPSW Firmware Catalog'}
                  </span>
                  <span className="text-[11px] text-zinc-400 font-medium">5 {isRu ? 'версий' : 'versions'}</span>
                </div>

                <div className="space-y-2">
                  {sampleFirmwares.map(fw => {
                    const isSelected = selectedFw.version === fw.version;
                    return (
                      <button
                        key={fw.version}
                        onClick={() => !isRestoringFw && setSelectedFw(fw)}
                        className={`w-full p-3 rounded-xl border text-left transition-all flex items-center justify-between ${
                          isSelected
                            ? 'border-blue-500 bg-blue-500/10'
                            : 'border-black/5 dark:border-white/5 hover:border-black/20 bg-black/[0.02] dark:bg-white/[0.02]'
                        }`}
                      >
                        <div className="flex items-center space-x-2.5">
                          <div className={`w-4 h-4 rounded-full border flex items-center justify-center ${isSelected ? 'border-blue-500 bg-blue-500' : 'border-zinc-400'}`}>
                            {isSelected && <span className="w-1.5 h-1.5 rounded-full bg-white" />}
                          </div>
                          <div>
                            <div className="flex items-center space-x-1.5">
                              <span className="font-bold text-sm">{fw.version}</span>
                              {fw.isBeta && (
                                <span className="text-[10px] px-1.5 py-0.5 rounded bg-purple-500/15 text-purple-400 font-bold">
                                  BETA
                                </span>
                              )}
                            </div>
                            <div className="text-[11px] text-zinc-500">{fw.build} • {isRu ? fw.dateRu : fw.dateEn}</div>
                          </div>
                        </div>

                        <div className="flex items-center space-x-1.5 text-xs">
                          <span className={`px-2 py-0.5 rounded-full text-[10px] font-semibold ${
                            fw.isSigned ? 'bg-green-500/10 text-green-500' : 'bg-orange-500/10 text-orange-400'
                          }`}>
                            {fw.isSigned ? (isRu ? 'TSS Подписана' : 'TSS Signed') : 'SHSH2'}
                          </span>
                        </div>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Selected Firmware Specs */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-2.5 text-xs`}>
                <div className="flex justify-between items-center pb-1 border-b border-black/5 dark:border-white/5">
                  <span className="font-bold text-zinc-500 uppercase tracking-wider">{isRu ? 'Спецификация' : 'Specification'}</span>
                  <span className="font-bold text-blue-500">{selectedFw.version}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Сборка' : 'Build'}</span>
                  <span className="font-mono">{selectedFw.build}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Объем файла' : 'File Size'}</span>
                  <span>{selectedFw.sizeGB} GB</span>
                </div>
                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Подпись TSS' : 'TSS Signing'}</span>
                  <span className={`font-semibold ${selectedFw.isSigned ? 'text-green-500' : 'text-orange-400'}`}>
                    {selectedFw.isSigned ? (isRu ? 'Подписана (Apple TSS)' : 'Signed (Apple TSS)') : (isRu ? 'Не подписана (SHSH2)' : 'Unsigned (SHSH2)')}
                  </span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-zinc-500">{isRu ? 'SEP Совместимость' : 'SEP Compatibility'}</span>
                  <span className="text-blue-500 font-medium">{isRu ? selectedFw.sepRu : selectedFw.sepEn}</span>
                </div>
              </div>

              {/* Restore Options */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                <span className="text-xs font-bold text-zinc-500 uppercase tracking-wider block">
                  {isRu ? 'Параметры прошивки' : 'Flashing Options'}
                </span>

                <div className="flex items-center justify-between text-xs">
                  <span>{isRu ? 'Сохранить данные пользователя (Update)' : 'Preserve User Data (Update)'}</span>
                  <input type="checkbox" checked={keepUserData} onChange={e => setKeepUserData(e.target.checked)} className="rounded" />
                </div>
                <div className="flex items-center justify-between text-xs">
                  <span>{isRu ? 'Верификация SEP & Baseband (Cryptex1)' : 'Verify SEP & Baseband (Cryptex1)'}</span>
                  <input type="checkbox" checked={verifySep} onChange={e => setVerifySep(e.target.checked)} className="rounded" />
                </div>
                <div className="flex items-center justify-between text-xs">
                  <span>{isRu ? 'Автогенерация Nonce / ApTicket' : 'Auto-generate Nonce / ApTicket'}</span>
                  <input type="checkbox" checked={autoNonce} onChange={e => setAutoNonce(e.target.checked)} className="rounded" />
                </div>
              </div>

              {/* Restore Engine & Execution */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                {isRestoringFw ? (
                  <div className="space-y-2">
                    <div className="flex justify-between text-xs">
                      <span className="font-bold">{isRu ? restoreStageTitlesRu[restoreStage] : restoreStageTitlesEn[restoreStage]}</span>
                      <span className="font-mono text-blue-500 font-bold">{Math.round(restoreProgress * 100)}%</span>
                    </div>

                    <div className="w-full h-2 bg-blue-500/15 rounded-full overflow-hidden">
                      <div className="h-full bg-gradient-to-r from-blue-500 to-cyan-400 rounded-full transition-all" style={{ width: `${restoreProgress * 100}%` }} />
                    </div>

                    <div className="flex justify-between text-[11px] text-zinc-500">
                      <span>48.5 MB/s</span>
                      <span>{(restoreProgress * selectedFw.sizeGB).toFixed(1)} / {selectedFw.sizeGB} GB</span>
                    </div>

                    {restoreLogs.length > 0 && (
                      <div className="p-2.5 rounded-lg bg-black/90 text-cyan-400 font-mono text-[10px] space-y-0.5">
                        {restoreLogs.slice(-2).map((l, i) => (
                          <p key={i} className="truncate">{l}</p>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  <button
                    onClick={startFlashing}
                    disabled={isRestoringFw}
                    className="w-full py-3.5 px-4 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl transition-all shadow-md flex items-center justify-center space-x-2"
                  >
                    <Download className="w-4 h-4" />
                    <span>{isRu ? 'Начать откат на' : 'Start Downgrade to'} {selectedFw.version}</span>
                  </button>
                )}

                {restoreComplete && (
                  <div className="p-3 bg-green-500/10 text-green-500 rounded-xl text-xs flex items-center space-x-2">
                    <Check className="w-4 h-4" />
                    <span>{isRu ? `Восстановление на ${selectedFw.version} успешно завершено!` : `Restore to ${selectedFw.version} completed!`}</span>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* TAB 3: SETTINGS (ДИНАМИЧЕСКИЕ НАСТРОЙКИ) */}
          {activeTab === 'settings' && (
            <div className="space-y-4">
              
              {/* Appearance & Language */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                <span className="text-xs font-bold text-zinc-500 uppercase tracking-wider block">
                  {isRu ? 'Внешний вид и язык' : 'Appearance & Language'}
                </span>

                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center space-x-2">
                    {isDarkMode ? <Moon className="w-4 h-4 text-indigo-400" /> : <Sun className="w-4 h-4 text-amber-500" />}
                    <span>{isRu ? 'Темная тема' : 'Dark Mode'}</span>
                  </div>
                  <button 
                    onClick={() => setIsDarkMode(!isDarkMode)}
                    className={`w-11 h-6 rounded-full transition-colors relative ${isDarkMode ? 'bg-blue-600' : 'bg-zinc-300'}`}
                  >
                    <div className={`w-5 h-5 rounded-full bg-white absolute top-0.5 transition-transform ${isDarkMode ? 'left-[22px]' : 'left-0.5'}`} />
                  </button>
                </div>

                <hr className="border-black/5 dark:border-white/5" />

                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center space-x-2">
                    <Globe className="w-4 h-4 text-blue-500" />
                    <span>{isRu ? 'Язык интерфейса' : 'Language'}</span>
                  </div>
                  <div className="flex space-x-1 p-1 bg-black/5 dark:bg-white/10 rounded-lg text-xs font-semibold">
                    <button
                      onClick={() => setLang('ru')}
                      className={`px-2.5 py-1 rounded-md transition-all ${lang === 'ru' ? 'bg-white dark:bg-[#2C2C2E] shadow-sm text-blue-500' : 'text-zinc-500'}`}
                    >
                      Русский
                    </button>
                    <button
                      onClick={() => setLang('en')}
                      className={`px-2.5 py-1 rounded-md transition-all ${lang === 'en' ? 'bg-white dark:bg-[#2C2C2E] shadow-sm text-blue-500' : 'text-zinc-500'}`}
                    >
                      English
                    </button>
                  </div>
                </div>
              </div>

              {/* System Environment Section with Dynamic User Device Info */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-2.5 text-xs`}>
                <span className="text-xs font-bold text-zinc-500 uppercase tracking-wider block">
                  {isRu ? 'Системное окружение' : 'System Environment'}
                </span>

                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Модель устройства' : 'Device Model'}</span>
                  <span className="font-semibold">{deviceInfo.device}</span>
                </div>

                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Версия ОС' : 'OS Version'}</span>
                  <span className="font-semibold text-blue-500">iOS {deviceInfo.os}</span>
                </div>

                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Архитектура' : 'Architecture'}</span>
                  <span className="font-mono">arm64e (PPL Bypass)</span>
                </div>

                <div className="flex justify-between py-1">
                  <span className="text-zinc-500">{isRu ? 'Эксплойт' : 'Exploit'}</span>
                  <span className="font-medium">PhysPuppet / LandCast</span>
                </div>
              </div>

              {/* Jailbreak Management Section */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                <span className="text-xs font-bold text-zinc-500 uppercase tracking-wider block">
                  {isRu ? 'Управление джейлбрейком' : 'Jailbreak Management'}
                </span>

                <div className="flex items-center justify-between text-sm">
                  <span className="text-zinc-500">{isRu ? 'Статус' : 'Status'}</span>
                  <span className={`font-semibold ${isJailbroken ? 'text-green-500' : 'text-zinc-400'}`}>
                    {isJailbroken ? (isRu ? 'Активирован' : 'Active') : (isRu ? 'Не установлен' : 'Not installed')}
                  </span>
                </div>

                <hr className="border-black/5 dark:border-white/5" />

                <button
                  onClick={() => setShowRemoveModal(true)}
                  className="w-full py-2.5 px-3 rounded-xl bg-red-500/10 hover:bg-red-500/20 text-red-500 font-semibold text-sm flex items-center justify-center space-x-2 transition-all"
                >
                  <Trash2 className="w-4 h-4" />
                  <span>{isRu ? 'Убрать джейлбрейк' : 'Remove Jailbreak'}</span>
                </button>
              </div>

              {/* About App */}
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-2.5 text-xs`}>
                <span className="text-xs font-bold text-zinc-500 uppercase tracking-wider block">
                  {isRu ? 'О программе' : 'About'}
                </span>

                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Название' : 'App Name'}</span>
                  <span className="font-bold">Cort1so1</span>
                </div>

                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Версия' : 'Version'}</span>
                  <span className="font-medium">1.0.6 (iOS Native HIG)</span>
                </div>

                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Пакетный менеджер' : 'Package Manager'}</span>
                  <span className="font-medium">Sileo v2.6</span>
                </div>

                {/* Creator with Sky-Blue Telegram Icon */}
                <div className="flex items-center justify-between py-1">
                  <span className="text-zinc-500">{isRu ? 'Создатель' : 'Creator'}</span>
                  <a 
                    href="https://t.me/VityaV" 
                    target="_blank" 
                    rel="noreferrer" 
                    className="flex items-center space-x-1.5 text-[#24A1DE] font-semibold hover:underline"
                  >
                    <Send className="w-3.5 h-3.5 text-[#24A1DE] fill-[#24A1DE]" />
                    <span>@VityaV 🇷🇺</span>
                  </a>
                </div>

                <p className="text-[11px] text-zinc-400 pt-2">
                  {isRu 
                    ? 'Cort1so1 — развлекательное демонстрационное приложение-симулятор. Проект создан исключительно в ознакомительных целях.' 
                    : 'Cort1so1 is an educational demonstration simulator created solely for learning and entertainment purposes.'}
                </p>
              </div>
            </div>
          )}
        </main>

        {/* Modal: Remove Jailbreak Confirmation */}
        {showRemoveModal && (
          <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
            <div className={`max-w-xs w-full p-5 rounded-2xl shadow-xl space-y-4 ${isDarkMode ? 'bg-[#1C1C1E]' : 'bg-white'}`}>
              <div className="text-center space-y-1">
                <h3 className="font-bold text-base">{isRu ? 'Удаление джейлбрейка' : 'Remove Jailbreak'}</h3>
                <p className="text-xs text-zinc-500">
                  {isRu 
                    ? 'Вы действительно хотите сбросить состояние джейлбрейка и вернуть систему в исходное состояние?' 
                    : 'Are you sure you want to remove the jailbreak state and restore system status?'}
                </p>
              </div>
              <div className="grid grid-cols-2 gap-2 text-sm font-semibold">
                <button
                  onClick={() => setShowRemoveModal(false)}
                  className="py-2.5 rounded-xl bg-black/5 dark:bg-white/10 hover:bg-black/10 transition-all"
                >
                  {isRu ? 'Отмена' : 'Cancel'}
                </button>
                <button
                  onClick={removeJailbreak}
                  className="py-2.5 rounded-xl bg-red-600 hover:bg-red-500 text-white transition-all"
                >
                  {isRu ? 'Убрать' : 'Remove'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* iOS Native Tab Bar */}
        <nav className={`fixed bottom-0 left-0 right-0 max-w-md mx-auto border-t backdrop-blur-md px-6 py-2 flex justify-around ${
          isDarkMode ? 'bg-[#000000]/85 border-white/10 text-zinc-400' : 'bg-[#F2F2F7]/85 border-black/10 text-zinc-500'
        }`}>
          <button
            onClick={() => setActiveTab('main')}
            className={`flex flex-col items-center space-y-1 transition-colors ${activeTab === 'main' ? 'text-blue-500' : 'hover:text-zinc-300'}`}
          >
            <Shield className="w-5 h-5" />
            <span className="text-[10px] font-medium">{isRu ? 'Основное' : 'Main'}</span>
          </button>
          <button
            onClick={() => setActiveTab('downgrade')}
            className={`flex flex-col items-center space-y-1 transition-colors ${activeTab === 'downgrade' ? 'text-blue-500' : 'hover:text-zinc-300'}`}
          >
            <RotateCcw className="w-5 h-5" />
            <span className="text-[10px] font-medium">{isRu ? 'Откат iOS' : 'Downgrade'}</span>
          </button>
          <button
            onClick={() => setActiveTab('settings')}
            className={`flex flex-col items-center space-y-1 transition-colors ${activeTab === 'settings' ? 'text-blue-500' : 'hover:text-zinc-300'}`}
          >
            <Settings className="w-5 h-5" />
            <span className="text-[10px] font-medium">{isRu ? 'Настройки' : 'Settings'}</span>
          </button>
        </nav>

      </div>
    </div>
  );
}

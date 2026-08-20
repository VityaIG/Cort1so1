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
  Check
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

const sampleFirmwares = [
  { version: "iOS 26.0", build: "30A195", dateRu: "Сентябрь 2025", dateEn: "September 2025", isSigned: true, sizeGB: 7.1 },
  { version: "iOS 25.5.1", build: "29F80", dateRu: "Июль 2025", dateEn: "July 2025", isSigned: true, sizeGB: 6.8 },
  { version: "iOS 25.4", build: "29E210", dateRu: "Май 2025", dateEn: "May 2025", isSigned: false, sizeGB: 6.6 },
  { version: "iOS 25.1", build: "29B120", dateRu: "Декабрь 2024", dateEn: "December 2024", isSigned: false, sizeGB: 6.3 }
];

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

  const [currentStep, setCurrentStep] = useState(0);
  const [executionMode, setExecutionMode] = useState(0);
  const [liveLogs, setLiveLogs] = useState<string[]>([]);
  const [showRemoveModal, setShowRemoveModal] = useState(false);

  // Downgrade states
  const [selectedFw, setSelectedFw] = useState(sampleFirmwares[0]);
  const [isDownloadingFw, setIsDownloadingFw] = useState(false);
  const [downloadProgress, setDownloadProgress] = useState(0);
  const [downgradeComplete, setDowngradeComplete] = useState(false);

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
    setLiveLogs(['[+] Initializing Cort1so1 Dopamine exploit engine...', '[*] Target: iOS 26.0 (arm64e)']);

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

  const startDowngrade = () => {
    setIsDownloadingFw(true);
    setDownloadProgress(0);
    setDowngradeComplete(false);

    const intv = setInterval(() => {
      setDownloadProgress(prev => {
        if (prev >= 1) {
          clearInterval(intv);
          setIsDownloadingFw(false);
          setDowngradeComplete(true);
          return 1;
        }
        return prev + 0.08;
      });
    }, 200);
  };

  const isRu = lang === 'ru';

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
            <span className="text-white/70 font-semibold">CORT1SO1 EXPLOIT ENGINE — iOS 26.0</span>
            <span className="animate-pulse">● EXPLOITING</span>
          </div>
          <div className="flex-1 space-y-1.5 overflow-y-auto">
            <p className="text-white">[+] Kernel slide: 0x1f400000</p>
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
                      <h4 className="font-bold text-sm">iOS 26.0 — {isRu ? 'Совместимо' : 'Compatible'}</h4>
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

          {/* TAB 2: DOWNGRADE */}
          {activeTab === 'downgrade' && (
            <div className="space-y-4">
              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                <label className="text-xs font-bold text-zinc-500 uppercase tracking-wider block">
                  {isRu ? 'Целевая версия прошивки' : 'Target Firmware Version'}
                </label>
                <div className="grid grid-cols-2 gap-2">
                  {sampleFirmwares.map(fw => (
                    <button
                      key={fw.version}
                      onClick={() => setSelectedFw(fw)}
                      className={`p-3 rounded-xl border text-left transition-all ${
                        selectedFw.version === fw.version 
                          ? 'border-blue-500 bg-blue-500/10 text-blue-500' 
                          : 'border-black/5 dark:border-white/10 hover:border-black/20'
                      }`}
                    >
                      <div className="font-bold text-sm">{fw.version}</div>
                      <div className="text-[11px] text-zinc-500">{fw.build} • {fw.isSigned ? (isRu ? 'Подписана' : 'Signed') : 'SHSH2'}</div>
                    </button>
                  ))}
                </div>
              </div>

              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-2 text-xs`}>
                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Сборка' : 'Build'}</span>
                  <span className="font-medium">{selectedFw.build}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-black/5 dark:border-white/5">
                  <span className="text-zinc-500">{isRu ? 'Размер файла' : 'File Size'}</span>
                  <span className="font-medium">{selectedFw.sizeGB} GB</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-zinc-500">{isRu ? 'Статус подписи' : 'Signature Status'}</span>
                  <span className={`font-semibold ${selectedFw.isSigned ? 'text-green-500' : 'text-red-500'}`}>
                    {selectedFw.isSigned ? (isRu ? 'Подписана (TSS)' : 'Signed (TSS)') : (isRu ? 'Не подписана' : 'Unsigned')}
                  </span>
                </div>
              </div>

              <div className={`p-4 rounded-2xl border ${isDarkMode ? 'bg-[#1C1C1E] border-white/5' : 'bg-white border-black/5'} shadow-sm space-y-3`}>
                <button
                  onClick={startDowngrade}
                  disabled={isDownloadingFw}
                  className="w-full py-3.5 px-4 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl transition-all shadow-md flex items-center justify-center space-x-2"
                >
                  <Download className="w-4 h-4" />
                  <span>
                    {isDownloadingFw 
                      ? (isRu ? 'Выполняется симуляция...' : 'Simulating...') 
                      : `${isRu ? 'Начать откат на' : 'Start Downgrade to'} ${selectedFw.version}`}
                  </span>
                </button>

                {isDownloadingFw && (
                  <div className="space-y-1 pt-1">
                    <div className="w-full h-2 bg-blue-500/15 rounded-full overflow-hidden">
                      <div className="h-full bg-blue-500 rounded-full transition-all" style={{ width: `${downloadProgress * 100}%` }} />
                    </div>
                    <div className="flex justify-between text-[11px] text-zinc-500">
                      <span>{Math.round(downloadProgress * 100)}%</span>
                      <span>{(downloadProgress * selectedFw.sizeGB).toFixed(1)} / {selectedFw.sizeGB} GB</span>
                    </div>
                  </div>
                )}

                {downgradeComplete && (
                  <div className="p-3 bg-green-500/10 text-green-500 rounded-xl text-xs flex items-center space-x-2">
                    <Check className="w-4 h-4" />
                    <span>{isRu ? 'Симуляция отката успешно завершена!' : 'Downgrade simulation completed!'}</span>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* TAB 3: SETTINGS */}
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


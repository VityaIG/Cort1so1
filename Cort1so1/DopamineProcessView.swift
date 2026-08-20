import SwiftUI
import UIKit

/// Фазы процесса джейлбрейка в стиле Dopamine
enum DopamineProcessPhase {
    case logging
    case appleWhite
    case blackScreen
    case appleRed
    case respring
}

/// Модель отдельного шага логов процесса джейлбрейка
struct JailbreakLogStep: Identifiable {
    let id: Int
    let titleRu: String
    let titleEn: String
    let detailRu: String
    let detailEn: String
    let isMajorPhase: Bool
    let stageNameRu: String
    let stageNameEn: String
    let telemetryField: String?
    let telemetryValue: String?
    let iconName: String
}

/// Модальное окно процесса джейлбрейка в стиле Dopamine с нативными тактильными откликами, телеметрией и крупным шрифтом
struct DopamineProcessView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [JailbreakLogStep] = []
    @State private var currentStepIndex: Int = 0
    @State private var appleWhiteOpacity: Double = 0.0
    @State private var appleRedOpacity: Double = 0.0
    
    // Живые параметры телеметрии
    @State private var telemetryKaslr: String = "0x0000000000000000"
    @State private var telemetryTfp0: String = "Ожидание..."
    @State private var telemetryUid: String = "UID: 501 (mobile)"
    @State private var telemetryPpl: String = "Защищен (PPL/SPTM)"
    @State private var telemetryTrustCache: String = "Стандартный"
    @State private var currentStageLabel: String = "Инициализация"

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    /// Расширенная и детализированная последовательность логов
    private var logSteps: [JailbreakLogStep] {
        [
            JailbreakLogStep(
                id: 1,
                titleRu: "Инициализация Cort1so1 Engine",
                titleEn: "Initializing Cort1so1 Engine",
                detailRu: "Определение архитектуры Apple Silicon arm64e и ревизии ядра",
                detailEn: "Detecting Apple Silicon arm64e architecture & kernel revision",
                isMajorPhase: false,
                stageNameRu: "Ядро",
                stageNameEn: "Kernel",
                telemetryField: "kaslr",
                telemetryValue: "0x1bc24000",
                iconName: "cpu"
            ),
            JailbreakLogStep(
                id: 2,
                titleRu: "Определение KASLR Slide mach_kernel",
                titleEn: "Computing mach_kernel KASLR Slide",
                detailRu: "Базовый адрес: 0xfffffff007004000 | Смещение: 0x1bc24000",
                detailEn: "Base address: 0xfffffff007004000 | Slide: 0x1bc24000",
                isMajorPhase: false,
                stageNameRu: "Ядро",
                stageNameEn: "Kernel",
                telemetryField: "kaslr",
                telemetryValue: "0x1bc24000",
                iconName: "memorychip"
            ),
            JailbreakLogStep(
                id: 3,
                titleRu: "Картирование физической памяти",
                titleEn: "Mapping Physical Memory Space",
                detailRu: "Диапазон: 0xffffffe000000000 - 0xffffffe3ffffffff (PhysPuppet)",
                detailEn: "Range: 0xffffffe000000000 - 0xffffffe3ffffffff (PhysPuppet)",
                isMajorPhase: false,
                stageNameRu: "Ядро",
                stageNameEn: "Kernel",
                telemetryField: "tfp0",
                telemetryValue: "kread64 / kwrite64 OK",
                iconName: "square.stack.3d.down.right.fill"
            ),
            JailbreakLogStep(
                id: 4,
                titleRu: "Активация примитива kread64 / kwrite64",
                titleEn: "Activating kread64 / kwrite64 Primitives",
                detailRu: "Получен порт задачи ядра task_for_pid(0) [tfp0: 0x403]",
                detailEn: "Acquired kernel task port task_for_pid(0) [tfp0: 0x403]",
                isMajorPhase: false,
                stageNameRu: "Ядро",
                stageNameEn: "Kernel",
                telemetryField: "tfp0",
                telemetryValue: "0x403 (Active)",
                iconName: "bolt.horizontal.fill"
            ),
            JailbreakLogStep(
                id: 5,
                titleRu: "Фаза 1 завершена: Ядро и память инициализированы",
                titleEn: "Phase 1 Complete: Kernel & Memory Mapped",
                detailRu: "Стабильность примитива чтения/записи ядра: 100%",
                detailEn: "Kernel memory read/write primitive stability: 100%",
                isMajorPhase: true,
                stageNameRu: "Ядро OK",
                stageNameEn: "Kernel OK",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "checkmark.seal.fill"
            ),
            JailbreakLogStep(
                id: 6,
                titleRu: "Обход защиты Page Protection Layer (PPL)",
                titleEn: "Bypassing Page Protection Layer (PPL)",
                detailRu: "Разблокированы таблицы страниц L2 PTE для записи в память ядра",
                detailEn: "Unlocked L2 PTE page tables for kernel memory write access",
                isMajorPhase: false,
                stageNameRu: "PPL & PAC",
                stageNameEn: "PPL & PAC",
                telemetryField: "ppl",
                telemetryValue: "PPL Bypassed (L2 PTE)",
                iconName: "shield.slash.fill"
            ),
            JailbreakLogStep(
                id: 7,
                titleRu: "Анализ Pointer Authentication (PAC)",
                titleEn: "Evaluating Pointer Authentication (PAC)",
                detailRu: "Подмена криптографических ключей подписи указателей IA / DA",
                detailEn: "Forging pointer authentication signing keys IA / DA",
                isMajorPhase: false,
                stageNameRu: "PPL & PAC",
                stageNameEn: "PPL & PAC",
                telemetryField: "ppl",
                telemetryValue: "PPL + PAC Bypassed",
                iconName: "key.fill"
            ),
            JailbreakLogStep(
                id: 8,
                titleRu: "Поиск дескриптора процесса proc_t",
                titleEn: "Locating Process Descriptor proc_t",
                detailRu: "Смещение allproc найдено по адресу: 0xfffffff00938b120",
                detailEn: "allproc offset located at: 0xfffffff00938b120",
                isMajorPhase: false,
                stageNameRu: "Привилегии",
                stageNameEn: "Privileges",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "magnifyingglass.circle.fill"
            ),
            JailbreakLogStep(
                id: 9,
                titleRu: "Повышение привилегий до Root (UID 0)",
                titleEn: "Escalating Privileges to Root (UID 0)",
                detailRu: "Замена структуры ucred: UID 501 -> UID 0, сброс флагов cr_svgid",
                detailEn: "Swapping ucred struct: UID 501 -> UID 0, cr_svgid flags cleared",
                isMajorPhase: false,
                stageNameRu: "Привилегии",
                stageNameEn: "Privileges",
                telemetryField: "uid",
                telemetryValue: "UID: 0 (root)",
                iconName: "crown.fill"
            ),
            JailbreakLogStep(
                id: 10,
                titleRu: "Снятие ограничений песочницы (Sandbox Escape)",
                titleEn: "Unsandboxing Process (Sandbox Escape)",
                detailRu: "Отключение изоляции Mach Sandbox для текущего task_t",
                detailEn: "Disabled Mach Sandbox container isolation for task_t",
                isMajorPhase: false,
                stageNameRu: "Привилегии",
                stageNameEn: "Privileges",
                telemetryField: "uid",
                telemetryValue: "UID: 0 (Unsandboxed)",
                iconName: "lock.open.fill"
            ),
            JailbreakLogStep(
                id: 11,
                titleRu: "Фаза 2 завершена: Получены права Root и снята песочница",
                titleEn: "Phase 2 Complete: Root Escalation & Unsandboxing",
                detailRu: "Процесс обладает наивысшим уровнем системного доступа",
                detailEn: "Process running with unrestricted highest system privileges",
                isMajorPhase: true,
                stageNameRu: "Root OK",
                stageNameEn: "Root OK",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "checkmark.seal.fill"
            ),
            JailbreakLogStep(
                id: 12,
                titleRu: "Патчинг хуков AMFI и проверка CoreTrust",
                titleEn: "Patching AMFI Hooks & CoreTrust Bypass",
                detailRu: "Деактивация проверки подписи Mach-O и cs_enforcement флагов",
                detailEn: "Bypassed Mach-O signature verification & cs_enforcement flags",
                isMajorPhase: false,
                stageNameRu: "TrustCache",
                stageNameEn: "TrustCache",
                telemetryField: "trustCache",
                telemetryValue: "AMFI Patched",
                iconName: "checkmark.shield.fill"
            ),
            JailbreakLogStep(
                id: 13,
                titleRu: "Внедрение динамического TrustCache",
                titleEn: "Injecting Dynamic TrustCache to Kernel",
                detailRu: "Добавлено 1,420 SHA-256 хэшей системных утилит в память ядра",
                detailEn: "Injected 1,420 binary SHA-256 hashes into kernel TrustCache list",
                isMajorPhase: false,
                stageNameRu: "TrustCache",
                stageNameEn: "TrustCache",
                telemetryField: "trustCache",
                telemetryValue: "TrustCache (1,420 hashes)",
                iconName: "internaldrive.fill"
            ),
            JailbreakLogStep(
                id: 14,
                titleRu: "Тест стабильности и проверка вероятности бутлупа",
                titleEn: "Stability Test & Bootloop Probability Check",
                detailRu: "Вероятность сбоя: 0.00% | Проверка NVRAM boot-args успешна",
                detailEn: "Crash probability: 0.00% | NVRAM boot-args validation passed",
                isMajorPhase: false,
                stageNameRu: "Стабильность",
                stageNameEn: "Stability",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "waveform.path.ecg"
            ),
            JailbreakLogStep(
                id: 15,
                titleRu: "Фаза 3 завершена: TrustCache активен, риски отсутствуют",
                titleEn: "Phase 3 Complete: TrustCache Injected & Safe",
                detailRu: "Система полностью готова к монтированию rootless bootstrap",
                detailEn: "System integrity verified for rootless bootstrap mount",
                isMajorPhase: true,
                stageNameRu: "TrustCache OK",
                stageNameEn: "TrustCache OK",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "checkmark.seal.fill"
            ),
            JailbreakLogStep(
                id: 16,
                titleRu: "Монтирование файловой системы APFS RootFS",
                titleEn: "Mounting Rootless APFS Preboot Path",
                detailRu: "Точка монтирования: /private/preboot/cort1so1_rootfs (rw)",
                detailEn: "Mount point: /private/preboot/cort1so1_rootfs (read-write)",
                isMajorPhase: false,
                stageNameRu: "Bootstrap",
                stageNameEn: "Bootstrap",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "folder.fill"
            ),
            JailbreakLogStep(
                id: 17,
                titleRu: "Развертывание Procursus Bootstrap & ElleKit",
                titleEn: "Extracting Procursus Bootstrap & ElleKit",
                detailRu: "Распаковка dpkg, apt, libsubstrate.dylib, Sileo.app и Zebra.app",
                detailEn: "Unpacking dpkg, apt, libsubstrate.dylib, Sileo.app & Zebra.app",
                isMajorPhase: false,
                stageNameRu: "Bootstrap",
                stageNameEn: "Bootstrap",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "archivebox.fill"
            ),
            JailbreakLogStep(
                id: 18,
                titleRu: "Запуск системного демона cort1so1_daemon",
                titleEn: "Starting cort1so1_daemon IPC Service",
                detailRu: "Служба запущена на локальном сокете /var/run/cort1so1.sock",
                detailEn: "IPC daemon active on local socket /var/run/cort1so1.sock",
                isMajorPhase: false,
                stageNameRu: "Демон",
                stageNameEn: "Daemon",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "server.rack"
            ),
            JailbreakLogStep(
                id: 19,
                titleRu: "Инъекция хуков в launchd (PID: 1)",
                titleEn: "Hooking System Service launchd (PID: 1)",
                detailRu: "Твик-инжектор ElleKit успешно перехватил libsystem_trace",
                detailEn: "ElleKit hook engine successfully attached to launchd",
                isMajorPhase: false,
                stageNameRu: "Launchd",
                stageNameEn: "Launchd",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "arrow.triangle.merge"
            ),
            JailbreakLogStep(
                id: 20,
                titleRu: "Джейлбрейк успешно подготовлен к респрингу",
                titleEn: "Jailbreak Environment Ready for Respring",
                detailRu: "Синхронизация дескрипторов и запуск перезагрузки ядра",
                detailEn: "Syncing file descriptors and triggering kernel respring",
                isMajorPhase: true,
                stageNameRu: "Финал",
                stageNameEn: "Final",
                telemetryField: nil,
                telemetryValue: nil,
                iconName: "sparkles"
            )
        ]
    }

    var body: some View {
        ZStack {
            // Глубокий темный фон в стиле Apple / Dopamine
            Color(red: 0.05, green: 0.05, blue: 0.07)
                .ignoresSafeArea()

            switch phase {
            case .logging:
                loggingInterface
                    .transition(.opacity)

            case .appleWhite:
                appleLogoView(color: .white, opacity: appleWhiteOpacity)
                    .transition(.opacity)

            case .blackScreen:
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

            case .appleRed:
                appleLogoView(color: Color(red: 0.95, green: 0.22, blue: 0.22), opacity: appleRedOpacity)
                    .transition(.opacity)

            case .respring:
                respringView
                    .transition(.opacity)
            }
        }
        .interactiveDismissDisabled(true)
        .preferredColorScheme(.dark)
        .task {
            await runExecutionPipeline()
        }
    }

    // MARK: - 1. Главный интерфейс процесса джейлбрейка

    private var loggingInterface: some View {
        VStack(spacing: 0) {
            // Верхний нативный бар
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Circle().fill(Color(red: 0.95, green: 0.35, blue: 0.35)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 0.95, green: 0.75, blue: 0.25)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 0.35, green: 0.85, blue: 0.45)).frame(width: 10, height: 10)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Cort1so1 Exploit Engine")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("[\(currentStepIndex)/\(logSteps.count)]")
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.14))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.09, green: 0.09, blue: 0.12))

            // Прогресс-бар сверху
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 3.5)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan, Color(red: 0.3, green: 0.85, blue: 0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(10, geo.size.width * CGFloat(Double(currentStepIndex) / Double(max(1, logSteps.count)))),
                            height: 3.5
                        )
                        .animation(.easeInOut(duration: 0.25), value: currentStepIndex)
                }
            }
            .frame(height: 3.5)

            // Блок живой телеметрии эксплойта
            telemetryCard
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Divider()
                .background(Color.white.opacity(0.08))

            // Список логов с крупным и красивым шрифтом SF Pro
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(visibleLogs) { step in
                            logRowView(for: step)
                                .id(step.id)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: visibleLogs.count) { _ in
                    if let lastStep = visibleLogs.last {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(lastStep.id, anchor: .bottom)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            // Нижняя информационная плашка статуса
            HStack(spacing: 12) {
                ProgressView()
                    .tint(.blue)
                    .scaleEffect(0.9)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isRu ? "Выполняется джейлбрейк..." : "Jailbreak in progress...")
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundColor(.white)

                    Text(isRu ? "Этап: \(currentStageLabel)" : "Stage: \(currentStageLabel)")
                        .font(.system(size: 11, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "cpu")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    Text("arm64e • tfp0")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.12))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.08, green: 0.08, blue: 0.10))
        }
    }

    // MARK: - Карточка живой телеметрии эксплойта

    private var telemetryCard: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text(isRu ? "Телеметрия ядра" : "Kernel Telemetry")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Text(isRu ? "Текущий модуль: \(currentStageLabel)" : "Module: \(currentStageLabel)")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(.cyan)
            }

            // Сетка параметров телеметрии
            HStack(spacing: 8) {
                telemetryItem(label: "KASLR", value: telemetryKaslr, color: .blue)
                telemetryItem(label: "TFP0 Port", value: telemetryTfp0, color: .cyan)
                telemetryItem(label: "Привилегии", value: telemetryUid, color: .green)
            }

            HStack(spacing: 8) {
                telemetryItem(label: "PPL / PAC", value: telemetryPpl, color: .orange)
                telemetryItem(label: "TrustCache", value: telemetryTrustCache, color: .purple)
            }
        }
        .padding(12)
        .background(Color(red: 0.09, green: 0.09, blue: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func telemetryItem(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9.5, weight: .bold, design: .default))
                .foregroundColor(.secondary)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 10.5, weight: .semibold, design: .default))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // MARK: - Строка отдельного лога

    private func logRowView(for step: JailbreakLogStep) -> some View {
        let isMajor = step.isMajorPhase

        return HStack(alignment: .top, spacing: 12) {
            // Иконка шага
            ZStack {
                Circle()
                    .fill(isMajor ? Color.green.opacity(0.18) : Color.blue.opacity(0.12))
                    .frame(width: 30, height: 30)

                Image(systemName: step.iconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isMajor ? Color(red: 0.3, green: 0.9, blue: 0.5) : Color.blue)
            }
            .padding(.top, 1)

            // Заголовок и детальное описание
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center, spacing: 6) {
                    Text(isRu ? step.titleRu : step.titleEn)
                        .font(.system(size: isMajor ? 16 : 15, weight: isMajor ? .bold : .semibold, design: .default))
                        .foregroundColor(isMajor ? Color(red: 0.35, green: 0.92, blue: 0.55) : .white)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    if isMajor {
                        Text(isRu ? "УСПЕХ" : "DONE")
                            .font(.system(size: 9, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.35, green: 0.92, blue: 0.55))
                            .clipShape(Capsule())
                    }
                }

                Text(isRu ? step.detailRu : step.detailEn)
                    .font(.system(size: 12.5, weight: .regular, design: .default))
                    .foregroundColor(isMajor ? Color.white.opacity(0.85) : Color.white.opacity(0.6))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isMajor ? Color.green.opacity(0.08) : Color.white.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isMajor ? Color.green.opacity(0.25) : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - 2. Экран с логотипом Apple

    private func appleLogoView(color: Color, opacity: Double) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(systemName: "applelogo")
                .font(.system(size: 92, weight: .regular))
                .foregroundColor(color)
                .opacity(opacity)
        }
    }

    // MARK: - 3. Экран респринга (Respring)

    private var respringView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.6)

                Text(strings.respringText)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    // MARK: - 4. Асинхронный пайплайн выполнения с тактильным откликом (Haptics)

    private func runExecutionPipeline() async {
        // Фаза 1: Последовательный вывод логов с реалистичными задержками
        for (idx, step) in logSteps.enumerated() {
            let delayNanos: UInt64 = step.isMajorPhase ? 700_000_000 : 450_000_000
            try? await Task.sleep(nanoseconds: delayNanos)

            await MainActor.run {
                triggerHaptic(isMajor: step.isMajorPhase)
                
                // Обновление телеметрии
                if let field = step.telemetryField, let value = step.telemetryValue {
                    switch field {
                    case "kaslr":
                        telemetryKaslr = value
                    case "tfp0":
                        telemetryTfp0 = value
                    case "uid":
                        telemetryUid = value
                    case "ppl":
                        telemetryPpl = value
                    case "trustCache":
                        telemetryTrustCache = value
                    default:
                        break
                    }
                }
                
                currentStageLabel = isRu ? step.stageNameRu : step.stageNameEn
                
                withAnimation(.easeOut(duration: 0.22)) {
                    visibleLogs.append(step)
                    currentStepIndex = idx + 1
                }
            }
        }

        // Пауза перед переходом к экранам Apple
        try? await Task.sleep(nanoseconds: 700_000_000)

        // Фаза 2: Появление белого логотипа Apple
        await MainActor.run {
            triggerImpact(style: .light)
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .appleWhite
            }
        }
        await MainActor.run {
            withAnimation(.easeIn(duration: 0.35)) {
                appleWhiteOpacity = 1.0
            }
        }

        // Белый логотип отображается на экране
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        // Белый логотип плавно затухает
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.35)) {
                appleWhiteOpacity = 0.0
            }
        }
        try? await Task.sleep(nanoseconds: 350_000_000)

        // Фаза 3: Ровно 1 секунда чистого черного экрана
        await MainActor.run {
            phase = .blackScreen
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Фаза 4: Появление красного логотипа Apple
        await MainActor.run {
            triggerImpact(style: .medium)
            phase = .appleRed
        }
        await MainActor.run {
            withAnimation(.easeIn(duration: 0.35)) {
                appleRedOpacity = 1.0
            }
        }

        // Красный логотип отображается на экране
        try? await Task.sleep(nanoseconds: 1_300_000_000)

        // Красный логотип затухает
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.35)) {
                appleRedOpacity = 0.0
            }
        }
        try? await Task.sleep(nanoseconds: 350_000_000)

        // Фаза 5: Респринг SpringBoard
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                phase = .respring
            }
        }

        // Время респринга
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // Успешный финальный отклик и завершение
        await MainActor.run {
            triggerNotificationSuccess()
            onComplete()
        }
    }

    // MARK: - Тактильные эффекты (Haptics)

    private func triggerHaptic(isMajor: Bool) {
        if isMajor {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        } else {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }

    private func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    private func triggerNotificationSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    DopamineProcessView(onComplete: {})
}

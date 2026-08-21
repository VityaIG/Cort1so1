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
struct JailbreakLogStep: Identifiable, Equatable {
    let id: Int
    let titleRu: String
    let titleEn: String
    let isMajorPhase: Bool
    let iconName: String
}

/// Модальное окно процесса джейлбрейка в стиле Dopamine с ультра-плавными нативными анимациями
struct DopamineProcessView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [JailbreakLogStep] = []
    @State private var currentStepIndex: Int = 0
    
    // Анимационные параметры для логотипов Apple и респринга
    @State private var appleWhiteOpacity: Double = 0.0
    @State private var appleWhiteScale: CGFloat = 0.92
    @State private var appleRedOpacity: Double = 0.0
    @State private var appleRedScale: CGFloat = 0.94
    @State private var appleRedGlow: CGFloat = 0.0
    @State private var respringRotation: Double = 0.0

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    /// Список последовательных логов джейлбрейка
    private var logSteps: [JailbreakLogStep] {
        [
            JailbreakLogStep(
                id: 1,
                titleRu: "Инициализация Cort1so1 Engine",
                titleEn: "Initializing Cort1so1 Engine",
                isMajorPhase: false,
                iconName: "gearshape.fill"
            ),
            JailbreakLogStep(
                id: 2,
                titleRu: "Определение KASLR Slide mach_kernel",
                titleEn: "Computing mach_kernel KASLR Slide",
                isMajorPhase: false,
                iconName: "memorychip"
            ),
            JailbreakLogStep(
                id: 3,
                titleRu: "Картирование физической памяти PhysPuppet",
                titleEn: "Mapping Physical Memory (PhysPuppet)",
                isMajorPhase: false,
                iconName: "square.stack.3d.down.right.fill"
            ),
            JailbreakLogStep(
                id: 4,
                titleRu: "Активация примитива kread64 / kwrite64",
                titleEn: "Activating kread64 / kwrite64 Primitives",
                isMajorPhase: false,
                iconName: "bolt.horizontal.fill"
            ),
            JailbreakLogStep(
                id: 5,
                titleRu: "Фаза 1: Ядро и память инициализированы",
                titleEn: "Phase 1: Kernel & Memory Mapped",
                isMajorPhase: true,
                iconName: "checkmark.circle.fill"
            ),
            JailbreakLogStep(
                id: 6,
                titleRu: "Обход защиты Page Protection Layer (PPL)",
                titleEn: "Bypassing Page Protection Layer (PPL)",
                isMajorPhase: false,
                iconName: "shield.slash.fill"
            ),
            JailbreakLogStep(
                id: 7,
                titleRu: "Анализ Pointer Authentication (PAC)",
                titleEn: "Evaluating Pointer Authentication (PAC)",
                isMajorPhase: false,
                iconName: "key.fill"
            ),
            JailbreakLogStep(
                id: 8,
                titleRu: "Поиск дескриптора процесса proc_t",
                titleEn: "Locating Process Descriptor proc_t",
                isMajorPhase: false,
                iconName: "magnifyingglass"
            ),
            JailbreakLogStep(
                id: 9,
                titleRu: "Повышение привилегий до Root (UID 0)",
                titleEn: "Escalating Privileges to Root (UID 0)",
                isMajorPhase: false,
                iconName: "crown.fill"
            ),
            JailbreakLogStep(
                id: 10,
                titleRu: "Снятие ограничений песочницы (Sandbox Escape)",
                titleEn: "Unsandboxing Process (Sandbox Escape)",
                isMajorPhase: false,
                iconName: "lock.open.fill"
            ),
            JailbreakLogStep(
                id: 11,
                titleRu: "Фаза 2: Получены права Root и снята песочница",
                titleEn: "Phase 2: Root Escalation & Unsandboxed",
                isMajorPhase: true,
                iconName: "checkmark.circle.fill"
            ),
            JailbreakLogStep(
                id: 12,
                titleRu: "Патчинг хуков AMFI и проверка CoreTrust",
                titleEn: "Patching AMFI Hooks & CoreTrust Bypass",
                isMajorPhase: false,
                iconName: "checkmark.shield.fill"
            ),
            JailbreakLogStep(
                id: 13,
                titleRu: "Внедрение динамического TrustCache",
                titleEn: "Injecting Dynamic TrustCache to Kernel",
                isMajorPhase: false,
                iconName: "internaldrive.fill"
            ),
            JailbreakLogStep(
                id: 14,
                titleRu: "Тест стабильности и проверка вероятности бутлупа",
                titleEn: "Stability Test & Bootloop Check",
                isMajorPhase: false,
                iconName: "waveform.path.ecg"
            ),
            JailbreakLogStep(
                id: 15,
                titleRu: "Фаза 3: TrustCache активен, риски отсутствуют",
                titleEn: "Phase 3: TrustCache Injected & Safe",
                isMajorPhase: true,
                iconName: "checkmark.circle.fill"
            ),
            JailbreakLogStep(
                id: 16,
                titleRu: "Монтирование файловой системы APFS RootFS",
                titleEn: "Mounting Rootless APFS Preboot Path",
                isMajorPhase: false,
                iconName: "folder.fill"
            ),
            JailbreakLogStep(
                id: 17,
                titleRu: "Развертывание Procursus Bootstrap & ElleKit",
                titleEn: "Extracting Procursus Bootstrap & ElleKit",
                isMajorPhase: false,
                iconName: "archivebox.fill"
            ),
            JailbreakLogStep(
                id: 18,
                titleRu: "Запуск системного демона cort1so1_daemon",
                titleEn: "Starting cort1so1_daemon IPC Service",
                isMajorPhase: false,
                iconName: "server.rack"
            ),
            JailbreakLogStep(
                id: 19,
                titleRu: "Инъекция хуков в launchd (PID: 1)",
                titleEn: "Hooking System Service launchd (PID: 1)",
                isMajorPhase: false,
                iconName: "arrow.triangle.merge"
            ),
            JailbreakLogStep(
                id: 20,
                titleRu: "Джейлбрейк успешно подготовлен к респрингу",
                titleEn: "Jailbreak Environment Ready for Respring",
                isMajorPhase: true,
                iconName: "sparkles"
            )
        ]
    }

    private var progressRatio: Double {
        Double(currentStepIndex) / Double(max(1, logSteps.count))
    }

    var body: some View {
        ZStack {
            // Чистый сплошной черный фон без градиентов
            Color.black
                .ignoresSafeArea()

            switch phase {
            case .logging:
                loggingInterface
                    .transition(.opacity)

            case .appleWhite:
                appleLogoView(color: .white, opacity: appleWhiteOpacity, scale: appleWhiteScale)
                    .transition(.opacity)

            case .blackScreen:
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

            case .appleRed:
                appleRedView
                    .transition(.opacity)

            case .respring:
                respringView
                    .transition(.opacity)
            }
        }
        
        .preferredColorScheme(.dark)
        .onAppear {
            runExecutionPipeline(stepIndex: 0)
        }
    }

    // MARK: - Главный интерфейс логов

    private var loggingInterface: some View {
        VStack(spacing: 0) {
            // Верхняя нативная панель
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Circle().fill(Color(red: 0.95, green: 0.35, blue: 0.35)).frame(width: 9, height: 9)
                    Circle().fill(Color(red: 0.95, green: 0.75, blue: 0.25)).frame(width: 9, height: 9)
                    Circle().fill(Color(red: 0.35, green: 0.85, blue: 0.45)).frame(width: 9, height: 9)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Cort1so1")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("[\(currentStepIndex)/\(logSteps.count)]")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                    Text("\(Int(progressRatio * 100))%")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 0.35, green: 0.9, blue: 0.5))
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)

            // Прогресс-бар с динамической подсветкой
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 2.5)

                    Rectangle()
                        .fill(AppTheme.resolveColor(name: appThemeColor))
                        .frame(
                            width: max(6, geo.size.width * CGFloat(progressRatio)),
                            height: 2.5
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStepIndex)
                }
            }
            .frame(height: 2.5)

            // Список логов: анимации каждого элемента
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(visibleLogs.enumerated().reversed()), id: \.element.id) { index, step in
                            let isCurrentRunning = (index == visibleLogs.count - 1 && currentStepIndex < logSteps.count)
                            let isDone = !isCurrentRunning

                            HStack(alignment: .center, spacing: 12) {
                                // Иконка состояния: если выполняется — индикатор прогресса, если завершен — зеленая галочка / значок
                                if isCurrentRunning {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.85)
                                        .frame(width: 22, height: 22)
                                } else if step.isMajorPhase {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color(red: 0.35, green: 0.9, blue: 0.5))
                                        .frame(width: 22, height: 22)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(red: 0.35, green: 0.9, blue: 0.5).opacity(0.9))
                                        .frame(width: 22, height: 22)
                                }

                                // Текст лога
                                Text(isRu ? step.titleRu : step.titleEn)
                                    .font(.system(size: step.isMajorPhase ? 15 : 14, weight: step.isMajorPhase ? .bold : (isCurrentRunning ? .semibold : .regular)))
                                    .foregroundColor(step.isMajorPhase ? Color(red: 0.35, green: 0.9, blue: 0.5) : (isCurrentRunning ? Color.white : Color.white.opacity(0.85)))
                                    .lineLimit(2)

                                Spacer(minLength: 0)

                                if step.isMajorPhase {
                                    Text(isRu ? "OK" : "DONE")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2.5)
                                        .background(Color(red: 0.35, green: 0.9, blue: 0.5))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                isCurrentRunning
                                    ? Color.white.opacity(0.06)
                                    : (step.isMajorPhase ? Color(red: 0.35, green: 0.9, blue: 0.5).opacity(0.08) : Color.clear)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .id(step.id)
                            .scaleEffect(x: 1, y: -1, anchor: .center)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scaleEffect(x: 1, y: -1, anchor: .center)
            }

            Spacer(minLength: 0)

            // Нижняя компактная статусная строка
            HStack(spacing: 10) {
                ProgressView()
                    
                    .scaleEffect(0.8)

                Text(isRu ? "Выполняется джейлбрейк..." : "Jailbreak in progress...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Text("rootless • arm64e")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 0.5),
                alignment: .top
            )
        }
        .background(Color.black)
    }

    // MARK: - Экран с логотипом Apple

    private func appleLogoView(color: Color, opacity: Double, scale: CGFloat) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(systemName: "applelogo")
                .font(.system(size: 96, weight: .regular))
                .foregroundColor(color)
                .scaleEffect(scale)
                .opacity(opacity)
        }
    }

    private var appleRedView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(systemName: "applelogo")
                .font(.system(size: 96, weight: .regular))
                .foregroundColor(Color(red: 0.96, green: 0.22, blue: 0.22))
                .scaleEffect(appleRedScale)
                .opacity(appleRedOpacity)
        }
    }

    // MARK: - Экран респринга (Respring)

    private var respringView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 26) {
                // Плавный системный индикатор респринга SpringBoard
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.7)

                Text(strings.respringText)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    // MARK: - Замедленный асинхронный пайплайн выполнения

    private func runExecutionPipeline(stepIndex: Int) {
        if stepIndex < logSteps.count {
            let step = logSteps[stepIndex]
            self.currentStepIndex = stepIndex + 1
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.visibleLogs.append(step)
            }
            self.triggerHaptic(isMajor: step.isMajorPhase)
            
            let delay: Double = step.isMajorPhase ? 1.5 : 1.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.runExecutionPipeline(stepIndex: stepIndex + 1)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.phase = .appleWhite
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.appleWhiteOpacity = 1.0
                        self.appleWhiteScale = 1.0
                    }
                    self.triggerHaptic(isMajor: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.phase = .appleRed
                        }
                        withAnimation(.easeIn(duration: 1.5)) {
                            self.appleRedOpacity = 1.0
                            self.appleRedScale = 1.2
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.phase = .respring
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                self.onComplete()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Haptics

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

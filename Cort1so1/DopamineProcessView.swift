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
    let isMajorPhase: Bool
    let iconName: String
}

/// Модальное окно процесса джейлбрейка в стиле Dopamine с компактными логами на чистом черном фоне
struct DopamineProcessView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [JailbreakLogStep] = []
    @State private var currentStepIndex: Int = 0
    @State private var appleWhiteOpacity: Double = 0.0
    @State private var appleRedOpacity: Double = 0.0

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

                Text("[\(currentStepIndex)/\(logSteps.count)]")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)

            // Простой плоский сплошной прогресс-бар (без градиента)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 2)

                    Rectangle()
                        .fill(Color.white)
                        .frame(
                            width: max(8, geo.size.width * CGFloat(Double(currentStepIndex) / Double(max(1, logSteps.count)))),
                            height: 2
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentStepIndex)
                }
            }
            .frame(height: 2)

            // Компактный список логов: просто иконка и текст лога
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(visibleLogs) { step in
                            HStack(alignment: .center, spacing: 10) {
                                // Компактная иконка
                                Image(systemName: step.iconName)
                                    .font(.system(size: step.isMajorPhase ? 14 : 12, weight: step.isMajorPhase ? .bold : .medium))
                                    .foregroundColor(step.isMajorPhase ? Color(red: 0.35, green: 0.9, blue: 0.5) : Color.white.opacity(0.7))
                                    .frame(width: 18, height: 18)

                                // Текст лога
                                Text(isRu ? step.titleRu : step.titleEn)
                                    .font(.system(size: step.isMajorPhase ? 14 : 13, weight: step.isMajorPhase ? .bold : .regular))
                                    .foregroundColor(step.isMajorPhase ? Color(red: 0.35, green: 0.9, blue: 0.5) : Color.white)
                                    .lineLimit(2)

                                Spacer(minLength: 0)

                                if step.isMajorPhase {
                                    Text(isRu ? "OK" : "DONE")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1.5)
                                        .background(Color(red: 0.35, green: 0.9, blue: 0.5))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.vertical, 4)
                            .id(step.id)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: visibleLogs.count) { _ in
                    if let lastStep = visibleLogs.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastStep.id, anchor: .bottom)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            // Нижняя компактная статусная строка (сплошной черный фон)
            HStack(spacing: 10) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(0.8)

                Text(isRu ? "Выполняется джейлбрейк..." : "Jailbreak in progress...")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Text("iOS 18 • rootless")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 0.5),
                alignment: .top
            )
        }
        .background(Color.black)
    }

    // MARK: - Экран с логотипом Apple

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

    // MARK: - Экран респринга (Respring)

    private var respringView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.6)

                Text(strings.respringText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    // MARK: - Замедленный асинхронный пайплайн выполнения

    private func runExecutionPipeline() async {
        // Вывод логов с более плавными и медленными задержками (1.1s - 1.6s на шаг)
        for (idx, step) in logSteps.enumerated() {
            let delayNanos: UInt64 = step.isMajorPhase ? 1_600_000_000 : 1_100_000_000
            try? await Task.sleep(nanoseconds: delayNanos)

            await MainActor.run {
                triggerHaptic(isMajor: step.isMajorPhase)

                withAnimation(.easeOut(duration: 0.3)) {
                    visibleLogs.append(step)
                    currentStepIndex = idx + 1
                }
            }
        }

        // Пауза перед переходом к экранам Apple
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        // Появление белого логотипа Apple
        await MainActor.run {
            triggerImpact(style: .light)
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .appleWhite
            }
        }
        await MainActor.run {
            withAnimation(.easeIn(duration: 0.4)) {
                appleWhiteOpacity = 1.0
            }
        }

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Затухание белого логотипа
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.4)) {
                appleWhiteOpacity = 0.0
            }
        }
        try? await Task.sleep(nanoseconds: 400_000_000)

        // Чистый черный экран
        await MainActor.run {
            phase = .blackScreen
        }
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        // Появление красного логотипа Apple
        await MainActor.run {
            triggerImpact(style: .medium)
            phase = .appleRed
        }
        await MainActor.run {
            withAnimation(.easeIn(duration: 0.4)) {
                appleRedOpacity = 1.0
            }
        }

        try? await Task.sleep(nanoseconds: 1_600_000_000)

        // Затухание красного логотипа
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.4)) {
                appleRedOpacity = 0.0
            }
        }
        try? await Task.sleep(nanoseconds: 400_000_000)

        // Респринг
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                phase = .respring
            }
        }

        try? await Task.sleep(nanoseconds: 2_400_000_000)

        // Завершение
        await MainActor.run {
            triggerNotificationSuccess()
            onComplete()
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

import SwiftUI

/// Главный экран утилиты «Cort1so1» в стиле Dopamine Jailbreak (iOS HIG)
struct MainView: View {
    @Binding var jailbreakState: JailbreakState
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false

    @State private var currentStepIndex: Int = 0
    @State private var stepTimer: Timer?
    @State private var isProcessing: Bool = false
    @State private var executionMode: Int = 0
    @State private var liveLogs: [String] = []

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var pipelineSteps: [PipelineStep] {
        getPipelineSteps(for: strings)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Сегментированный переключатель режимов (Rootless / Стандарт / Эксперт)
                        modeSelectorSection

                        // Карточка системного состояния
                        systemStatusCard

                        // Карточка выполнения этапов в стиле Dopamine
                        dopaminePipelineCard

                        // Кнопки основного действия
                        actionButtonsSection
                            .padding(.top, 6)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(strings.mainTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Компоненты интерфейса

    /// Переключатель режимов
    private var modeSelectorSection: some View {
        Picker(strings.modeTitle, selection: $executionMode) {
            Text(strings.modeRootless).tag(0)
            Text(strings.modeStandard).tag(1)
            Text(strings.modeExpert).tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 2)
    }

    /// Карточка системных параметров
    private var systemStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text(strings.statusTitle)
                        .font(.system(.body, design: .default))
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundColor(.blue)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(jailbreakState == .completed ? Color.green : (isProcessing ? Color.orange : Color.blue))
                        .frame(width: 8, height: 8)
                    Text(statusBadgeText)
                        .foregroundColor(jailbreakState == .completed ? .green : (isProcessing ? .orange : .blue))
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    (jailbreakState == .completed ? Color.green : (isProcessing ? Color.orange : Color.blue)).opacity(0.12)
                )
                .clipShape(Capsule())
            }

            Divider()

            HStack {
                Label {
                    Text(strings.kernelTitle)
                        .font(.system(.subheadline, design: .default))
                } icon: {
                    Image(systemName: "cpu")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(kernelStatusText)
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .default))
            }

            HStack {
                Label {
                    Text(strings.archTitle)
                        .font(.system(.subheadline, design: .default))
                } icon: {
                    Image(systemName: "memorychip")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(strings.archValue)
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .default))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка этапов пайплайна в стиле Dopamine
    private var dopaminePipelineCard: some View {
        VStack(spacing: 14) {
            if isProcessing, currentStepIndex < pipelineSteps.count {
                let step = pipelineSteps[currentStepIndex]

                VStack(spacing: 14) {
                    // Dopamine animated progress header
                    HStack {
                        HStack(spacing: 6) {
                            Circle().fill(Color.red.opacity(0.8)).frame(width: 8, height: 8)
                            Circle().fill(Color.yellow.opacity(0.8)).frame(width: 8, height: 8)
                            Circle().fill(Color.green.opacity(0.8)).frame(width: 8, height: 8)
                        }
                        Spacer()
                        Text("[\(currentStepIndex + 1)/\(pipelineSteps.count)]")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }

                    // Активный шаг
                    VStack(spacing: 6) {
                        Text(step.title)
                            .font(.system(.headline, design: .default))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(step.subtitle)
                            .font(.system(.subheadline, design: .default))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    // Анимированная полоса прогресса в стиле Dopamine
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(16, geo.size.width * CGFloat(Double(currentStepIndex + 1) / Double(pipelineSteps.count))), height: 8)
                                    .animation(.easeInOut(duration: 0.35), value: currentStepIndex)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, 4)

                        HStack {
                            Text("\(strings.stepProgress) \(currentStepIndex + 1) \(strings.stepOf) \(pipelineSteps.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(Double(currentStepIndex + 1) / Double(pipelineSteps.count) * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 4)
                    }

                    // Живой мини-терминал шага
                    if !liveLogs.isEmpty {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(liveLogs.suffix(2), id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.green.opacity(0.9))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.black.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(.vertical, 4)
            } else if jailbreakState == .completed {
                // Состояние завершенного джейлбрейка
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 38))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(strings.completedTitle)
                                .font(.system(.headline, design: .default))
                                .fontWeight(.bold)
                            Text(strings.completedSubtitle)
                                .font(.system(.caption, design: .default))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }

                    Divider()

                    HStack(spacing: 10) {
                        Label("Procursus", systemImage: "cube.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Label("Sileo v2.6", systemImage: "shippingbox.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Label("tfp0: OK", systemImage: "terminal.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 6)
            } else {
                // Исходное состояние
                HStack(spacing: 14) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.blue)
                        .font(.system(size: 34))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(strings.readyTitle(for: UIDevice.current.systemVersion))
                            .font(.system(.headline, design: .default))
                            .fontWeight(.bold)
                        Text(strings.readySubtitle)
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Секция кнопок действий
    private var actionButtonsSection: some View {
        VStack(spacing: 10) {
            Button(action: startJailbreakSequence) {
                HStack(spacing: 8) {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: jailbreakState == .completed ? "arrow.clockwise" : "bolt.fill")
                    }

                    Text(buttonTitle)
                        .font(.system(.body, design: .default))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isProcessing ? Color.gray.opacity(0.5) : Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(isProcessing)

            // Дополнительная кнопка Respring при активном джейлбрейке
            if jailbreakState == .completed && !isProcessing {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        jailbreakState = .respring
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text(strings.buttonRespring)
                    }
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    // MARK: - Вспомогательные свойства и методы

    private var buttonTitle: String {
        if isProcessing {
            return strings.buttonProcessing
        } else if jailbreakState == .completed {
            return strings.buttonReJailbreak
        } else {
            return strings.buttonJailbreak
        }
    }

    private var statusBadgeText: String {
        switch jailbreakState {
        case .idle: return strings.statusCompatible
        case .initializing: return strings.statusRunning
        case .streamingLogs: return strings.statusExploit
        case .respring: return strings.statusRespring
        case .completed: return strings.statusActive
        }
    }

    private var kernelStatusText: String {
        switch jailbreakState {
        case .idle: return strings.kernelReady
        case .initializing, .streamingLogs: return strings.kernelPatching
        case .respring: return strings.kernelRestarting
        case .completed: return strings.kernelRootless
        }
    }

    private func startJailbreakSequence() {
        isProcessing = true
        currentStepIndex = 0
        liveLogs = ["[+] Starting Cort1so1 Dopamine exploit engine..."]

        let steps = pipelineSteps
        jailbreakState = .initializing(
            step: 1,
            total: steps.count,
            description: steps[0].title
        )

        stepTimer = Timer.scheduledTimer(withTimeInterval: 0.85, repeats: true) { timer in
            if currentStepIndex < steps.count - 1 {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentStepIndex += 1
                    let step = steps[currentStepIndex]
                    liveLogs.append("[*] Step \(currentStepIndex + 1): \(step.title)")
                    jailbreakState = .initializing(
                        step: currentStepIndex + 1,
                        total: steps.count,
                        description: step.title
                    )
                }
            } else {
                timer.invalidate()
                stepTimer = nil
                isProcessing = false

                withAnimation(.easeInOut(duration: 0.25)) {
                    jailbreakState = .streamingLogs
                }
            }
        }
    }
}

#Preview {
    MainView(jailbreakState: .constant(.idle))
}


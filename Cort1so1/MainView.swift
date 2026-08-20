import SwiftUI

/// Главный экран утилиты «Cort1so1» в дизайн-системе iOS 26 Liquid Glass HIG
struct MainView: View {
    @Binding var jailbreakState: JailbreakState
    @State private var currentStepIndex: Int = 0
    @State private var stepTimer: Timer?
    @State private var isProcessing: Bool = false
    @State private var executionMode: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Базовый фон с легкой диффузией для эффекта стекла
                ambientBackground

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        // Сегментированный переключатель режимов в стеклянном контейнере
                        modeSelectorCard

                        // Парящая карточка состояния среды
                        systemStatusCard

                        // Парящая карточка пайплайна выполнения
                        pipelineProcessCard

                        // Пространственная интерактивная кнопка действия
                        actionButton
                            .padding(.top, 4)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Cort1so1")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Фон с преломлением

    private var ambientBackground: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            // Мягкие ореолы рассеивания для пространственного преломления через ultraThinMaterial
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -80, y: -160)

            Circle()
                .fill(Color.cyan.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 75)
                .offset(x: 100, y: 120)
        }
    }

    // MARK: - Парящие карточки Liquid Glass

    /// Переключатель режимов
    private var modeSelectorCard: some View {
        Picker("Режим работы", selection: $executionMode) {
            Text("Rootless").tag(0)
            Text("Стандарт").tag(1)
            Text("Эксперт").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(6)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(glassBorder(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }

    /// Карточка системных параметров
    private var systemStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text("Состояние")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "shield.lefthalf.filled")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(jailbreakState == .completed ? Color.green : Color.blue)
                        .frame(width: 8, height: 8)
                    Text(statusBadgeText)
                        .foregroundColor(jailbreakState == .completed ? .green : .blue)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            (jailbreakState == .completed ? Color.green : Color.blue).opacity(0.3),
                            lineWidth: 0.5
                        )
                )
            }

            Divider()
                .opacity(0.6)

            HStack {
                Label {
                    Text("Ядро")
                        .font(.system(.subheadline, design: .rounded))
                } icon: {
                    Image(systemName: "cpu.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }
                Spacer()
                Text(kernelStatusText)
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .rounded))
            }

            HStack {
                Label {
                    Text("Архитектура")
                        .font(.system(.subheadline, design: .rounded))
                } icon: {
                    Image(systemName: "memorychip.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }
                Spacer()
                Text("arm64e (PPL Bypass)")
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .rounded))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.05), radius: 18, x: 0, y: 8)
    }

    /// Карточка этапов пайплайна
    private var pipelineProcessCard: some View {
        VStack(spacing: 14) {
            if isProcessing, currentStepIndex < defaultPipelineSteps.count {
                let step = defaultPipelineSteps[currentStepIndex]

                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding(.top, 4)

                    Text(step.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)

                    Text(step.subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    VStack(spacing: 6) {
                        ProgressView(value: Double(currentStepIndex + 1), total: Double(defaultPipelineSteps.count))
                            .tint(.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                        HStack {
                            Text("Этап \(currentStepIndex + 1) из \(defaultPipelineSteps.count)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(Double(currentStepIndex + 1) / Double(defaultPipelineSteps.count) * 100))%")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
            } else if jailbreakState == .completed {
                HStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.green)
                        .font(.system(size: 40))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Джейлбрейк активен")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                        Text("Пакетный менеджер Sileo готов к работе.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
            } else {
                HStack(spacing: 16) {
                    Image(systemName: "sparkles.square.filled.on.square")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                        .font(.system(size: 38))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("iOS 26.0 — Совместимо")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                        Text("Система готова к запуску симуляции.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.05), radius: 18, x: 0, y: 8)
    }

    /// Интерактивная кнопка с пружинной динамикой
    private var actionButton: some View {
        Button(action: startJailbreakSequence) {
            HStack(spacing: 8) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: jailbreakState == .completed ? "arrow.clockwise" : "bolt.fill")
                }

                Text(buttonTitle)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                Group {
                    if isProcessing {
                        Color.gray.opacity(0.6)
                    } else {
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .foregroundColor(.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.blue.opacity(0.25), radius: 14, x: 0, y: 7)
        }
        .disabled(isProcessing)
        .buttonStyle(SpringPressButtonStyle())
    }

    // MARK: - Вспомогательные модификаторы

    private func glassBorder(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.45),
                        Color.white.opacity(0.08),
                        Color.blue.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
    }

    private var buttonTitle: String {
        if isProcessing {
            return "Выполнение..."
        } else if jailbreakState == .completed {
            return "Повторить (Re-Jailbreak)"
        } else {
            return "Jailbreak"
        }
    }

    private var statusBadgeText: String {
        switch jailbreakState {
        case .idle: return "Совместимо"
        case .initializing: return "Выполняется"
        case .streamingLogs: return "Эксплойт"
        case .respring: return "Респринг"
        case .completed: return "Активирован"
        }
    }

    private var kernelStatusText: String {
        switch jailbreakState {
        case .idle: return "Готов к запуску"
        case .initializing, .streamingLogs: return "Патчинг..."
        case .respring: return "Перезапуск..."
        case .completed: return "Rootless (tfp0)"
        }
    }

    private func startJailbreakSequence() {
        isProcessing = true
        currentStepIndex = 0
        jailbreakState = .initializing(
            step: 1,
            total: defaultPipelineSteps.count,
            description: defaultPipelineSteps[0].title
        )

        stepTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { timer in
            if currentStepIndex < defaultPipelineSteps.count - 1 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    currentStepIndex += 1
                    let step = defaultPipelineSteps[currentStepIndex]
                    jailbreakState = .initializing(
                        step: currentStepIndex + 1,
                        total: defaultPipelineSteps.count,
                        description: step.title
                    )
                }
            } else {
                timer.invalidate()
                stepTimer = nil
                isProcessing = false

                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    jailbreakState = .streamingLogs
                }
            }
        }
    }
}

/// Пружинная динамика нажатия кнопки (iOS 26 Spring Dynamics)
struct SpringPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    MainView(jailbreakState: .constant(.idle))
}

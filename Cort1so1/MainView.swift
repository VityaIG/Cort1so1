import SwiftUI

/// Главный экран утилиты «Cort1so1» в нативном стиле Apple iOS HIG
struct MainView: View {
    @Binding var jailbreakState: JailbreakState
    @State private var currentStepIndex: Int = 0
    @State private var stepTimer: Timer?
    @State private var isProcessing: Bool = false
    @State private var executionMode: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Сегментированный переключатель режимов
                        modeSelectorSection

                        // Карточка системного состояния
                        systemStatusCard

                        // Карточка выполнения этапов
                        pipelineProcessCard

                        // Кнопка основного действия
                        actionButton
                            .padding(.top, 6)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Cort1so1")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Компоненты интерфейса

    /// Переключатель режимов
    private var modeSelectorSection: some View {
        Picker("Режим работы", selection: $executionMode) {
            Text("Rootless").tag(0)
            Text("Стандарт").tag(1)
            Text("Эксперт").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 2)
    }

    /// Карточка системных параметров
    private var systemStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text("Состояние")
                        .font(.system(.body, design: .default))
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundColor(.blue)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(jailbreakState == .completed ? Color.green : Color.blue)
                        .frame(width: 8, height: 8)
                    Text(statusBadgeText)
                        .foregroundColor(jailbreakState == .completed ? .green : .blue)
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    (jailbreakState == .completed ? Color.green : Color.blue).opacity(0.12)
                )
                .clipShape(Capsule())
            }

            Divider()

            HStack {
                Label {
                    Text("Ядро")
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
                    Text("Архитектура")
                        .font(.system(.subheadline, design: .default))
                } icon: {
                    Image(systemName: "memorychip")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("arm64e (PPL Bypass)")
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .default))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка этапов пайплайна
    private var pipelineProcessCard: some View {
        VStack(spacing: 14) {
            if isProcessing, currentStepIndex < defaultPipelineSteps.count {
                let step = defaultPipelineSteps[currentStepIndex]

                VStack(spacing: 12) {
                    ProgressView()
                        .padding(.top, 4)

                    Text(step.title)
                        .font(.system(.headline, design: .default))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text(step.subtitle)
                        .font(.system(.subheadline, design: .default))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    VStack(spacing: 6) {
                        ProgressView(value: Double(currentStepIndex + 1), total: Double(defaultPipelineSteps.count))
                            .tint(.blue)
                            .padding(.horizontal, 8)
                            .padding(.top, 4)

                        HStack {
                            Text("Этап \(currentStepIndex + 1) из \(defaultPipelineSteps.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(Double(currentStepIndex + 1) / Double(defaultPipelineSteps.count) * 100))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 8)
            } else if jailbreakState == .completed {
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Джейлбрейк активен")
                            .font(.system(.headline, design: .default))
                            .fontWeight(.bold)
                        Text("Пакетный менеджер Sileo готов к работе.")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                HStack(spacing: 14) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.blue)
                        .font(.system(size: 34))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("iOS 26.0 — Совместимо")
                            .font(.system(.headline, design: .default))
                            .fontWeight(.bold)
                        Text("Система готова к запуску симуляции.")
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

    /// Интерактивная кнопка действия
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
    }

    // MARK: - Вспомогательные свойства и методы

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

        stepTimer = Timer.scheduledTimer(withTimeInterval: 0.85, repeats: true) { timer in
            if currentStepIndex < defaultPipelineSteps.count - 1 {
                withAnimation(.easeInOut(duration: 0.25)) {
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

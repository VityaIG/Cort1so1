import SwiftUI

/// Главный экран утилиты «Cort1so1» в стиле Dopamine Jailbreak (iOS HIG)
struct MainView: View {
    @Binding var jailbreakState: JailbreakState
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false

    @State private var showingConfirmAlert: Bool = false
    @State private var showingProcessModal: Bool = false
    @State private var executionMode: Int = 0

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
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

                        // Карточка готовности / статуса джейлбрейка
                        dopamineStatusCard

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
            // 1. Стандартный алерт подтверждения перед джейлбрейком
            .alert(strings.confirmAlertTitle, isPresented: $showingConfirmAlert) {
                Button(strings.confirmYesBtn) {
                    showingProcessModal = true
                }
                Button(strings.cancelBtn, role: .cancel) { }
            } message: {
                Text(strings.confirmAlertMessage)
            }
            // 2. Модальное окно процесса (Dopamine style, non-dismissible)
            .fullScreenCover(isPresented: $showingProcessModal) {
                DopamineProcessView(onComplete: {
                    showingProcessModal = false
                    isJailbroken = true
                    withAnimation(.easeInOut(duration: 0.3)) {
                        jailbreakState = .completed
                    }
                })
            }
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

    /// Карточка статуса Dopamine
    private var dopamineStatusCard: some View {
        VStack(spacing: 16) {
            if jailbreakState == .completed {
                // Состояние завершенного джейлбрейка
                VStack(spacing: 14) {
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
                // Исходное состояние готовности
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
            Button(action: {
                showingConfirmAlert = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: jailbreakState == .completed ? "arrow.clockwise" : "bolt.fill")

                    Text(buttonTitle)
                        .font(.system(.body, design: .default))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            // Дополнительная кнопка Respring при активном джейлбрейке
            if jailbreakState == .completed {
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

    // MARK: - Вспомогательные свойства

    private var buttonTitle: String {
        if jailbreakState == .completed {
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
}

#Preview {
    MainView(jailbreakState: .constant(.idle))
}

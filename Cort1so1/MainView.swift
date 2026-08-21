import SwiftUI

/// Главный экран утилиты «Cort1so1» в стиле Dopamine Jailbreak (iOS HIG)
struct MainView: View {
    @Binding var jailbreakState: JailbreakState
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @AppStorage("customAppName") private var customAppName: String = "Cort1so1"
    @AppStorage("customSubtitle") private var customSubtitle: String = ""
    @AppStorage("customAppBgTheme") private var customAppBgTheme: String = "default"
    @AppStorage("customBgColorHex") private var customBgColorHex: String = ""
    @AppStorage("customCardColorHex") private var customCardColorHex: String = ""
    @AppStorage("customDeviceModel") private var customDeviceModel: String = ""
    @AppStorage("customOSVersion") private var customOSVersion: String = ""
    @AppStorage("customArch") private var customArch: String = ""
    @AppStorage("customExploitName") private var customExploitName: String = ""
    @AppStorage("customPackageManager") private var customPackageManager: String = ""

    private var isRu: Bool {
        appLanguage == "ru"
    }

    @State private var showingConfirmAlert: Bool = false
    @State private var showingMethodDialog: Bool = false
    @State private var selectedMethod: JailbreakMethod = .dopamine
    @State private var showingProcessModal: Bool = false

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var displayTitle: String {
        customAppName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? strings.mainTitle : customAppName
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppCustomStyle.resolveBgColor(customHex: customBgColorHex, themeId: customAppBgTheme)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Карточка системного состояния
                        systemStatusCard

                        // Карточка готовности / статуса джейлбрейка
                        dopamineStatusCard

                        // Кнопки основного действия
                        actionButtonsSection
                            .padding(.top, 6)
                            
                        // Инфо об устройстве
                        deviceInfoCard
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(displayTitle)
            // 1. Стандартный алерт подтверждения перед джейлбрейком
            .alert(isPresented: $showingConfirmAlert) {
                Alert(
                    title: Text(strings.confirmAlertTitle),
                    message: Text(strings.confirmAlertMessage),
                    primaryButton: .default(Text(strings.confirmYesBtn)) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.showingMethodDialog = true
                        }
                    },
                    secondaryButton: .cancel(Text(strings.cancelBtn))
                )
            }
            .confirmationDialog(
                isRu ? "Выберите метод джейлбрейка" : "Select Jailbreak Method",
                isPresented: $showingMethodDialog,
                titleVisibility: .visible
            ) {
                Button("Dopamine") {
                    self.selectedMethod = .dopamine
                    self.showingProcessModal = true
                }
                Button("Cortisol") {
                    self.selectedMethod = .cortisol
                    self.showingProcessModal = true
                }
                Button(strings.cancelBtn, role: .cancel) { }
            } message: {
                Text(isRu ? "Выберите желаемый метод джейлбрейка" : "Select desired jailbreak method")
            }
            // 3. Модальное окно процесса (Dopamine style, non-dismissible)
            .fullScreenCover(isPresented: $showingProcessModal) {
                DopamineProcessView(method: selectedMethod, onComplete: {
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

    /// Карточка системных параметров
    private var systemStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppTheme.resolveColor(name: appThemeColor).opacity(0.15))
                            .frame(width: 28, height: 28)
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                    }
                    Text(strings.statusTitle)
                        .font(.system(.body, design: .default))
                        .fontWeight(.bold)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(jailbreakState == .completed ? Color.green : AppTheme.resolveColor(name: appThemeColor))
                        .frame(width: 8, height: 8)
                        .shadow(color: (jailbreakState == .completed ? Color.green : AppTheme.resolveColor(name: appThemeColor)).opacity(0.6), radius: 4)
                    Text(statusBadgeText)
                        .foregroundColor(jailbreakState == .completed ? .green : AppTheme.resolveColor(name: appThemeColor))
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    (jailbreakState == .completed ? Color.green : AppTheme.resolveColor(name: appThemeColor)).opacity(0.12)
                )
                .clipShape(Capsule())
            }

            Divider()

            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 26, height: 26)
                        Image(systemName: "cpu")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    Text(strings.kernelTitle)
                        .font(.system(.subheadline, design: .default))
                }
                Spacer()
                Text(kernelStatusText)
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.medium)
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    /// Карточка статуса Dopamine
    private var dopamineStatusCard: some View {
        VStack(spacing: 16) {
            if jailbreakState == .completed {
                // Состояние завершенного джейлбрейка
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.05, green: 0.20, blue: 0.09))
                                .frame(width: 52, height: 52)

                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 30, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(strings.completedTitle)
                                .font(.system(.headline, design: .default))
                                .fontWeight(.bold)
                            Text(customSubtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? strings.completedSubtitle : customSubtitle)
                                .font(.system(.caption, design: .default))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }

                    Divider()

                    HStack(spacing: 10) {
                        Label(customArch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Procursus" : customArch, systemImage: "cube.fill")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Label(customPackageManager.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cort1so1" : customPackageManager, systemImage: "shippingbox.fill")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Label(customExploitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "tfp0: OK" : customExploitName, systemImage: "terminal.fill")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            } else {
                // Исходное состояние готовности
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.resolveColor(name: appThemeColor).opacity(0.12))
                            .frame(width: 50, height: 50)
                        Image(systemName: "lock.open.fill")
                            .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                            .font(.system(size: 26, weight: .bold))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        let os = customOSVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.systemVersion : customOSVersion
                        Text(strings.readyTitle(for: os))
                            .font(.system(.headline, design: .default))
                            .fontWeight(.bold)
                        Text(customSubtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? strings.readySubtitle : customSubtitle)
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    /// Секция кнопок действий
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                self.showingConfirmAlert = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: jailbreakState == .completed ? "arrow.clockwise" : "bolt.fill")
                        .font(.system(size: 17, weight: .bold))

                    Text(buttonTitle)
                        .font(.system(.body, design: .default))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppTheme.resolveColor(name: appThemeColor),
                            AppTheme.resolveColor(name: appThemeColor).opacity(0.85)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: AppTheme.resolveColor(name: appThemeColor).opacity(0.35), radius: 8, x: 0, y: 4)
            }

            // Дополнительная кнопка Respring при активном джейлбрейке
            if jailbreakState == .completed {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.jailbreakState = .respring
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 15, weight: .bold))
                        Text(strings.buttonRespring)
                            .font(.system(.subheadline, design: .default))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var deviceInfoCard: some View {
        VStack(spacing: 0) {
            infoRow(
                title: isRu ? "Модель" : "Model",
                value: customDeviceModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.friendlyModelName : customDeviceModel,
                icon: "iphone",
                color: .blue,
                isLast: false
            )
            infoRow(
                title: isRu ? "Версия iOS" : "iOS Version",
                value: customOSVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.systemVersion : customOSVersion,
                icon: "apple.logo",
                color: .indigo,
                isLast: false
            )
            infoRow(
                title: isRu ? "Архитектура" : "Architecture",
                value: customArch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "arm64e" : customArch,
                icon: "cpu",
                color: .teal,
                isLast: false
            )
            infoRow(
                title: isRu ? "Идентификатор" : "Identifier",
                value: UIDevice.current.hardwareIdentifier,
                icon: "number",
                color: .purple,
                isLast: true
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func infoRow(title: String, value: String, icon: String, color: Color, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.medium)

                Spacer()

                Text(value)
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.regular)
            }
            .padding(.vertical, 10)
            
            if !isLast {
                Divider()
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

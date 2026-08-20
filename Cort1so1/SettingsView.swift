import SwiftUI

/// Экран настроек приложения «Cort1so1» в стиле iOS HIG
struct SettingsView: View {
    @Binding var jailbreakState: JailbreakState
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    @AppStorage("tweakInjection") private var tweakInjection: Bool = true

    @State private var showRemoveJailbreakAlert: Bool = false
    @State private var showResetToast: Bool = false

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    // Точный фирменный цвет Telegram
    private let telegramColor = Color(red: 0.165, green: 0.67, blue: 0.94)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Секция оформления и языка
                        appearanceAndLanguageCard

                        // Секция управления состоянием джейлбрейка
                        jailbreakManagementCard

                        // Секция параметров симулятора
                        utilityOptionsCard

                        // Секция системного окружения
                        systemEnvironmentCard

                        // Секция «О приложении»
                        aboutCard
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(strings.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .alert(strings.removeJailbreakAlertTitle, isPresented: $showRemoveJailbreakAlert) {
                Button(strings.cancelBtn, role: .cancel) { }
                Button(strings.removeConfirmBtn, role: .destructive) {
                    removeJailbreak()
                }
            } message: {
                Text(strings.removeJailbreakAlertMsg)
            }
        }
    }

    // MARK: - Компоненты интерфейса

    /// Карточка темы оформления и выбора языка
    private var appearanceAndLanguageCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.appearanceSection)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Toggle(isOn: $isDarkMode) {
                Label {
                    Text(strings.darkModeToggle)
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.indigo)
                }
            }
            .tint(.blue)

            Divider()

            HStack {
                Label {
                    Text(strings.languageLabel)
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                }

                Spacer()

                Picker(strings.languageLabel, selection: $appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(.blue)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка управления состоянием джейлбрейка
    private var jailbreakManagementCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.jbManagementSection)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label {
                    Text(strings.statusTitle)
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: isJailbroken || jailbreakState == .completed ? "checkmark.shield.fill" : "shield.slash.fill")
                        .foregroundColor(isJailbroken || jailbreakState == .completed ? .green : .secondary)
                }

                Spacer()

                Text(isJailbroken || jailbreakState == .completed ? strings.statusActive : strings.statusCompatible)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.semibold)
                    .foregroundColor(isJailbroken || jailbreakState == .completed ? .green : .secondary)
            }

            Divider()

            Button(role: .destructive, action: {
                showRemoveJailbreakAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text(strings.removeJailbreakBtn)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка параметров работы
    private var utilityOptionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.utilitySection)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Toggle(isOn: $verboseLogs) {
                Label {
                    Text(strings.verboseLogsToggle)
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "terminal.fill")
                        .foregroundColor(.blue)
                }
            }
            .tint(.blue)

            Divider()

            Toggle(isOn: $autoRespring) {
                Label {
                    Text(strings.autoRespringToggle)
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .tint(.blue)

            Divider()

            Toggle(isOn: $tweakInjection) {
                Label {
                    Text(strings.tweakInjectionToggle)
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "puzzlepiece.extension.fill")
                        .foregroundColor(.orange)
                }
            }
            .tint(.blue)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка системного окружения
    private var systemEnvironmentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.systemSection)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label(strings.osVersionLabel, systemImage: "iphone")
                Spacer()
                Text("iOS 26.0")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label(strings.archTitle, systemImage: "cpu")
                Spacer()
                Text("arm64e")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label(strings.exploitLabel, systemImage: "bolt.fill")
                Spacer()
                Text("PhysPuppet")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка «О программе»
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.aboutSection)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label(strings.appNameLabel, systemImage: "app.fill")
                Spacer()
                Text("Cort1so1")
                    .fontWeight(.bold)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label(strings.versionLabel, systemImage: "info.circle.fill")
                Spacer()
                Text("1.0.6 (iOS Native HIG)")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label(strings.packageManagerLabel, systemImage: "shippingbox.fill")
                Spacer()
                Text("Sileo v2.6")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label {
                    Text(strings.creatorLabel)
                } icon: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(telegramColor)
                }
                Spacer()
                Link(destination: URL(string: "https://t.me/VityaV") ?? URL(string: "https://telegram.org")!) {
                    HStack(spacing: 4) {
                        Text("@VityaV 🇷🇺")
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundColor(telegramColor)
                    }
                }
            }

            Divider()

            Text(strings.aboutDisclaimer)
                .font(.system(.caption, design: .default))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Логика действий

    private func removeJailbreak() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isJailbroken = false
            jailbreakState = .idle
        }
    }
}

#Preview {
    SettingsView(jailbreakState: .constant(.completed))
}

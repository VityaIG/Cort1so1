import SwiftUI
import UIKit
import AVKit
import AVFoundation

/// Полностью переработанный экран настроек «Cort1so1» в нативном стиле Apple iOS HIG
struct SettingsView: View {
    static var hasPlayedInSession: Bool = false

    @Binding var jailbreakState: JailbreakState

    init(jailbreakState: Binding<JailbreakState>) {
        self._jailbreakState = jailbreakState
    }
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("hideStatusBar") private var hideStatusBar: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    @AppStorage("tweakInjection") private var tweakInjection: Bool = true
    @AppStorage("safeMode") private var safeMode: Bool = false

    // ADMIN State
    @AppStorage("isAdminUnlocked") private var isAdminUnlocked: Bool = false
    @AppStorage("customAppName") private var customAppName: String = "Cort1so1"
    @AppStorage("customSubtitle") private var customSubtitle: String = ""
    @AppStorage("customAppVersion") private var customAppVersion: String = "1.3"
    @AppStorage("customAppBuild") private var customAppBuild: String = "26B101"
    @AppStorage("customAppBgTheme") private var customAppBgTheme: String = "default"
    @AppStorage("customBgColorHex") private var customBgColorHex: String = ""
    @AppStorage("customCardColorHex") private var customCardColorHex: String = ""
    @AppStorage("customTextColorHex") private var customTextColorHex: String = ""
    @AppStorage("customDeviceModel") private var customDeviceModel: String = ""
    @AppStorage("customOSVersion") private var customOSVersion: String = ""
    @AppStorage("customArch") private var customArch: String = ""
    @AppStorage("customExploitName") private var customExploitName: String = ""
    @AppStorage("customPackageManager") private var customPackageManager: String = ""
    @AppStorage("hasSeenFirstLaunchWelcome") private var hasSeenFirstLaunchWelcome: Bool = false

    @State private var adminTapCount: Int = 0
    @State private var lastAdminTapDate: Date = Date.distantPast
    @State private var showAdminDashboardSheet: Bool = false

    @State private var showRemoveJailbreakAlert: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showEasterEggVideo: Bool = false
    @State private var lastTriggerTime: Date = Date.distantPast
    @State private var hasPlayedEasterEgg: Bool = SettingsView.hasPlayedInSession

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private let telegramColor = Color(red: 0.165, green: 0.67, blue: 0.94)

    var body: some View {
        NavigationView {
            Form {
                // Кнопка перехода в отдельный раздел ADMIN (если разблокирован)
                if isAdminUnlocked {
                    Section {
                        Button(action: {
                            self.showAdminDashboardSheet = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.purple)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("ADMIN")
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)

                                    Text(isRu ? "Панель разработчика и конфигурации" : "Developer configuration panel")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                // 1. Профиль приложения Cort1so1 & Star on GitHub
                Section {
                    HStack(alignment: .center, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 48, height: 48)
                                .shadow(color: AppTheme.resolveColor(name: appThemeColor).opacity(0.24), radius: 6, x: 0, y: 2)

                            Cort1so1IconShape()
                                .fill(Color(red: 0.08, green: 0.09, blue: 0.10))
                                .frame(width: 30, height: 30)
                        }
                        .fixedSize()
                        .onTapGesture {
                            handleAdminTap()
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .center, spacing: 6) {
                                Text(customAppName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cort1so1" : customAppName)
                                    .font(.system(size: 18, weight: .bold))
                                    .lineLimit(1)
                                    .onTapGesture {
                                        handleAdminTap()
                                    }

                                let versionDisplay = customAppVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "v1.3" : (customAppVersion.hasPrefix("v") ? customAppVersion : "v\(customAppVersion)")
                                Text(versionDisplay)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2.5)
                                    .background(AppTheme.resolveColor(name: appThemeColor).opacity(0.14))
                                    .clipShape(Capsule())
                            }

                            Text(customSubtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "iOS Jailbreak & IPSW Utility" : customSubtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 4)

                        HStack(spacing: 5) {
                            Circle()
                                .fill(isJailbroken || jailbreakState == .completed ? Color.green : Color.secondary.opacity(0.45))
                                .frame(width: 7, height: 7)

                            Text(isJailbroken || jailbreakState == .completed ? (isRu ? "Активен" : "Active") : (isRu ? "Stock" : "Stock"))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(isJailbroken || jailbreakState == .completed ? .green : .secondary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((isJailbroken || jailbreakState == .completed ? Color.green : Color.secondary).opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                    .id("topHeader")

                    Link(destination: URL(string: "https://github.com/VityaIG/Cort1so1")!) {
                        HStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.yellow)

                            Text(strings.starOnGithubBtn)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                // 2. Внешний вид и язык
                Section(header: Text(strings.appearanceSection)) {
                    Toggle(isOn: $isDarkMode) {
                        settingRowLabel(title: strings.darkModeToggle, icon: "moon.fill", color: .indigo)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

                    Toggle(isOn: $hideStatusBar) {
                        settingRowLabel(title: strings.hideStatusBarToggle, icon: "eye.slash.circle.fill", color: .purple)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

                    HStack {
                        settingRowLabel(title: isRu ? "Тема приложения" : "App Theme", icon: "paintpalette.fill", color: .pink)
                        Spacer()
                        Picker("", selection: $appThemeColor) {
                            ForEach(AppTheme.availableColors, id: \.name) { theme in
                                HStack {
                                    Circle().fill(theme.color).frame(width: 14, height: 14)
                                    Text(isRu ? localizedThemeName(theme.name) : theme.name.capitalized)
                                }
                                .tag(theme.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(AppTheme.resolveColor(name: appThemeColor))
                    }

                    HStack {
                        settingRowLabel(title: strings.languageLabel, icon: "globe", color: .blue)

                        Spacer()

                        Picker("", selection: $appLanguage) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(AppTheme.resolveColor(name: appThemeColor))
                    }
                }

                // 3. Параметры джейлбрейка
                Section(header: Text(strings.utilitySection)) {
                    Toggle(isOn: $verboseLogs) {
                        settingRowLabel(title: strings.verboseLogsToggle, icon: "terminal.fill", color: .slateColor)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

                    Toggle(isOn: $autoRespring) {
                        settingRowLabel(title: strings.autoRespringToggle, icon: "arrow.clockwise.circle.fill", color: .green)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

                    Toggle(isOn: $tweakInjection) {
                        settingRowLabel(title: strings.tweakInjectionToggle, icon: "puzzlepiece.extension.fill", color: .orange)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

                    Toggle(isOn: $safeMode) {
                        settingRowLabel(title: isRu ? "Безопасный режим (Safe Mode)" : "Safe Mode Fallback", icon: "shield.lefthalf.filled", color: .cyan)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))
                }

                // 4. Системные сведения
                Section(header: Text(strings.systemSection)) {
                    infoRow(title: strings.deviceModelLabel, value: customDeviceModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.friendlyModelName : customDeviceModel, icon: "ipad.and.iphone", color: .blue)
                    infoRow(title: strings.osVersionLabel, value: customOSVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "iOS \(UIDevice.current.systemVersion)" : (customOSVersion.lowercased().hasPrefix("ios") ? customOSVersion : "iOS \(customOSVersion)"), icon: "iphone", color: .indigo)
                    infoRow(title: strings.archTitle, value: customArch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "arm64e (SPTM & PAC Bypass)" : customArch, icon: "cpu", color: .teal)
                    infoRow(title: strings.exploitLabel, value: customExploitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "PhysPuppet / LandCast" : customExploitName, icon: "bolt.fill", color: .orange)
                    infoRow(title: strings.packageManagerLabel, value: customPackageManager.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cort1so1 Installer (Procursus)" : customPackageManager, icon: "shippingbox.fill", color: .cyan)
                }

                // 5. Управление джейлбрейком (Danger Zone)
                Section(header: Text(strings.jbManagementSection)) {
                    Button(action: {
                        self.showRemoveJailbreakAlert = true
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(Color.red.opacity(0.12))
                                    .frame(width: 28, height: 28)

                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.red)
                            }

                            Text(strings.removeJailbreakBtn)
                                .font(.system(.body, design: .default))
                                .fontWeight(.semibold)
                                .foregroundColor(.red)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.6))
                        }
                    }
                }

                // 6. О программе
                Section(header: Text(strings.aboutSection)) {
                    HStack {
                        settingRowLabel(title: strings.appNameLabel, icon: "app.fill", color: .blue)
                        Spacer()
                        Text(customAppName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cort1so1" : customAppName)
                            .fontWeight(.bold)
                            .font(.system(.subheadline, design: .default))
                    }

                    HStack {
                        settingRowLabel(title: strings.versionLabel, icon: "number.circle.fill", color: .purple)
                        Spacer()
                        let v = customAppVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1.3" : customAppVersion
                        let b = customAppBuild.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "26B101" : customAppBuild
                        Text("\(v) (Build \(b))")
                            .foregroundColor(.secondary)
                            .font(.system(.subheadline, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(strings.aboutDisclaimer)
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    .padding(.vertical, 2)
                }

                // 7. Создатель & Разработчик
                Section(header: Text(strings.creatorSection)) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppTheme.resolveColor(name: appThemeColor).opacity(0.12))
                                .frame(width: 32, height: 32)

                            Image(systemName: "terminal.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("@VityaV")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primary)

                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                            }

                            Text(isRu ? "Создатель и ведущий разработчик" : "Lead Developer & Researcher")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)

                    Link(destination: URL(string: "https://t.me/VityaV") ?? URL(string: "https://telegram.org")!) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(telegramColor)

                            Text("Telegram")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.primary)

                            Spacer()

                            Text("@VityaV")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://t.me/vitalyabk") ?? URL(string: "https://telegram.org")!) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(telegramColor)

                            Text(isRu ? "Канал в Telegram" : "Telegram Channel")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // 8. Секретный триггер Пасхалки
                if !SettingsView.hasPlayedInSession && !hasPlayedEasterEgg {
                    Section {
                        easterEggBottomTrigger
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
            .navigationTitle(strings.settingsTitle)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(strings.settingsTitle)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleAdminTap()
                        }
                }
            }
            .fullScreenCover(isPresented: $showAdminDashboardSheet) {
                AdminDashboardView()
            }
            .fullScreenCover(isPresented: $showEasterEggVideo) {
                EasterEggVideoPlayerView(isPresented: $showEasterEggVideo, hasPlayedEasterEgg: $hasPlayedEasterEgg)
            }
            // Подтверждение удаления джейлбрейка
            .alert(isPresented: $showRemoveJailbreakAlert) {
                Alert(
                    title: Text(strings.removeJailbreakAlertTitle),
                    message: Text(strings.removeJailbreakAlertMsg),
                    primaryButton: .destructive(Text(strings.removeConfirmBtn)) {
                        self.removeJailbreak()
                    },
                    secondaryButton: .cancel(Text(strings.cancelBtn))
                )
            }
        }
    }

    /// Обработка 5 нажатий на название «Настройки»
    private func handleAdminTap() {
        let now = Date()
        if now.timeIntervalSince(lastAdminTapDate) > 2.5 {
            adminTapCount = 1
        } else {
            adminTapCount += 1
        }
        lastAdminTapDate = now

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if adminTapCount >= 5 {
            adminTapCount = 0
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                isAdminUnlocked = true
                showAdminDashboardSheet = true
            }
        }
    }

    // MARK: - 0. Кнопка входа в отдельный раздел ADMIN
    private var adminEntryCard: some View {
        Button(action: {
            self.showAdminDashboardSheet = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.purple)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("ADMIN")
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(isRu ? "Панель разработчика и конфигурации" : "Developer configuration panel")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 1. Профиль приложения Cort1so1 (Улучшенная карточка без обводок)

    private var appHeaderCard: some View {
        VStack(spacing: 14) {
            // Верхняя строка: Иконка, Название, Версия и Статус
            HStack(alignment: .center, spacing: 14) {
                // Фирменная векторная иконка приложения (чистый дизайн без обводки)
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 54, height: 54)
                        .shadow(color: AppTheme.resolveColor(name: appThemeColor).opacity(0.24), radius: 8, x: 0, y: 3)

                    Cort1so1IconShape()
                        .fill(Color(red: 0.08, green: 0.09, blue: 0.10))
                        .frame(width: 34, height: 34)
                }
                .fixedSize()
                .onTapGesture {
                    handleAdminTap()
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 6) {
                        Text(customAppName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cort1so1" : customAppName)
                            .font(.system(size: 21, weight: .bold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .layoutPriority(2)
                            .onTapGesture {
                                handleAdminTap()
                            }

                        let versionDisplay = customAppVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "v1.3" : (customAppVersion.hasPrefix("v") ? customAppVersion : "v\(customAppVersion)")
                        Text(versionDisplay)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                            .padding(.horizontal, 7.5)
                            .padding(.vertical, 3)
                            .background(AppTheme.resolveColor(name: appThemeColor).opacity(0.14))
                            .clipShape(Capsule())
                            .fixedSize(horizontal: true, vertical: false)
                    }

                    Text(customSubtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "iOS Jailbreak & IPSW Utility" : customSubtitle)
                        .font(.system(size: 12.5, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                // Индикатор статуса джейлбрейка
                HStack(spacing: 5) {
                    Circle()
                        .fill(isJailbroken || jailbreakState == .completed ? Color.green : Color.secondary.opacity(0.45))
                        .frame(width: 7, height: 7)
                        .shadow(color: (isJailbroken || jailbreakState == .completed ? Color.green : Color.clear).opacity(0.7), radius: 4)

                    Text(isJailbroken || jailbreakState == .completed ? (isRu ? "Активен" : "Active") : (isRu ? "Не активен" : "Stock"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isJailbroken || jailbreakState == .completed ? .green : .secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 9.5)
                .padding(.vertical, 5)
                .background((isJailbroken || jailbreakState == .completed ? Color.green : Color.secondary).opacity(0.12))
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)
            }

            // Нижняя строка: Информационные чипы телеметрии (без обводок)
            HStack(spacing: 8) {
                HStack(spacing: 4.5) {
                    Image(systemName: "cpu")
                        .font(.system(size: 10, weight: .semibold))
                    Text(customArch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "arm64e / SPTM" : customArch)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8.5)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                HStack(spacing: 4.5) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Rootless")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8.5)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "bolt.badge.checkmark.fill")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                    Text("iOS 16–27")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(AppTheme.resolveColor(name: appThemeColor).opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 1.1. Star on GitHub Card (На самом верху под карточкой Cort1so1 - Чистый стиль без обводок)

    private var starOnGithubCard: some View {
        Link(destination: URL(string: "https://github.com/VityaIG/Cort1so1")!) {
            HStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.yellow)

                Text(strings.starOnGithubBtn)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 2. Внешний вид и язык

    private var appearanceSectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.appearanceSection, icon: "paintbrush.fill", color: .purple)

            Toggle(isOn: $isDarkMode) {
                settingRowLabel(title: strings.darkModeToggle, icon: "moon.fill", color: .indigo)
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

            Divider()

            Toggle(isOn: $hideStatusBar) {
                settingRowLabel(title: strings.hideStatusBarToggle, icon: "eye.slash.circle.fill", color: .purple)
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

            Divider()
            
            HStack {
                settingRowLabel(title: isRu ? "Тема приложения" : "App Theme", icon: "paintpalette.fill", color: .pink)
                Spacer()
                Picker("", selection: $appThemeColor) {
                    ForEach(AppTheme.availableColors, id: \.name) { theme in
                        HStack {
                            Circle().fill(theme.color).frame(width: 14, height: 14)
                            Text(isRu ? localizedThemeName(theme.name) : theme.name.capitalized)
                        }
                        .tag(theme.name)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(AppTheme.resolveColor(name: appThemeColor))
            }

            Divider()

            HStack {
                settingRowLabel(title: strings.languageLabel, icon: "globe", color: .blue)

                Spacer()

                Picker("", selection: $appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(AppTheme.resolveColor(name: appThemeColor))
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func localizedThemeName(_ name: String) -> String {
        switch name {
        case "blue": return "Синий"
        case "purple": return "Пурпурный"
        case "pink": return "Розовый"
        case "red": return "Красный"
        case "orange": return "Оранжевый"
        case "green": return "Зеленый"
        case "cyan": return "Голубой"
        case "indigo": return "Индиго"
        default: return name.capitalized
        }
    }

    // MARK: - 3. Параметры джейлбрейка

    private var utilitySectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.utilitySection, icon: "gearshape.fill", color: .blue)

            Toggle(isOn: $verboseLogs) {
                settingRowLabel(title: strings.verboseLogsToggle, icon: "terminal.fill", color: .slateColor)
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

            Divider()

            Toggle(isOn: $autoRespring) {
                settingRowLabel(title: strings.autoRespringToggle, icon: "arrow.clockwise.circle.fill", color: .green)
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

            Divider()

            Toggle(isOn: $tweakInjection) {
                settingRowLabel(title: strings.tweakInjectionToggle, icon: "puzzlepiece.extension.fill", color: .orange)
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))

            Divider()

            Toggle(isOn: $safeMode) {
                settingRowLabel(title: isRu ? "Безопасный режим (Safe Mode)" : "Safe Mode Fallback", icon: "shield.lefthalf.filled", color: .cyan)
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.resolveColor(name: appThemeColor)))
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 4. Системные сведения

    private var systemDiagnosticsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.systemSection, icon: "cpu.fill", color: .teal)

            infoRow(title: strings.deviceModelLabel, value: customDeviceModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.friendlyModelName : customDeviceModel, icon: "ipad.and.iphone", color: .blue)
            Divider()
            infoRow(title: strings.osVersionLabel, value: customOSVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "iOS \(UIDevice.current.systemVersion)" : (customOSVersion.lowercased().hasPrefix("ios") ? customOSVersion : "iOS \(customOSVersion)"), icon: "iphone", color: .indigo)
            Divider()
            infoRow(title: strings.archTitle, value: customArch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "arm64e (SPTM & PAC Bypass)" : customArch, icon: "cpu", color: .teal)
            Divider()
            infoRow(title: strings.exploitLabel, value: customExploitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "PhysPuppet / LandCast" : customExploitName, icon: "bolt.fill", color: .orange)
            Divider()
            infoRow(title: strings.packageManagerLabel, value: customPackageManager.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cort1so1 Installer (Procursus)" : customPackageManager, icon: "shippingbox.fill", color: .cyan)
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 5. Управление джейлбрейком (Danger Zone)

    private var jailbreakManagementCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.jbManagementSection, icon: "exclamationmark.shield.fill", color: .red)

            Button(action: {
                self.showRemoveJailbreakAlert = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 30, height: 30)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }

                    Text(strings.removeJailbreakBtn)
                        .font(.system(.body, design: .default))
                        .fontWeight(.semibold)
                        .foregroundColor(.red)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 6. О программе

    private var aboutProjectCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.aboutSection, icon: "info.circle.fill", color: .blue)

            HStack {
                Text(strings.appNameLabel)
                    .font(.system(.subheadline, design: .default))
                Spacer()
                Text(customAppName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Cort1so1" : customAppName)
                    .fontWeight(.bold)
                    .font(.system(.subheadline, design: .default))
            }

            Divider()

            HStack {
                Text(strings.versionLabel)
                    .font(.system(.subheadline, design: .default))
                Spacer()
                let v = customAppVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1.3" : customAppVersion
                let b = customAppBuild.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "26B101" : customAppBuild
                Text("\(v) (Build \(b))")
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .monospaced))
            }

            Divider()

            Text(strings.aboutDisclaimer)
                .font(.system(.caption, design: .default))
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 7. Создатель & Разработчик
    private var creatorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Заголовок категории
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.resolveColor(name: appThemeColor))

                Text(strings.creatorSection)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Spacer()
            }
            .padding(.horizontal, 4)

            // Основная карточка информации и контактов разработчика
            VStack(spacing: 0) {
                // Имя и статус ведущего разработчика
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppTheme.resolveColor(name: appThemeColor).opacity(0.12))
                            .frame(width: 38, height: 38)

                        Image(systemName: "terminal.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Text("@VityaV")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)

                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                        }

                        Text(isRu ? "Создатель и ведущий разработчик" : "Lead Developer & Researcher")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(14)

                Divider()
                    .padding(.leading, 14)

                // Telegram ссылка (@VityaV)
                Link(destination: URL(string: "https://t.me/VityaV") ?? URL(string: "https://telegram.org")!) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(telegramColor)

                            Text("Telegram")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Text("@VityaV")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(14)
                }

                Divider()
                    .padding(.leading, 14)

                // Discord (@a8o4) - копирование юзернейма
                Button(action: {
                    UIPasteboard.general.string = "@a8o4"
                    let haptic = UINotificationFeedbackGenerator()
                    haptic.notificationOccurred(.success)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        toastMessage = isRu ? "Discord скопирован: @a8o4" : "Discord copied: @a8o4"
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showToast = false
                        }
                    }
                }) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.indigo)

                            Text(strings.discordLabel)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Text("@a8o4")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)

                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(14)
                }
            }
            .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - 8. Триггер Пасхалки (невидимый иконка глубоко внизу)
    private var easterEggBottomTrigger: some View {
        VStack(spacing: 0) {
            // Огромный отступ вниз, чтобы верхний интерфейс ушел далеко наверх
            Spacer()
                .frame(height: 1000)

            // Невидимая иконка в самом низу
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .opacity(0.001)
                .background(
                    GeometryReader { geo -> Color in
                        let minY = geo.frame(in: .global).minY
                        let screenHeight = UIScreen.main.bounds.height
                        if !SettingsView.hasPlayedInSession && minY > 0 && minY < screenHeight - 20 && Date().timeIntervalSince(self.lastTriggerTime) > 3.0 {
                            DispatchQueue.main.async {
                                self.lastTriggerTime = Date()
                                SettingsView.hasPlayedInSession = true
                                self.hasPlayedEasterEgg = true
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.prepare()
                                generator.impactOccurred()
                                self.showEasterEggVideo = true
                            }
                        }
                        return Color.clear
                    }
                )
        }
        .padding(.bottom, 100)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }

    // MARK: - Вспомогательные компоненты разметки

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
    }

    private func settingRowLabel(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                    .frame(width: 30, height: 30)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(.system(.body, design: .default))
        }
    }

    private func infoRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            settingRowLabel(title: title, icon: icon, color: color)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.system(.subheadline, design: .default))
        }
    }

    // MARK: - Логика действий

    private func removeJailbreak() {
        isJailbroken = false
        UserDefaults.standard.set(false, forKey: "isJailbroken")
        UserDefaults.standard.set("", forKey: "lastJailbreakMethod")
        UserDefaults.standard.set(false, forKey: "customStatusBarActive")
        UserDefaults.standard.set(-1, forKey: "customBatteryPercentage")
        UserDefaults.standard.set(-1.0, forKey: "customBatteryLevel")

        withAnimation(.easeInOut(duration: 0.25)) {
            jailbreakState = .idle
        }
    }
}

extension Color {
    static let slateColor = Color(red: 0.35, green: 0.45, blue: 0.55)
}

/// Векторная форма фирменной центрированной буквы «C» Cort1so1
struct Cort1so1IconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = rect.width * (310.0 / 1024.0)
        let innerRadius = rect.width * (220.0 / 1024.0)
        
        let cutOffsetY = rect.height * (95.0 / 1024.0)
        let topCutY = center.y - cutOffsetY
        let bottomCutY = center.y + cutOffsetY
        
        let outerXOffset = sqrt(max(0, outerRadius * outerRadius - cutOffsetY * cutOffsetY))
        let innerXOffset = sqrt(max(0, innerRadius * innerRadius - cutOffsetY * cutOffsetY))
        
        let outerTop = CGPoint(x: center.x + outerXOffset, y: topCutY)
        let innerTop = CGPoint(x: center.x + innerXOffset, y: topCutY)
        let outerBottom = CGPoint(x: center.x + outerXOffset, y: bottomCutY)
        
        let startAngleOuter = atan2(-cutOffsetY, outerXOffset)
        let endAngleOuter = atan2(cutOffsetY, outerXOffset)
        let startAngleInner = atan2(cutOffsetY, innerXOffset)
        let endAngleInner = atan2(-cutOffsetY, innerXOffset)
        
        path.move(to: outerTop)
        path.addLine(to: innerTop)
        path.addArc(center: center, radius: innerRadius, startAngle: Angle(radians: Double(endAngleInner)), endAngle: Angle(radians: Double(startAngleInner)), clockwise: true)
        path.addLine(to: outerBottom)
        path.addArc(center: center, radius: outerRadius, startAngle: Angle(radians: Double(endAngleOuter)), endAngle: Angle(radians: Double(startAngleOuter)), clockwise: false)
        path.closeSubpath()
        return path
    }
}

/// Нативный UIViewControllerRepresentable / UIViewRepresentable для чистой полноэкранной трансляции без контроллеров и паузы
struct CustomAVPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }

    class PlayerUIView: UIView {
        override class var layerClass: AnyClass {
            return AVPlayerLayer.self
        }

        var playerLayer: AVPlayerLayer {
            return layer as! AVPlayerLayer
        }
    }
}

/// Нативный плеер для автовоспроизведения пасхалки без возможности паузы
struct EasterEggVideoPlayerView: View {
    @Binding var isPresented: Bool
    @Binding var hasPlayedEasterEgg: Bool
    @State private var player: AVPlayer?
    @State private var endObserver: NSObjectProtocol?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                CustomAVPlayerView(player: player)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            setupAudioAndPlay()
        }
        .onDisappear {
            if let obs = endObserver {
                NotificationCenter.default.removeObserver(obs)
                endObserver = nil
            }
            player?.pause()
            player = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            resumePlayback()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            player?.pause()
        }
    }

    private func resumePlayback() {
        guard let player = player else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession resume error: \(error)")
        }
        player.play()
    }

    private func setupAudioAndPlay() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession configuration error: \(error)")
        }

        let videoUrl = Bundle.main.url(forResource: "easter_egg", withExtension: "mp4")
            ?? Bundle.main.url(forResource: "input_file_0", withExtension: "mp4")

        guard let url = videoUrl else { return }

        let newPlayer = AVPlayer(url: url)
        self.player = newPlayer

        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }

        self.endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            if let obs = self.endObserver {
                NotificationCenter.default.removeObserver(obs)
                self.endObserver = nil
            }
            newPlayer.pause()
            SettingsView.hasPlayedInSession = true
            hasPlayedEasterEgg = true
            isPresented = false
        }

        newPlayer.play()
    }
}

#Preview {
    SettingsView(jailbreakState: .constant(.completed))
}

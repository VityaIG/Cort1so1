import SwiftUI
import AVFoundation

/// Отдельный полноэкранный раздел панели администратора (ADMIN)
struct AdminDashboardView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    @AppStorage("safeMode") private var safeMode: Bool = false
    @AppStorage("hasSeenFirstLaunchWelcome") private var hasSeenFirstLaunchWelcome: Bool = false

    // ADMIN Настройки
    @AppStorage("isAdminUnlocked") private var isAdminUnlocked: Bool = true
    @AppStorage("customAppName") private var customAppName: String = "Cort1so1"
    @AppStorage("customSubtitle") private var customSubtitle: String = ""
    @AppStorage("customAppVersion") private var customAppVersion: String = "1.2"
    @AppStorage("customAppBuild") private var customAppBuild: String = "26B101"

    // Цвета оформления (Фон экрана и элементы)
    @AppStorage("customAppBgTheme") private var customAppBgTheme: String = "default"
    @AppStorage("customBgColorHex") private var customBgColorHex: String = ""
    @AppStorage("customCardColorHex") private var customCardColorHex: String = ""
    @AppStorage("customTextColorHex") private var customTextColorHex: String = ""

    // Подмена системных параметров
    @AppStorage("customDeviceModel") private var customDeviceModel: String = ""
    @AppStorage("customOSVersion") private var customOSVersion: String = ""
    @AppStorage("customArch") private var customArch: String = ""
    @AppStorage("customExploitName") private var customExploitName: String = ""
    @AppStorage("customPackageManager") private var customPackageManager: String = ""

    // Тюнинг движка
    @AppStorage("simulationSpeedMultiplier") private var simulationSpeedMultiplier: Double = 1.0
    @AppStorage("easterEggChancePercent") private var easterEggChancePercent: Int = 1
    @AppStorage("customRespringDuration") private var customRespringDuration: Double = 2.5
    @AppStorage("custom_apply_button_text") private var customApplyButtonText: String = ""
    @AppStorage("custom_apply_title_text") private var customApplyTitleText: String = ""

    // Локальные состояния
    @State private var bgColorPicker: Color = Color(uiColor: .systemGroupedBackground)
    @State private var cardColorPicker: Color = Color(uiColor: .secondarySystemGroupedBackground)
    @State private var textColorPicker: Color = .primary
    @State private var showResetConfirmationAlert: Bool = false
    @State private var showSecretVideoModal: Bool = false
    @State private var showSecretBootloopModal: Bool = false
    @State private var showRespringModal: Bool = false
    @State private var dummyBool: Bool = false

    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppCustomStyle.resolveBgColor(customHex: customBgColorHex, themeId: customAppBgTheme)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 20) {
                        // 1. Верхний баннер статуса ADMIN
                        adminHeaderBanner

                        // 2. Свои цвета фона и элементов
                        customColorsCard

                        // 3. Название приложения и брендинг
                        appIdentityCard

                        // 4. Подмена системных значений и оборудования
                        systemOverridesCard

                        // 5. Тюнинг симулятора и вероятностей
                        engineTuningCard

                        // 6. Тексты алертов и кнопок
                        customAlertsCard

                        // 7. Инструменты тестирования и действия
                        developerActionsCard

                        // 8. Сброс и блокировка
                        managementCard
                            .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("ADMIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(isRu ? "Готово" : "Done")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                    }
                }
            }
            .fullScreenCover(isPresented: $showSecretVideoModal) {
                EasterEggVideoPlayerView(isPresented: $showSecretVideoModal, hasPlayedEasterEgg: $dummyBool)
            }
            .fullScreenCover(isPresented: $showSecretBootloopModal) {
                SecretEasterEggFloatingView(isPresented: $showSecretBootloopModal)
            }
            .fullScreenCover(isPresented: $showRespringModal) {
                NeoSpringView(onFinished: {
                    showRespringModal = false
                })
            }
            .alert(isPresented: $showResetConfirmationAlert) {
                Alert(
                    title: Text(isRu ? "Сбросить настройки ADMIN?" : "Reset All Admin Settings?"),
                    message: Text(isRu ? "Все кастомные цвета, название приложения, подмены системы и тайминги будут сброшены к значениям по умолчанию." : "All custom colors, app renaming, system overrides, and timings will be restored to defaults."),
                    primaryButton: .destructive(Text(isRu ? "Сбросить" : "Reset")) {
                        resetAllAdminSettings()
                    },
                    secondaryButton: .cancel(Text(isRu ? "Отмена" : "Cancel"))
                )
            }
        }
        .onAppear {
            syncColorPickers()
        }
    }

    // MARK: - 1. Верхний баннер статуса ADMIN
    private var adminHeaderBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 3)

                Image(systemName: "terminal.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("ADMINISTRATOR")
                        .font(.system(size: 16, weight: .heavy, design: .monospaced))
                        .foregroundColor(.primary)

                    Text("ROOT")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple)
                        .clipShape(Capsule())
                }

                Text(isRu ? "Полный контроль над параметрами, цветами и логикой" : "Full control over UI styling, parameters & logic")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.purple.opacity(0.35), lineWidth: 1.5)
        )
    }

    // MARK: - 2. Свои цвета фона и элементов
    private var customColorsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(isRu ? "Кастомизация цветов (Фон и элементы)" : "Custom UI Colors (Background & Elements)", icon: "paintpalette.fill", color: .purple)

            // ColorPicker 1: Цвет фона экрана
            HStack {
                Circle()
                    .fill(AppCustomStyle.resolveBgColor(customHex: customBgColorHex, themeId: customAppBgTheme))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))

                Text(isRu ? "Свой цвет фона экрана" : "Custom Screen Background")
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                ColorPicker("", selection: $bgColorPicker, supportsOpacity: false)
                    .labelsHidden()
                    .onChange(of: bgColorPicker) { newColor in
                        customBgColorHex = newColor.toHex()
                    }

                if !customBgColorHex.isEmpty && customBgColorHex != "default" {
                    Button(action: {
                        customBgColorHex = ""
                        bgColorPicker = Color(uiColor: .systemGroupedBackground)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // ColorPicker 2: Цвет карточек и элементов
            HStack {
                Circle()
                    .fill(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))

                Text(isRu ? "Свой цвет карточек и элементов" : "Custom Card / Element Background")
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                ColorPicker("", selection: $cardColorPicker, supportsOpacity: false)
                    .labelsHidden()
                    .onChange(of: cardColorPicker) { newColor in
                        customCardColorHex = newColor.toHex()
                    }

                if !customCardColorHex.isEmpty && customCardColorHex != "default" {
                    Button(action: {
                        customCardColorHex = ""
                        cardColorPicker = Color(uiColor: .secondarySystemGroupedBackground)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // ColorPicker 3: Цвет текста
            HStack {
                Circle()
                    .fill(AppCustomStyle.resolveTextColor(customHex: customTextColorHex))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))

                Text(isRu ? "Свой цвет текста элементов" : "Custom Element Text Color")
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                ColorPicker("", selection: $textColorPicker, supportsOpacity: false)
                    .labelsHidden()
                    .onChange(of: textColorPicker) { newColor in
                        customTextColorHex = newColor.toHex()
                    }

                if !customTextColorHex.isEmpty && customTextColorHex != "default" {
                    Button(action: {
                        customTextColorHex = ""
                        textColorPicker = .primary
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // Готовые темы фона
            VStack(alignment: .leading, spacing: 8) {
                Text(isRu ? "Быстрые пресеты фоновых тем:" : "Quick Background Presets:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AppBgTheme.availableThemes) { theme in
                            Button(action: {
                                withAnimation {
                                    customAppBgTheme = theme.id
                                    customBgColorHex = ""
                                    bgColorPicker = theme.color
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(theme.color)
                                        .frame(width: 14, height: 14)
                                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5))

                                    Text(isRu ? theme.nameRu : theme.nameEn)
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(customAppBgTheme == theme.id && customBgColorHex.isEmpty ? Color.purple : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 3. Название приложения и брендинг
    private var appIdentityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(isRu ? "Имя приложения и брендинг" : "App Identity & Branding", icon: "textformat.size", color: .blue)

            VStack(spacing: 10) {
                textFieldRow(title: isRu ? "Название:" : "App Name:", placeholder: "Cort1so1", text: $customAppName)
                textFieldRow(title: isRu ? "Подзаголовок:" : "Subtitle:", placeholder: "iOS Jailbreak & IPSW Utility", text: $customSubtitle)
                textFieldRow(title: isRu ? "Версия:" : "Version:", placeholder: "1.2", text: $customAppVersion)
                textFieldRow(title: isRu ? "Сборка:" : "Build:", placeholder: "26B101", text: $customAppBuild)
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 4. Подмена системных значений и оборудования
    private var systemOverridesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(isRu ? "Подмена системного окружения" : "System & Device Overrides", icon: "cpu.fill", color: .teal)

            VStack(spacing: 10) {
                textFieldRow(title: isRu ? "Модель:" : "Device Model:", placeholder: UIDevice.current.model, text: $customDeviceModel)
                textFieldRow(title: isRu ? "Версия iOS:" : "iOS Version:", placeholder: "iOS \(UIDevice.current.systemVersion)", text: $customOSVersion)
                textFieldRow(title: isRu ? "Архитектура:" : "Architecture:", placeholder: "arm64e (SPTM & PAC Bypass)", text: $customArch)
                textFieldRow(title: isRu ? "Эксплойт:" : "Exploit Name:", placeholder: "PhysPuppet / LandCast", text: $customExploitName)
                textFieldRow(title: isRu ? "Пакет-менеджер:" : "Package Manager:", placeholder: "Cort1so1 Installer (Procursus)", text: $customPackageManager)
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 5. Тюнинг симулятора и вероятностей
    private var engineTuningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(isRu ? "Тюнинг движка и вероятностей" : "Engine & Simulation Tuning", icon: "speedometer", color: .orange)

            // 1. Множитель скорости
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(isRu ? "Скорость симуляции джейлбрейка:" : "Exploit Simulation Speed:")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text(String(format: "%.1fx", simulationSpeedMultiplier))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Slider(value: $simulationSpeedMultiplier, in: 0.5...10.0, step: 0.5)
                    .accentColor(.orange)
            }

            Divider()

            // 2. Шанс пасхалки в настройках
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(isRu ? "Шанс пасхалки при входе в Настройки:" : "Easter Egg Trigger Chance:")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text("\(easterEggChancePercent)%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.purple)
                }

                Slider(value: Binding(
                    get: { Double(easterEggChancePercent) },
                    set: { easterEggChancePercent = Int($0) }
                ), in: 0...100, step: 1)
                .accentColor(.purple)
            }

            Divider()

            // 3. Длительность респринга
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(isRu ? "Длительность респринга SpringBoard:" : "SpringBoard Respring Duration:")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text(String(format: "%.1f сек", customRespringDuration))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }

                Slider(value: $customRespringDuration, in: 0.5...10.0, step: 0.5)
                    .accentColor(.blue)
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 6. Тексты алертов и кнопок
    private var customAlertsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(isRu ? "Кастомизация текста алертов" : "Pop-up & Alert Overrides", icon: "bubble.left.and.bubble.right.fill", color: .indigo)

            VStack(spacing: 10) {
                textFieldRow(title: isRu ? "Заголовок применения:" : "Apply Alert Title:", placeholder: isRu ? "Запустил" : "son", text: $customApplyTitleText)
                textFieldRow(title: isRu ? "Текст кнопки применения:" : "Apply Button Label:", placeholder: isRu ? "Семя в арбуууз" : "bruh", text: $customApplyButtonText)
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 7. Инструменты тестирования и действия
    private var developerActionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(isRu ? "Быстрые тесты разработчика" : "Live Triggers & Developer Tools", icon: "hammer.fill", color: .red)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                actionButton(
                    title: isRu ? "Тест видео" : "Play Video",
                    icon: "play.fill",
                    color: .purple
                ) {
                    showSecretVideoModal = true
                }

                actionButton(
                    title: isRu ? "Тест Бутлупа" : "Bootloop & Crash",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                ) {
                    showSecretBootloopModal = true
                }

                actionButton(
                    title: isRu ? "Тест Респринга" : "Test Respring",
                    icon: "arrow.clockwise",
                    color: .blue
                ) {
                    showRespringModal = true
                }

                actionButton(
                    title: isRu ? "Сбросить Онбординг" : "Reset Onboard",
                    icon: "bell.badge.fill",
                    color: .indigo
                ) {
                    hasSeenFirstLaunchWelcome = false
                }

                actionButton(
                    title: isJailbroken ? (isRu ? "Снять JB" : "Unjailbreak") : (isRu ? "Дать JB" : "Set Jailbroken"),
                    icon: "lock.open.fill",
                    color: .green
                ) {
                    withAnimation {
                        isJailbroken.toggle()
                    }
                }

                actionButton(
                    title: isRu ? "Звук ошибки" : "Haptic / Beep",
                    icon: "speaker.wave.3.fill",
                    color: .orange
                ) {
                    let haptic = UINotificationFeedbackGenerator()
                    haptic.notificationOccurred(.error)
                }
            }
        }
        .padding(16)
        .background(AppCustomStyle.resolveCardColor(customHex: customCardColorHex))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 8. Сброс и блокировка
    private var managementCard: some View {
        VStack(spacing: 12) {
            Button(action: {
                showResetConfirmationAlert = true
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                    Text(isRu ? "Сбросить все параметры ADMIN" : "Reset All Admin Settings")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .foregroundColor(.red)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: {
                withAnimation {
                    isAdminUnlocked = false
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "lock.fill")
                    Text(isRu ? "Заблокировать раздел ADMIN" : "Lock ADMIN Section")
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.vertical, 10)
            }
        }
    }

    // MARK: - Вспомогательные компоненты
    private func sectionTitle(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)

            Spacer()
        }
    }

    private func textFieldRow(title: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(width: 110, alignment: .leading)

            TextField(placeholder, text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 13))

            if !text.wrappedValue.isEmpty {
                Button(action: { text.wrappedValue = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.6))
                        .font(.system(size: 14))
                }
            }
        }
    }

    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func syncColorPickers() {
        if !customBgColorHex.isEmpty && customBgColorHex != "default" {
            bgColorPicker = Color(hex: customBgColorHex)
        }
        if !customCardColorHex.isEmpty && customCardColorHex != "default" {
            cardColorPicker = Color(hex: customCardColorHex)
        }
        if !customTextColorHex.isEmpty && customTextColorHex != "default" {
            textColorPicker = Color(hex: customTextColorHex)
        }
    }

    private func resetAllAdminSettings() {
        withAnimation {
            customAppName = "Cort1so1"
            customSubtitle = ""
            customAppVersion = "1.2"
            customAppBuild = "26B101"
            customAppBgTheme = "default"
            customBgColorHex = ""
            customCardColorHex = ""
            customTextColorHex = ""
            customDeviceModel = ""
            customOSVersion = ""
            customArch = ""
            customExploitName = ""
            customPackageManager = ""
            simulationSpeedMultiplier = 1.0
            easterEggChancePercent = 1
            customRespringDuration = 2.5
            customApplyButtonText = ""
            customApplyTitleText = ""
            syncColorPickers()
        }
    }
}

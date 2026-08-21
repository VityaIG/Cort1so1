import SwiftUI
import AVFoundation

/// Панель разработчика и конфигурации (ADMIN) в строгом нативном стиле Apple iOS Settings
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
            Form {
                // MARK: 1. Внешний вид и цвета
                Section(
                    header: Text(isRu ? "Цветовая схема и оформление" : "Appearance & Colors"),
                    footer: Text(isRu ? "Вы можете выбрать любой цвет фона экрана и цвет карточек элементов." : "Select custom background, card, and element colors.")
                ) {
                    ColorPicker(
                        isRu ? "Цвет фона экрана" : "Screen Background Color",
                        selection: $bgColorPicker,
                        supportsOpacity: false
                    )
                    .onChange(of: bgColorPicker) { newColor in
                        customBgColorHex = newColor.toHex()
                    }

                    ColorPicker(
                        isRu ? "Цвет карточек и блоков" : "Card & Block Color",
                        selection: $cardColorPicker,
                        supportsOpacity: false
                    )
                    .onChange(of: cardColorPicker) { newColor in
                        customCardColorHex = newColor.toHex()
                    }

                    ColorPicker(
                        isRu ? "Цвет текста элементов" : "Element Text Color",
                        selection: $textColorPicker,
                        supportsOpacity: false
                    )
                    .onChange(of: textColorPicker) { newColor in
                        customTextColorHex = newColor.toHex()
                    }

                    Picker(isRu ? "Пресет темы фона" : "Background Theme Preset", selection: $customAppBgTheme) {
                        ForEach(AppBgTheme.availableThemes) { theme in
                            Text(isRu ? theme.nameRu : theme.nameEn).tag(theme.id)
                        }
                    }
                    .onChange(of: customAppBgTheme) { newThemeId in
                        customBgColorHex = ""
                        bgColorPicker = AppBgTheme.resolveColor(id: newThemeId)
                    }

                    if !customBgColorHex.isEmpty || !customCardColorHex.isEmpty || !customTextColorHex.isEmpty || customAppBgTheme != "default" {
                        Button(action: {
                            withAnimation {
                                customBgColorHex = ""
                                customCardColorHex = ""
                                customTextColorHex = ""
                                customAppBgTheme = "default"
                                bgColorPicker = Color(uiColor: .systemGroupedBackground)
                                cardColorPicker = Color(uiColor: .secondarySystemGroupedBackground)
                                textColorPicker = .primary
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text(isRu ? "Сбросить цвета оформления" : "Reset UI Colors to Default")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }

                // MARK: 2. Идентификация приложения
                Section(
                    header: Text(isRu ? "Идентификация приложения" : "Application Identity"),
                    footer: Text(isRu ? "Название обновляется на всех вкладках и экранах приложения." : "Custom name applies globally across all tabs and screens.")
                ) {
                    HStack {
                        Text(isRu ? "Название" : "App Name")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("Cort1so1", text: $customAppName)
                    }

                    HStack {
                        Text(isRu ? "Подзаголовок" : "Subtitle")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("iOS Jailbreak & IPSW Utility", text: $customSubtitle)
                    }

                    HStack {
                        Text(isRu ? "Версия" : "Version")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("1.2", text: $customAppVersion)
                    }

                    HStack {
                        Text(isRu ? "Сборка" : "Build")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("26B101", text: $customAppBuild)
                    }
                }

                // MARK: 3. Подмена системного окружения
                Section(
                    header: Text(isRu ? "Подмена системных параметров" : "System & Device Overrides"),
                    footer: Text(isRu ? "Значения подставляются на главном экране и во вкладке даунгрейда." : "Custom hardware and OS parameters override native readings.")
                ) {
                    HStack {
                        Text(isRu ? "Модель" : "Device")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField(UIDevice.current.friendlyModelName, text: $customDeviceModel)
                    }

                    HStack {
                        Text("iOS")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField(UIDevice.current.systemVersion, text: $customOSVersion)
                    }

                    HStack {
                        Text(isRu ? "Архитектура" : "Arch")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("arm64e", text: $customArch)
                    }

                    HStack {
                        Text(isRu ? "Эксплойт" : "Exploit")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("PhysPuppet / LandCast", text: $customExploitName)
                    }

                    HStack {
                        Text(isRu ? "Менеджер" : "Pkg Manager")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("Cort1so1 Installer", text: $customPackageManager)
                    }
                }

                // MARK: 4. Параметры симуляции и тайминги
                Section(
                    header: Text(isRu ? "Параметры симуляции" : "Simulation & Timings"),
                    footer: Text(isRu ? "Управление множителем скорости эксплойта и длительностью респринга." : "Controls exploit execution speed multiplier and respring duration.")
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(isRu ? "Скорость симуляции" : "Exploit Speed")
                            Spacer()
                            Text(String(format: "%.1fx", simulationSpeedMultiplier))
                                .foregroundColor(.secondary)
                                .font(.system(.body, design: .monospaced))
                        }
                        Slider(value: $simulationSpeedMultiplier, in: 0.5...10.0, step: 0.5)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(isRu ? "Шанс пасхалки в настройках" : "Easter Egg Trigger Chance")
                            Spacer()
                            Text("\(easterEggChancePercent)%")
                                .foregroundColor(.secondary)
                                .font(.system(.body, design: .monospaced))
                        }
                        Slider(value: Binding(
                            get: { Double(easterEggChancePercent) },
                            set: { easterEggChancePercent = Int($0) }
                        ), in: 0...100, step: 1)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(isRu ? "Длительность респринга" : "Respring Duration")
                            Spacer()
                            Text(String(format: "%.1f s", customRespringDuration))
                                .foregroundColor(.secondary)
                                .font(.system(.body, design: .monospaced))
                        }
                        Slider(value: $customRespringDuration, in: 0.5...10.0, step: 0.5)
                    }
                    .padding(.vertical, 4)
                }

                // MARK: 5. Кастомизация сообщений
                Section(
                    header: Text(isRu ? "Кастомизация алертов твиков" : "Tweak Alert Overrides"),
                    footer: Text(isRu ? "Текст, отображаемый в окне после нажатия «Применить»." : "Custom text displayed in the alert when applying tweaks.")
                ) {
                    HStack {
                        Text(isRu ? "Заголовок" : "Title")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField(isRu ? "Запустил" : "Applied", text: $customApplyTitleText)
                    }

                    HStack {
                        Text(isRu ? "Кнопка" : "Button")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField(isRu ? "OK" : "OK", text: $customApplyButtonText)
                    }
                }

                // MARK: 6. Инструменты тестирования и действия
                Section(
                    header: Text(isRu ? "Диагностика и тестирование" : "Diagnostics & Live Actions")
                ) {
                    Button(action: {
                        showSecretVideoModal = true
                    }) {
                        Label(isRu ? "Воспроизвести скрытое видео" : "Play Easter Egg Video", systemImage: "play.circle")
                    }

                    Button(action: {
                        showSecretBootloopModal = true
                    }) {
                        Label(isRu ? "Тест бутлупа и краша" : "Test Bootloop & Panic Crash", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }

                    Button(action: {
                        showRespringModal = true
                    }) {
                        Label(isRu ? "Тест респринга SpringBoard" : "Trigger SpringBoard Respring", systemImage: "arrow.clockwise")
                    }

                    Button(action: {
                        hasSeenFirstLaunchWelcome = false
                        let haptic = UINotificationFeedbackGenerator()
                        haptic.notificationOccurred(.success)
                    }) {
                        Label(isRu ? "Сбросить статус онбординга" : "Reset First Launch Onboarding", systemImage: "bell")
                    }

                    Button(action: {
                        withAnimation {
                            isJailbroken.toggle()
                        }
                    }) {
                        Label(
                            isJailbroken ? (isRu ? "Переключить в Non-Jailbroken" : "Set Non-Jailbroken") : (isRu ? "Переключить в Jailbroken" : "Set Jailbroken"),
                            systemImage: "lock.open"
                        )
                    }
                }

                // MARK: 7. Сброс и блокировка
                Section {
                    Button(action: {
                        showResetConfirmationAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text(isRu ? "Сбросить все параметры ADMIN" : "Reset All Admin Settings")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }

                    Button(action: {
                        withAnimation {
                            isAdminUnlocked = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(isRu ? "Заблокировать раздел ADMIN" : "Lock Admin Section")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
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
                            .fontWeight(.semibold)
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

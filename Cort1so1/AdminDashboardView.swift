import SwiftUI
import AVFoundation

/// Панель разработчика и конфигурации (ADMIN) в строгом нативном стиле Apple iOS Settings
struct AdminDashboardView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
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

    // Кастомизация сообщений
    @AppStorage("custom_apply_button_text") private var customApplyButtonText: String = ""
    @AppStorage("custom_apply_title_text") private var customApplyTitleText: String = ""

    // Локальные состояния для модальных окон
    @State private var showResetConfirmationAlert: Bool = false
    @State private var showSecretVideoModal: Bool = false
    @State private var showRespringModal: Bool = false
    @State private var dummyBool: Bool = false

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var bgColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                if !customBgColorHex.isEmpty && customBgColorHex != "default" {
                    return Color(hex: customBgColorHex)
                }
                return AppBgTheme.resolveColor(id: customAppBgTheme)
            },
            set: { newColor in
                customBgColorHex = newColor.toHex()
            }
        )
    }

    private var cardColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                if !customCardColorHex.isEmpty && customCardColorHex != "default" {
                    return Color(hex: customCardColorHex)
                }
                return Color(uiColor: .secondarySystemGroupedBackground)
            },
            set: { newColor in
                customCardColorHex = newColor.toHex()
            }
        )
    }

    private var textColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                if !customTextColorHex.isEmpty && customTextColorHex != "default" {
                    return Color(hex: customTextColorHex)
                }
                return .primary
            },
            set: { newColor in
                customTextColorHex = newColor.toHex()
            }
        )
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
                        selection: bgColorBinding,
                        supportsOpacity: false
                    )

                    ColorPicker(
                        isRu ? "Цвет карточек и блоков" : "Card & Block Color",
                        selection: cardColorBinding,
                        supportsOpacity: false
                    )

                    ColorPicker(
                        isRu ? "Цвет текста элементов" : "Element Text Color",
                        selection: textColorBinding,
                        supportsOpacity: false
                    )

                    Picker(isRu ? "Пресет темы фона" : "Background Theme Preset", selection: $customAppBgTheme) {
                        ForEach(AppBgTheme.availableThemes) { theme in
                            Text(isRu ? theme.nameRu : theme.nameEn).tag(theme.id)
                        }
                    }
                    .onChange(of: customAppBgTheme) { newThemeId in
                        customBgColorHex = ""
                    }

                    if !customBgColorHex.isEmpty || !customCardColorHex.isEmpty || !customTextColorHex.isEmpty || customAppBgTheme != "default" {
                        Button(action: {
                            withAnimation {
                                customBgColorHex = ""
                                customCardColorHex = ""
                                customTextColorHex = ""
                                customAppBgTheme = "default"
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
                    footer: Text(isRu ? "Название и версия обновляются на всех экранах и карточках приложения." : "Custom name and version apply globally across all tabs and screens.")
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
                    footer: Text(isRu ? "Значения отображаются на главном экране, в настройках и во вкладке отката." : "Custom hardware and OS parameters override native readings across all views.")
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
                        TextField("arm64e (SPTM & PAC Bypass)", text: $customArch)
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
                        TextField("Cort1so1 Installer (Procursus)", text: $customPackageManager)
                    }
                }

                // MARK: 4. Кастомизация сообщений
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

                // MARK: 5. Инструменты тестирования и действия
                Section(
                    header: Text(isRu ? "Диагностика и тестирование" : "Diagnostics & Live Actions")
                ) {
                    Button(action: {
                        showSecretVideoModal = true
                    }) {
                        Label(isRu ? "Воспроизвести скрытое видео" : "Play Easter Egg Video", systemImage: "play.circle")
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

                // MARK: 6. Сброс и блокировка
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
            .fullScreenCover(isPresented: $showRespringModal) {
                NeoSpringView(onFinished: {
                    showRespringModal = false
                })
            }
            .alert(isPresented: $showResetConfirmationAlert) {
                Alert(
                    title: Text(isRu ? "Сбросить настройки ADMIN?" : "Reset All Admin Settings?"),
                    message: Text(isRu ? "Все кастомные цвета, название приложения, версия и подмены системы будут сброшены к значениям по умолчанию." : "All custom colors, app renaming, version, and system overrides will be restored to defaults."),
                    primaryButton: .destructive(Text(isRu ? "Сбросить" : "Reset")) {
                        resetAllAdminSettings()
                    },
                    secondaryButton: .cancel(Text(isRu ? "Отмена" : "Cancel"))
                )
            }
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
            customApplyButtonText = ""
            customApplyTitleText = ""
        }
    }
}

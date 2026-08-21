import SwiftUI
import AVFoundation
import AVKit

/// Перечисление всплывающих окон первого запуска
enum FirstLaunchAlertItem: Identifiable {
    case welcome
    case volumeWarning

    var id: String {
        switch self {
        case .welcome: return "welcome"
        case .volumeWarning: return "volumeWarning"
        }
    }
}

/// Корневой контейнер приложения с нативным TabView в стиле iOS HIG
struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("hideStatusBar") private var hideStatusBar: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @AppStorage("hasSeenFirstLaunchWelcome") private var hasSeenFirstLaunchWelcome: Bool = false
    @AppStorage("customAppBgTheme") private var customAppBgTheme: String = "default"
    @AppStorage("customBgColorHex") private var customBgColorHex: String = ""

    @State private var jailbreakState: JailbreakState = .idle
    @State private var selectedTab: Int = 0
    @State private var activeFirstLaunchAlert: FirstLaunchAlertItem? = nil

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        ZStack {
            AppCustomStyle.resolveBgColor(customHex: customBgColorHex, themeId: customAppBgTheme)
                .ignoresSafeArea()

            // Нативный системный TabView
            TabView(selection: $selectedTab) {
                MainView(jailbreakState: $jailbreakState)
                    .tabItem {
                        Label(strings.tabMain, systemImage: "lock.open.fill")
                    }
                    .tag(0)

                // Раздел «Твики» (доступен только после выполнения джейлбрейка)
                if isJailbroken || jailbreakState == .completed {
                    TweaksView()
                        .tabItem {
                            Label(strings.tabTweaks, systemImage: "hammer.fill")
                        }
                        .tag(1)
                }

                DowngradeView()
                    .tabItem {
                        Label(strings.tabDowngrade, systemImage: "arrow.counterclockwise.circle.fill")
                    }
                    .tag(2)

                SettingsView(jailbreakState: $jailbreakState)
                    .tabItem {
                        Label(strings.tabSettings, systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .id("tabview-\(isJailbroken)-\(jailbreakState == .completed)")

            // Оверлей выполнения респринга SpringBoard
            if jailbreakState == .respring {
                NeoSpringView(onFinished: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        jailbreakState = isJailbroken ? .completed : .idle
                    }
                })
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .onAppear {
            // Если ранее был выполнен джейлбрейк, восстанавливаем состояние
            if isJailbroken {
                jailbreakState = .completed
            }

            // Показ приветственного поп-апа при самом первом запуске
            if !hasSeenFirstLaunchWelcome {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    self.activeFirstLaunchAlert = .welcome
                }
            }
        }
        .onChange(of: isJailbroken) { newValue in
            if newValue && jailbreakState != .completed {
                withAnimation(.easeInOut(duration: 0.25)) {
                    jailbreakState = .completed
                }
            }
        }
        .onChange(of: jailbreakState) { newState in
            if newState == .completed && !isJailbroken {
                isJailbroken = true
                UserDefaults.standard.set(true, forKey: "isJailbroken")
            }
        }
        .alert(item: $activeFirstLaunchAlert) { item in
            switch item {
            case .welcome:
                return Alert(
                    title: Text(isRu ? "Привет!" : "Hello!"),
                    message: Text(isRu ? "Добро пожаловать в Cort1so1!\n\nЭто приложение открывает возможности интерактивной среды iOS:\n\n• Выполнение джейлбрейка на движках Dopamine (Old) и Cortisol (New)\n• Настройка и применение твиков подсистемы Substrate\n• Симуляция отката и восстановления прошивок iOS" : "Welcome to Cort1so1!\n\nThis app allows you to explore an interactive iOS environment:\n\n• Jailbreak with Dopamine (Old) and Cortisol (New) engines\n• Customize and apply Substrate runtime tweaks\n• Simulate iOS firmware downgrades and restores"),
                    dismissButton: .default(Text(isRu ? "Продолжить" : "Continue")) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.activeFirstLaunchAlert = .volumeWarning
                        }
                    }
                )
            case .volumeWarning:
                return Alert(
                    title: Text(isRu ? "ВНИМАНИЕ!" : "WARNING!"),
                    message: Text(isRu ? "Некоторые процессы симуляции в приложении сопровождаются внезапными громкими звуковыми эффектами.\n\nЕсли вы используете наушники, пожалуйста, снимите их перед продолжением." : "Some simulation sequences in this app include sudden high-volume sound effects.\n\nIf you are using headphones or earphones, please remove them before proceeding."),
                    dismissButton: .default(Text(isRu ? "Понятно" : "I Understand")) {
                        self.hasSeenFirstLaunchWelcome = true
                        UserDefaults.standard.set(true, forKey: "hasSeenFirstLaunchWelcome")
                    }
                )
            }
        }
        // Поддержка двух режимов оформления
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .accentColor(AppTheme.resolveColor(name: appThemeColor))
        .statusBarHidden(hideStatusBar || jailbreakState == .respring)
    }
}

#Preview {
    ContentView()
}

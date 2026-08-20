import SwiftUI

/// Корневой контейнер приложения с нативным TabView в стиле iOS HIG
struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @State private var jailbreakState: JailbreakState = .idle
    @State private var selectedTab: Int = 0

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    var body: some View {
        ZStack {
            // Нативный системный TabView
            TabView(selection: $selectedTab) {
                MainView(jailbreakState: $jailbreakState)
                    .tabItem {
                        Label(strings.tabMain, systemImage: "lock.open.fill")
                    }
                    .tag(0)

                // Раздел «Твики» появляется только после выполнения джейлбрейка
                if isJailbroken || jailbreakState == .completed {
                    TweaksView()
                        .tabItem {
                            Label(strings.tabTweaks, systemImage: "wand.and.stars")
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

            // Оверлей симуляции нативного респринга SpringBoard
            if jailbreakState == .respring {
                NeoSpringView(onFinished: {
                    isJailbroken = true
                    withAnimation(.easeInOut(duration: 0.3)) {
                        jailbreakState = .completed
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
        }
        // Поддержка двух режимов оформления
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}

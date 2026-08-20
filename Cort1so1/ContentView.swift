import SwiftUI

/// Корневой контейнер приложения с нативным TabView в концепции iOS 26 Liquid Glass
struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @State private var jailbreakState: JailbreakState = .idle
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            // Нативный системный TabView с материалом ультратонкого стекла
            TabView(selection: $selectedTab) {
                MainView(jailbreakState: $jailbreakState)
                    .tabItem {
                        Label("Основное", systemImage: "bolt.shield.fill")
                    }
                    .tag(0)

                DowngradeView()
                    .tabItem {
                        Label("Откат iOS", systemImage: "arrow.counterclockwise.circle.fill")
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("Настройки", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)

            // Фаза 2: Оверлей быстрого потока системных логов
            if jailbreakState == .streamingLogs {
                LogStreamView(onCompleted: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        jailbreakState = .respring
                    }
                })
                .transition(.opacity)
                .zIndex(10)
            }

            // Фаза 3: Оверлей симуляции респринга SpringBoard
            if jailbreakState == .respring {
                NeoSpringView(onFinished: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        jailbreakState = .completed
                    }
                })
                .transition(.opacity)
                .zIndex(20)
            }
        }
        // Поддержка двух режимов оформления
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}

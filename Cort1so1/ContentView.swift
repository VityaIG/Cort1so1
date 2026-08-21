import SwiftUI
import AVFoundation
import AVKit

/// Корневой контейнер приложения с нативным TabView в стиле iOS HIG
struct ContentView: View {
    static var hasPlayedSecretEasterEggInSession: Bool = false

    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("hideStatusBar") private var hideStatusBar: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @State private var jailbreakState: JailbreakState = .idle
    @State private var selectedTab: Int = 0
    @State private var showSecretEasterEgg: Bool = false

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

                SettingsView(jailbreakState: $jailbreakState, showSecretEasterEgg: $showSecretEasterEgg)
                    .tabItem {
                        Label(strings.tabSettings, systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .id("tabview-\(isJailbroken)-\(jailbreakState == .completed)")

            // Нативный компактный iOS Pop-up по центру экрана (нельзя закрыть вручную, пропадает по окончании видео)
            if showSecretEasterEgg {
                SecretEasterEggFloatingView(isPresented: $showSecretEasterEgg)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
                    .zIndex(15)
            }

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
        .onChange(of: selectedTab) { newTab in
            // Фиксированный шанс 5% при открытии Настроек (только 1 раз за сессию приложения)
            if newTab == 3 && !ContentView.hasPlayedSecretEasterEggInSession && !showSecretEasterEgg {
                if Int.random(in: 1...100) <= 5 {
                    ContentView.hasPlayedSecretEasterEggInSession = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showSecretEasterEgg = true
                        }
                    }
                }
            }
        }
        // Поддержка двух режимов оформления
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .accentColor(AppTheme.resolveColor(name: appThemeColor))
        .statusBarHidden(hideStatusBar || jailbreakState == .respring)
    }
}

/// Нативный компактный всплывающий поп-ап в стиле iOS HIG (без лишних эффектов)
struct SecretEasterEggFloatingView: View {
    @Binding var isPresented: Bool
    @State private var player: AVPlayer?

    var body: some View {
        VStack(spacing: 12) {
            // Обычный аккуратный системный заголовок
            Text("Congratulations, you won bootloop")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 4)
                .padding(.top, 2)

            // Компактный встроенный видеоплеер
            ZStack {
                Color.black

                if let player = player {
                    CustomAVPlayerView(player: player)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 240, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(16)
        .frame(width: 270)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.28), radius: 24, x: 0, y: 10)
        .onAppear {
            setupAudioAndPlay()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func setupAudioAndPlay() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession error: \(error)")
        }

        let videoUrl = Bundle.main.url(forResource: "secreteaster", withExtension: "mp4")
            ?? Bundle.main.url(forResource: "secreteaster.mp4", withExtension: nil)

        guard let url = videoUrl else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }
            return
        }

        let newPlayer = AVPlayer(url: url)
        self.player = newPlayer

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            newPlayer.pause()
            withAnimation(.easeInOut(duration: 0.3)) {
                isPresented = false
            }
        }

        newPlayer.play()
    }
}

#Preview {
    ContentView()
}

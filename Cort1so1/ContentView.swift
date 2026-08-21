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
    @State private var secretEasterEggChance: Double = 5.0

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

            // Секретная пасхалка по центру экрана (не закрывает навигацию и остается при смене страниц)
            if showSecretEasterEgg {
                SecretEasterEggFloatingView(isPresented: $showSecretEasterEgg)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.85).combined(with: .opacity)
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
            // При каждом переключении вкладки шанс увеличивается на +0.05%
            secretEasterEggChance += 0.05

            // Если открыли Настройки и пасхалка еще не воспроизводилась в текущей сессии
            if newTab == 3 && !ContentView.hasPlayedSecretEasterEggInSession && !showSecretEasterEgg {
                let roll = Double.random(in: 0.0..<100.0)
                if roll < secretEasterEggChance {
                    ContentView.hasPlayedSecretEasterEggInSession = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
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

/// Плавающее окно секретной пасхалки с золотым градиентным текстом и видео по центру
struct SecretEasterEggFloatingView: View {
    @Binding var isPresented: Bool
    @State private var player: AVPlayer?

    var body: some View {
        VStack(spacing: 12) {
            // Золотой градиентный текст
            Text("Congratulations, you won bootloop")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.90, blue: 0.45),
                            Color(red: 0.98, green: 0.72, blue: 0.15),
                            Color(red: 1.0, green: 0.85, blue: 0.30),
                            Color(red: 0.85, green: 0.58, blue: 0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .mask(
                    Text("Congratulations, you won bootloop")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                )
                .shadow(color: Color(red: 1.0, green: 0.80, blue: 0.20).opacity(0.4), radius: 6, x: 0, y: 1)
                .padding(.horizontal, 8)

            // Видеоплеер по центру
            ZStack {
                Color.black

                if let player = player {
                    CustomAVPlayerView(player: player)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                }
            }
            .frame(width: 270, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.88, blue: 0.40).opacity(0.8),
                                Color(red: 0.90, green: 0.65, blue: 0.15).opacity(0.4),
                                Color(red: 1.0, green: 0.88, blue: 0.40).opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.30).opacity(0.6),
                                    Color(red: 0.85, green: 0.60, blue: 0.10).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.55), radius: 20, x: 0, y: 10)
                .shadow(color: Color(red: 1.0, green: 0.80, blue: 0.20).opacity(0.15), radius: 15, x: 0, y: 0)
        )
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

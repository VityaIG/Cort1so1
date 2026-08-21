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
    static var hasPlayedSecretEasterEggInSession: Bool = false

    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("hideStatusBar") private var hideStatusBar: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @AppStorage("hasSeenFirstLaunchWelcome") private var hasSeenFirstLaunchWelcome: Bool = false

    @State private var jailbreakState: JailbreakState = .idle
    @State private var selectedTab: Int = 0
    @State private var showSecretEasterEgg: Bool = false
    @State private var activeFirstLaunchAlert: FirstLaunchAlertItem? = nil

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
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

            // Нативный компактный iOS Pop-up по центру экрана, переходящий в бутлуп с яблоком и краш
            if showSecretEasterEgg {
                SecretEasterEggFloatingView(isPresented: $showSecretEasterEgg)
                    .zIndex(50)
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
        .onChange(of: selectedTab) { newTab in
            // Фиксированный шанс 1% при открытии Настроек (только 1 раз за сессию приложения)
            if newTab == 3 && !ContentView.hasPlayedSecretEasterEggInSession && !showSecretEasterEgg {
                if Int.random(in: 1...100) == 1 {
                    ContentView.hasPlayedSecretEasterEggInSession = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showSecretEasterEgg = true
                        }
                    }
                }
            }
        }
        .alert(item: $activeFirstLaunchAlert) { item in
            switch item {
            case .welcome:
                return Alert(
                    title: Text(isRu ? "Привет!" : "Hello!"),
                    message: Text(isRu ? "Добро пожаловать в Cort1so1!\n\nЗдесь вы можете выполнить джейлбрейк устройства методами Dopamine или Cortisol, откатывать версии iOS, настраивать и применять кастомные твики, а также исследовать скрытые возможности системы." : "Welcome to Cort1so1!\n\nHere you can jailbreak your device with Dopamine or Cortisol, downgrade iOS versions, customize and apply custom tweaks, and explore unique system features."),
                    dismissButton: .default(Text(isRu ? "Далее" : "Next")) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.activeFirstLaunchAlert = .volumeWarning
                        }
                    }
                )
            case .volumeWarning:
                return Alert(
                    title: Text(isRu ? "ВНИМАНИЕ!" : "WARNING!"),
                    message: Text(isRu ? "Некоторые функции в этом приложении могут быть очень громкими! Если вы в наушниках, пожалуйста, снимите их!" : "WARNING! Some parts in this app may be very loud, if you're in headphones, please take them off!"),
                    dismissButton: .default(Text(isRu ? "Понятно" : "OK, got it")) {
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

/// Нативный всплывающий поп-ап, переходящий в полноэкранный бутлуп с белым->зеленым яблоком и крашем
struct SecretEasterEggFloatingView: View {
    @Binding var isPresented: Bool
    @State private var player: AVPlayer?
    @State private var endObserver: NSObjectProtocol?
    @State private var bootloopPhase: Int = 0 // 0: Video Pop-up, 1: White Apple, 2: Green Apple

    var body: some View {
        ZStack {
            if bootloopPhase == 0 {
                // Компактный нативный iOS поп-ап с видео
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
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                // Полноэкранный бутлуп: черный фон на весь экран и яблоко
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

                Image(systemName: "apple.logo")
                    .font(.system(size: 84, weight: .regular))
                    .foregroundColor(bootloopPhase >= 2 ? Color.green : Color.white)
                    .animation(.easeInOut(duration: 0.6), value: bootloopPhase)
                    .transition(.opacity)
            }
        }
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
            triggerBootloopAndCrash()
            return
        }

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
            self.triggerBootloopAndCrash()
        }

        newPlayer.play()
    }

    private func triggerBootloopAndCrash() {
        // 1. Показываем белое яблоко на весь экран
        withAnimation(.easeInOut(duration: 0.35)) {
            bootloopPhase = 1
        }

        // 2. Через 1.2 секунды яблоко перекрашивается в зеленый цвет
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.6)) {
                bootloopPhase = 2
            }

            // 3. Через 1.2 секунды после зеленого яблока приложение крашится
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                exit(0)
            }
        }
    }
}

#Preview {
    ContentView()
}

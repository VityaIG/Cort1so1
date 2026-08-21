import SwiftUI
import UIKit
import MediaPlayer
import AVFoundation

/// Фазы процесса джейлбрейка в стиле Dopamine
enum DopamineProcessPhase {
    case logging
    case restoreWhite
    case glitchRedMultiply
    case respring
}

/// Модель отдельного шага логов процесса джейлбрейка
struct JailbreakLogStep: Identifiable, Equatable {
    let id: Int
    let titleRu: String
    let titleEn: String
    let isMajorPhase: Bool
    let iconName: String
}

/// Модель клона для глитч-эффекта телепортации и размножения
struct GlitchClone: Identifiable {
    let id = UUID()
    var offset: CGSize
    var scale: CGFloat
    var rotation: Double
    var opacity: Double
}

/// Модальное окно процесса джейлбрейка
struct DopamineProcessView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("installedOS") private var installedOS: String = "iOS"
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    @AppStorage("safeMode") private var safeMode: Bool = false
    @AppStorage("simulationSpeedMultiplier") private var simulationSpeedMultiplier: Double = 1.0
    var method: JailbreakMethod = .dopamine
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [JailbreakLogStep] = []
    @State private var currentStepIndex: Int = 0
    
    // Параметры экрана восстановления (40 секунд)
    @State private var restoreProgress: Double = 0.0
    @State private var restoreTimer: Timer? = nil
    
    // Параметры стандартного глитч-эффекта
    @State private var glitchClones: [GlitchClone] = []
    @State private var glitchTimer: Timer? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil

    // Параметры Safe Mode (DVD Bouncing с физикой вращения)
    @State private var dvdPosition: CGPoint = .zero
    @State private var dvdRotation: Double = 0.0
    @State private var dvdAngularVelocity: Double = 220.0
    @State private var maxDvdOffsetX: CGFloat = 80
    @State private var maxDvdOffsetY: CGFloat = 200
    @State private var dvdTimer: Timer? = nil

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    /// Список последовательных логов джейлбрейка
    private var logSteps: [JailbreakLogStep] {
        method.logs(isRu: isRu, verbose: verboseLogs)
    }

    private var progressRatio: Double {
        Double(currentStepIndex) / Double(max(1, logSteps.count))
    }

    private var currentPhaseDescription: String {
        if currentStepIndex == 0 {
            return isRu ? "Инициализация среды..." : "Initializing environment..."
        } else if currentStepIndex < logSteps.count {
            let current = logSteps[currentStepIndex - 1]
            return isRu ? current.titleRu : current.titleEn
        } else {
            return isRu ? "Среда подготовлена." : "Environment ready."
        }
    }

    var body: some View {
        ZStack {
            // Чистый сплошной черный фон OLED
            Color.black
                .ignoresSafeArea()

            switch phase {
            case .logging:
                loggingInterface
                    .transition(.opacity)

            case .restoreWhite:
                restoreAppleView(color: .white, progress: restoreProgress)
                    .transition(.opacity)

            case .glitchRedMultiply:
                glitchMultiplyView
                    .transition(.identity)

            case .respring:
                NeoSpringView(onFinished: {
                    self.onComplete()
                })
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(phase != .logging)
        .onAppear {
            runExecutionPipeline(stepIndex: 0)
        }
        .onDisappear {
            restoreTimer?.invalidate()
            glitchTimer?.invalidate()
            dvdTimer?.invalidate()
            audioPlayer?.stop()
        }
    }

    // MARK: - Главный интерфейс логов

    private var loggingInterface: some View {
        VStack(spacing: 0) {
            // Верхняя нативная панель
            HStack(alignment: .center) {
                // Левая сторона: Индикаторы статуса
                HStack(spacing: 6) {
                    Circle().fill(Color.red.opacity(0.85)).frame(width: 8, height: 8)
                    Circle().fill(Color.yellow.opacity(0.85)).frame(width: 8, height: 8)
                    Circle().fill(Color.green.opacity(0.85)).frame(width: 8, height: 8)
                }

                Spacer()

                // Центральный счетчик шагов и процент
                Text(String(format: "%d%% • %d/%d", Int(progressRatio * 100), currentStepIndex, logSteps.count))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                // Правая сторона: Название метода
                HStack(spacing: 6) {
                    Image(systemName: method == .dopamine ? "drop.fill" : "bolt.shield.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(method.primaryColor)
                    Text(method.shortTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(white: 0.05))

            // Прогресс-бар с плавным spring-эффектом
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 2.5)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [method.primaryColor.opacity(0.8), method.primaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(8, geo.size.width * CGFloat(progressRatio)),
                            height: 2.5
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStepIndex)
                }
            }
            .frame(height: 2.5)

            // Список логов: плавный поток и подсветка (снизу вверх)
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(Array(visibleLogs.enumerated().reversed()), id: \.element.id) { index, step in
                            let isCurrentRunning = (index == visibleLogs.count - 1 && currentStepIndex < logSteps.count)

                            HStack(alignment: .center, spacing: 12) {
                                // Иконка состояния
                                if isCurrentRunning {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: method.primaryColor))
                                        .scaleEffect(0.85)
                                        .frame(width: 22, height: 22)
                                } else if step.isMajorPhase {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(method.primaryColor)
                                        .frame(width: 22, height: 22)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(method.primaryColor.opacity(0.9))
                                        .frame(width: 22, height: 22)
                                }

                                // Текст лога
                                Text(isRu ? step.titleRu : step.titleEn)
                                    .font(.system(
                                        size: step.isMajorPhase ? 14 : 13,
                                        weight: step.isMajorPhase ? .bold : (isCurrentRunning ? .semibold : .regular),
                                        design: .monospaced
                                    ))
                                    .foregroundColor(
                                        step.isMajorPhase
                                            ? method.primaryColor
                                            : (isCurrentRunning ? Color.white : Color.white.opacity(0.8))
                                    )
                                    .lineLimit(2)

                                Spacer(minLength: 0)

                                if step.isMajorPhase {
                                    Text(isRu ? "OK" : "DONE")
                                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2.5)
                                        .background(method.primaryColor)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                isCurrentRunning
                                    ? method.primaryColor.opacity(0.12)
                                    : (step.isMajorPhase ? method.primaryColor.opacity(0.08) : Color.clear)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .id(step.id)
                            .scaleEffect(x: 1, y: -1, anchor: .center)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scaleEffect(x: 1, y: -1, anchor: .center)
            }

            Spacer(minLength: 0)

            // Нижняя статусная строка
            HStack(spacing: 10) {
                Text(currentPhaseDescription)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)

                Spacer()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: method.primaryColor))
                    .scaleEffect(0.75)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color(white: 0.05))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 0.5),
                alignment: .top
            )
        }
        .background(Color.black)
    }

    // MARK: - Экран восстановления Apple (Яблоко + полоска снизу без текста на 40 сек)

    private func restoreAppleView(color: Color, progress: Double) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 48) {
                // Логотип Apple или кастомной ОС
                if installedOS == "Android 17" || installedOS == "Android 17 Beta" {
                    AndroidRobotHead(color: color)
                        .frame(width: 96, height: 96)
                } else if installedOS == "Windows 11" {
                    WindowsLogoView(color: color)
                        .frame(width: 96, height: 96)
                } else if installedOS == "Ubuntu 26.04" {
                    UbuntuLogoView(color: color)
                        .frame(width: 96, height: 96)
                } else {
                    Image(systemName: "applelogo")
                        .font(.system(size: 96, weight: .regular))
                        .foregroundColor(color)
                }

                // Нативная полоса восстановления в стиле iOS (без текста)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(white: 0.22))
                        .frame(width: 210, height: 4.5)

                    Capsule()
                        .fill(color)
                        .frame(width: max(4.5, 210 * CGFloat(min(1.0, max(0.0, progress)))), height: 4.5)
                }
                .frame(width: 210, height: 4.5)
            }
        }
    }

    // MARK: - Safe Mode Вращающийся логотип

    private func safeModeAppleLogo(color: Color) -> some View {
        Group {
            if installedOS == "Android 17" || installedOS == "Android 17 Beta" {
                AndroidRobotHead(color: color)
                    .frame(width: 100, height: 100)
            } else if installedOS == "Windows 11" {
                WindowsLogoView(color: color)
                    .frame(width: 100, height: 100)
            } else if installedOS == "Ubuntu 26.04" {
                UbuntuLogoView(color: color)
                    .frame(width: 100, height: 100)
            } else {
                Image(systemName: "applelogo")
                    .font(.system(size: 100, weight: .regular))
                    .foregroundColor(color)
            }
        }
        .rotationEffect(.degrees(dvdRotation))
        .shadow(color: color.opacity(0.85), radius: 22)
    }

    // MARK: - Экран красного яблока (Обычный глитч ИЛИ Safe Mode DVD Bounce)

    private var glitchMultiplyView: some View {
        let redColor = Color(red: 0.98, green: 0.22, blue: 0.26)

        return GeometryReader { geo in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if safeMode {
                    // Safe Mode: Только красное яблоко БЕЗ полоски, летает и крутится от столкновений как DVD!
                    safeModeAppleLogo(color: redColor)
                        .position(
                            x: geo.size.width / 2 + dvdPosition.x,
                            y: geo.size.height / 2 + dvdPosition.y
                        )
                } else {
                    // Обычный режим: Центральный объект + размноженные телепортирующиеся копии
                    restoreAppleView(color: redColor, progress: 1.0)
                        .shadow(color: redColor.opacity(0.8), radius: 24)

                    ForEach(glitchClones) { clone in
                        restoreAppleView(color: redColor, progress: 1.0)
                            .scaleEffect(clone.scale)
                            .rotationEffect(.degrees(clone.rotation))
                            .offset(clone.offset)
                            .opacity(clone.opacity)
                            .shadow(color: redColor.opacity(0.6), radius: 16)
                    }
                }
            }
            .onAppear {
                if safeMode {
                    initDVDBoundaries(screenSize: geo.size)
                }
            }
        }
    }

    // MARK: - Асинхронный пайплайн выполнения

    private func runExecutionPipeline(stepIndex: Int) {
        let speed = max(0.2, min(20.0, simulationSpeedMultiplier))
        if stepIndex < logSteps.count {
            let step = logSteps[stepIndex]
            self.currentStepIndex = stepIndex + 1
            
            // Тактильный отклик под каждый метод
            triggerHaptic(isMajor: step.isMajorPhase)
            
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.visibleLogs.append(step)
            }
            
            let baseDelay = method.stepDelay(verbose: verboseLogs) / speed
            let delay: Double = step.isMajorPhase ? (baseDelay * 1.4) : baseDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.runExecutionPipeline(stepIndex: stepIndex + 1)
            }
        } else {
            // Завершение логов -> Переход к экрану восстановления с белым яблоком и полосой
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.8 / speed)) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.phase = .restoreWhite
                }
                
                self.start40SecondsRestoreSequence()
            }
        }
    }

    // MARK: - Расчет прогресса восстановления (40 сек с правдоподобными паузами каждые 4-6 сек)

    private struct RestoreKeyframe {
        let time: Double
        let progress: Double
    }

    private var restoreKeyframes: [RestoreKeyframe] {
        [
            RestoreKeyframe(time: 0.0, progress: 0.0),
            RestoreKeyframe(time: 4.5, progress: 0.12),
            RestoreKeyframe(time: 6.0, progress: 0.12),
            RestoreKeyframe(time: 10.5, progress: 0.28),
            RestoreKeyframe(time: 12.5, progress: 0.28),
            RestoreKeyframe(time: 17.5, progress: 0.46),
            RestoreKeyframe(time: 19.0, progress: 0.46),
            RestoreKeyframe(time: 24.5, progress: 0.65),
            RestoreKeyframe(time: 26.5, progress: 0.65),
            RestoreKeyframe(time: 31.0, progress: 0.80),
            RestoreKeyframe(time: 32.5, progress: 0.80),
            RestoreKeyframe(time: 37.0, progress: 0.93),
            RestoreKeyframe(time: 38.5, progress: 0.93),
            RestoreKeyframe(time: 40.0, progress: 1.00)
        ]
    }

    private func calculateRestoreProgress(at elapsedNormalizedTime: Double) -> Double {
        let t = max(0.0, min(40.0, elapsedNormalizedTime))
        if t >= 40.0 { return 1.0 }

        let keyframes = restoreKeyframes
        for i in 0..<(keyframes.count - 1) {
            let k1 = keyframes[i]
            let k2 = keyframes[i + 1]

            if t >= k1.time && t <= k2.time {
                let duration = k2.time - k1.time
                if duration <= 0 { return k2.progress }
                let fraction = (t - k1.time) / duration
                return k1.progress + (k2.progress - k1.progress) * fraction
            }
        }
        return 1.0
    }

    /// Запуск 40-секундной полосы восстановления с правдоподобными остановками каждые 4-6 секунд
    private func start40SecondsRestoreSequence() {
        let speed = max(0.2, min(20.0, simulationSpeedMultiplier))
        self.restoreProgress = 0.0
        let totalRealDuration: Double = 40.0 / speed
        let interval: Double = 0.04
        let startTime = Date()
        
        self.restoreTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            let actualElapsed = Date().timeIntervalSince(startTime)
            let normalizedElapsed = actualElapsed * speed
            
            self.restoreProgress = self.calculateRestoreProgress(at: normalizedElapsed)
            
            if normalizedElapsed >= 40.0 || actualElapsed >= totalRealDuration {
                self.restoreProgress = 1.0
                timer.invalidate()
                self.restoreTimer = nil
                
                if self.safeMode {
                    // Safe Mode: НЕТ звука, НЕТ регулировки громкости, только крутящееся DVD-яблоко ровно 10 сек
                    withAnimation(.none) {
                        self.phase = .glitchRedMultiply
                    }
                    self.startSafeModeDVDSequence()
                } else {
                    // Обычный режим: Максимальная громкость + bigalert.mp3 + глитч
                    self.setSystemVolumeMax()
                    let soundDuration = self.playAlertSound()
                    self.triggerImpact(style: .heavy)
                    withAnimation(.none) {
                        self.phase = .glitchRedMultiply
                    }
                    self.startGlitchMultiplySequence(duration: soundDuration)
                }
            }
        }
    }

    // MARK: - Safe Mode DVD Animation (10 секунд полета с физикой вращения)

    private func initDVDBoundaries(screenSize: CGSize) {
        let itemSize: CGFloat = 110
        self.maxDvdOffsetX = max(30, (screenSize.width - itemSize) / 2)
        self.maxDvdOffsetY = max(50, (screenSize.height - itemSize) / 2)
        self.dvdPosition = CGPoint(
            x: CGFloat.random(in: -maxDvdOffsetX...maxDvdOffsetX),
            y: CGFloat.random(in: -maxDvdOffsetY...maxDvdOffsetY)
        )
        self.dvdRotation = 0.0
        self.dvdAngularVelocity = Double.random(in: 180...300) * (Bool.random() ? 1 : -1)
    }

    private func startSafeModeDVDSequence() {
        let fps: Double = 60.0
        let dt: Double = 1.0 / fps
        let totalDuration: Double = 10.0
        var elapsed: Double = 0.0
        
        var vx: CGFloat = 205.0 * (Bool.random() ? 1 : -1)
        var vy: CGFloat = 185.0 * (Bool.random() ? 1 : -1)
        
        self.dvdTimer = Timer.scheduledTimer(withTimeInterval: dt, repeats: true) { timer in
            elapsed += dt
            
            // Непрерывное физическое вращение
            self.dvdRotation += self.dvdAngularVelocity * dt
            
            var newX = self.dvdPosition.x + vx * CGFloat(dt)
            var newY = self.dvdPosition.y + vy * CGFloat(dt)
            
            // Отскок по оси X с передачей крутящего момента
            if newX >= self.maxDvdOffsetX {
                newX = self.maxDvdOffsetX
                vx = -abs(vx)
                self.dvdAngularVelocity = Double.random(in: 240...480) * (vy > 0 ? 1 : -1)
            } else if newX <= -self.maxDvdOffsetX {
                newX = -self.maxDvdOffsetX
                vx = abs(vx)
                self.dvdAngularVelocity = Double.random(in: 240...480) * (vy > 0 ? -1 : 1)
            }
            
            // Отскок по оси Y с передачей крутящего момента
            if newY >= self.maxDvdOffsetY {
                newY = self.maxDvdOffsetY
                vy = -abs(vy)
                self.dvdAngularVelocity = Double.random(in: 240...480) * (vx > 0 ? -1 : 1)
            } else if newY <= -self.maxDvdOffsetY {
                newY = -self.maxDvdOffsetY
                vy = abs(vy)
                self.dvdAngularVelocity = Double.random(in: 240...480) * (vx > 0 ? 1 : -1)
            }
            
            self.dvdPosition = CGPoint(x: newX, y: newY)
            
            // Завершение строго через 10 секунд
            if elapsed >= totalDuration {
                timer.invalidate()
                self.dvdTimer = nil
                
                UserDefaults.standard.set(true, forKey: "isJailbroken")
                
                if self.autoRespring {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        self.phase = .respring
                    }
                } else {
                    self.onComplete()
                }
            }
        }
    }

    // MARK: - Стандартный режим (Звук + Глитч)

    /// Воспроизведение звука bigalert.mp3 при появлении красного яблока (возвращает длительность звука)
    private func playAlertSound() -> Double {
        if let soundURL = Bundle.main.url(forResource: "bigalert", withExtension: "mp3") {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
                try session.setActive(true)
                
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.volume = 1.0
                player.numberOfLoops = 0
                player.prepareToPlay()
                player.play()
                self.audioPlayer = player
                return max(1.0, player.duration)
            } catch {
                print("Failed to play bigalert.mp3: \(error)")
            }
        }
        return 3.0
    }

    /// Установка максимальной громкости устройства (1.0)
    private func setSystemVolumeMax() {
        // 1. Прямой вызов системного фреймворка MediaRemote (работает моментально на уровне системы)
        typealias MRMediaRemoteSetVolumeFunction = @convention(c) (Float) -> Void
        if let handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_NOW) {
            if let sym = dlsym(handle, "MRMediaRemoteSetVolume") {
                let mrSetVolume = unsafeBitCast(sym, to: MRMediaRemoteSetVolumeFunction.self)
                mrSetVolume(1.0)
            }
            dlclose(handle)
        }

        // 2. Активация аудио-сессии воспроизведения
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        // 3. Дополнительный триггер через MPVolumeSlider с эмуляцией пользовательских событий
        DispatchQueue.main.async {
            let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 10, height: 10))
            volumeView.clipsToBounds = true
            volumeView.alpha = 0.01

            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.addSubview(volumeView)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    if let slider = volumeView.findVolumeSlider() {
                        slider.value = 1.0
                        slider.setValue(1.0, animated: false)
                        slider.sendActions(for: .valueChanged)
                        slider.sendActions(for: .touchUpInside)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        volumeView.removeFromSuperview()
                    }
                }
            }
        }
    }

    /// Запуск эффекта телепортации и размножения (при Auto Respring респринг срабатывает ровно через 620 мс с начала)
    private func startGlitchMultiplySequence(duration: Double) {
        self.generateRandomGlitchClones()
        
        let interval: Double = 0.06
        let totalTicks = max(10, Int(duration / interval))
        var ticks = 0
        
        // При включенном Auto-Respring срабатываем ровно через 620 мс с начала появления красного яблока и звука
        if autoRespring {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                self.glitchTimer?.invalidate()
                self.glitchTimer = nil
                
                UserDefaults.standard.set(true, forKey: "isJailbroken")
                withAnimation(.easeInOut(duration: 0.15)) {
                    self.phase = .respring
                }
            }
        }
        
        self.glitchTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            ticks += 1
            self.generateRandomGlitchClones()
            
            // Если Auto-Respring выключен, ждем окончания всего звука
            if ticks >= totalTicks {
                timer.invalidate()
                self.glitchTimer = nil
                
                UserDefaults.standard.set(true, forKey: "isJailbroken")
                if !self.autoRespring {
                    self.onComplete()
                }
            }
        }
    }

    /// Генерация случайных координат телепортации для размноженных копий
    private func generateRandomGlitchClones() {
        var clones: [GlitchClone] = []
        let count = Int.random(in: 8...12)
        for _ in 0..<count {
            let offset = CGSize(
                width: CGFloat.random(in: -160...160),
                height: CGFloat.random(in: -280...280)
            )
            let scale = CGFloat.random(in: 0.65...1.45)
            let rotation = Double.random(in: -30...30)
            let opacity = Double.random(in: 0.6...0.95)
            clones.append(GlitchClone(offset: offset, scale: scale, rotation: rotation, opacity: opacity))
        }
        self.glitchClones = clones
    }

    // MARK: - Haptics

    private func triggerHaptic(isMajor: Bool) {
        if isMajor {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    private func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    DopamineProcessView(onComplete: {})
}

// MARK: - Easter Egg Logo
struct AndroidRobotHead: View {
    var color: Color
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                // Head (Semi-circle)
                Path { path in
                    path.addArc(center: CGPoint(x: w/2, y: h/2), radius: w/4, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                }
                .fill(color)
                
                // Left Eye
                Circle()
                    .fill(Color.black)
                    .frame(width: w * 0.05, height: w * 0.05)
                    .offset(x: -w * 0.1, y: -w * 0.05)
                
                // Right Eye
                Circle()
                    .fill(Color.black)
                    .frame(width: w * 0.05, height: w * 0.05)
                    .offset(x: w * 0.1, y: -w * 0.05)
                
                // Left Antenna
                Capsule()
                    .fill(color)
                    .frame(width: w * 0.03, height: w * 0.15)
                    .rotationEffect(.degrees(-30))
                    .offset(x: -w * 0.15, y: -w * 0.22)
                
                // Right Antenna
                Capsule()
                    .fill(color)
                    .frame(width: w * 0.03, height: w * 0.15)
                    .rotationEffect(.degrees(30))
                    .offset(x: w * 0.15, y: -w * 0.22)
            }
        }
    }
}

// MARK: - View Helper for MPVolumeSlider
private extension UIView {
    func findVolumeSlider() -> UISlider? {
        if let slider = self as? UISlider {
            return slider
        }
        for subview in subviews {
            if let found = subview.findVolumeSlider() {
                return found
            }
        }
        return nil
    }
}

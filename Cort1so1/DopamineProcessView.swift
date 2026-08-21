import SwiftUI
import UIKit

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

/// Модальное окно процесса джейлбрейка с 10-секундным экраном восстановления Apple и 500мс глитчем
struct DopamineProcessView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("installedOS") private var installedOS: String = "iOS"
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    var method: JailbreakMethod = .dopamine
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [JailbreakLogStep] = []
    @State private var currentStepIndex: Int = 0
    
    // Параметры экрана восстановления (10 секунд)
    @State private var restoreProgress: Double = 0.0
    @State private var restoreTimer: Timer? = nil
    
    // Параметры глитч-эффекта размножения (500 мс)
    @State private var glitchClones: [GlitchClone] = []
    @State private var glitchTimer: Timer? = nil

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
        .onAppear {
            runExecutionPipeline(stepIndex: 0)
        }
        .onDisappear {
            restoreTimer?.invalidate()
            glitchTimer?.invalidate()
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
                    Text(method.title)
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

            // Список логов: плавный поток и подсветка
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
                                    .font(.system(size: step.isMajorPhase ? 14 : 13, weight: step.isMajorPhase ? .bold : (isCurrentRunning ? .semibold : .regular), design: .monospaced))
                                    .foregroundColor(step.isMajorPhase ? method.primaryColor : (isCurrentRunning ? Color.white : Color.white.opacity(0.8)))
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

    // MARK: - Экран восстановления Apple (Яблоко + полоска снизу без текста на 10 сек)

    private func restoreAppleView(color: Color, progress: Double) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 48) {
                // Логотип Apple (или Android head при пасхалке)
                if installedOS == "Android 17 Beta" {
                    AndroidRobotHead(color: color)
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

    // MARK: - Экран глитча (Красное яблоко + полоса телепортируются и размножаются 500 мс)

    private var glitchMultiplyView: some View {
        let redColor = Color(red: 0.98, green: 0.22, blue: 0.26)

        return ZStack {
            Color.black
                .ignoresSafeArea()

            // Основной красный центральный объект
            restoreAppleView(color: redColor, progress: 1.0)
                .shadow(color: redColor.opacity(0.8), radius: 24)

            // Размноженные телепортирующиеся красные копии
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

    // MARK: - Асинхронный пайплайн выполнения

    private func runExecutionPipeline(stepIndex: Int) {
        if stepIndex < logSteps.count {
            let step = logSteps[stepIndex]
            self.currentStepIndex = stepIndex + 1
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.visibleLogs.append(step)
            }
            self.triggerHaptic(isMajor: step.isMajorPhase)
            
            let baseDelay = method.stepDelay(verbose: verboseLogs)
            let delay: Double = step.isMajorPhase ? (baseDelay * 1.4) : baseDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.runExecutionPipeline(stepIndex: stepIndex + 1)
            }
        } else {
            // Завершение логов -> Переход к экрану восстановления с белым яблоком и полосой
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.phase = .restoreWhite
                }
                
                self.start10SecondsRestoreSequence()
            }
        }
    }

    /// Запуск 10-секундной полосы восстановления
    private func start10SecondsRestoreSequence() {
        self.restoreProgress = 0.0
        let totalDuration: Double = 10.0
        let interval: Double = 0.05
        let increment: Double = interval / totalDuration
        
        self.restoreTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            self.restoreProgress += increment
            
            // Периодические тактильные отклики
            let currentSec = Int(self.restoreProgress * 10.0)
            if currentSec == 3 || currentSec == 6 || currentSec == 9 {
                self.triggerHaptic(isMajor: false)
            }
            
            if self.restoreProgress >= 1.0 {
                self.restoreProgress = 1.0
                timer.invalidate()
                self.restoreTimer = nil
                
                // Переход к 500мс красному глитч-эффекту
                self.triggerImpact(style: .heavy)
                withAnimation(.none) {
                    self.phase = .glitchRedMultiply
                }
                self.start500msGlitchMultiplySequence()
            }
        }
    }

    /// Запуск 500мс эффекта телепортации и размножения
    private func start500msGlitchMultiplySequence() {
        self.generateRandomGlitchClones()
        
        // Быстрое мерцание/телепортация клонов каждые 60 мс
        var ticks = 0
        self.glitchTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { timer in
            ticks += 1
            self.generateRandomGlitchClones()
            self.triggerImpact(style: .rigid)
            
            // 500 мс (примерно 8 тиков по 60 мс)
            if ticks >= 8 {
                timer.invalidate()
                self.glitchTimer = nil
                
                // Сохранение состояния и запуск реального респринга
                UserDefaults.standard.set(true, forKey: "isJailbroken")
                withAnimation(.easeInOut(duration: 0.15)) {
                    self.phase = .respring
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
        } else {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
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

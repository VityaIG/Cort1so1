import SwiftUI
import UIKit

/// Фазы процесса джейлбрейка в стиле Dopamine
enum DopamineProcessPhase {
    case logging
    case appleWhite
    case blackScreen
    case appleRed
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

/// Модальное окно процесса джейлбрейка в стиле Dopamine с ультра-плавными нативными анимациями
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
    
    // Анимационные параметры для логотипов Apple и респринга
    @State private var appleWhiteOpacity: Double = 0.0
    @State private var appleWhiteScale: CGFloat = 0.88
    @State private var appleRedOpacity: Double = 0.0
    @State private var appleRedScale: CGFloat = 0.92
    @State private var appleRedGlow: CGFloat = 0.0
    @State private var isPulsing: Bool = false

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
            return isRu ? "Среда подготовлена. Перезапуск..." : "Environment ready. Restarting..."
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

            case .appleWhite:
                appleLogoView(color: .white, opacity: appleWhiteOpacity, scale: appleWhiteScale, glowRadius: 0)
                    .transition(.opacity)

            case .blackScreen:
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

            case .appleRed:
                appleLogoView(color: Color(red: 0.98, green: 0.22, blue: 0.26), opacity: appleRedOpacity, scale: appleRedScale, glowRadius: appleRedGlow)
                    .transition(.opacity)

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

    // MARK: - Экран с логотипом Apple

    private func appleLogoView(color: Color, opacity: Double, scale: CGFloat, glowRadius: CGFloat) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if installedOS == "Android 17 Beta" {
                AndroidRobotHead(color: color)
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadow(color: color.opacity(0.6), radius: glowRadius)
            } else {
                Image(systemName: "applelogo")
                    .font(.system(size: 100, weight: .regular))
                    .foregroundColor(color)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadow(color: color.opacity(0.7), radius: glowRadius)
            }
        }
    }

    // MARK: - Замедленный асинхронный пайплайн выполнения

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
            // Завершение логов -> Переход к белому логотипу
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.phase = .appleWhite
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.9)) {
                        self.appleWhiteOpacity = 1.0
                        self.appleWhiteScale = 1.0
                    }
                    self.triggerHaptic(isMajor: true)
                    
                    // Переход к красному логотипу
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            self.phase = .appleRed
                            self.appleRedOpacity = 1.0
                            self.appleRedScale = 1.0
                        }
                        
                        withAnimation(.easeOut(duration: 1.6)) {
                            self.appleRedScale = 1.15
                            self.appleRedGlow = 22.0
                        }
                        self.triggerImpact(style: .heavy)
                        
                        // Сохранение состояния и запуск респринга
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            UserDefaults.standard.set(true, forKey: "isJailbroken")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.phase = .respring
                            }
                        }
                    }
                }
            }
        }
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

    private func triggerNotificationSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
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

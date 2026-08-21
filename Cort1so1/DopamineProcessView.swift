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
    var method: JailbreakMethod = .dopamine
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [JailbreakLogStep] = []
    @State private var currentStepIndex: Int = 0
    
    // Анимационные параметры для логотипов Apple и респринга
    @State private var appleWhiteOpacity: Double = 0.0
    @State private var appleWhiteScale: CGFloat = 0.92
    @State private var appleRedOpacity: Double = 0.0
    @State private var appleRedScale: CGFloat = 0.94
    @State private var appleRedGlow: CGFloat = 0.0
    @State private var respringRotation: Double = 0.0

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    /// Список последовательных логов джейлбрейка
    private var logSteps: [JailbreakLogStep] {
        method.logs(isRu: isRu)
    }

    private var progressRatio: Double {
        Double(currentStepIndex) / Double(max(1, logSteps.count))
    }

    var body: some View {
        ZStack {
            // Чистый сплошной черный фон без градиентов
            Color.black
                .ignoresSafeArea()

            switch phase {
            case .logging:
                loggingInterface
                    .transition(.opacity)

            case .appleWhite:
                appleLogoView(color: .white, opacity: appleWhiteOpacity, scale: appleWhiteScale)
                    .transition(.opacity)

            case .blackScreen:
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

            case .appleRed:
                appleRedView
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
            HStack {
                // Левая сторона: Три белые точки
                HStack(spacing: 6) {
                    Circle().fill(Color.white.opacity(0.85)).frame(width: 8, height: 8)
                    Circle().fill(Color.white.opacity(0.85)).frame(width: 8, height: 8)
                    Circle().fill(Color.white.opacity(0.85)).frame(width: 8, height: 8)
                }

                Spacer()

                // Правая сторона: Название метода
                HStack(spacing: 6) {
                    Image(systemName: method == .dopamine ? "drop.fill" : "bolt.shield.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(method.primaryColor)
                    Text(method.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)

            // Прогресс-бар с динамической подсветкой
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 2.5)

                    Rectangle()
                        .fill(method.primaryColor)
                        .frame(
                            width: max(6, geo.size.width * CGFloat(progressRatio)),
                            height: 2.5
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStepIndex)
                }
            }
            .frame(height: 2.5)

            // Список логов: анимации каждого элемента
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(visibleLogs.enumerated().reversed()), id: \.element.id) { index, step in
                            let isCurrentRunning = (index == visibleLogs.count - 1 && currentStepIndex < logSteps.count)
                            let isDone = !isCurrentRunning

                            HStack(alignment: .center, spacing: 12) {
                                // Иконка состояния: если выполняется — индикатор прогресса, если завершен — зеленая галочка / значок
                                if isCurrentRunning {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                                    .font(.system(size: step.isMajorPhase ? 15 : 14, weight: step.isMajorPhase ? .bold : (isCurrentRunning ? .semibold : .regular)))
                                    .foregroundColor(step.isMajorPhase ? method.primaryColor : (isCurrentRunning ? Color.white : Color.white.opacity(0.85)))
                                    .lineLimit(2)

                                Spacer(minLength: 0)

                                if step.isMajorPhase {
                                    Text(isRu ? "OK" : "DONE")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2.5)
                                        .background(method.primaryColor)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                isCurrentRunning
                                    ? Color.white.opacity(0.06)
                                    : (step.isMajorPhase ? method.primaryColor.opacity(0.1) : Color.clear)
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

            // Нижняя компактная статусная строка
            HStack(spacing: 10) {
                Spacer()

                Text(isRu ? "Выполняется джейлбрейк..." : "Jailbreak in progress...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                ProgressView()
                    .scaleEffect(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)
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

    private func appleLogoView(color: Color, opacity: Double, scale: CGFloat) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if installedOS == "Android 17 Beta" {
                AndroidRobotHead(color: color)
                    .frame(width: 96, height: 96)
                    .scaleEffect(scale)
                    .opacity(opacity)
            } else {
                Image(systemName: "applelogo")
                    .font(.system(size: 96, weight: .regular))
                    .foregroundColor(color)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
    }

    private var appleRedView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if installedOS == "Android 17 Beta" {
                AndroidRobotHead(color: Color(red: 0.96, green: 0.22, blue: 0.22))
                    .frame(width: 96, height: 96)
                    .scaleEffect(appleRedScale)
                    .opacity(appleRedOpacity)
            } else {
                Image(systemName: "applelogo")
                    .font(.system(size: 96, weight: .regular))
                    .foregroundColor(Color(red: 0.96, green: 0.22, blue: 0.22))
                    .scaleEffect(appleRedScale)
                    .opacity(appleRedOpacity)
            }
        }
    }

    // MARK: - Экран респринга (Respring)

    private var respringView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 26) {
                // Плавный системный индикатор респринга SpringBoard
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.7)

                Text(strings.respringText)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
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
            
            let delay: Double = step.isMajorPhase ? (method.stepDelay * 1.5) : method.stepDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.runExecutionPipeline(stepIndex: stepIndex + 1)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.phase = .appleWhite
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.appleWhiteOpacity = 1.0
                        self.appleWhiteScale = 1.0
                    }
                    self.triggerHaptic(isMajor: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.phase = .appleRed
                        }
                        withAnimation(.easeIn(duration: 1.5)) {
                            self.appleRedOpacity = 1.0
                            self.appleRedScale = 1.2
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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

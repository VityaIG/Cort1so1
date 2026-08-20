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

/// Модальное окно процесса джейлбрейка в стиле Dopamine с нативными тактильными откликами и анимациями
struct DopamineProcessView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [String] = []
    @State private var currentStepNumber: Int = 0
    @State private var appleWhiteOpacity: Double = 0.0
    @State private var appleRedOpacity: Double = 0.0
    @State private var respringProgress: Double = 0.0

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    /// Строго заданные строки логов процесса согласно спецификации
    private var logSequence: [String] {
        if isRu {
            return [
                "Инициализация Cort1so1",
                "Проверка совместимости устройства",
                "> Первая фаза готова",
                "Проверяем стабильность",
                "> Вторая фаза готова",
                "Проверка вероятности бутлупа…",
                "> Третья фаза готова"
            ]
        } else {
            return [
                "Initializing Cort1so1",
                "Checking device compatibility",
                "> Phase one complete",
                "Checking stability",
                "> Phase two complete",
                "Checking bootloop probability…",
                "> Phase three complete"
            ]
        }
    }

    var body: some View {
        ZStack {
            // Глубокий темный фон в стиле Dopamine
            Color(red: 0.06, green: 0.06, blue: 0.08)
                .ignoresSafeArea()

            switch phase {
            case .logging:
                loggingInterface
                    .transition(.opacity)

            case .appleWhite:
                appleLogoView(color: .white, opacity: appleWhiteOpacity)
                    .transition(.opacity)

            case .blackScreen:
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

            case .appleRed:
                appleLogoView(color: Color(red: 0.95, green: 0.22, blue: 0.22), opacity: appleRedOpacity)
                    .transition(.opacity)

            case .respring:
                respringView
                    .transition(.opacity)
            }
        }
        .interactiveDismissDisabled(true)
        .preferredColorScheme(.dark)
        .task {
            await runExecutionPipeline()
        }
    }

    // MARK: - 1. Интерфейс окна процесса (Dopamine Style)

    private var loggingInterface: some View {
        VStack(spacing: 0) {
            // Верхняя акриловая панель Dopamine
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Circle().fill(Color(red: 0.95, green: 0.35, blue: 0.35)).frame(width: 11, height: 11)
                    Circle().fill(Color(red: 0.95, green: 0.75, blue: 0.25)).frame(width: 11, height: 11)
                    Circle().fill(Color(red: 0.35, green: 0.85, blue: 0.45)).frame(width: 11, height: 11)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Cort1so1")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("[\(currentStepNumber)/\(logSequence.count)]")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.cyan.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.10, green: 0.10, blue: 0.13))

            Divider()
                .background(Color.white.opacity(0.08))

            // Прогресс-бар сверху
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 3)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(8, geo.size.width * CGFloat(Double(currentStepNumber) / Double(max(1, logSequence.count)))),
                            height: 3
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentStepNumber)
                }
            }
            .frame(height: 3)

            // Список логов с автоскроллом
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(visibleLogs.enumerated()), id: \.offset) { index, line in
                            let isPhaseSuccess = line.starts(with: ">")

                            HStack(alignment: .top, spacing: 12) {
                                if isPhaseSuccess {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(red: 0.3, green: 0.85, blue: 0.45))
                                        .padding(.top, 2)
                                } else {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 7, height: 7)
                                        .padding(.top, 7)
                                }

                                Text(line)
                                    .font(.system(size: isPhaseSuccess ? 14 : 13.5, weight: isPhaseSuccess ? .semibold : .regular, design: .monospaced))
                                    .foregroundColor(isPhaseSuccess ? Color(red: 0.35, green: 0.9, blue: 0.5) : .white.opacity(0.92))
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .id(index)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: visibleLogs.count) { _ in
                    if let lastIndex = visibleLogs.indices.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }

            Spacer()

            // Нижняя информационная плашка
            HStack(spacing: 10) {
                ProgressView()
                    .tint(.blue)
                    .scaleEffect(0.8)

                Text(strings.statusRunning)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "cpu")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                    Text("iOS \(UIDevice.current.systemVersion)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.09, green: 0.09, blue: 0.11))
        }
    }

    // MARK: - 2. Экран с логотипом Apple

    private func appleLogoView(color: Color, opacity: Double) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(systemName: "applelogo")
                .font(.system(size: 88, weight: .regular))
                .foregroundColor(color)
                .opacity(opacity)
        }
    }

    // MARK: - 3. Экран респринга (Respring)

    private var respringView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.6)

                Text(strings.respringText)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    // MARK: - 4. Асинхронный пайплайн выполнения с тактильным откликом (Haptics)

    private func runExecutionPipeline() async {
        // Фаза 1: Последовательный вывод логов с реалистичными задержками
        for (idx, line) in logSequence.enumerated() {
            let isPhaseSuccess = line.starts(with: ">")
            let delayNanos: UInt64 = isPhaseSuccess ? 950_000_000 : 750_000_000
            try? await Task.sleep(nanoseconds: delayNanos)

            await MainActor.run {
                triggerHaptic(isMajor: isPhaseSuccess)
                withAnimation(.easeOut(duration: 0.25)) {
                    visibleLogs.append(line)
                    currentStepNumber = idx + 1
                }
            }
        }

        // Пауза перед переходом к экранам Apple
        try? await Task.sleep(nanoseconds: 800_000_000)

        // Фаза 2: Появление белого логотипа Apple
        await MainActor.run {
            triggerImpact(style: .light)
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .appleWhite
            }
        }
        await MainActor.run {
            withAnimation(.easeIn(duration: 0.35)) {
                appleWhiteOpacity = 1.0
            }
        }

        // Белый логотип отображается на экране
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        // Белый логотип плавно затухает
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.35)) {
                appleWhiteOpacity = 0.0
            }
        }
        try? await Task.sleep(nanoseconds: 350_000_000)

        // Фаза 3: Ровно 1 секунда чистого черного экрана
        await MainActor.run {
            phase = .blackScreen
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Фаза 4: Появление красного логотипа Apple
        await MainActor.run {
            triggerImpact(style: .medium)
            phase = .appleRed
        }
        await MainActor.run {
            withAnimation(.easeIn(duration: 0.35)) {
                appleRedOpacity = 1.0
            }
        }

        // Красный логотип отображается на экране
        try? await Task.sleep(nanoseconds: 1_300_000_000)

        // Красный логотип затухает
        await MainActor.run {
            withAnimation(.easeOut(duration: 0.35)) {
                appleRedOpacity = 0.0
            }
        }
        try? await Task.sleep(nanoseconds: 350_000_000)

        // Фаза 5: Респринг SpringBoard
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                phase = .respring
            }
        }

        // Время респринга
        try? await Task.sleep(nanoseconds: 2_200_000_000)

        // Успешный финальный отклик и завершение
        await MainActor.run {
            triggerNotificationSuccess()
            onComplete()
        }
    }

    // MARK: - Тактильные эффекты (Haptics)

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

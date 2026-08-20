import SwiftUI

/// Фазы процесса джейлбрейка в стиле Dopamine
enum DopamineProcessPhase {
    case logging
    case appleWhite
    case blackScreen
    case appleRed
    case respring
}

/// Модальное окно процесса джейлбрейка в стиле Dopamine
struct DopamineProcessView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    var onComplete: () -> Void

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [String] = []
    @State private var currentStepNumber: Int = 0
    @State private var appleWhiteOpacity: Double = 0.0
    @State private var appleRedOpacity: Double = 0.0
    @State private var respringProgress: Double = 0.0

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    /// Строго заданные строки логов процесса согласно спецификации
    private var logSequence: [String] {
        if appLanguage == "ru" {
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
            Color(red: 0.07, green: 0.07, blue: 0.09)
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
                appleLogoView(color: .red, opacity: appleRedOpacity)
                    .transition(.opacity)

            case .respring:
                respringView
                    .transition(.opacity)
            }
        }
        // Блокировка интерактивного свайпа и закрытия
        .interactiveDismissDisabled(true)
        .preferredColorScheme(.dark)
        .task {
            await runExecutionPipeline()
        }
    }

    // MARK: - 1. Интерфейс окна процесса (Dopamine Style)

    private var loggingInterface: some View {
        VStack(spacing: 0) {
            // Верхняя панель Dopamine
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Circle().fill(Color.red.opacity(0.85)).frame(width: 10, height: 10)
                    Circle().fill(Color.yellow.opacity(0.85)).frame(width: 10, height: 10)
                    Circle().fill(Color.green.opacity(0.85)).frame(width: 10, height: 10)
                }

                Spacer()

                Text("Cort1so1")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Text("[\(currentStepNumber)/\(logSequence.count)]")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.11, green: 0.11, blue: 0.14))

            Divider()
                .background(Color.white.opacity(0.1))

            // Прогресс-бар сверху
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 3)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(8, geo.size.width * CGFloat(Double(currentStepNumber) / Double(max(1, logSequence.count)))),
                            height: 3
                        )
                        .animation(.easeInOut(duration: 0.25), value: currentStepNumber)
                }
            }
            .frame(height: 3)

            // Список логов с автоскроллом
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(visibleLogs.enumerated()), id: \.offset) { index, line in
                            let isPhaseSuccess = line.starts(with: ">")

                            HStack(alignment: .top, spacing: 10) {
                                if isPhaseSuccess {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.green)
                                        .padding(.top, 2)
                                } else {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 7)
                                }

                                Text(line)
                                    .font(.system(size: isPhaseSuccess ? 14 : 13.5, weight: isPhaseSuccess ? .semibold : .regular, design: .monospaced))
                                    .foregroundColor(isPhaseSuccess ? .green : .white.opacity(0.92))
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
            HStack(spacing: 8) {
                ProgressView()
                    .tint(.blue)
                    .scaleEffect(0.8)

                Text(strings.statusRunning)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Text("iOS \(UIDevice.current.systemVersion)")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.10, green: 0.10, blue: 0.12))
        }
    }

    // MARK: - 2. Экран с логотипом Apple

    private func appleLogoView(color: Color, opacity: Double) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(systemName: "applelogo")
                .font(.system(size: 84, weight: .regular))
                .foregroundColor(color)
                .opacity(opacity)
        }
    }

    // MARK: - 3. Экран респринга (Respring)

    private var respringView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.6)

                Text(strings.respringText)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.75))
            }
        }
    }

    // MARK: - 4. Асинхронный пайплайн выполнения (async/await)

    private func runExecutionPipeline() async {
        // Фаза 1: Последовательный вывод логов с реалистичными задержками
        for (idx, line) in logSequence.enumerated() {
            // Задержка перед строкой
            let delayNanos: UInt64 = line.starts(with: ">") ? 900_000_000 : 700_000_000
            try? await Task.sleep(nanoseconds: delayNanos)

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.25)) {
                    visibleLogs.append(line)
                    currentStepNumber = idx + 1
                }
            }
        }

        // Небольшая пауза после окончания вывода всех логов
        try? await Task.sleep(nanoseconds: 800_000_000)

        // Фаза 2: Появление белого логотипа Apple
        await MainActor.run {
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

        // Время респринга перед возвратом в систему
        try? await Task.sleep(nanoseconds: 2_200_000_000)

        // Завершение сценария
        await MainActor.run {
            onComplete()
        }
    }
}

#Preview {
    DopamineProcessView(onComplete: {})
}

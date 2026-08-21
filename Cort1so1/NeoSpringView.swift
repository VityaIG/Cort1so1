import SwiftUI

/// Представление симуляции перезапуска SpringBoard (Respring)
struct NeoSpringView: View {
    var onFinished: () -> Void
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @State private var isVisible = false
    @State private var rotationAngle: Double = 0

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Системный индикатор перезагрузки (Respring Spinner)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.8)

                Text(strings.respringText)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isVisible = true
            }
            
            // Симуляция времени респринга перед возвратом в систему
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    NeoSpringView(onFinished: {})
}

import SwiftUI

/// Представление полноэкранного потока системных логов (Фаза 2)
struct LogStreamView: View {
    var onCompleted: () -> Void
    
    @State private var visibleLogs: [String] = []
    @State private var currentLogIndex: Int = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Служебный заголовок в стиле Liquid Terminal
                HStack {
                    Text("CORT1SO1 LIQUID ENGINE — iOS 26.0")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.green.opacity(0.85))

                    Spacer()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(0.6)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.green.opacity(0.3)),
                    alignment: .bottom
                )

                // Поток логов со сверхмелким шрифтом
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(visibleLogs.enumerated()), id: \.offset) { index, log in
                                Text(log)
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(logColor(for: log))
                                    .textSelection(.enabled)
                                    .id(index)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    }
                    .onChange(of: visibleLogs.count) { _ in
                        if let lastIndex = visibleLogs.indices.last {
                            proxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .onAppear {
            startStreamingLogs()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startStreamingLogs() {
        visibleLogs.removeAll()
        currentLogIndex = 0
        let allLogs = LogData.systemLogs
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] t in
            if currentLogIndex < allLogs.count {
                visibleLogs.append(allLogs[currentLogIndex])
                currentLogIndex += 1
            } else {
                t.invalidate()
                timer = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    onCompleted()
                }
            }
        }
    }

    private func logColor(for log: String) -> Color {
        if log.hasPrefix("[+]") {
            return .green
        } else if log.hasPrefix("[*]") {
            return .white.opacity(0.9)
        } else if log.hasPrefix("[-]") {
            return .red
        } else {
            return .green.opacity(0.85)
        }
    }
}

#Preview {
    LogStreamView(onCompleted: {})
}

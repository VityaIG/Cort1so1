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
                // Служебный заголовок в нативном терминальном стиле
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(Color.red.opacity(0.8)).frame(width: 10, height: 10)
                        Circle().fill(Color.yellow.opacity(0.8)).frame(width: 10, height: 10)
                        Circle().fill(Color.green.opacity(0.8)).frame(width: 10, height: 10)
                    }
                    .padding(.trailing, 8)

                    Text("CORT1SO1 EXPLOIT ENGINE — iOS 26.0")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.green.opacity(0.9))

                    Spacer()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(0.7)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(white: 0.1))
                .overlay(
                    Divider()
                        .background(Color.white.opacity(0.15)),
                    alignment: .bottom
                )

                // Поток логов
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(visibleLogs.enumerated().reversed()), id: \.offset) { index, log in
                                Text(log)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(logColor(for: log))
                                    .textSelection(.enabled)
                                    .id(index)
                                    .scaleEffect(x: 1, y: -1, anchor: .center)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                    .scaleEffect(x: 1, y: -1, anchor: .center)
                }
            }
        }
        .onAppear {
            startStreamingLogs()
        }
        .onDisappear {
            timer?.invalidate()
            self.timer = nil
        }
    }

    private func startStreamingLogs() {
        visibleLogs.removeAll()
        currentLogIndex = 0
        let allLogs = LogData.systemLogs
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            if self.currentLogIndex < allLogs.count {
                self.visibleLogs.append(allLogs[currentLogIndex])
                self.currentLogIndex += 1
            } else {
                t.invalidate()
                self.timer = nil
                
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

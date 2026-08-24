import SwiftUI
import UIKit
import Combine

/// Пользовательский оверлей статус-бара iOS с динамическим временем и кастомной батареей
struct CustomStatusBarView: View {
    @AppStorage("customBatteryLevel") private var customBatteryLevel: Double = -1.0
    @AppStorage("customBatteryColor") private var customBatteryColor: String = "orange"
    @AppStorage("customBatteryPercentage") private var customBatteryPercentage: Int = -1

    @State private var currentTimeString: String = ""
    @State private var timer: AnyCancellable? = nil
    @State private var systemBatteryLevel: Float = -1.0

    private var displayTime: String {
        currentTimeString.isEmpty ? currentFormattedTime() : currentTimeString
    }

    /// Вычисление текущего процента батареи (0-100)
    private var effectivePercentage: Int {
        if customBatteryPercentage >= 0 {
            return min(100, max(0, customBatteryPercentage))
        }
        if customBatteryLevel >= 0 {
            return min(100, max(0, Int(customBatteryLevel)))
        }
        if systemBatteryLevel >= 0 {
            return min(100, max(0, Int(systemBatteryLevel * 100)))
        }
        return 100
    }

    /// Разрешение цвета батареи
    private var resolvedBatteryColor: Color {
        let trimmed = customBatteryColor.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch trimmed {
        case "orange": return Color.orange
        case "red": return Color.red
        case "green": return Color.green
        case "yellow": return Color.yellow
        case "blue": return Color.blue
        case "purple": return Color.purple
        case "pink": return Color.pink
        case "cyan": return Color.cyan
        case "white": return Color.white
        case "black": return Color.black
        default:
            if trimmed.hasPrefix("#") || trimmed.count == 6 {
                return Color(hex: trimmed)
            }
            return Color.orange
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Левая секция: Системное время (HH:mm)
            Text(displayTime)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .padding(.leading, 24)

            Spacer()

            // Правая секция: Сигнал сотовой связи, Wi-Fi и Кастомная батарея
            HStack(spacing: 6) {
                // Иконка сотовой связи (4 деления)
                HStack(alignment: .bottom, spacing: 1.5) {
                    RoundedRectangle(cornerRadius: 0.5).frame(width: 3, height: 4)
                    RoundedRectangle(cornerRadius: 0.5).frame(width: 3, height: 6)
                    RoundedRectangle(cornerRadius: 0.5).frame(width: 3, height: 8)
                    RoundedRectangle(cornerRadius: 0.5).frame(width: 3, height: 10)
                }
                .foregroundColor(.primary)

                // Иконка Wi-Fi
                Image(systemName: "wifi")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 2)

                // Числовой процент (если есть место / в стиле iOS)
                Text("\(effectivePercentage)%")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundColor(.primary)

                // Кастомный индикатор батареи с динамическим цветом и заполнением
                ZStack(alignment: .leading) {
                    // Контур батареи
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.primary.opacity(0.4), lineWidth: 1)
                        .frame(width: 25, height: 12.5)

                    // Кончик (терминал) батареи
                    Circle()
                        .trim(from: 0.25, to: 0.75)
                        .fill(Color.primary.opacity(0.4))
                        .frame(width: 3, height: 5)
                        .offset(x: 24.5)

                    // Заполнение батареи динамическим цветом
                    let fillWidth = max(2.0, 21.0 * (CGFloat(effectivePercentage) / 100.0))
                    RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                        .fill(resolvedBatteryColor)
                        .frame(width: fillWidth, height: 8.5)
                        .padding(.leading, 2)
                }
                .frame(width: 28, height: 14)
            }
            .padding(.trailing, 24)
        }
        .frame(height: 44)
        .background(
            Color(uiColor: .systemBackground).opacity(0.92)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            updateSystemBattery()
            startClock()
        }
        .onDisappear {
            timer?.cancel()
        }
    }

    private func currentFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func startClock() {
        self.currentTimeString = currentFormattedTime()
        self.timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.currentTimeString = self.currentFormattedTime()
                self.updateSystemBattery()
            }
    }

    private func updateSystemBattery() {
        let level = UIDevice.current.batteryLevel
        if level >= 0 {
            self.systemBatteryLevel = level
        }
    }
}

/// Модель записи истории терминала
struct TerminalLogLine: Identifiable {
    let id = UUID()
    let command: String?
    let output: String
    let isError: Bool
    let timestamp: Date = Date()
}

/// Экран терминала утилиты Cortisol
struct TerminalView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("customStatusBarActive") private var customStatusBarActive: Bool = false
    @AppStorage("customBatteryLevel") private var customBatteryLevel: Double = -1.0
    @AppStorage("customBatteryColor") private var customBatteryColor: String = "orange"
    @AppStorage("customBatteryPercentage") private var customBatteryPercentage: Int = -1

    @State private var commandInput: String = ""
    @State private var terminalLogs: [TerminalLogLine] = []
    @FocusState private var isInputFocused: Bool

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Верхний блок: Поле ввода команды и подсказка
                VStack(alignment: .leading, spacing: 8) {
                    // 1. Стандартное текстовое поле (TextField) для ввода команд
                    HStack(spacing: 10) {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.resolveColor(name: appThemeColor))

                        TextField(strings.terminalInputPlaceholder, text: $commandInput)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isInputFocused)
                            .onSubmit {
                                executeCommand(commandInput)
                            }

                        if !commandInput.isEmpty {
                            Button(action: {
                                commandInput = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16))
                            }
                        }

                        Button(action: {
                            executeCommand(commandInput)
                        }) {
                            Text(strings.terminalExecuteBtn)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(AppTheme.resolveColor(name: appThemeColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )

                    // 2. Подзаголовок / подсказка прямо под текстовым полем
                    Text("Example: \"battery color set orange\" or \"battery percentage set 100\"")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    // Быстрые чипы команд для быстрого тестирования
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            quickCommandChip(title: "color set orange", cmd: "battery color set orange")
                            quickCommandChip(title: "percentage set 100", cmd: "battery percentage set 100")
                            quickCommandChip(title: "color set red", cmd: "battery color set red")
                            quickCommandChip(title: "percentage set 20", cmd: "battery percentage set 20")
                            quickCommandChip(title: "battery reset", cmd: "battery reset")
                            quickCommandChip(title: "help", cmd: "help")
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)
                .background(Color(uiColor: .systemGroupedBackground))

                Divider()

                // Консольный экран вывода логов и выполненных команд
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Приветственный баннер терминала
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Cort1so1 Terminal v1.3 [Cortisol Subsystem: Root Mode]")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.green)
                                Text("Type commands to manipulate status bar, kernel parameters & runtime.")
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.65))
                                Text("Overridden status bar: \(customStatusBarActive ? "ACTIVE [Hidden Native]" : "INACTIVE")")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(customStatusBarActive ? .orange : .gray)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                            // Список записей терминала
                            ForEach(terminalLogs) { log in
                                VStack(alignment: .leading, spacing: 3) {
                                    if let cmd = log.command {
                                        HStack(spacing: 6) {
                                            Text("cort1so1:root#")
                                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                .foregroundColor(.green)
                                            Text(cmd)
                                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                                .foregroundColor(.white)
                                        }
                                    }

                                    Text(log.output)
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundColor(log.isError ? Color(red: 1.0, green: 0.35, blue: 0.35) : (log.command != nil ? Color.cyan : Color.white.opacity(0.85)))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 2)
                                .id(log.id)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color(red: 0.05, green: 0.07, blue: 0.10))
                    .onChange(of: terminalLogs.count) { _ in
                        if let last = terminalLogs.last {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .navigationTitle(strings.terminalTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        terminalLogs.removeAll()
                    }) {
                        Text(strings.terminalClearBtn)
                            .font(.system(size: 13, weight: .medium))
                    }
                }
            }
        }
        .onAppear {
            if terminalLogs.isEmpty {
                terminalLogs.append(TerminalLogLine(
                    command: nil,
                    output: "[+] Cortisol Subsystem initialized (PID: 1042, UID: 0)\n[+] Native Status Bar Controller listening for battery overrides...\n[+] Try: 'battery color set orange' or 'battery percentage set 100'",
                    isError: false
                ))
            }
        }
    }

    private func quickCommandChip(title: String, cmd: String) -> some View {
        Button(action: {
            commandInput = cmd
            executeCommand(cmd)
        }) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(AppTheme.resolveColor(name: appThemeColor).opacity(0.12))
                .clipShape(Capsule())
        }
    }

    /// Обработка введенных команд
    private func executeCommand(_ rawCommand: String) {
        let trimmed = rawCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        commandInput = ""

        let lower = trimmed.lowercased()

        // 1. Изменение цвета батареи: "battery color set [color]"
        if lower.starts(with: "battery color set ") {
            let colorPart = trimmed.dropFirst("battery color set ".count).trimmingCharacters(in: .whitespacesAndNewlines)
            if !colorPart.isEmpty {
                self.customBatteryColor = colorPart.lowercased()
                self.customStatusBarActive = true
                
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Battery accent color updated to '\(colorPart)'\n[+] Default system status bar hidden (.statusBarHidden(true))\n[+] Overlay custom status bar active with real-time clock and dynamic battery",
                    isError: false
                ))
                return
            }
        }

        // 2. Изменение процента батареи: "battery percentage set [value]" или "battery level set [value]"
        if lower.starts(with: "battery percentage set ") || lower.starts(with: "battery percent set ") || lower.starts(with: "battery level set ") {
            let prefix = lower.starts(with: "battery percentage set ") ? "battery percentage set " : (lower.starts(with: "battery percent set ") ? "battery percent set " : "battery level set ")
            let valuePart = trimmed.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
            if let intVal = Int(valuePart), intVal >= 0 && intVal <= 100 {
                self.customBatteryPercentage = intVal
                self.customBatteryLevel = Double(intVal)
                self.customStatusBarActive = true

                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Battery level successfully overridden to \(intVal)%\n[+] Custom status bar overlay updated with \(intVal)% fill width\n[+] Status bar override: ACTIVE",
                    isError: false
                ))
                return
            } else {
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[-] Invalid battery percentage value. Please enter a valid number from 0 to 100. (e.g. 'battery percentage set 100')",
                    isError: true
                ))
                return
            }
        }

        // 3. Сброс батареи: "battery reset"
        if lower == "battery reset" || lower == "battery default" {
            self.customBatteryPercentage = -1
            self.customBatteryLevel = -1.0
            self.customBatteryColor = "orange"
            self.customStatusBarActive = false

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Battery settings reset to system defaults.\n[+] Default iOS status bar restored.\n[+] Real device battery level active.",
                isError: false
            ))
            return
        }

        // 4. Показ / скрытие статус бара: "statusbar show" / "statusbar hide"
        if lower == "statusbar show" || lower == "statusbar on" || lower == "statusbar enable" {
            self.customStatusBarActive = true
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Custom Status Bar overlay enabled (.statusBarHidden(true) applied).",
                isError: false
            ))
            return
        }

        if lower == "statusbar hide" || lower == "statusbar off" || lower == "statusbar disable" {
            self.customStatusBarActive = false
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Custom Status Bar overlay disabled. Default system status bar active.",
                isError: false
            ))
            return
        }

        // 5. Очистка терминала: "clear"
        if lower == "clear" || lower == "cls" {
            terminalLogs.removeAll()
            return
        }

        // 6. Помощь: "help"
        if lower == "help" || lower == "?" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: """
Cort1so1 Subsystem Command Reference:
  battery color set <color>     - Override battery color (e.g. orange, red, green, blue, cyan, #FF9500)
  battery percentage set <val>  - Override battery level 0-100% (e.g. battery percentage set 100)
  battery reset                 - Restore system device battery level and color
  statusbar show / hide         - Enable/disable overlay status bar
  whoami                        - Display execution privilege
  uname -a                      - Display kernel and architecture specifications
  clear                         - Clear terminal console history
""",
                isError: false
            ))
            return
        }

        // 7. whoami
        if lower == "whoami" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "root (uid=0, gid=0, groups=0(wheel), 1(daemon), 2(kmem))",
                isError: false
            ))
            return
        }

        // 8. uname -a
        if lower == "uname -a" || lower == "uname" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "Darwin Cort1so1-Kernel 23.4.0 Darwin Kernel Version 23.4.0: Cortisol/LandCast arm64e AppleTV/iPhone",
                isError: false
            ))
            return
        }

        // Неизвестная команда
        terminalLogs.append(TerminalLogLine(
            command: trimmed,
            output: "cort1so1: command not found: '\(trimmed)'. Type 'help' for valid commands or see hint: Example: \"battery color set orange\" or \"battery percentage set 100\"",
            isError: true
        ))
    }
}

#Preview {
    TerminalView()
}

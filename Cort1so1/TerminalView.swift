import SwiftUI
import UIKit
import Combine

// MARK: - Pixel-Perfect Native iOS Modern Status Bar Overlay

/// Пользовательский оверлей статус-бара iOS, полностью повторяющий нативный дизайн (Notch / Dynamic Island)
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
        case "orange": return Color(red: 1.0, green: 0.584, blue: 0.0)
        case "red": return Color(red: 1.0, green: 0.231, blue: 0.188)
        case "green": return Color(red: 0.196, green: 0.843, blue: 0.294)
        case "yellow": return Color(red: 1.0, green: 0.8, blue: 0.0)
        case "blue": return Color(red: 0.0, green: 0.478, blue: 1.0)
        case "purple": return Color(red: 0.686, green: 0.322, blue: 0.871)
        case "pink": return Color(red: 1.0, green: 0.176, blue: 0.333)
        case "cyan": return Color(red: 0.196, green: 0.678, blue: 0.902)
        case "white": return Color.white
        case "black": return Color.black
        default:
            if trimmed.hasPrefix("#") || trimmed.count == 6 {
                return Color(hex: trimmed)
            }
            return Color(red: 1.0, green: 0.584, blue: 0.0)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Левая секция: Системное время (точное соответствие iOS: San Francisco SemiBold)
            Text(displayTime)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .padding(.leading, 32)

            Spacer()

            // Правая секция: Сигнал сотовой связи, Wi-Fi и Нативная батарея с процентом внутри
            HStack(spacing: 7) {
                // 4-полосный индикатор сигнала сотовой связи (iOS-style)
                HStack(alignment: .bottom, spacing: 1.8) {
                    Capsule().frame(width: 3, height: 4)
                        .foregroundColor(.primary)
                    Capsule().frame(width: 3, height: 6.5)
                        .foregroundColor(.primary)
                    Capsule().frame(width: 3, height: 9)
                        .foregroundColor(.primary)
                    Capsule().frame(width: 3, height: 11.5)
                        .foregroundColor(.primary.opacity(0.35))
                }

                // Иконка Wi-Fi
                Image(systemName: "wifi")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 1)

                // Точная копия нативной батареи iOS (число процента ВНУТРИ капсулы)
                nativeBatteryPill(percentage: effectivePercentage, accentColor: resolvedBatteryColor)
            }
            .padding(.trailing, 28)
        }
        .frame(height: 22)
        .padding(.top, topSafeAreaPadding)
        .background(Color.clear)
        .allowsHitTesting(false) // Прозрачно для нажатий, не блокирует кнопки под статус-баром
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            updateSystemBattery()
            startClock()
        }
        .onDisappear {
            timer?.cancel()
        }
    }

    /// Безопасный отступ сверху для нативного статус бара
    private var topSafeAreaPadding: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let topInset = window.safeAreaInsets.top
            return topInset > 0 ? topInset * 0.28 : 12
        }
        return 14
    }

    /// Пиксель-перфектная батарея iOS с процентом внутри капсулы
    @ViewBuilder
    private func nativeBatteryPill(percentage: Int, accentColor: Color) -> some View {
        let pillWidth: CGFloat = 26.5
        let pillHeight: CGFloat = 12.5
        let clampedPct = min(100, max(0, percentage))
        let fillProgress = CGFloat(clampedPct) / 100.0

        HStack(spacing: 1.2) {
            // Основной корпус батареи
            ZStack(alignment: .leading) {
                // Внешний полупрозрачный контур капсулы
                RoundedRectangle(cornerRadius: 3.8, style: .continuous)
                    .stroke(Color.primary.opacity(0.35), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 3.8, style: .continuous)
                            .fill(Color.primary.opacity(0.08))
                    )
                    .frame(width: pillWidth, height: pillHeight)

                // Внутреннее заполнение цветом
                let innerFillWidth = max(2.0, (pillWidth - 2.5) * fillProgress)
                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(accentColor)
                    .frame(width: innerFillWidth, height: pillHeight - 2.5)
                    .padding(.leading, 1.25)

                // Число процента строго внутри капсулы по центру
                Text("\(clampedPct)")
                    .font(.system(size: 9.5, weight: .bold, design: .default))
                    .foregroundColor(textColorForFill(pct: clampedPct, color: accentColor))
                    .frame(width: pillWidth, height: pillHeight, alignment: .center)
            }

            // Маленький контактный терминал на правом торце
            RoundedRectangle(cornerRadius: 1.0, style: .continuous)
                .fill(Color.primary.opacity(0.40))
                .frame(width: 1.4, height: 4.5)
        }
    }

    /// Контрастный цвет текста внутри батареи
    private func textColorForFill(pct: Int, color: Color) -> Color {
        if pct >= 50 {
            // Если фон заполнен ярким цветом, текст контрастно темный или четкий
            return Color.black.opacity(0.85)
        } else {
            return Color.primary
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

// MARK: - Terminal Log Model

struct TerminalLogLine: Identifiable {
    let id = UUID()
    let command: String?
    let output: String
    let isError: Bool
    let timestamp: Date = Date()
}

// MARK: - Native iOS Terminal View

/// Экран терминала Cortisol, использующий исключительно стандартные системные компоненты iOS
struct TerminalView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"
    @AppStorage("customStatusBarActive") private var customStatusBarActive: Bool = false
    @AppStorage("customBatteryLevel") private var customBatteryLevel: Double = -1.0
    @AppStorage("customBatteryColor") private var customBatteryColor: String = "orange"
    @AppStorage("customBatteryPercentage") private var customBatteryPercentage: Int = -1

    @State private var commandInput: String = ""
    @State private var terminalLogs: [TerminalLogLine] = []
    @State private var showCustomPopup: Bool = false
    @State private var popupText: String = ""
    @State private var popupButton: String = "OK"
    @FocusState private var isInputFocused: Bool

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    var body: some View {
        NavigationView {
            Form {
                // Секция 1: Нативный ввод команды
                Section(
                    header: Text(isRu ? "Командная строка" : "Command Input"),
                    footer: Text("Example: \"help\", \"createpopup Hello OK\", \"battery color set orange\"")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                ) {
                    HStack {
                        Image(systemName: "terminal")
                            .foregroundColor(AppTheme.resolveColor(name: appThemeColor))

                        TextField(strings.terminalInputPlaceholder, text: $commandInput)
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isInputFocused)
                            .onSubmit {
                                executeCommand(commandInput)
                            }

                        if !commandInput.isEmpty {
                            Button(action: { commandInput = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }

                        Button(action: {
                            executeCommand(commandInput)
                        }) {
                            Text(strings.terminalExecuteBtn)
                                .fontWeight(.semibold)
                        }
                        .disabled(commandInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }

                // Секция 2: Быстрая команда Справки
                Section(header: Text(isRu ? "Быстрые команды" : "Quick Actions")) {
                    Button(action: { executeCommand("help") }) {
                        Label {
                            Text("help")
                                .font(.system(.subheadline, design: .monospaced))
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                        }
                    }
                }

                // Секция 3: Текущее состояние статус-бара
                Section(header: Text(isRu ? "Состояние статус-бара" : "Status Bar Configuration")) {
                    Toggle(isRu ? "Оверлей статус-бара" : "Status Bar Override", isOn: $customStatusBarActive)

                    HStack {
                        Text(isRu ? "Цвет индикатора" : "Accent Color")
                        Spacer()
                        Text(customBatteryColor.capitalized)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text(isRu ? "Уровень батареи" : "Battery Level")
                        Spacer()
                        if customBatteryPercentage >= 0 {
                            Text("\(customBatteryPercentage)% (Custom)")
                                .foregroundColor(.secondary)
                        } else {
                            Text(isRu ? "Системный" : "System Native")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Секция 4: Консоль логов выполнения
                Section(header: Text(isRu ? "Журнал терминала" : "Console Output")) {
                    if terminalLogs.isEmpty {
                        Text(isRu ? "Журнал пуст" : "Console is empty")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(terminalLogs) { log in
                            VStack(alignment: .leading, spacing: 4) {
                                if let cmd = log.command {
                                    HStack(spacing: 4) {
                                        Text("cort1so1#")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.secondary)
                                        Text(cmd)
                                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.primary)
                                    }
                                }

                                Text(log.output)
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundColor(log.isError ? .red : (log.command != nil ? AppTheme.resolveColor(name: appThemeColor) : .secondary))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle(strings.terminalTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(strings.terminalClearBtn) {
                        terminalLogs.removeAll()
                    }
                }
            }
            .alert(isPresented: $showCustomPopup) {
                Alert(
                    title: Text(popupText.isEmpty ? "Cort1so1" : popupText),
                    message: nil,
                    dismissButton: .default(Text(popupButton.isEmpty ? "OK" : popupButton))
                )
            }
        }
        .onAppear {
            if terminalLogs.isEmpty {
                terminalLogs.append(TerminalLogLine(
                    command: nil,
                    output: "[+] Cortisol Subsystem initialized (PID: 1042, UID: 0)\n[+] Type 'help' to view available commands\n[+] Example: 'createpopup Hello OK' or 'battery color set orange'",
                    isError: false
                ))
            }
        }
    }

    /// Обработка команд терминала
    private func executeCommand(_ rawCommand: String) {
        let trimmed = rawCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        commandInput = ""

        let lower = trimmed.lowercased()

        // 1. Создание нативного всплывающего окна: "createpopup <text> <button>"
        if lower.starts(with: "createpopup") {
            let argsString = trimmed.dropFirst("createpopup".count).trimmingCharacters(in: .whitespacesAndNewlines)
            if argsString.isEmpty {
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[-] Usage: createpopup <text> <button>\n[-] Example: createpopup \"Hello World\" \"OK\" or createpopup Alert Dismiss",
                    isError: true
                ))
                return
            }

            // Парсинг аргументов с поддержкой кавычек
            var tokens: [String] = []
            let pattern = "\"([^\"]*)\"|'([^']*)'|(\\S+)"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let nsString = argsString as NSString
                let matches = regex.matches(in: argsString, range: NSRange(location: 0, length: nsString.length))
                for match in matches {
                    if match.range(at: 1).location != NSNotFound {
                        tokens.append(nsString.substring(with: match.range(at: 1)))
                    } else if match.range(at: 2).location != NSNotFound {
                        tokens.append(nsString.substring(with: match.range(at: 2)))
                    } else if match.range(at: 3).location != NSNotFound {
                        tokens.append(nsString.substring(with: match.range(at: 3)))
                    }
                }
            }

            if tokens.isEmpty {
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[-] Usage: createpopup <text> <button>",
                    isError: true
                ))
                return
            }

            let text: String
            let button: String
            if tokens.count == 1 {
                text = tokens[0]
                button = "OK"
            } else {
                button = tokens.last!
                text = tokens.dropLast().joined(separator: " ")
            }

            self.popupText = text
            self.popupButton = button
            self.showCustomPopup = true

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Native popup triggered:\n    Text: \"\(text)\"\n    Button: \"\(button)\"",
                isError: false
            ))
            return
        }

        // 2. Изменение цвета батареи: "battery color set [color]"
        if lower.starts(with: "battery color set ") {
            let colorPart = trimmed.dropFirst("battery color set ".count).trimmingCharacters(in: .whitespacesAndNewlines)
            if !colorPart.isEmpty {
                self.customBatteryColor = colorPart.lowercased()
                self.customStatusBarActive = true

                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Battery accent color updated to '\(colorPart)'\n[+] Native status bar override: ACTIVE",
                    isError: false
                ))
                return
            }
        }

        // 2. Изменение процента батареи: "battery percentage set [value]"
        if lower.starts(with: "battery percentage set ") || lower.starts(with: "battery percent set ") || lower.starts(with: "battery level set ") {
            let prefix = lower.starts(with: "battery percentage set ") ? "battery percentage set " : (lower.starts(with: "battery percent set ") ? "battery percent set " : "battery level set ")
            let valuePart = trimmed.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
            if let intVal = Int(valuePart), intVal >= 0 && intVal <= 100 {
                self.customBatteryPercentage = intVal
                self.customBatteryLevel = Double(intVal)
                self.customStatusBarActive = true

                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Battery level overridden to \(intVal)%\n[+] Inner pill fill updated to \(intVal)%\n[+] Native status bar override: ACTIVE",
                    isError: false
                ))
                return
            } else {
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[-] Invalid battery percentage. Enter 0-100 (e.g. 'battery percentage set 100')",
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
                output: "[+] Battery settings reset to system defaults.\n[+] Default iOS status bar restored.",
                isError: false
            ))
            return
        }

        // 4. Показ / скрытие статус бара
        if lower == "statusbar show" || lower == "statusbar on" || lower == "statusbar enable" {
            self.customStatusBarActive = true
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Status Bar override enabled.",
                isError: false
            ))
            return
        }

        if lower == "statusbar hide" || lower == "statusbar off" || lower == "statusbar disable" {
            self.customStatusBarActive = false
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Status Bar override disabled.",
                isError: false
            ))
            return
        }

        // 5. Очистка терминала
        if lower == "clear" || lower == "cls" {
            terminalLogs.removeAll()
            return
        }

        // 6. Помощь
        if lower == "help" || lower == "?" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: """
Cort1so1 Subsystem Command Reference:
  help                          - Show this list of available commands
  createpopup <text> <button>   - Show a custom native iOS popup dialog
  battery color set <color>     - Override battery color (e.g. orange, red, green, blue, #hex)
  battery percentage set <val>  - Override battery percentage (0-100)
  battery reset                 - Restore system device battery values
  statusbar show / hide         - Enable/disable status bar override
  whoami                        - Display execution privilege (root)
  uname -a                      - Display kernel and architecture
  clear                         - Clear console output
""",
                isError: false
            ))
            return
        }

        // 7. whoami
        if lower == "whoami" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "root (uid=0, gid=0, groups=0(wheel))",
                isError: false
            ))
            return
        }

        // 8. uname -a
        if lower == "uname -a" || lower == "uname" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "Darwin Cort1so1-Kernel 23.4.0 arm64e AppleTV/iPhone",
                isError: false
            ))
            return
        }

        // Неизвестная команда
        terminalLogs.append(TerminalLogLine(
            command: trimmed,
            output: "cort1so1: command not found: '\(trimmed)'. Type 'help' to see all available commands.",
            isError: true
        ))
    }
}

#Preview {
    TerminalView()
}

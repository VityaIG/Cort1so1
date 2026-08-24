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
    @State private var isCharging: Bool = false

    private var displayTime: String {
        currentTimeString.isEmpty ? currentFormattedTime() : currentTimeString
    }

    /// Проверка, модифицирован ли процент пользователем
    private var isBatteryCustomized: Bool {
        customBatteryPercentage >= 0 || customBatteryLevel >= 0
    }

    /// Вычисление эффективного процента батареи (0-100)
    private var effectivePercentage: Int {
        if customBatteryPercentage >= 0 {
            return min(100, max(0, customBatteryPercentage))
        }
        if customBatteryLevel >= 0 {
            return min(100, max(0, Int(customBatteryLevel)))
        }
        // Реальный процент с устройства
        if systemBatteryLevel >= 0 {
            return min(100, max(0, Int(round(systemBatteryLevel * 100))))
        }
        return 100
    }

    /// Разрешение цвета батареи
    private var resolvedBatteryColor: Color {
        if !isBatteryCustomized && customBatteryColor == "orange" {
            // Если цвет не менялся пользователем вручную, используем нативную логику iOS:
            if effectivePercentage <= 20 {
                return Color(red: 1.0, green: 0.27, blue: 0.228) // Красный при <= 20%
            }
            if ProcessInfo.processInfo.isLowPowerModeEnabled {
                return Color(red: 1.0, green: 0.8, blue: 0.0) // Желтый в режиме энергосбережения
            }
            return Color.primary // Белый в темной теме / черный в светлой
        }

        let trimmed = customBatteryColor.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch trimmed {
        case "orange": return Color(red: 1.0, green: 0.584, blue: 0.0)
        case "red": return Color(red: 1.0, green: 0.27, blue: 0.228)
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
            // Левая секция: Системное время (точное соответствие iOS: SF Pro Text Semibold)
            Text(displayTime)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .padding(.leading, 28)

            Spacer()

            // Правая секция: Сигнал сотовой связи, Wi-Fi и Нативная батарея с процентом внутри
            HStack(spacing: 6.0) {
                // 4-полосный индикатор сигнала сотовой связи (iOS-style)
                HStack(alignment: .bottom, spacing: 1.8) {
                    Capsule().frame(width: 3.0, height: 4.0)
                        .foregroundColor(.primary)
                    Capsule().frame(width: 3.0, height: 6.5)
                        .foregroundColor(.primary)
                    Capsule().frame(width: 3.0, height: 9.0)
                        .foregroundColor(.primary)
                    Capsule().frame(width: 3.0, height: 11.5)
                        .foregroundColor(.primary.opacity(0.32))
                }

                // Иконка Wi-Fi
                Image(systemName: "wifi")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 0.5)

                // Точная копия нативной батареи iOS (число процента ВНУТРИ капсулы с двухтоновым инвертированием)
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
            NotificationCenter.default.addObserver(forName: UIDevice.batteryLevelDidChangeNotification, object: nil, queue: .main) { _ in
                self.updateSystemBattery()
            }
            NotificationCenter.default.addObserver(forName: UIDevice.batteryStateDidChangeNotification, object: nil, queue: .main) { _ in
                self.updateSystemBattery()
            }
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
            if topInset >= 50 {
                return 15 // Dynamic Island
            } else if topInset > 0 {
                return 11 // Notch
            }
        }
        return 12
    }

    /// Пиксель-перфектная батарея iOS с процентом внутри капсулы (100% совпадение с iOS)
    @ViewBuilder
    private func nativeBatteryPill(percentage: Int, accentColor: Color) -> some View {
        let pillWidth: CGFloat = 27.0
        let pillHeight: CGFloat = 13.0
        let cornerRad: CGFloat = 4.5
        let clampedPct = min(100, max(0, percentage))
        let fillProgress = CGFloat(clampedPct) / 100.0
        let fillW = pillWidth * fillProgress

        HStack(spacing: 1.2) {
            // Основной корпус батареи (100% совпадение с нативной капсулой Apple iOS)
            ZStack(alignment: .leading) {
                // 1. Неотъемлемый базовый полупрозрачный фон незаполненной части
                RoundedRectangle(cornerRadius: cornerRad, style: .continuous)
                    .fill(Color.primary.opacity(0.32))
                    .frame(width: pillWidth, height: pillHeight)

                // 2. Белый текст процента на полупрозрачной части
                Text("\(clampedPct)")
                    .font(.system(size: 10.5, weight: .bold, design: .default))
                    .foregroundColor(Color.white)
                    .frame(width: pillWidth, height: pillHeight, alignment: .center)

                // 3. Заполненная часть цвета акцента (полноформатная, без зазоров)
                Rectangle()
                    .fill(accentColor)
                    .frame(width: fillW, height: pillHeight)

                // 4. Инвертированный черный текст строго над заполненной частью (через точную маску)
                Text("\(clampedPct)")
                    .font(.system(size: 10.5, weight: .bold, design: .default))
                    .foregroundColor(Color(white: 0.08))
                    .frame(width: pillWidth, height: pillHeight, alignment: .center)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: fillW, height: pillHeight)
                            Spacer(minLength: 0)
                        }
                        .frame(width: pillWidth, height: pillHeight, alignment: .leading)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRad, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRad, style: .continuous)
                    .stroke(Color.primary.opacity(0.35), lineWidth: 1.0)
            )
            .frame(width: pillWidth, height: pillHeight)

            // Маленький контактный терминал на правом торце (пиксель-в-пиксель с iOS)
            RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                .fill(Color.primary.opacity(0.40))
                .frame(width: 1.5, height: 4.8)
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
        self.isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
    }
}

// MARK: - Terminal Log Model

struct TerminalLogLine: Identifiable, Equatable {
    let id = UUID()
    let command: String?
    let output: String
    let isError: Bool
    let tag: String
    let timestamp: Date

    init(command: String?, output: String, isError: Bool = false, tag: String = "INFO") {
        self.command = command
        self.output = output
        self.isError = isError
        self.tag = tag
        self.timestamp = Date()
    }
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

    private var currentSystemBatteryText: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        if level >= 0 {
            return "\(Int(round(level * 100)))% (Real)"
        }
        return "100% (Real)"
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

                // Секция 2: Быстрые команды
                Section(header: Text(isRu ? "Быстрые команды" : "Quick Actions")) {
                    Button(action: { executeCommand("respring") }) {
                        Label {
                            Text("respring")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                        } icon: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                        }
                    }

                    Button(action: { executeCommand("deviceinfo") }) {
                        Label {
                            Text("deviceinfo")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "cpu.fill")
                                .foregroundColor(.cyan)
                        }
                    }

                    Button(action: { executeCommand("help") }) {
                        Label {
                            Text("help")
                                .font(.system(.subheadline, design: .monospaced))
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                        }
                    }

                    Button(action: { resetAllModifications() }) {
                        Label {
                            Text(strings.terminalResetAllBtn)
                                .font(.system(.subheadline, design: .default))
                                .foregroundColor(.red)
                        } icon: {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }

                // Секция 3: Консоль логов с встроенным скроллбаром (РАСПОЛОЖЕНА НАД КОНФИГУРАЦИЕЙ)
                Section(
                    header: HStack {
                        Text(isRu ? "Журнал терминала" : "Console Output")
                        Spacer()
                        Text("\(terminalLogs.count) lines")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                ) {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(alignment: .leading, spacing: 6) {
                                if terminalLogs.isEmpty {
                                    Text(isRu ? "Журнал пуст. Введите команду выше." : "Console is empty. Enter a command above.")
                                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 8)
                                } else {
                                    ForEach(terminalLogs) { log in
                                        VStack(alignment: .leading, spacing: 3) {
                                            if let cmd = log.command {
                                                HStack(spacing: 5) {
                                                    Text(formattedTime(date: log.timestamp))
                                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                                        .foregroundColor(.secondary.opacity(0.8))
                                                    Text("root@cort1so1:~#")
                                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                        .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                                                    Text(cmd)
                                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                                        .foregroundColor(.primary)
                                                }
                                            }

                                            HStack(alignment: .top, spacing: 5) {
                                                if log.command == nil {
                                                    Text(formattedTime(date: log.timestamp))
                                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                                        .foregroundColor(.secondary.opacity(0.8))
                                                }

                                                Text(log.output)
                                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                                    .foregroundColor(log.isError ? .red : (log.command != nil ? Color.primary : .secondary))
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                        .id(log.id)
                                        .padding(.vertical, 1)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(height: 200) // Фиксированная высота с встроенным скроллбаром
                        .onChange(of: terminalLogs.count) { _ in
                            if let lastId = terminalLogs.last?.id {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Секция 4: Текущее состояние статус-бара (РАСПОЛОЖЕНА ПОД ЖУРНАЛОМ)
                Section(header: Text(isRu ? "Состояние статус-бара" : "Status Bar Configuration")) {
                    Toggle(isRu ? "Оверлей статус-бара" : "Status Bar Override", isOn: $customStatusBarActive)

                    HStack {
                        Text(isRu ? "Цвет индикатора" : "Accent Color")
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(resolvedColorForDisplay(customBatteryColor))
                                .frame(width: 10, height: 10)
                            Text(customBatteryColor.capitalized)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text(isRu ? "Уровень батареи" : "Battery Level")
                        Spacer()
                        if customBatteryPercentage >= 0 {
                            Text("\(customBatteryPercentage)% (Custom)")
                                .foregroundColor(.secondary)
                        } else {
                            Text(currentSystemBatteryText)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: { resetAllModifications() }) {
                        HStack {
                            Spacer()
                            Text(strings.terminalResetAllBtn)
                                .foregroundColor(.red)
                            Spacer()
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
            UIDevice.current.isBatteryMonitoringEnabled = true
            if terminalLogs.isEmpty {
                terminalLogs.append(TerminalLogLine(
                    command: nil,
                    output: "[+] Cort1so1 Subsystem v1.3 loaded (PID: 1042, UID: 0)\n[*] Real battery sync: ACTIVE\n[*] Type 'help' to list available commands",
                    isError: false,
                    tag: "SYS"
                ))
            }
        }
    }

    /// Сброс всех модификаций терминала и статус-бара к системным значениям
    private func resetAllModifications() {
        self.customBatteryPercentage = -1
        self.customBatteryLevel = -1.0
        self.customBatteryColor = "orange"
        self.customStatusBarActive = false
        self.showCustomPopup = false
        self.popupText = ""
        self.popupButton = "OK"

        terminalLogs.append(TerminalLogLine(
            command: "reset",
            output: "[+] All terminal modifications and status bar overrides cleared.\n[*] Restored native iOS system device status.",
            isError: false,
            tag: "RESET"
        ))
    }

    private func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private func resolvedColorForDisplay(_ colorName: String) -> Color {
        let trimmed = colorName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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
                    isError: true,
                    tag: "ERR"
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
                    isError: true,
                    tag: "ERR"
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
                output: "[+] Native popup dialog displayed:\n    Message: \"\(text)\"\n    Button:  \"\(button)\"",
                isError: false,
                tag: "OK"
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
                    output: "[+] Battery accent color updated to '\(colorPart)'\n[+] Status bar override: ACTIVE",
                    isError: false,
                    tag: "BAT"
                ))
                return
            }
        }

        // 3. Изменение процента батареи: "battery percentage set [value]"
        if lower.starts(with: "battery percentage set ") || lower.starts(with: "battery percent set ") || lower.starts(with: "battery level set ") {
            let prefix = lower.starts(with: "battery percentage set ") ? "battery percentage set " : (lower.starts(with: "battery percent set ") ? "battery percent set " : "battery level set ")
            let valuePart = trimmed.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
            if let intVal = Int(valuePart), intVal >= 0 && intVal <= 100 {
                self.customBatteryPercentage = intVal
                self.customBatteryLevel = Double(intVal)
                self.customStatusBarActive = true

                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Battery percentage set to \(intVal)%\n[+] Inner pill fill updated to \(intVal)%\n[+] Status bar override: ACTIVE",
                    isError: false,
                    tag: "BAT"
                ))
                return
            } else {
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[-] Invalid battery percentage. Enter 0-100 (e.g. 'battery percentage set 100')",
                    isError: true,
                    tag: "ERR"
                ))
                return
            }
        }

        // 4. Сброс всех настроек или батареи
        if lower == "reset" || lower == "reset all" || lower == "clear all" || lower == "restore" {
            resetAllModifications()
            return
        }

        if lower == "battery reset" || lower == "battery default" {
            self.customBatteryPercentage = -1
            self.customBatteryLevel = -1.0
            self.customBatteryColor = "orange"
            self.customStatusBarActive = false

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Battery settings reset to system defaults.\n[*] Real device battery level restored: \(currentSystemBatteryText)",
                isError: false,
                tag: "BAT"
            ))
            return
        }

        // 5. Показ / скрытие статус бара
        if lower == "statusbar show" || lower == "statusbar on" || lower == "statusbar enable" {
            self.customStatusBarActive = true
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Status Bar override enabled.",
                isError: false,
                tag: "SB"
            ))
            return
        }

        if lower == "statusbar hide" || lower == "statusbar off" || lower == "statusbar disable" {
            self.customStatusBarActive = false
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] Status Bar override disabled.",
                isError: false,
                tag: "SB"
            ))
            return
        }

        // 6. Выполнение респринга SpringBoard: "respring" / "sbreload" / "killall springboard"
        if lower == "respring" || lower == "sbreload" || lower == "killall springboard" || lower == "killall -9 springboard" {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[*] Initiating SpringBoard respring sequence...\n[+] Sending SIGTERM to com.apple.springboard (PID: \(Int.random(in: 412...890)))\n[+] Reloading SpringBoard server & tweak injection...",
                isError: false,
                tag: "RESPRING"
            ))

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                NotificationCenter.default.post(name: NSNotification.Name("TriggerRespring"), object: nil)
            }
            return
        }

        // 7. Очистка кэша иконок: "uicache"
        if lower.starts(with: "uicache") {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[*] Running uicache --all...\n[*] Scanning /Applications & /var/mobile/Containers...\n[+] Successfully rebuilt IconServices cache for 142 bundles.\n[+] SpringBoard icon grid refreshed.",
                isError: false,
                tag: "CACHE"
            ))
            return
        }

        // 8. Перезагрузка Userspace: "reboot" / "ldrestart"
        if lower == "reboot" || lower == "ldrestart" {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[*] Performing userspace restart (ldrestart)...\n[*] Terminating launchd user daemons...\n[+] Re-initializing SpringBoard...",
                isError: false,
                tag: "REBOOT"
            ))

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                NotificationCenter.default.post(name: NSNotification.Name("TriggerRespring"), object: nil)
            }
            return
        }

        // 9. Тестирование тактильного отклика Taptic Engine: "haptic [type]"
        if lower.starts(with: "haptic") {
            let hapticType = lower.dropFirst("haptic".count).trimmingCharacters(in: .whitespacesAndNewlines)
            switch hapticType {
            case "light":
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case "medium":
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case "heavy":
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case "warning":
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case "error":
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case "success", "":
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            default:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] CoreHaptics / Taptic Engine pulse triggered: \(hapticType.isEmpty ? "SUCCESS" : hapticType.uppercased())",
                isError: false,
                tag: "HAPTIC"
            ))
            return
        }

        // 10. Изменение системной темы оформления: "theme [color]"
        if lower.starts(with: "theme ") {
            let colorChoice = lower.dropFirst("theme ".count).trimmingCharacters(in: .whitespacesAndNewlines)
            let valid = ["blue", "purple", "cyan", "orange", "red", "green", "pink"]
            if valid.contains(colorChoice) {
                self.appThemeColor = colorChoice
                UserDefaults.standard.set(colorChoice, forKey: "appThemeColor")

                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Application accent theme updated to '\(colorChoice.capitalized)'.",
                    isError: false,
                    tag: "THEME"
                ))
            } else {
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[-] Unknown theme '\(colorChoice)'. Available themes: \(valid.joined(separator: ", "))",
                    isError: true,
                    tag: "ERR"
                ))
            }
            return
        }

        // 11. Смена языка: "language [en|ru]" / "lang [en|ru]"
        if lower.starts(with: "language ") || lower.starts(with: "lang ") {
            let prefix = lower.starts(with: "language ") ? "language " : "lang "
            let langChoice = lower.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
            if langChoice == "ru" || langChoice == "russian" {
                self.appLanguage = "ru"
                UserDefaults.standard.set("ru", forKey: "appLanguage")
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Язык интерфейса успешно изменен на Русский (ru).",
                    isError: false,
                    tag: "LANG"
                ))
                return
            } else if langChoice == "en" || langChoice == "english" {
                self.appLanguage = "en"
                UserDefaults.standard.set("en", forKey: "appLanguage")
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[+] Interface language set to English (en).",
                    isError: false,
                    tag: "LANG"
                ))
                return
            } else {
                terminalLogs.append(TerminalLogLine(
                    command: trimmed,
                    output: "[-] Invalid language '\(langChoice)'. Use 'lang en' or 'lang ru'.",
                    isError: true,
                    tag: "ERR"
                ))
                return
            }
        }

        // 12. Режим Safe Mode: "safemode [on|off|toggle]"
        if lower.starts(with: "safemode") {
            let arg = lower.dropFirst("safemode".count).trimmingCharacters(in: .whitespacesAndNewlines)
            if arg == "on" || arg == "1" || arg == "enable" {
                self.safeMode = true
            } else if arg == "off" || arg == "0" || arg == "disable" {
                self.safeMode = false
            } else {
                self.safeMode.toggle()
            }
            UserDefaults.standard.set(self.safeMode, forKey: "safeMode")

            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "[+] SpringBoard Safe Mode: \(self.safeMode ? "ENABLED (Tweaks disabled)" : "DISABLED (Normal mode)")",
                isError: false,
                tag: "SAFE"
            ))
            return
        }

        // 13. Сведения об устройстве: "deviceinfo" / "neofetch" / "sysinfo"
        if lower == "deviceinfo" || lower == "neofetch" || lower == "sysinfo" || lower == "info" {
            let model = UIDevice.current.model
            let sysVer = UIDevice.current.systemVersion
            let name = UIDevice.current.name
            let ramGb = ProcessInfo.processInfo.physicalMemory / (1024 * 1024 * 1024)
            let cores = ProcessInfo.processInfo.activeProcessorCount
            let batPct = effectivePercentage

            let infoText = """
╭──────────────── Cort1so1 Subsystem ────────────────╮
│ Model:       \(model) (\(name))
│ Firmware:    iOS \(sysVer) (Darwin 23.4.0)
│ Architecture: arm64e (A12-A18 Pro / Apple Silicon)
│ Processor:   \(cores) Active CPU Cores
│ Memory:      \(ramGb) GB Unified Memory
│ Battery:     \(batPct)% (\(UIDevice.current.batteryState == .charging ? "Charging" : "Discharging"))
│ Subsystem:   Cort1so1 v1.3 [Rooted & Jailbroken]
╰────────────────────────────────────────────────────╯
"""
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: infoText,
                isError: false,
                tag: "SYS"
            ))
            return
        }

        // 14. Вывод текста: "echo [text]"
        if lower.starts(with: "echo ") {
            let echoText = trimmed.dropFirst("echo ".count)
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: String(echoText),
                isError: false,
                tag: "ECHO"
            ))
            return
        }

        // 15. Текущая дата и время: "date" / "time"
        if lower == "date" || lower == "time" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: formatter.string(from: Date()),
                isError: false,
                tag: "DATE"
            ))
            return
        }

        // 16. Очистка терминала
        if lower == "clear" || lower == "cls" {
            terminalLogs.removeAll()
            return
        }

        // 17. Помощь
        if lower == "help" || lower == "?" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: """
Cort1so1 Subsystem Command Reference:
  respring                      - Trigger SpringBoard respring reload sequence
  uicache                       - Rebuild IconServices cache & refresh app layout
  reboot / ldrestart            - Userspace daemon restart sequence
  deviceinfo / neofetch         - Display detailed hardware & system info
  haptic <light|heavy|success>  - Fire Taptic Engine vibration feedback
  theme <blue|purple|cyan|...>  - Switch application accent color
  lang <en|ru>                  - Switch app interface language
  safemode <on|off>             - Toggle SpringBoard Safe Mode
  battery color set <color>     - Override battery color (e.g. orange, red, green, #hex)
  battery percentage set <val>  - Override battery percentage (0-100)
  battery reset                 - Restore real device hardware battery readings
  statusbar show / hide         - Enable/disable custom status bar overlay
  createpopup <text> <button>   - Trigger native iOS popup dialog
  echo <text>                   - Print text to console
  date / time                   - Show system timestamp
  whoami                        - Display execution privilege (root)
  uname -a                      - Display kernel and architecture
  reset / clear all             - Clear all modifications and restore stock state
  clear                         - Clear console log output
""",
                isError: false,
                tag: "HELP"
            ))
            return
        }

        // 18. whoami
        if lower == "whoami" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "root (uid=0, gid=0, groups=0(wheel), context=cort1so1_subsystem_t)",
                isError: false,
                tag: "AUTH"
            ))
            return
        }

        // 19. uname -a
        if lower == "uname -a" || lower == "uname" {
            terminalLogs.append(TerminalLogLine(
                command: trimmed,
                output: "Darwin Cort1so1-Kernel 23.4.0 arm64e AppleTV/iPhone",
                isError: false,
                tag: "KERNEL"
            ))
            return
        }

        // Неизвестная команда
        terminalLogs.append(TerminalLogLine(
            command: trimmed,
            output: "cort1so1: command not found: '\(trimmed)'. Type 'help' to see all available commands.",
            isError: true,
            tag: "ERR"
        ))
    }
}

#Preview {
    TerminalView()
}


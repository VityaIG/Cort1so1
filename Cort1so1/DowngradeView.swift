import SwiftUI
import UIKit

// MARK: - UIDevice Extension for Real Hardware Info
extension UIDevice {
    var hardwareIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    var friendlyModelName: String {
        let identifier = hardwareIdentifier
        let map: [String: String] = [
            "iPhone12,1": "iPhone 11", "iPhone12,3": "iPhone 11 Pro", "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone13,1": "iPhone 12 mini", "iPhone13,2": "iPhone 12", "iPhone13,3": "iPhone 12 Pro", "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,4": "iPhone 13 mini", "iPhone14,5": "iPhone 13", "iPhone14,2": "iPhone 13 Pro", "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,7": "iPhone 14", "iPhone14,8": "iPhone 14 Plus", "iPhone15,2": "iPhone 14 Pro", "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15", "iPhone15,5": "iPhone 15 Plus", "iPhone16,1": "iPhone 15 Pro", "iPhone16,2": "iPhone 15 Pro Max",
            "iPad8,1": "iPad Pro 11-inch", "iPad8,9": "iPad Pro 11-inch (2nd gen)", "iPad13,4": "iPad Pro 11-inch (3rd gen)",
            "arm64": "Simulator (arm64)", "x86_64": "Simulator (x86_64)"
        ]
        return map[identifier] ?? identifier
    }
}

struct DowngradeView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @State private var activeFirmware: FirmwareVersion? = nil
    
    @State private var selectedFirmwareId: UUID? = sampleFirmwares.first?.id
    
    // Options
    @State private var preserveData: Bool = true
    @State private var updateBaseband: Bool = true
    @State private var verboseRestore: Bool = false
    
    @State private var selectedExploit: String = "checkm8 (Bootrom)"
    private let exploits = ["checkm8 (Bootrom)", "Cryptex1 Bypass", "SEP Exploit", "Tethered Boot"]
    
    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isRu ? "Профиль устройства" : "Device Profile")) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: "iphone")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(UIDevice.current.friendlyModelName)
                                .font(.system(size: 16, weight: .bold))
                            
                            HStack(spacing: 6) {
                                Text("iOS \(UIDevice.current.systemVersion)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.12))
                                    .clipShape(Capsule())

                                Text("arm64e")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(
                    header: Text(isRu ? "Выбор прошивки" : "Target Firmware"),
                    footer: Text(isRu ? "Некоторые прошивки могут быть несовместимы с текущим SEP." : "Some firmwares may be incompatible with the current SEP.")
                ) {
                    Picker(isRu ? "Прошивка" : "Firmware", selection: $selectedFirmwareId) {
                        ForEach(sampleFirmwares) { fw in
                            Text("\(fw.version) (\(fw.build))").tag(fw.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text(isRu ? "Статус подписи (TSS)" : "TSS Status")) {
                    HStack {
                        Label {
                            Text(isRu ? "Статус окна" : "Signing Window")
                        } icon: {
                            Image(systemName: "key.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                        Spacer()
                        if let fw = sampleFirmwares.first(where: { $0.id == selectedFirmwareId }), fw.version == "iOS 18.0" {
                            HStack(spacing: 4) {
                                Circle().fill(Color.green).frame(width: 6, height: 6)
                                Text(isRu ? "Открыто" : "Signed")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                        } else {
                            HStack(spacing: 4) {
                                Circle().fill(Color.red).frame(width: 6, height: 6)
                                Text(isRu ? "Закрыто" : "Unsigned")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                        }
                    }
                    HStack {
                        Label {
                            Text("SHSH2 Blobs")
                        } icon: {
                            Image(systemName: "doc.zipper")
                                .foregroundColor(.indigo)
                                .font(.caption)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                            Text(isRu ? "Найдены локально" : "Found Locally")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.indigo)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.indigo.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
                
                Section(header: Text(isRu ? "Метод отката" : "Downgrade Method")) {
                    Picker(isRu ? "Эксплойт" : "Exploit", selection: $selectedExploit) {
                        ForEach(exploits, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                }
                
                Section(
                    header: Text(isRu ? "Резервная копия" : "Backup & Safety"),
                    footer: Text(isRu ? "Откат на несовместимый SEP может привести к поломке FaceID или код-пароля." : "Downgrading to an incompatible SEP may corrupt FaceID or Passcode data.")
                ) {
                    HStack {
                        Label {
                            Text(isRu ? "Последняя копия" : "Last Backup")
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.teal)
                                .font(.caption)
                        }
                        Spacer()
                        Text(isRu ? "Сегодня в 10:42" : "Today at 10:42 AM")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(
                    header: Text(isRu ? "Параметры Отката" : "Downgrade Options"),
                    footer: Text(isRu ? "Откат с сохранением данных может привести к нестабильной работе системы, если версии несовместимы." : "Preserving data during downgrade may cause system instability if versions are incompatible.")
                ) {
                    Toggle(isRu ? "Сохранить данные" : "Preserve Data", isOn: $preserveData)
                    Toggle(isRu ? "Обновить модем (Baseband)" : "Update Baseband", isOn: $updateBaseband)
                    Toggle(isRu ? "Подробный лог (Verbose)" : "Verbose Restore", isOn: $verboseRestore)
                }
                
                Section {
                    Button(action: {
                        triggerSelectionHaptic()
                        if let fw = sampleFirmwares.first(where: { $0.id == selectedFirmwareId }) {
                            self.activeFirmware = fw
                        }
                    }) {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text(isRu ? "Начать Откат" : "Start Downgrade")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                    }
                }
                
                // Extremely long spacer to hide the easter egg far below
                Section {
                    Color.clear
                        .frame(height: 3000)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                
                // Easter Egg
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        Button(action: {
                            triggerSelectionHaptic()
                            let androidFirmware = FirmwareVersion(
                                version: "Android 17 Beta",
                                build: "SWEET_CAT",
                                features: "Easter Egg Bypass",
                                badgeText: "SECRET",
                                badgeColor: .green,
                                group: "EASTER EGG",
                                sha256: "deadbeef00000000000000000000000000000000000000000000000000000000"
                            )
                            activeFirmware = androidFirmware
                        }) {
                            Text("Android 17 Beta")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle(isRu ? "Откат iOS" : "iOS Downgrade")
            .sheet(item: $activeFirmware) { firmware in
                DowngradeExecutionSheet(firmware: firmware, appLanguage: appLanguage, verbose: verboseRestore)
            }
        }
    }
    
    private func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// MARK: - Execution Sheet (Remains similar visually, adjusted for minimal/iOS style)

struct DowngradeExecutionSheet: View {
    let firmware: FirmwareVersion
    let appLanguage: String
    let verbose: Bool
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("installedOS") private var installedOS: String = "iOS"
    
    private var isRu: Bool {
        appLanguage == "ru"
    }
    
    // Status
    @State private var isRestoring = false
    @State private var elapsedSeconds: Double = 0.0
    @State private var restoreSpeedMBs: Double = 0.0
    @State private var terminalLogs: [String] = []
    @State private var currentStageIndex: Int = -1
    @State private var isRespringing = false
    
    // Alerts
    @State private var showCancelAlert = false
    @State private var showSuccessAlert = false
    
    @State private var restoreTimer: Timer?
    
    struct RestoreStage {
        let title: String
        let range: ClosedRange<Double>
    }
    let stages: [RestoreStage] = [
        RestoreStage(title: "Handshake & TSS", range: 0.0...10.0),
        RestoreStage(title: "Mounting APFS & RootFS", range: 10.0...25.0),
        RestoreStage(title: "Flashing SEP & Baseband", range: 25.0...40.0),
        RestoreStage(title: "Creating Snapshots", range: 40.0...52.0),
        RestoreStage(title: "Verifying Integrity", range: 52.0...60.0)
    ]
    
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section {
                        if isRestoring {
                            Button(action: {
                                cancelFlashing()
                            }) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "stop.fill")
                                    Text(isRu ? "Прервать Откат" : "Stop Flashing")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        } else if elapsedSeconds > 0 && elapsedSeconds < 60 {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Spacer()
                                    Text(isRu ? "Закрыть" : "Close")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .foregroundColor(.blue)
                            }
                        } else if elapsedSeconds == 60 {
                            Button(action: {
                                self.isRespringing = true
                            }) {
                                HStack {
                                    Spacer()
                                    Text(isRu ? "Завершить и перезагрузить" : "Finish & Respring")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .foregroundColor(.green)
                            }
                        } else {
                            Button(action: { start60SecondsFlashingSequence() }) {
                                HStack {
                                    Spacer()
                                    Text(isRu ? "Начать установку (60 сек)" : "Start Flashing (60s)")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .foregroundColor(firmware.badgeColor)
                            }
                        }
                    }

                    Section(header: Text(isRu ? "Прогресс" : "Progress")) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color(UIColor.tertiarySystemFill), lineWidth: 12)
                                .frame(width: 140, height: 140)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(elapsedSeconds / 60.0))
                                .stroke(
                                    firmware.badgeColor,
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.1), value: elapsedSeconds)
                            
                            VStack(spacing: 4) {
                                Text(String(format: "%.0f%%", (elapsedSeconds / 60.0) * 100))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                
                                Text(String(format: "%.1f MB/s", restoreSpeedMBs))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Section(header: Text(isRu ? "Статус установки" : "Installation Status")) {
                    ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                        let isActive = currentStageIndex == index
                        let isCompleted = elapsedSeconds > stage.range.upperBound
                        
                        HStack(spacing: 12) {
                            if isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(firmware.badgeColor)
                                    .font(.system(size: 20))
                            } else if isActive {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: firmware.badgeColor))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                                    .font(.system(size: 20))
                            }
                            
                            Text(stage.title)
                                .font(.system(size: 16, weight: isActive ? .semibold : .regular))
                                .foregroundColor(isActive || isCompleted ? .primary : .secondary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text(isRu ? "Терминал" : "Terminal Log")) {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(alignment: .leading, spacing: 4) {
                                if terminalLogs.isEmpty {
                                    Text("Waiting for command...")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(terminalLogs.indices, id: \.self) { i in
                                        Text(terminalLogs[i])
                                            .id(i)
                                    }
                                }
                            }
                            .font(.system(size: 11, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        }
                        .frame(height: 150)
                        .onChange(of: terminalLogs.count) { _ in
                            if !terminalLogs.isEmpty {
                                withAnimation {
                                    proxy.scrollTo(terminalLogs.count - 1, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isRu ? "Установка" : "Flashing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isRestoring && elapsedSeconds == 0 {
                        Button(isRu ? "Закрыть" : "Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .alert(isPresented: $showCancelAlert) {
                Alert(
                    title: Text(isRu ? "Прервать Откат?" : "Cancel Downgrade?"),
                    message: Text(isRu ? "Прерывание процесса может привести к bootloop." : "Interrupting the flash process may cause a bootloop."),
                    primaryButton: .destructive(Text(isRu ? "Прервать" : "Cancel Process")) {
                        cancelFlashing()
                    },
                    secondaryButton: .cancel(Text(isRu ? "Продолжить" : "Keep Flashing"))
                )
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text(isRu ? "Откат Завершён!" : "Downgrade Complete!"),
                    message: Text(isRu ? "Устройство было успешно восстановлено на \(firmware.version). Для применения изменений требуется перезагрузка SpringBoard." : "Your device was successfully restored to \(firmware.version). SpringBoard will now restart to apply changes."),
                    dismissButton: .default(Text(isRu ? "Перезагрузить" : "Respring")) {
                        self.isRespringing = true
                    }
                )
            }
            .onDisappear {
                restoreTimer?.invalidate()
            }
            
            if isRespringing {
                NeoSpringView(onFinished: {
                    self.isRespringing = false
                    presentationMode.wrappedValue.dismiss()
                })
                .ignoresSafeArea()
                .zIndex(100)
            }
        }
    }
    
    // MARK: - Logic
    
    private func start60SecondsFlashingSequence() {
        triggerMajorHaptic()
        isRestoring = true
        elapsedSeconds = 0.0
        currentStageIndex = 0
        restoreSpeedMBs = 48.5
        terminalLogs = [
            "[00:00] [Futurerestore v2.4.1] Initializing downgrade engine...",
            "[00:01] [TSS] Handshake with gs.apple.com:443 established"
        ]
        
        if verbose {
            terminalLogs.append("[00:01] [VERBOSE] Setting verbose boot arguments...")
        }
        
        restoreTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            elapsedSeconds += 0.1
            let currentSecondsInt = Int(elapsedSeconds)
            let formattedTime = String(format: "[%02d:%02d]", currentSecondsInt / 60, currentSecondsInt % 60)
            
            if elapsedSeconds <= 10.0 {
                if currentStageIndex != 0 { currentStageIndex = 0; triggerSelectionHaptic() }
                restoreSpeedMBs = Double.random(in: 44.0...54.0)
                if currentSecondsInt == 3 && terminalLogs.count < 3 + (verbose ? 1 : 0) {
                    terminalLogs.append("\(formattedTime) [ApTicket] Validating SHSH2 ApTicket payload")
                } else if currentSecondsInt == 7 && terminalLogs.count < 4 + (verbose ? 1 : 0) {
                    terminalLogs.append("\(formattedTime) [TSS] Received signed ApTicket hash: \(firmware.sha256.prefix(10))...")
                }
            }
            else if elapsedSeconds <= 25.0 {
                if currentStageIndex != 1 { currentStageIndex = 1; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [APFS] Mounting DMG RootFS container: disk0s1s1") }
                restoreSpeedMBs = Double.random(in: 55.0...68.0)
                if currentSecondsInt == 18 && terminalLogs.count < 6 + (verbose ? 1 : 0) {
                    terminalLogs.append("\(formattedTime) [Cryptex1] Verifying OS TrustCache and entitlements...")
                }
            }
            else if elapsedSeconds <= 40.0 {
                if currentStageIndex != 2 { currentStageIndex = 2; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [SEP] Sending signed Secure Enclave microcode...") }
                restoreSpeedMBs = Double.random(in: 52.0...64.0)
                if currentSecondsInt == 33 && terminalLogs.count < 8 + (verbose ? 1 : 0) {
                    terminalLogs.append("\(formattedTime) [Baseband] Flashing modem firmware version 4.02.01: OK")
                }
            }
            else if elapsedSeconds <= 52.0 {
                if currentStageIndex != 3 { currentStageIndex = 3; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [APFS] Creating root snapshot com.apple.os.update") }
                restoreSpeedMBs = Double.random(in: 60.0...75.0)
                if currentSecondsInt == 47 && terminalLogs.count < 10 + (verbose ? 1 : 0) {
                    terminalLogs.append("\(formattedTime) [Kernel] Updating KASLR slide & devicetree components...")
                }
            }
            else if elapsedSeconds < 60.0 {
                if currentStageIndex != 4 { currentStageIndex = 4; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [NVRAM] Updating boot-args: rootless=1 cs_enforcement=1") }
                restoreSpeedMBs = Double.random(in: 25.0...40.0)
                if currentSecondsInt == 56 && terminalLogs.count < 12 + (verbose ? 1 : 0) {
                    terminalLogs.append("\(formattedTime) [SHA256] System partition integrity check passed: OK")
                }
            }
            else {
                elapsedSeconds = 60.0
                restoreSpeedMBs = 0.0
                currentStageIndex = 5 // Fully done
                terminalLogs.append("[01:00] [Done] Restore completed successfully in 60s! System ready.")
                timer.invalidate()
                restoreTimer = nil
                isRestoring = false
                triggerNotificationSuccess()
                installedOS = firmware.version
                UserDefaults.standard.set(firmware.version, forKey: "installedOS")
                showSuccessAlert = true
            }
        }
    }
    
    private func cancelFlashing() {
        restoreTimer?.invalidate()
        restoreTimer = nil
        isRestoring = false
        terminalLogs.append("[Terminated] Downgrade process cancelled by user.")
    }
    
    private func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    private func triggerMajorHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func triggerNotificationSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

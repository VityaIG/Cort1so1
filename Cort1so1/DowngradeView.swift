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
            return identifier + String(UnicodeScalar(UInt8(bitPattern: value)))
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
    @AppStorage("customAppBgTheme") private var customAppBgTheme: String = "default"
    @AppStorage("customBgColorHex") private var customBgColorHex: String = ""
    @AppStorage("customDeviceModel") private var customDeviceModel: String = ""
    @AppStorage("customOSVersion") private var customOSVersion: String = ""
    @AppStorage("customArch") private var customArch: String = ""
    @State private var activeFirmware: FirmwareVersion? = nil
    @State private var activeEasterAlert: DowngradeEasterAlert? = nil
    @State private var activeEasterFlashingFirmware: EasterFirmware? = nil
    
    @State private var selectedFirmwareId: UUID? = sampleFirmwares.first?.id
    
    // Options
    @State private var preserveData: Bool = true
    @State private var updateBaseband: Bool = true
    @AppStorage("verboseLogs") private var verboseRestore: Bool = true
    
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
                            Text(customDeviceModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.friendlyModelName : customDeviceModel)
                                .font(.system(size: 16, weight: .bold))
                            
                            HStack(spacing: 6) {
                                Text(customOSVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "iOS \(UIDevice.current.systemVersion)" : customOSVersion)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.12))
                                    .clipShape(Capsule())

                                Text(customArch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "arm64e" : customArch)
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
                    VStack(alignment: .center, spacing: 14) {
                        // easter2.png without rounded corners
                        Button(action: {
                            self.activeEasterAlert = .easter2Warning
                        }) {
                            Image("easter2")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // 1. Green Button - Install Android 17
                        Button(action: {
                            self.activeEasterAlert = .confirmInstall(.android)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "ladybug.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(isRu ? "Установить Android 17" : "Install Android 17")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundColor(.white)
                            .background(Color(red: 0.24, green: 0.86, blue: 0.36))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())

                        // 2. Blue Button - Install Windows 11
                        Button(action: {
                            self.activeEasterAlert = .confirmInstall(.windows)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "desktopcomputer")
                                    .font(.system(size: 16, weight: .bold))
                                Text(isRu ? "Установить Windows 11" : "Install Windows 11")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundColor(.white)
                            .background(Color(red: 0.00, green: 0.47, blue: 0.84))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())

                        // 3. Orange Button - Install Ubuntu 26.04
                        Button(action: {
                            self.activeEasterAlert = .confirmInstall(.ubuntu)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "terminal.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(isRu ? "Установить Ubuntu 26.04" : "Install Ubuntu 26.04")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundColor(.white)
                            .background(Color(red: 0.90, green: 0.28, blue: 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16))
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppCustomStyle.resolveBgColor(customHex: customBgColorHex, themeId: customAppBgTheme).ignoresSafeArea())
            .navigationTitle(isRu ? "Откат iOS" : "iOS Downgrade")
            .sheet(item: $activeFirmware) { firmware in
                DowngradeExecutionSheet(firmware: firmware, appLanguage: appLanguage, verbose: verboseRestore)
            }
            .alert(item: $activeEasterAlert) { alertType in
                switch alertType {
                case .easter2Warning:
                    return Alert(
                        title: Text(isRu ? "Снизу находится пиздец" : "Everything below is deep friend pls no install"),
                        dismissButton: .default(Text(isRu ? "Понятно" : "Ok, son"))
                    )
                case .confirmInstall(let fw):
                    return Alert(
                        title: Text(isRu ? "Вы серьезно хотите установить \(fw.name) на свое устройство?" : "Are you seriously sure you want to install \(fw.name) on your device?"),
                        primaryButton: .default(Text(isRu ? "Дай мне его" : "Yes pls")) {
                            self.activeEasterFlashingFirmware = fw
                        },
                        secondaryButton: .cancel(Text(isRu ? "Нет, нахуй" : "No, wtf"))
                    )
                }
            }
            .fullScreenCover(item: $activeEasterFlashingFirmware) { fw in
                EasterFirmwareProcessView(firmware: fw) {
                    self.activeEasterFlashingFirmware = nil
                }
            }
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
                UICollectionView.appearance().backgroundColor = .clear
            }
        }
    }
}

// MARK: - Execution Sheet (Remains similar visually, adjusted for minimal/iOS style)

struct DowngradeExecutionSheet: View {
    let firmware: FirmwareVersion
    let appLanguage: String
    let verbose: Bool
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("installedOS") private var installedOS: String = "iOS"
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    
    private var isRu: Bool {
        appLanguage == "ru"
    }
    
    // Status
    @State private var isRestoring = false
    @State private var elapsedSeconds: Double = 0.0
    @State private var restoreSpeedMBs: Double = 0.0
    @State private var terminalLogs: [String] = []
    @State private var currentStageIndex: Int = -1
    @State private var restoreTimer: Timer? = nil
    @State private var showCancelAlert = false
    @State private var showSuccessAlert = false
    @State private var isRespringing = false
    
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
                    primaryButton: .default(Text(isRu ? "Респринг" : "Respring")) {
                        self.isRespringing = true
                    },
                    secondaryButton: .cancel(Text(isRu ? "Закрыть" : "Close")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .onDisappear {
                restoreTimer?.invalidate()
            }
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
        let isVerbose = verbose || verboseLogs
        isRestoring = true
        elapsedSeconds = 0.0
        currentStageIndex = 0
        restoreSpeedMBs = 48.5
        terminalLogs = [
            "[00:00] [Futurerestore v2.4.1] Initializing downgrade engine...",
            "[00:01] [TSS] Handshake with gs.apple.com:443 established"
        ]
        
        if isVerbose {
            terminalLogs.append("[00:01] [VERBOSE] Sending TSS request for BoardConfig D73AP (ApBoardID: 0x14)...")
        }
        
        var emittedSeconds = Set<Int>()
        if isVerbose {
            emittedSeconds.insert(1)
        }
        
        restoreTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            elapsedSeconds += 0.1
            let sec = Int(elapsedSeconds)
            let formattedTime = String(format: "[%02d:%02d]", sec / 60, sec % 60)
            
            // Stages & Speeds
            if elapsedSeconds <= 10.0 {
                if currentStageIndex != 0 { currentStageIndex = 0 }
                restoreSpeedMBs = Double.random(in: 44.0...54.0)
            } else if elapsedSeconds <= 25.0 {
                if currentStageIndex != 1 { currentStageIndex = 1; terminalLogs.append("\(formattedTime) [APFS] Mounting DMG RootFS container: disk0s1s1") }
                restoreSpeedMBs = Double.random(in: 55.0...68.0)
            } else if elapsedSeconds <= 40.0 {
                if currentStageIndex != 2 { currentStageIndex = 2; terminalLogs.append("\(formattedTime) [SEP] Sending signed Secure Enclave microcode...") }
                restoreSpeedMBs = Double.random(in: 52.0...64.0)
            } else if elapsedSeconds <= 52.0 {
                if currentStageIndex != 3 { currentStageIndex = 3; terminalLogs.append("\(formattedTime) [APFS] Creating root snapshot com.apple.os.update") }
                restoreSpeedMBs = Double.random(in: 60.0...75.0)
            } else if elapsedSeconds < 60.0 {
                if currentStageIndex != 4 { currentStageIndex = 4; terminalLogs.append("\(formattedTime) [NVRAM] Updating boot-args: rootless=1 cs_enforcement=1") }
                restoreSpeedMBs = Double.random(in: 25.0...40.0)
            } else {
                elapsedSeconds = 60.0
                restoreSpeedMBs = 0.0
                currentStageIndex = 5 // Fully done
                terminalLogs.append("[01:00] [Done] Restore completed successfully in 60s! System ready.")
                timer.invalidate()
                restoreTimer = nil
                isRestoring = false
                installedOS = firmware.version
                UserDefaults.standard.set(firmware.version, forKey: "installedOS")
                if autoRespring {
                    self.isRespringing = true
                } else {
                    showSuccessAlert = true
                }
                return
            }
            
            // Timed verbose / standard events
            if !emittedSeconds.contains(sec) {
                emittedSeconds.insert(sec)
                
                switch sec {
                case 3:
                    terminalLogs.append("\(formattedTime) [ApTicket] Validating SHSH2 ApTicket payload")
                case 4:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Nonce generator: 0x1111111111111111 (ApNonce match: OK)") }
                case 6:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] ECID: 0x0012A3B4C5D6 — Cryptographic signature valid") }
                case 8:
                    terminalLogs.append("\(formattedTime) [TSS] Received signed ApTicket hash: \(firmware.sha256.prefix(10))...")
                case 9:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] TSS response payload verified with Apple Root CA") }
                case 12:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Extracting Restore.ipsw root filesystem partition...") }
                case 15:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Verifying chunk hashes: 4,096 / 4,096 chunks OK") }
                case 18:
                    terminalLogs.append("\(formattedTime) [Cryptex1] Verifying OS TrustCache and entitlements...")
                case 21:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Dynamic TrustCache size: 18.4 MB (3,412 Mach-O binaries)") }
                case 24:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] RootFS volume mounted rw: /private/preboot/restore_rootfs") }
                case 28:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] SEP FW: sep-firmware.d73.RELEASE.im4p (Cryptex1 valid)") }
                case 30:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Uploading modem image: ICE23-4.02.01.Release.bbfw...") }
                case 33:
                    terminalLogs.append("\(formattedTime) [Baseband] Flashing modem firmware version 4.02.01: OK")
                case 36:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Verifying Baseband NVM checksum and calibration blocks...") }
                case 38:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Secure Enclave Processor reset vectors aligned: OK") }
                case 43:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Sealing APFS container snapshot with Apple Root Certificate...") }
                case 47:
                    terminalLogs.append("\(formattedTime) [Kernel] Updating KASLR slide & devicetree components...")
                case 50:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] KernelCache: kernelcache.release.iPhone15,2 flashed") }
                case 54:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Syncing devicetree parameters and hardware ID register...") }
                case 56:
                    terminalLogs.append("\(formattedTime) [SHA256] System partition integrity check passed: OK")
                case 58:
                    if isVerbose { terminalLogs.append("\(formattedTime) [VERBOSE] Preparing system watchdog and reboot vectors...") }
                default:
                    break
                }
            }
        }
    }
    
    private func cancelFlashing() {
        restoreTimer?.invalidate()
        restoreTimer = nil
        isRestoring = false
        terminalLogs.append("[Terminated] Downgrade process cancelled by user.")
    }
}

// MARK: - Easter Egg Custom OS Firmware Models & Definitions

enum EasterFirmware: String, CaseIterable, Identifiable {
    case android = "Android 17"
    case windows = "Windows 11"
    case ubuntu = "Ubuntu 26.04"

    var id: String { rawValue }
    var name: String { rawValue }

    var buttonTitleRu: String {
        "Установить " + name
    }

    var buttonTitleEn: String {
        "Install " + name
    }

    var primaryColor: Color {
        switch self {
        case .android: return Color(red: 0.24, green: 0.86, blue: 0.36) // Android Green
        case .windows: return Color(red: 0.00, green: 0.47, blue: 0.84) // Windows Blue
        case .ubuntu: return Color(red: 0.90, green: 0.28, blue: 0.12)  // Ubuntu Orange
        }
    }

    var systemIcon: String {
        switch self {
        case .android: return "ladybug.fill"
        case .windows: return "desktopcomputer"
        case .ubuntu: return "terminal.fill"
        }
    }

    func logs(isRu: Bool) -> [JailbreakLogStep] {
        switch self {
        case .android:
            return [
                JailbreakLogStep(id: 1, titleRu: "[Fastboot] Подключение устройства в EDL Mode (9008)...", titleEn: "[Fastboot] Connecting device in EDL Mode (9008)...", isMajorPhase: false, iconName: "cable.connector"),
                JailbreakLogStep(id: 2, titleRu: "[Bootloader] Разблокировка Knox и OEM загрузчика...", titleEn: "[Bootloader] Unlocking Knox & OEM bootloader verification...", isMajorPhase: false, iconName: "lock.open.fill"),
                JailbreakLogStep(id: 3, titleRu: "[VBMeta] Патчинг vbmeta.img (--disable-verity)...", titleEn: "[VBMeta] Patching vbmeta.img (--disable-verity)...", isMajorPhase: false, iconName: "shield.slash.fill"),
                JailbreakLogStep(id: 4, titleRu: "[Partition] Разметка динамического Super раздела (system/vendor)...", titleEn: "[Partition] Repartitioning dynamic Super partition...", isMajorPhase: false, iconName: "square.grid.2x2.fill"),
                JailbreakLogStep(id: 5, titleRu: "[Kernel] Прошивка GKI ядра (Linux 6.6-android)...", titleEn: "[Kernel] Flashing GKI (Generic Kernel Image 6.6-android)...", isMajorPhase: false, iconName: "cpu"),
                JailbreakLogStep(id: 6, titleRu: "Фаза 1: Разделы Super и Bootloader успешно прошиты", titleEn: "Phase 1: Super Partition & Bootloader Flashed", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                JailbreakLogStep(id: 7, titleRu: "[System] Распаковка system_ext.img (Android 17 SWEET_CAT)...", titleEn: "[System] Extracting system_ext.img (Android 17 SWEET_CAT)...", isMajorPhase: false, iconName: "archivebox.fill"),
                JailbreakLogStep(id: 8, titleRu: "[Vendor] Инъекция Apple Bionic HAL и драйверов дисплея...", titleEn: "[Vendor] Injecting Apple Bionic HAL & display drivers...", isMajorPhase: false, iconName: "memorychip"),
                JailbreakLogStep(id: 9, titleRu: "[Magisk] Установка Magisk v27.0 root демона в init.rc...", titleEn: "[Magisk] Injecting Magisk v27.0 root daemon into init.rc...", isMajorPhase: false, iconName: "crown.fill"),
                JailbreakLogStep(id: 10, titleRu: "[Zygote] Инициализация среды ART runtime и Dalvik VM...", titleEn: "[Zygote] Initializing ART runtime & Dalvik VM...", isMajorPhase: false, iconName: "bolt.fill"),
                JailbreakLogStep(id: 11, titleRu: "Фаза 2: Системные образы и Magisk Root развернуты", titleEn: "Phase 2: System Images & Magisk Root Deployed", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                JailbreakLogStep(id: 12, titleRu: "[GMS] Установка сервисов Google Play и MicroG framework...", titleEn: "[GMS] Installing Google Play Services & MicroG framework...", isMajorPhase: false, iconName: "shippingbox.fill"),
                JailbreakLogStep(id: 13, titleRu: "[SELinux] Перевод политик безопасности в Permissive mode...", titleEn: "[SELinux] Setting SELinux state: Permissive mode...", isMajorPhase: false, iconName: "checkmark.shield.fill"),
                JailbreakLogStep(id: 14, titleRu: "[Sync] Очистка кэш-разделов и сборка dalvik-cache...", titleEn: "[Sync] Wiping cache partition & rebuilding dalvik-cache...", isMajorPhase: false, iconName: "arrow.clockwise"),
                JailbreakLogStep(id: 15, titleRu: "Фаза 3: Android 17 подготовлен к перезагрузке", titleEn: "Phase 3: Android 17 Ready for Reboot", isMajorPhase: true, iconName: "sparkles")
            ]
        case .windows:
            return [
                JailbreakLogStep(id: 1, titleRu: "[UEFI] Загрузка ACPI таблиц и прошивки EDK2 UEFI...", titleEn: "[UEFI] Loading ACPI tables and EDK2 UEFI firmware...", isMajorPhase: false, iconName: "cpu"),
                JailbreakLogStep(id: 2, titleRu: "[GPT] Конвертация APFS контейнера в разметку GPT...", titleEn: "[GPT] Converting APFS container to GPT partition table...", isMajorPhase: false, iconName: "square.grid.2x2.fill"),
                JailbreakLogStep(id: 3, titleRu: "[DISM] Развертывание install.wim (Windows 11 ARM64 Build 26100)...", titleEn: "[DISM] Applying install.wim (Windows 11 ARM64 Build 26100)...", isMajorPhase: false, iconName: "archivebox.fill"),
                JailbreakLogStep(id: 4, titleRu: "[BCDBoot] Инициализация EFI системного раздела (ESP)...", titleEn: "[BCDBoot] Initializing EFI System Partition (ESP)...", isMajorPhase: false, iconName: "folder.badge.gearshape"),
                JailbreakLogStep(id: 5, titleRu: "[Drivers] Интеграция драйверов ARM64 SoC и дисплея...", titleEn: "[Drivers] Injecting ARM64 SoC & display drivers...", isMajorPhase: false, iconName: "memorychip"),
                JailbreakLogStep(id: 6, titleRu: "Фаза 1: Образ Windows 11 ARM64 успешно развернут", titleEn: "Phase 1: Windows 11 ARM64 Image Deployed", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                JailbreakLogStep(id: 7, titleRu: "[Registry] Инъекция кустов реестра SYSTEM и SOFTWARE...", titleEn: "[Registry] Injecting SYSTEM & SOFTWARE registry hives...", isMajorPhase: false, iconName: "doc.badge.gearshape"),
                JailbreakLogStep(id: 8, titleRu: "[Bypass] Обход требований TPM 2.0 и SecureBoot checks...", titleEn: "[Bypass] Bypassing TPM 2.0 & SecureBoot verification checks...", isMajorPhase: false, iconName: "lock.open.fill"),
                JailbreakLogStep(id: 9, titleRu: "[Winlogon] Создание профиля Администратора (OOBE Bypass)...", titleEn: "[Winlogon] Creating Administrator profile (OOBE Bypass)...", isMajorPhase: false, iconName: "person.crop.circle.badge.checkmark"),
                JailbreakLogStep(id: 10, titleRu: "[DirectX] Инициализация графического конвейера DX12 / WDDM...", titleEn: "[DirectX] Initializing DX12 & WDDM graphics pipeline...", isMajorPhase: false, iconName: "bolt.fill"),
                JailbreakLogStep(id: 11, titleRu: "Фаза 2: Реестр и подсистема драйверов настроены", titleEn: "Phase 2: Registry & Driver Subsystems Configured", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                JailbreakLogStep(id: 12, titleRu: "[Services] Запуск служб Windows Explorer и DWM...", titleEn: "[Services] Enabling Windows Explorer & DWM shell services...", isMajorPhase: false, iconName: "server.rack"),
                JailbreakLogStep(id: 13, titleRu: "[BSOD] Подавление системных вотчдогов CRITICAL_PROCESS_DIED...", titleEn: "[BSOD] Suppressing CRITICAL_PROCESS_DIED watchdogs...", isMajorPhase: false, iconName: "shield.fill"),
                JailbreakLogStep(id: 14, titleRu: "[Bootmgr] Обновление BCD: режим без проверки подписи...", titleEn: "[Bootmgr] Updating BCD: /nointegritychecks enabled...", isMajorPhase: false, iconName: "arrow.clockwise"),
                JailbreakLogStep(id: 15, titleRu: "Фаза 3: Windows 11 готова к первому запуску", titleEn: "Phase 3: Windows 11 Ready for First Boot", isMajorPhase: true, iconName: "sparkles")
            ]
        case .ubuntu:
            return [
                JailbreakLogStep(id: 1, titleRu: "[U-Boot] Инициализация device tree blob (dtb) для Apple Silicon...", titleEn: "[U-Boot] Initializing device tree blob (dtb) for Apple Silicon...", isMajorPhase: false, iconName: "cpu"),
                JailbreakLogStep(id: 2, titleRu: "[Ext4] Форматирование /dev/nvme0n1p2 в файловую систему ext4...", titleEn: "[Ext4] Formatting /dev/nvme0n1p2 filesystem to ext4 (64k)...", isMajorPhase: false, iconName: "square.grid.2x2.fill"),
                JailbreakLogStep(id: 3, titleRu: "[debootstrap] Распаковка базовой rootfs Ubuntu 26.04 LTS...", titleEn: "[debootstrap] Unpacking Ubuntu 26.04 Noble LTS rootfs...", isMajorPhase: false, iconName: "archivebox.fill"),
                JailbreakLogStep(id: 4, titleRu: "[Kernel] Установка ядра Linux 6.10-noble-arm64...", titleEn: "[Kernel] Installing Linux Kernel 6.10-noble-arm64...", isMajorPhase: false, iconName: "memorychip"),
                JailbreakLogStep(id: 5, titleRu: "[initramfs] Генерация initramfs образа (zstd сжатие)...", titleEn: "[initramfs] Generating initramfs image with zstd compression...", isMajorPhase: false, iconName: "bolt.horizontal.fill"),
                JailbreakLogStep(id: 6, titleRu: "Фаза 1: Корневая файловая система и Linux ядро установлены", titleEn: "Phase 1: Linux Kernel & RootFS Installed", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                JailbreakLogStep(id: 7, titleRu: "[systemd] Настройка systemd таргетов и служб multi-user...", titleEn: "[systemd] Configuring systemd targets and multi-user services...", isMajorPhase: false, iconName: "server.rack"),
                JailbreakLogStep(id: 8, titleRu: "[Sudo] Настройка прав sudo для пользователя 'cort1so1'...", titleEn: "[Sudo] Granting root sudoers privileges to user 'cort1so1'...", isMajorPhase: false, iconName: "crown.fill"),
                JailbreakLogStep(id: 9, titleRu: "[APT] Обновление репозиториев и установка базовых утилит...", titleEn: "[APT] Updating repository sources and installing essential packages...", isMajorPhase: false, iconName: "shippingbox.fill"),
                JailbreakLogStep(id: 10, titleRu: "[Mesa] Инициализация Gallium GPU и Wayland композитора...", titleEn: "[Mesa] Initializing Asahi GPU Gallium driver & Wayland compositor...", isMajorPhase: false, iconName: "bolt.fill"),
                JailbreakLogStep(id: 11, titleRu: "Фаза 2: Графический стек Mesa и Wayland настроены", titleEn: "Phase 2: Mesa Graphics Stack & Wayland Configured", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                JailbreakLogStep(id: 12, titleRu: "[GNOME] Развертывание окружения рабочего стола GNOME 47...", titleEn: "[GNOME] Deploying GNOME 47 Desktop Environment & Shell...", isMajorPhase: false, iconName: "macwindow"),
                JailbreakLogStep(id: 13, titleRu: "[Network] Запуск NetworkManager и демона wpa_supplicant...", titleEn: "[Network] Starting NetworkManager & wpa_supplicant daemon...", isMajorPhase: false, iconName: "wifi"),
                JailbreakLogStep(id: 14, titleRu: "[GRUB] Установка загрузчика GRUB-EFI в /boot/efi...", titleEn: "[GRUB] Installing GRUB-EFI bootloader into /boot/efi...", isMajorPhase: false, iconName: "arrow.triangle.merge"),
                JailbreakLogStep(id: 15, titleRu: "Фаза 3: Ubuntu 26.04 готова к перезагрузке", titleEn: "Phase 3: Ubuntu 26.04 Ready for Reboot", isMajorPhase: true, iconName: "sparkles")
            ]
        }
    }
}

enum DowngradeEasterAlert: Identifiable {
    case easter2Warning
    case confirmInstall(EasterFirmware)

    var id: String {
        switch self {
        case .easter2Warning: return "easter2Warning"
        case .confirmInstall(let fw): return "confirm_\(fw.rawValue)"
        }
    }
}

// MARK: - Custom Logos for OS Recovery Screen

struct WindowsLogoView: View {
    var color: Color
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Rectangle().fill(color).frame(width: 44, height: 44)
                Rectangle().fill(color).frame(width: 44, height: 44)
            }
            HStack(spacing: 6) {
                Rectangle().fill(color).frame(width: 44, height: 44)
                Rectangle().fill(color).frame(width: 44, height: 44)
            }
        }
    }
}

struct UbuntuLogoView: View {
    var color: Color
    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 14)
                .frame(width: 84, height: 84)
            Circle().fill(color).frame(width: 20, height: 20).offset(y: -42)
            Circle().fill(color).frame(width: 20, height: 20).offset(x: 36, y: 21)
            Circle().fill(color).frame(width: 20, height: 20).offset(x: -36, y: 21)
        }
    }
}

// MARK: - EasterFirmwareProcessView (Dopamine-style installation pipeline for custom OS)

struct EasterFirmwareProcessView: View {
    let firmware: EasterFirmware
    var onComplete: () -> Void

    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("simulationSpeedMultiplier") private var simulationSpeedMultiplier: Double = 1.0
    @AppStorage("installedOS") private var installedOS: String = "iOS"
    @AppStorage("safeMode") private var safeMode: Bool = false

    @State private var phase: DopamineProcessPhase = .logging
    @State private var visibleLogs: [JailbreakLogStep] = []
    @State private var currentStepIndex: Int = 0
    @State private var restoreProgress: Double = 0.0
    @State private var restoreTimer: Timer? = nil

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var logSteps: [JailbreakLogStep] {
        firmware.logs(isRu: isRu)
    }

    private var progressRatio: Double {
        Double(currentStepIndex) / Double(max(1, logSteps.count))
    }

    private var currentPhaseDescription: String {
        if currentStepIndex == 0 {
            return isRu ? "Прошивка, удачи!" : "Flashing, good luck!"
        } else if currentStepIndex < logSteps.count {
            let current = logSteps[currentStepIndex - 1]
            return isRu ? current.titleRu : current.titleEn
        } else {
            return isRu ? "Прошивка, удачи!" : "Flashing, good luck!"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch phase {
            case .logging:
                loggingView
                    .transition(.opacity)

            case .restoreWhite, .glitchRedMultiply:
                restoreFirmwareView
                    .transition(.opacity)

            case .respring:
                NeoSpringView(onFinished: {
                    self.onComplete()
                })
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(phase != .logging)
        .onAppear {
            runExecutionPipeline(stepIndex: 0)
        }
        .onDisappear {
            restoreTimer?.invalidate()
        }
    }

    // MARK: - Logging Interface
    private var loggingView: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Circle().fill(firmware.primaryColor).frame(width: 8, height: 8)
                    Circle().fill(firmware.primaryColor.opacity(0.7)).frame(width: 8, height: 8)
                    Circle().fill(firmware.primaryColor.opacity(0.4)).frame(width: 8, height: 8)
                }

                Spacer()

                Text(String(format: "%d%% • %d/%d", Int(progressRatio * 100), currentStepIndex, logSteps.count))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: firmware.systemIcon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(firmware.primaryColor)
                    Text(firmware.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(white: 0.05))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 2.5)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [firmware.primaryColor.opacity(0.8), firmware.primaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(8, geo.size.width * CGFloat(progressRatio)),
                            height: 2.5
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStepIndex)
                }
            }
            .frame(height: 2.5)

            // Log stream
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(Array(visibleLogs.enumerated().reversed()), id: \.element.id) { index, step in
                            let isCurrentRunning = (index == visibleLogs.count - 1 && currentStepIndex < logSteps.count)

                            HStack(alignment: .center, spacing: 12) {
                                if isCurrentRunning {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: firmware.primaryColor))
                                        .scaleEffect(0.85)
                                        .frame(width: 22, height: 22)
                                } else if step.isMajorPhase {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(firmware.primaryColor)
                                        .frame(width: 22, height: 22)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(firmware.primaryColor.opacity(0.9))
                                        .frame(width: 22, height: 22)
                                }

                                Text(isRu ? step.titleRu : step.titleEn)
                                    .font(.system(
                                        size: step.isMajorPhase ? 14 : 13,
                                        weight: step.isMajorPhase ? .bold : (isCurrentRunning ? .semibold : .regular),
                                        design: .monospaced
                                    ))
                                    .foregroundColor(
                                        step.isMajorPhase
                                            ? firmware.primaryColor
                                            : (isCurrentRunning ? Color.white : Color.white.opacity(0.8))
                                    )
                                    .lineLimit(2)

                                Spacer(minLength: 0)

                                if step.isMajorPhase {
                                    Text(isRu ? "OK" : "DONE")
                                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2.5)
                                        .background(firmware.primaryColor)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                isCurrentRunning
                                    ? firmware.primaryColor.opacity(0.12)
                                    : (step.isMajorPhase ? firmware.primaryColor.opacity(0.08) : Color.clear)
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

            // Bottom bar
            HStack(spacing: 10) {
                Text(isRu ? "Прошивка, удачи!" : "Flashing, good luck!")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(firmware.primaryColor)

                Text("•")
                    .foregroundColor(.white.opacity(0.4))

                Text(currentPhaseDescription)
                    .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)

                Spacer()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: firmware.primaryColor))
                    .scaleEffect(0.75)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color(white: 0.05))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 0.5),
                alignment: .top
            )
        }
        .background(Color.black)
    }

    // MARK: - Restore View (OS Logo + Progress bar)
    private var restoreFirmwareView: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 48) {
                switch firmware {
                case .android:
                    AndroidRobotHead(color: firmware.primaryColor)
                        .frame(width: 96, height: 96)
                case .windows:
                    WindowsLogoView(color: firmware.primaryColor)
                        .frame(width: 96, height: 96)
                case .ubuntu:
                    UbuntuLogoView(color: firmware.primaryColor)
                        .frame(width: 96, height: 96)
                }

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(white: 0.22))
                        .frame(width: 210, height: 4.5)

                    Capsule()
                        .fill(firmware.primaryColor)
                        .frame(width: max(4.5, 210 * CGFloat(min(1.0, max(0.0, restoreProgress)))), height: 4.5)
                }
                .frame(width: 210, height: 4.5)
            }
        }
    }

    // Pipeline
    private func runExecutionPipeline(stepIndex: Int) {
        let speed = max(0.2, min(20.0, simulationSpeedMultiplier))
        if stepIndex < logSteps.count {
            let step = logSteps[stepIndex]
            self.currentStepIndex = stepIndex + 1

            if step.isMajorPhase {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.visibleLogs.append(step)
            }

            let baseDelay = 0.38 / speed
            let delay = step.isMajorPhase ? (baseDelay * 1.4) : baseDelay

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.runExecutionPipeline(stepIndex: stepIndex + 1)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.8 / speed)) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.phase = .restoreWhite
                }
                self.startRestoreSequence()
            }
        }
    }

    private func startRestoreSequence() {
        let speed = max(0.2, min(20.0, simulationSpeedMultiplier))
        self.restoreProgress = 0.0
        let totalDuration: Double = 40.0 / speed
        let interval: Double = 0.05
        var elapsed: Double = 0.0

        self.restoreTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            elapsed += interval
            let normalizedTime = (elapsed / totalDuration) * 40.0
            self.restoreProgress = calculateRestoreProgress(at: normalizedTime)

            if elapsed >= totalDuration || self.restoreProgress >= 1.0 {
                self.restoreProgress = 1.0
                timer.invalidate()
                self.restoreTimer = nil

                // Save installed OS
                self.installedOS = firmware.name
                UserDefaults.standard.set(firmware.name, forKey: "installedOS")

                withAnimation(.easeInOut(duration: 0.5)) {
                    self.phase = .respring
                }
            }
        }
    }

    private func calculateRestoreProgress(at elapsedNormalizedTime: Double) -> Double {
        let t = max(0.0, min(40.0, elapsedNormalizedTime))
        if t >= 40.0 { return 1.0 }

        let keyframes: [(time: Double, progress: Double)] = [
            (0.0, 0.0),
            (4.5, 0.12),
            (6.0, 0.12),
            (10.5, 0.28),
            (12.5, 0.28),
            (17.5, 0.46),
            (19.0, 0.46),
            (24.5, 0.65),
            (26.5, 0.65),
            (31.0, 0.80),
            (32.5, 0.80),
            (37.0, 0.93),
            (38.5, 0.93),
            (40.0, 1.00)
        ]

        for i in 0..<(keyframes.count - 1) {
            let k1 = keyframes[i]
            let k2 = keyframes[i + 1]

            if t >= k1.time && t <= k2.time {
                let duration = k2.time - k1.time
                if duration <= 0 { return k2.progress }
                let fraction = (t - k1.time) / duration
                return k1.progress + (k2.progress - k1.progress) * fraction
            }
        }
        return 1.0
    }
}

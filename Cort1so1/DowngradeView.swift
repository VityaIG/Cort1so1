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
                    VStack(alignment: .center, spacing: 16) {
                        if let image = UIImage(named: "easter2") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "easter2", ofType: "png") ?? "") {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        } else {
                            Image("easter2")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }

                        Button(action: {
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
                            VStack(spacing: 8) {
                                Image(systemName: "ladybug.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green)
                                Text("android_build_override")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppCustomStyle.resolveBgColor(customHex: customBgColorHex, themeId: customAppBgTheme).ignoresSafeArea())
            .navigationTitle(isRu ? "Откат iOS" : "iOS Downgrade")
            .sheet(item: $activeFirmware) { firmware in
                DowngradeExecutionSheet(firmware: firmware, appLanguage: appLanguage, verbose: verboseRestore)
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

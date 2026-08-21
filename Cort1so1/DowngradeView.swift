import SwiftUI
import UIKit

struct DowngradeView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @State private var activeFirmware: FirmwareVersion? = nil

    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Modern Header
                    headerSection
                    
                    // Device Banner
                    deviceInfoBanner

                    // Firmware List
                    firmwareSection(title: "LATEST & BETAS", groupName: "LATEST & BETAS")
                    firmwareSection(title: "STABLE RELEASES", groupName: "STABLE RELEASES")

                    // Easter Egg Spacer
                    Color.clear.frame(height: 100)

                    // Easter Egg Section
                    easterEggSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 60)
            }
            .background(
                ZStack {
                    Color.black.ignoresSafeArea()
                    // Subtle background gradient
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                }
            )
            .navigationBarHidden(true)
            .sheet(item: $activeFirmware) { firmware in
                DowngradeExecutionSheet(firmware: firmware, appLanguage: appLanguage)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Downgrade")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(isRu ? "Восстановление прошивок через Checkm8" : "Restore firmware versions via Checkm8")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(Color(white: 0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 10)
    }

    private var deviceInfoBanner: some View {
        HStack(spacing: 16) {
            Image(systemName: "iphone.gen3")
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("iPhone 15 Pro Max")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("A17 Pro • iOS 17.5.1")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(white: 0.5))
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.system(size: 20))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.1))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func firmwareSection(title: String, groupName: String) -> some View {
        let items = sampleFirmwares.filter { $0.group == groupName }
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(Color.gray)
                    .tracking(1.5)
                    .padding(.leading, 4)

                VStack(spacing: 12) {
                    ForEach(items) { item in
                        firmwareCard(item)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func firmwareCard(_ item: FirmwareVersion) -> some View {
        Button {
            triggerSelectionHaptic()
            activeFirmware = item
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(item.badgeColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundColor(item.badgeColor)
                }

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.version)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(item.badgeText)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(item.badgeColor.opacity(0.2))
                            .foregroundColor(item.badgeColor)
                            .clipShape(Capsule())
                    }
                    
                    HStack {
                        Text("Build: \(item.build)")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(white: 0.6))
                        Spacer()
                        Text(item.features)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(white: 0.5))
                    }
                }
            }
            .padding(16)
            .background(Color(white: 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(ModernScaleButtonStyle())
    }

    private var easterEggSection: some View {
        VStack(spacing: 24) {
            Image("IMG_9744")
                .resizable()
                .scaledToFill()
                .frame(width: 240, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            Button {
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
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "ant.fill")
                        .font(.system(size: 20))
                    Text("Android 17 Beta")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.black)
                .frame(height: 56)
                .frame(maxWidth: 240)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                )
                .clipShape(Capsule())
                .shadow(color: Color.green.opacity(0.4), radius: 12, y: 4)
            }
            .buttonStyle(ModernScaleButtonStyle())
        }
        .padding(.bottom, 60)
    }

    private func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// Custom button scale effect for firmwares
struct ModernScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - 60-Second Flash Execution View

struct DowngradeExecutionSheet: View {
    let firmware: FirmwareVersion
    let appLanguage: String
    @Environment(\.presentationMode) var presentationMode
    
    private var isRu: Bool {
        appLanguage == "ru"
    }
    
    // Status
    @State private var isRestoring = false
    @State private var elapsedSeconds: Double = 0.0
    @State private var restoreSpeedMBs: Double = 0.0
    @State private var terminalLogs: [String] = []
    @State private var currentStageIndex: Int = -1
    
    // Alerts
    @State private var showCancelAlert = false
    @State private var showSuccessAlert = false
    
    @State private var restoreTimer: Timer?
    
    // 60-second downgrade stages
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
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color(white: 0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isRu ? "Установка прошивки" : "Flashing Firmware")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(firmware.version) (\(firmware.build))")
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .foregroundColor(firmware.badgeColor)
                    }
                    Spacer()
                    
                    if !isRestoring && elapsedSeconds == 0 {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(white: 0.5))
                        }
                    }
                }
                .padding(20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Progress ring and center data
                        progressViewSection
                        
                        // Action Button
                        actionButton
                        
                        // Stages list
                        stagesListSection
                        
                        // Terminal
                        terminalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
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
                message: Text(isRu ? "Устройство было успешно восстановлено на \(firmware.version)." : "Your device was successfully restored to \(firmware.version)."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onDisappear {
            restoreTimer?.invalidate()
        }
    }
    
    private var progressViewSection: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 16)
                .frame(width: 220, height: 220)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(elapsedSeconds / 60.0))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [firmware.badgeColor, firmware.badgeColor.opacity(0.5)]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: elapsedSeconds)
            
            VStack(spacing: 8) {
                Text(String(format: "%.0f%%", (elapsedSeconds / 60.0) * 100))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(String(format: "%.1f MB/s", restoreSpeedMBs))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(white: 0.6))
            }
        }
        .padding(.vertical, 10)
    }
    
    private var stagesListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isRu ? "СТАТУС УСТАНОВКИ" : "INSTALLATION STATUS")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                    let isActive = currentStageIndex == index
                    let isCompleted = elapsedSeconds > stage.range.upperBound
                    
                    HStack(spacing: 16) {
                        // Checkbox / Circle
                        ZStack {
                            let fColor: Color = isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor.opacity(0.2) : Color.clear)
                            let sColor: Color = isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor : Color(white: 0.3))
                            
                            Circle()
                                .foregroundColor(fColor)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle()
                                        .stroke(sColor, lineWidth: 2)
                                )
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                            } else if isActive {
                                Circle()
                                    .fill(firmware.badgeColor)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Text(stage.title)
                            .font(.system(size: 15, weight: isActive ? .bold : .medium))
                            .foregroundColor(isCompleted ? .white : (isActive ? firmware.badgeColor : Color(white: 0.5)))
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(white: 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    private var actionButton: some View {
        Group {
            if isRestoring {
                Button(action: {
                    showCancelAlert = true
                }) {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.9)
                        Text(isRu ? "Остановить" : "Stop Flashing")
                    }
                    .font(.system(.body, design: .default))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.red, lineWidth: 1))
                }
            } else if elapsedSeconds == 60 {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(isRu ? "Завершить" : "Done")
                        .font(.system(.body, design: .default))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            } else {
                Button(action: { start60SecondsFlashingSequence() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                        Text(isRu ? "Начать откат (60 сек)" : "Start Flashing (60s)")
                    }
                    .font(.system(.body, design: .default))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(firmware.badgeColor)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .buttonStyle(ModernScaleButtonStyle())
    }
    
    private var terminalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isRu ? "ТЕРМИНАЛ" : "TERMINAL LOG")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(.gray)
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 4) {
                        if terminalLogs.isEmpty {
                            Text("Waiting for command...")
                                .foregroundColor(Color(white: 0.4))
                        } else {
                            ForEach(terminalLogs.indices, id: \.self) { i in
                                Text(terminalLogs[i])
                                    .id(i)
                            }
                        }
                    }
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(white: 0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .frame(height: 140)
                .background(Color(white: 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
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
        
        restoreTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            elapsedSeconds += 0.1
            let currentSecondsInt = Int(elapsedSeconds)
            let formattedTime = String(format: "[%02d:%02d]", currentSecondsInt / 60, currentSecondsInt % 60)
            
            if elapsedSeconds <= 10.0 {
                if currentStageIndex != 0 { currentStageIndex = 0; triggerSelectionHaptic() }
                restoreSpeedMBs = Double.random(in: 44.0...54.0)
                if currentSecondsInt == 3 && terminalLogs.count < 3 {
                    terminalLogs.append("\(formattedTime) [ApTicket] Validating SHSH2 ApTicket payload")
                } else if currentSecondsInt == 7 && terminalLogs.count < 4 {
                    terminalLogs.append("\(formattedTime) [TSS] Received signed ApTicket hash: \(firmware.sha256.prefix(10))...")
                }
            }
            else if elapsedSeconds <= 25.0 {
                if currentStageIndex != 1 { currentStageIndex = 1; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [APFS] Mounting DMG RootFS container: disk0s1s1") }
                restoreSpeedMBs = Double.random(in: 55.0...68.0)
                if currentSecondsInt == 18 && terminalLogs.count < 6 {
                    terminalLogs.append("\(formattedTime) [Cryptex1] Verifying OS TrustCache and entitlements...")
                }
            }
            else if elapsedSeconds <= 40.0 {
                if currentStageIndex != 2 { currentStageIndex = 2; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [SEP] Sending signed Secure Enclave microcode...") }
                restoreSpeedMBs = Double.random(in: 52.0...64.0)
                if currentSecondsInt == 33 && terminalLogs.count < 8 {
                    terminalLogs.append("\(formattedTime) [Baseband] Flashing modem firmware version 4.02.01: OK")
                }
            }
            else if elapsedSeconds <= 52.0 {
                if currentStageIndex != 3 { currentStageIndex = 3; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [APFS] Creating root snapshot com.apple.os.update") }
                restoreSpeedMBs = Double.random(in: 60.0...75.0)
                if currentSecondsInt == 47 && terminalLogs.count < 10 {
                    terminalLogs.append("\(formattedTime) [Kernel] Updating KASLR slide & devicetree components...")
                }
            }
            else if elapsedSeconds < 60.0 {
                if currentStageIndex != 4 { currentStageIndex = 4; triggerSelectionHaptic(); terminalLogs.append("\(formattedTime) [NVRAM] Updating boot-args: rootless=1 cs_enforcement=1") }
                restoreSpeedMBs = Double.random(in: 25.0...40.0)
                if currentSecondsInt == 56 && terminalLogs.count < 12 {
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
                showSuccessAlert = true
            }
        }
    }
    
    private func cancelFlashing() {
        restoreTimer?.invalidate()
        restoreTimer = nil
        isRestoring = false
        elapsedSeconds = 0.0
        restoreSpeedMBs = 0.0
        currentStageIndex = -1
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

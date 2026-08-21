import SwiftUI
import UIKit

/// Полностью переработанный экран «Откат iOS» (iOS Downgrade) в минималистичном стиле
/// на основе предложенного дизайна
struct DowngradeView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    
    // Состояние процесса отката
    @State private var activeFirmware: FirmwareVersion? = nil
    
    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    firmwareSection(title: "LATEST & BETAS", groupName: "LATEST & BETAS")
                    firmwareSection(title: "STABLE RELEASES", groupName: "STABLE RELEASES")
                    
                    // --- EASTER EGG ---
                    Color.clear.frame(height: 1500)
                    
                    VStack(spacing: 16) {
                        AsyncImage(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Cat_August_2010-4.jpg/1280px-Cat_August_2010-4.jpg")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                ZStack {
                                    Color(white: 0.2)
                                    Image(systemName: "cat.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(white: 0.5))
                                        .padding(40)
                                }
                            }
                        }
                        .frame(width: 240, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        
                        Button {
                            self.triggerSelectionHaptic()
                            let androidFirmware = FirmwareVersion(
                                version: "Android 17 Beta",
                                build: "SWEET_CAT",
                                features: "Easter Egg Bypass",
                                badgeText: "SECRET",
                                badgeColor: .green,
                                group: "EASTER EGG",
                                sha256: "deadbeef00000000000000000000000000000000000000000000000000000000"
                            )
                            self.activeFirmware = androidFirmware
                        } label: {
                            Text("Android 17 Beta")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(strings.downgradeTitle)
            .navigationBarTitleDisplayMode(.inline)
            // Использование sheet для показа процесса отката
            .sheet(item: $activeFirmware) { firmware in
                DowngradeExecutionSheet(firmware: firmware, appLanguage: appLanguage)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Список прошивок
    
    @ViewBuilder
    private func firmwareSection(title: String, groupName: String) -> some View {
        let items = sampleFirmwares.filter { $0.group == groupName }
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(white: 0.4))
                    .padding(.leading, 4)
                
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        firmwareRow(item)
                        
                        if index < items.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(Color(white: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
    
    @ViewBuilder
    private func firmwareRow(_ item: FirmwareVersion) -> some View {
        HStack(spacing: 14) {
            // Иконка
            ZStack {
                Circle()
                    .strokeBorder(Color(white: 0.3), lineWidth: 1.5)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "gearshape")
                    .font(.system(size: 22))
                    .foregroundColor(Color(white: 0.7))
            }
            
            // Информация
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(item.version)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(item.badgeText)
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.badgeColor.opacity(0.2))
                        .foregroundColor(item.badgeColor)
                        .clipShape(Capsule())
                }
                
                Text("Build \(item.build) • \(item.features)")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(white: 0.5))
            }
            
            Spacer(minLength: 0)
            
            // Кнопка
            Button {
                self.triggerSelectionHaptic()
                activeFirmware = item
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .font(.system(size: 12, weight: .bold))
                    Text("Downgrade")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(item.badgeColor)
                .clipShape(Capsule())
            }
        }
        .padding(16)
    }
    
    private func self.triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// MARK: - Экран выполнения процесса (Sheet)

struct DowngradeExecutionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let firmware: FirmwareVersion
    let appLanguage: String
    
    @State private var isRestoring: Bool = false
    @State private var elapsedSeconds: Double = 0.0
    @State private var totalSeconds: Double = 60.0
    @State private var currentStageIndex: Int = 0
    @State private var restoreSpeedMBs: Double = 0.0
    @State private var terminalLogs: [String] = []
    @State private var restoreTimer: Timer?
    @State private var showSuccessAlert: Bool = false
    @State private var showCancelAlert: Bool = false
    
    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var progressRatio: Double {
        min(1.0, elapsedSeconds / totalSeconds)
    }

    // 5 этапов восстановления
    private var restoreStages: [(titleRu: String, titleEn: String, detailRu: String, detailEn: String, range: ClosedRange<Double>)] {
        [
            (
                "1. Проверка подписи TSS / SHSH2",
                "1. Validating TSS / SHSH2 Tickets",
                "Запрос gs.apple.com & верификация бинарного ApTicket...",
                "Querying gs.apple.com & validating ApTicket payload...",
                0.0...10.0
            ),
            (
                "2. Распаковка RootFS & Cryptex1",
                "2. Extracting RootFS & Cryptex1 OS",
                "Извлечение системного образа DMG и компонентов Cryptex OS...",
                "Extracting DMG system image and Cryptex OS components...",
                10.0...25.0
            ),
            (
                "3. Прошивка SEP & Baseband",
                "3. Flashing SEP & Baseband Firmware",
                "Отправка подписанного Secure Enclave микрокода в чип безопасности...",
                "Sending signed Secure Enclave microcode to security processor...",
                25.0...40.0
            ),
            (
                "4. Запись APFS Snapshot & Kernel",
                "4. Writing APFS Snapshot & KernelCache",
                "Создание корневого снимка APFS и синхронизация KernelCache...",
                "Creating APFS root snapshot and synchronizing KernelCache...",
                40.0...52.0
            ),
            (
                "5. Финализация и NVRAM",
                "5. Finalizing & NVRAM Boot Update",
                "Обновление системных переменных NVRAM и верификация SHA-256...",
                "Updating NVRAM boot variables and verifying SHA-256 integrity...",
                52.0...60.0
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Цель
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isRu ? "Целевая прошивка" : "Target Firmware")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(white: 0.5))
                                Text(firmware.version)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Text(firmware.badgeText)
                                .font(.system(size: 12, weight: .heavy))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(firmware.badgeColor.opacity(0.2))
                                .foregroundColor(firmware.badgeColor)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 20)
                        
                        // Процесс выполнения
                        restoreExecutionCard
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle(isRu ? "Откат устройства" : "Device Downgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isRu ? "Закрыть" : "Close") {
                        if self.isRestoring {
                            self.showCancelAlert = true
                        } else {
                            self.dismiss()
                        }
                    }
                    .foregroundColor(Color(white: 0.6))
                }
            }
            // Алерт успешного завершения процесса отката
            .alert(strings.downgradeFinished, isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { self.dismiss() }
            } message: {
                Text(strings.downgradeFinishedMsg)
            }
            // Алерт прерывания
            .alert(isRu ? "Прервать откат?" : "Cancel Downgrade?", isPresented: $showCancelAlert) {
                Button(isRu ? "Прервать" : "Stop", role: .destructive) {
                    self.cancelFlashing()
                    self.dismiss()
                }
                Button(strings.cancelBtn, role: .cancel) { }
            } message: {
                Text(isRu ? "Процесс прошивки будет безопасно остановлен." : "The restore process will be safely terminated.")
            }
            .onAppear {
                // Автозапуск можно включить, или ждать нажатия кнопки
            }
        }
    }
    
    private var restoreExecutionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Прогресс бар
            VStack(spacing: 8) {
                HStack {
                    Text(isRu ? "Прогресс" : "Progress")
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(Int(progressRatio * 100))%")
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(firmware.badgeColor)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(white: 0.2))
                            .frame(height: 8)
                        Capsule()
                            .fill(firmware.badgeColor)
                            .frame(width: max(0, geo.size.width * progressRatio), height: 8)
                            .animation(.linear(duration: 0.1), value: progressRatio)
                    }
                }
                .frame(height: 8)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Этапы
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<restoreStages.count, id: \.self) { i in
                    let stage = restoreStages[i]
                    let isActive = isRestoring && stage.range.contains(elapsedSeconds)
                    let isCompleted = elapsedSeconds > stage.range.upperBound
                    
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor.opacity(0.2) : Color.clear))
                                .stroke(isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor : Color(white: 0.3)), lineWidth: 1.5)
                                .frame(width: 14, height: 14)
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.black)
                            } else if isActive {
                                Circle()
                                    .fill(firmware.badgeColor)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isRu ? stage.titleRu : stage.titleEn)
                                .font(.system(.subheadline, design: .default))
                                .fontWeight(.semibold)
                                .foregroundColor(isActive || isCompleted ? .white : Color(white: 0.5))
                            
                            if isActive {
                                Text(isRu ? stage.detailRu : stage.detailEn)
                                    .font(.system(.caption2, design: .default))
                                    .foregroundColor(firmware.badgeColor)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            
            // Терминал
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "terminal")
                    Text("Futurerestore Engine")
                    Spacer()
                    if self.isRestoring {
                        Text("\(String(format: "%.1f", restoreSpeedMBs)) MB/s")
                            .foregroundColor(firmware.badgeColor)
                    }
                }
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color(white: 0.5))
                .padding(.bottom, 8)
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 4) {
                            if terminalLogs.isEmpty {
                                Text("Awaiting command...")
                                    .foregroundColor(Color(white: 0.3))
                            } else {
                                ForEach(terminalLogs.indices, id: \.self) { i in
                                    Text(terminalLogs[i])
                                        .id(i)
                                }
                            }
                        }
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(white: 0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 120)
                    .onChange(of: terminalLogs.count) { _ in
                        if !terminalLogs.isEmpty {
                            withAnimation {
                                proxy.scrollTo(terminalLogs.count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(white: 0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            // Кнопка
            if self.isRestoring {
                Button(action: {
                    self.showCancelAlert = true
                }) {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.9)
                        Text(isRu ? "Откат выполняется... Прервать" : "Flashing... Cancel")
                    }
                    .font(.system(.body, design: .default))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            } else {
                Button(action: start60SecondsFlashingSequence) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .font(.system(size: 18))
                        Text(isRu ? "Начать откат (60 сек)" : "Start Downgrade (60s)")
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
        .padding(16)
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Логика 60-секундного отката (1 минута)
    private func start60SecondsFlashingSequence() {
        triggerMajorHaptic()
        isRestoring = true
        elapsedSeconds = 0.0
        totalSeconds = 60.0
        currentStageIndex = 0
        restoreSpeedMBs = 48.5
        terminalLogs = [
            "[00:00] [Futurerestore v2.4.1] Initializing downgrade engine...",
            "[00:01] [TSS] Handshake with gs.apple.com:443 established"
        ]

        self.restoreTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.elapsedSeconds += 0.1
            let currentSecondsInt = Int(self.elapsedSeconds)
            let formattedTime = String(format: "[%02d:%02d]", currentSecondsInt / 60, currentSecondsInt % 60)

            if self.elapsedSeconds <= 10.0 {
                if self.currentStageIndex != 0 {
                    self.currentStageIndex = 0
                    self.triggerSelectionHaptic()
                }
                self.restoreSpeedMBs = Double.random(in: 44.0...54.0)
                if currentSecondsInt == 3 && self.terminalLogs.count < 3 {
                    self.terminalLogs.append("\(formattedTime) [ApTicket] Validating SHSH2 ApTicket cryptographic payload: OK")
                } else if currentSecondsInt == 7 && self.terminalLogs.count < 4 {
                    self.terminalLogs.append("\(formattedTime) [TSS] Received signed ApTicket hash: \(self.firmware.sha256.prefix(10))...")
                }
            }
            else if self.elapsedSeconds <= 25.0 {
                if self.currentStageIndex != 1 {
                    self.currentStageIndex = 1
                    self.triggerSelectionHaptic()
                    self.terminalLogs.append("\(formattedTime) [APFS] Mounting DMG RootFS container: disk0s1s1")
                }
                self.restoreSpeedMBs = Double.random(in: 55.0...68.0)
                if currentSecondsInt == 18 && self.terminalLogs.count < 6 {
                    self.terminalLogs.append("\(formattedTime) [Cryptex1] Verifying OS TrustCache and entitlements...")
                }
            }
            else if self.elapsedSeconds <= 40.0 {
                if self.currentStageIndex != 2 {
                    self.currentStageIndex = 2
                    self.triggerSelectionHaptic()
                    self.terminalLogs.append("\(formattedTime) [SEP] Sending signed Secure Enclave microcode to SEP chip...")
                }
                self.restoreSpeedMBs = Double.random(in: 52.0...64.0)
                if currentSecondsInt == 33 && self.terminalLogs.count < 8 {
                    self.terminalLogs.append("\(formattedTime) [Baseband] Flashing modem firmware version 4.02.01: OK")
                }
            }
            else if self.elapsedSeconds <= 52.0 {
                if self.currentStageIndex != 3 {
                    self.currentStageIndex = 3
                    self.triggerSelectionHaptic()
                    self.terminalLogs.append("\(formattedTime) [APFS] Creating root snapshot com.apple.os.update-\(self.firmware.build)")
                }
                self.restoreSpeedMBs = Double.random(in: 60.0...75.0)
                if currentSecondsInt == 47 && self.terminalLogs.count < 10 {
                    self.terminalLogs.append("\(formattedTime) [Kernel] Updating KASLR slide & devicetree components...")
                }
            }
            else if self.elapsedSeconds < 60.0 {
                if self.currentStageIndex != 4 {
                    self.currentStageIndex = 4
                    self.triggerSelectionHaptic()
                    self.terminalLogs.append("\(formattedTime) [NVRAM] Updating boot-args: rootless=1 cs_enforcement=1")
                }
                self.restoreSpeedMBs = Double.random(in: 25.0...40.0)
                if currentSecondsInt == 56 && self.terminalLogs.count < 12 {
                    self.terminalLogs.append("\(formattedTime) [SHA256] System partition integrity check passed: OK")
                }
            }
            else {
                self.elapsedSeconds = 60.0
                self.restoreSpeedMBs = 0.0
                self.terminalLogs.append("[01:00] [Done] Restore completed successfully in 60s! System ready.")
                timer.invalidate()
                self.restoreTimer = nil
                self.isRestoring = false
                self.triggerNotificationSuccess()
                self.showSuccessAlert = true
            }
        }
    }

    private func self.cancelFlashing() {
        restoreTimer?.invalidate()
        restoreTimer = nil
        isRestoring = false
        elapsedSeconds = 0.0
        restoreSpeedMBs = 0.0
        terminalLogs.append("[Terminated] Downgrade process cancelled by user.")
    }

    private func self.triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    private func triggerMajorHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    private func self.triggerNotificationSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    DowngradeView()
}

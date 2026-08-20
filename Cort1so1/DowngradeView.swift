import SwiftUI
import UIKit

/// Полностью переработанный экран «Откат iOS» (iOS Downgrade) в премиальном стиле iOS HIG
/// Включает 60-секундный (1 минута) тайминг выполнения, пошаговые этапы, живой терминал и тактильный отклик
struct DowngradeView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @State private var selectedFirmware: FirmwareVersion = sampleFirmwares[0]
    
    // Параметры восстановления
    @State private var keepUserData: Bool = true
    @State private var verifySepCryptex: Bool = true
    @State private var autoGenerateNonce: Bool = true
    
    // Состояние 60-секундного процесса
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

    // 5 этапов восстановления, точно распределенных на 60 секунд
    private var restoreStages: [(titleRu: String, titleEn: String, detailRu: String, detailEn: String, range: ClosedRange<Double>)] {
        [
            (
                "1. Проверка подписи TSS / SHSH2",
                "1. Validating TSS / SHSH2 Tickets",
                "Запрос gs.apple.com & сверка ApTicket генератора Nonce...",
                "Querying gs.apple.com & verifying ApTicket nonce generator...",
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
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Верхний информационный баннер устройства и цели
                        deviceAndTargetHeader

                        // 2. Выбор прошивки IPSW (Каталог)
                        firmwareCatalogSection

                        // 3. Спецификация и совместимость выбранной прошивки
                        firmwareDetailsCard

                        // 4. Параметры прошивки
                        restoreOptionsCard

                        // 5. Движок отката (60-секундный таймер, лог, прогресс)
                        restoreExecutionCard

                        // 6. Дисклеймер безопасности
                        disclaimerFooter
                            .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(strings.downgradeTitle)
            .navigationBarTitleDisplayMode(.inline)
            // Алерт успешного завершения 1-минутного процесса
            .alert(strings.downgradeFinished, isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("\(strings.downgradeFinishedMsg)\n\n" + (isRu ? "Целевая ОС: iOS " : "Target OS: iOS ") + "\(selectedFirmware.version) (\(selectedFirmware.build))")
            }
            // Алерт прерывания
            .alert(isRu ? "Прервать откат?" : "Cancel Downgrade?", isPresented: $showCancelAlert) {
                Button(isRu ? "Прервать" : "Stop", role: .destructive) {
                    cancelFlashing()
                }
                Button(strings.cancelBtn, role: .cancel) { }
            } message: {
                Text(isRu ? "Процесс прошивки будет безопасно остановлен." : "The restore process will be safely terminated.")
            }
        }
    }

    // MARK: - 1. Баннер устройства и целевой версии

    private var deviceAndTargetHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: "iphone.gen3")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(UIDevice.current.model)
                        .font(.system(.headline, design: .default))
                        .fontWeight(.bold)

                    HStack(spacing: 6) {
                        Text("\(isRu ? "Текущая" : "Current"): iOS \(UIDevice.current.systemVersion)")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text("arm64e")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(isRu ? "Цель" : "Target")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text(selectedFirmware.version)
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Divider()

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("SEP Cryptex: OK")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "key.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text("Nonce: 0x1111111111111111")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 2. Каталог версий IPSW

    private var firmwareCatalogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text(isRu ? "Каталог прошивок IPSW" : "IPSW Firmware Catalog")
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.bold)
                } icon: {
                    Image(systemName: "internaldrive.fill")
                        .foregroundColor(.blue)
                }

                Spacer()

                Text("\(sampleFirmwares.count) " + (isRu ? "версий" : "versions"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(sampleFirmwares) { fw in
                    let isSelected = selectedFirmware.id == fw.id

                    Button(action: {
                        if !isRestoring {
                            triggerSelectionHaptic()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFirmware = fw
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            // Индикатор радиобаттона
                            ZStack {
                                Circle()
                                    .strokeBorder(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: isSelected ? 5 : 1.5)
                                    .frame(width: 20, height: 20)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(fw.version)
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    if fw.isBeta {
                                        Text("BETA")
                                            .font(.system(size: 9, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.purple.opacity(0.15))
                                            .foregroundColor(.purple)
                                            .clipShape(Capsule())
                                    }
                                }

                                HStack(spacing: 6) {
                                    Text(fw.build)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.secondary)

                                    Text("•")
                                        .foregroundColor(.secondary.opacity(0.5))

                                    Text(fw.releaseDate(isRu: isRu))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Статус подписи
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(fw.isSigned ? Color.green : Color.orange)
                                    .frame(width: 6, height: 6)

                                Text(fw.isSigned ? (isRu ? "TSS Подписана" : "TSS Signed") : "SHSH2 Blobs")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(fw.isSigned ? .green : .orange)
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background((fw.isSigned ? Color.green : Color.orange).opacity(0.12))
                            .clipShape(Capsule())
                        }
                        .padding(12)
                        .background(
                            isSelected
                                ? Color.blue.opacity(0.09)
                                : Color(uiColor: .tertiarySystemGroupedBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSelected ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isRestoring)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 3. Спецификация выбранной прошивки

    private var firmwareDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text(strings.fwInfoTitle)
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.bold)
                } icon: {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.blue)
                }

                Spacer()

                Text("iOS \(selectedFirmware.version)")
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            VStack(spacing: 10) {
                specRow(title: strings.fwBuild, value: selectedFirmware.build, isMono: true, icon: "number", color: .indigo)
                Divider()
                specRow(title: strings.fwReleaseDate, value: selectedFirmware.releaseDate(isRu: isRu), isMono: false, icon: "calendar", color: .blue)
                Divider()
                specRow(title: strings.fwSize, value: String(format: "%.1f GB", selectedFirmware.sizeGB), isMono: false, icon: "internaldrive", color: .teal)
                Divider()
                
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(selectedFirmware.isSigned ? .green : .orange)
                        Text(strings.fwSignedStatus)
                            .font(.system(.subheadline, design: .default))
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(selectedFirmware.isSigned ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(selectedFirmware.isSigned ? strings.fwSigned : strings.fwUnsigned)
                            .foregroundColor(selectedFirmware.isSigned ? .green : .orange)
                            .font(.system(.subheadline, design: .default))
                            .fontWeight(.semibold)
                    }
                }
                
                Divider()

                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        Text(strings.fwSepCompatibility)
                            .font(.system(.subheadline, design: .default))
                    }
                    Spacer()
                    Text(selectedFirmware.sepStatus(isRu: isRu))
                        .foregroundColor(.blue)
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.medium)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func specRow(title: String, value: String, isMono: Bool, icon: String, color: Color) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(.subheadline, design: .default))
            }
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(isMono ? .system(.subheadline, design: .monospaced) : .system(.subheadline, design: .default))
        }
    }

    // MARK: - 4. Параметры восстановления

    private var restoreOptionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text(strings.restoreOptionsSection)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.bold)
            } icon: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
            }

            Toggle(isOn: $keepUserData) {
                Label {
                    Text(strings.keepDataToggle)
                        .font(.system(.subheadline, design: .default))
                } icon: {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .foregroundColor(.blue)
                }
            }
            .tint(.blue)
            .disabled(isRestoring)

            Divider()

            Toggle(isOn: $verifySepCryptex) {
                Label {
                    Text(strings.verifySepToggle)
                        .font(.system(.subheadline, design: .default))
                } icon: {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                }
            }
            .tint(.blue)
            .disabled(isRestoring)

            Divider()

            Toggle(isOn: $autoGenerateNonce) {
                Label {
                    Text(strings.bypassNoncesToggle)
                        .font(.system(.subheadline, design: .default))
                } icon: {
                    Image(systemName: "key.fill")
                        .foregroundColor(.orange)
                }
            }
            .tint(.blue)
            .disabled(isRestoring)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 5. Движок отката (60-секундный таймер)

    private var restoreExecutionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text(strings.processTitle)
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.bold)
                } icon: {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                }

                Spacer()

                if isRestoring {
                    // Точный таймер обратного отсчета (1 минута = 60 секунд)
                    let remaining = max(0, Int(ceil(totalSeconds - elapsedSeconds)))
                    let minutes = remaining / 60
                    let seconds = remaining % 60

                    HStack(spacing: 5) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 11))
                            .foregroundColor(.cyan)

                        Text(String(format: "%02d:%02d", minutes, seconds))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            if isRestoring {
                let stage = restoreStages[min(currentStageIndex, restoreStages.count - 1)]

                VStack(spacing: 12) {
                    // Текущий шаг и процент
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(isRu ? stage.titleRu : stage.titleEn)
                                .font(.system(.subheadline, design: .default))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text(isRu ? stage.detailRu : stage.detailEn)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text("\(Int(progressRatio * 100))%")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }

                    // Анимированный плавный прогресс-бар
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.blue.opacity(0.12))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(12, geo.size.width * CGFloat(progressRatio)), height: 8)
                                .animation(.linear(duration: 0.1), value: progressRatio)
                        }
                    }
                    .frame(height: 8)

                    // Статистика скорости и объема переданных данных
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f MB/s", restoreSpeedMBs))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text(String(format: "%.2f / %.1f GB (%.0fs / 60s)", progressRatio * selectedFirmware.sizeGB, selectedFirmware.sizeGB, elapsedSeconds))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    // Терминальный вывод логов восстановления
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(terminalLogs.suffix(4), id: \.self) { log in
                            Text(log)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.95))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.black.opacity(0.88))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.vertical, 4)
            }

            // Кнопка запуска / отмены
            if isRestoring {
                Button(action: {
                    showCancelAlert = true
                }) {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.9)
                        Text(isRu ? "Откат выполняется (60 сек)... Прервать" : "Flashing (60 sec)... Cancel")
                    }
                    .font(.system(.body, design: .default))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            } else {
                Button(action: start60SecondsFlashingSequence) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .font(.system(size: 18))
                        Text("\(strings.startDowngradeBtn) \(selectedFirmware.version)")
                    }
                    .font(.system(.body, design: .default))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 6. Дисклеймер

    private var disclaimerFooter: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.secondary)
                .font(.subheadline)
            Text(strings.disclaimerText)
                .font(.system(.caption, design: .default))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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

        // Таймер тикает каждые 0.1 секунды (600 тиков = 60.0 секунд)
        restoreTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            elapsedSeconds += 0.1

            let currentSecondsInt = Int(elapsedSeconds)
            let formattedTime = String(format: "[%02d:%02d]", currentSecondsInt / 60, currentSecondsInt % 60)

            // 1. Этап 1 (0s - 10s): Проверка подписи TSS / SHSH2
            if elapsedSeconds <= 10.0 {
                if currentStageIndex != 0 {
                    currentStageIndex = 0
                    triggerSelectionHaptic()
                }
                restoreSpeedMBs = Double.random(in: 44.0...54.0)

                if currentSecondsInt == 3 && terminalLogs.count < 3 {
                    terminalLogs.append("\(formattedTime) [ApTicket] Verifying Nonce 0x1111111111111111 generator: OK")
                } else if currentSecondsInt == 7 && terminalLogs.count < 4 {
                    terminalLogs.append("\(formattedTime) [TSS] Received signed ApTicket hash: \(selectedFirmware.sha256.prefix(10))...")
                }
            }
            // 2. Этап 2 (10s - 25s): Распаковка RootFS & Cryptex1 OS
            else if elapsedSeconds <= 25.0 {
                if currentStageIndex != 1 {
                    currentStageIndex = 1
                    triggerSelectionHaptic()
                    terminalLogs.append("\(formattedTime) [APFS] Mounting DMG RootFS container: disk0s1s1")
                }
                restoreSpeedMBs = Double.random(in: 55.0...68.0)

                if currentSecondsInt == 18 && terminalLogs.count < 6 {
                    terminalLogs.append("\(formattedTime) [Cryptex1] Verifying OS TrustCache and entitlements...")
                }
            }
            // 3. Этап 3 (25s - 40s): Прошивка SEP & Baseband
            else if elapsedSeconds <= 40.0 {
                if currentStageIndex != 2 {
                    currentStageIndex = 2
                    triggerSelectionHaptic()
                    terminalLogs.append("\(formattedTime) [SEP] Sending signed Secure Enclave microcode to SEP chip...")
                }
                restoreSpeedMBs = Double.random(in: 52.0...64.0)

                if currentSecondsInt == 33 && terminalLogs.count < 8 {
                    terminalLogs.append("\(formattedTime) [Baseband] Flashing modem firmware version 4.02.01: OK")
                }
            }
            // 4. Этап 4 (40s - 52s): Запись APFS Snapshot & KernelCache
            else if elapsedSeconds <= 52.0 {
                if currentStageIndex != 3 {
                    currentStageIndex = 3
                    triggerSelectionHaptic()
                    terminalLogs.append("\(formattedTime) [APFS] Creating root snapshot com.apple.os.update-\(selectedFirmware.build)")
                }
                restoreSpeedMBs = Double.random(in: 60.0...75.0)

                if currentSecondsInt == 47 && terminalLogs.count < 10 {
                    terminalLogs.append("\(formattedTime) [Kernel] Updating KASLR slide & devicetree components...")
                }
            }
            // 5. Этап 5 (52s - 60s): Финализация, NVRAM & проверка целостности
            else if elapsedSeconds < 60.0 {
                if currentStageIndex != 4 {
                    currentStageIndex = 4
                    triggerSelectionHaptic()
                    terminalLogs.append("\(formattedTime) [NVRAM] Updating boot-args: rootless=1 cs_enforcement=1")
                }
                restoreSpeedMBs = Double.random(in: 25.0...40.0)

                if currentSecondsInt == 56 && terminalLogs.count < 12 {
                    terminalLogs.append("\(formattedTime) [SHA256] System partition integrity check passed: OK")
                }
            }
            // Завершение ровно на 60 секунде
            else {
                elapsedSeconds = 60.0
                restoreSpeedMBs = 0.0
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
        terminalLogs.append("[Terminated] Downgrade process cancelled by user.")
    }

    // MARK: - Тактильные эффекты

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

#Preview {
    DowngradeView()
}

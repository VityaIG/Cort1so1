import SwiftUI

/// Полностью обновленный экран «Откат iOS» (iOS Downgrade) в нативном стиле iOS HIG
struct DowngradeView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @State private var selectedFirmware: FirmwareVersion = sampleFirmwares[0]
    
    // Параметры восстановления
    @State private var keepUserData: Bool = true
    @State private var verifySepCryptex: Bool = true
    @State private var autoGenerateNonce: Bool = true
    
    // Состояние процесса
    @State private var isRestoring: Bool = false
    @State private var restoreProgress: Double = 0.0
    @State private var currentStageIndex: Int = 0
    @State private var restoreSpeedMBs: Double = 0.0
    @State private var terminalLogs: [String] = []
    @State private var restoreTimer: Timer?
    @State private var showSuccessAlert: Bool = false
    
    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    // Этапы восстановления
    private var restoreStages: [(titleRu: String, titleEn: String, detailRu: String, detailEn: String)] {
        [
            ("Проверка подписи TSS / SHSH2", "Validating TSS / SHSH2 Tickets", "Запрос Apple TSS & сверка ApTicket генератора Nonce...", "Querying Apple TSS & verifying ApTicket nonce generator..."),
            ("Распаковка RootFS & Cryptex1", "Extracting RootFS & Cryptex1", "Извлечение системного образа DMG и компонентов Cryptex OS...", "Extracting DMG system image and Cryptex OS components..."),
            ("Прошивка SEP & Baseband", "Flashing SEP & Baseband", "Отправка подписанного Secure Enclave микрокода в чип безопасности...", "Sending signed Secure Enclave microcode to security processor..."),
            ("Запись APFS Snapshot", "Writing APFS Snapshot", "Создание корневого снимка APFS и синхронизация KernelCache...", "Creating APFS root snapshot and synchronizing KernelCache..."),
            ("Финализация и NVRAM", "Finalizing & NVRAM Update", "Обновление системных переменных NVRAM и верификация SHA-256...", "Updating NVRAM boot variables and verifying SHA-256 integrity...")
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Верхний баннер текущего устройства и iOS
                        currentDeviceBanner

                        // Секция выбора версии прошивки
                        firmwareSelectionSection

                        // Спецификация выбранной прошивки
                        firmwareSpecCard

                        // Параметры установки
                        flashingOptionsCard

                        // Процесс прошивки и терминал
                        restoreEngineCard

                        // Дисклеймер
                        disclaimerCard
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(strings.downgradeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .alert(strings.downgradeFinished, isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("\(strings.downgradeFinishedMsg)\n\nВерсия: \(selectedFirmware.version) (\(selectedFirmware.build))")
            }
        }
    }

    // MARK: - Компоненты

    /// Баннер текущего устройства
    private var currentDeviceBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(UIDevice.current.model)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.semibold)

                HStack(spacing: 6) {
                    Text("\(isRu ? "Текущая" : "Current"): iOS \(UIDevice.current.systemVersion)")
                        .font(.system(.caption, design: .default))
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text("arm64e")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(isRu ? "Цель" : "Target")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(selectedFirmware.version)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Секция выбора версии прошивки
    private var firmwareSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isRu ? "Каталог версий IPSW" : "IPSW Firmware Catalog")
                    .font(.system(.caption, design: .default))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Spacer()

                Text("5 \(isRu ? "версий" : "versions")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(sampleFirmwares) { fw in
                    Button(action: {
                        if !isRestoring {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFirmware = fw
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            // Индикатор выбора
                            Image(systemName: selectedFirmware.id == fw.id ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(selectedFirmware.id == fw.id ? .blue : .secondary.opacity(0.4))

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(fw.version)
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    if fw.isBeta {
                                        Text("BETA")
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.purple.opacity(0.15))
                                            .foregroundColor(.purple)
                                            .clipShape(Capsule())
                                    }
                                }

                                Text("\(fw.build) • \(fw.releaseDate(isRu: isRu))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Бейдж статуса подписи
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(fw.isSigned ? Color.green : Color.orange)
                                    .frame(width: 6, height: 6)

                                Text(fw.isSigned ? (isRu ? "TSS Подписана" : "TSS Signed") : "SHSH2 Blobs")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(fw.isSigned ? .green : .orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((fw.isSigned ? Color.green : Color.orange).opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .padding(12)
                        .background(
                            selectedFirmware.id == fw.id
                                ? Color.blue.opacity(0.08)
                                : Color(uiColor: .tertiarySystemGroupedBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selectedFirmware.id == fw.id ? Color.blue.opacity(0.35) : Color.clear, lineWidth: 1.5)
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
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Спецификация выбранной прошивки
    private var firmwareSpecCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(strings.fwInfoTitle)
                    .font(.system(.caption, design: .default))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Spacer()

                Text(selectedFirmware.version)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            VStack(spacing: 10) {
                HStack {
                    Label(strings.fwBuild, systemImage: "number")
                    Spacer()
                    Text(selectedFirmware.build)
                        .foregroundColor(.secondary)
                        .font(.system(.subheadline, design: .monospaced))
                }

                Divider()

                HStack {
                    Label(strings.fwReleaseDate, systemImage: "calendar")
                    Spacer()
                    Text(selectedFirmware.releaseDate(isRu: isRu))
                        .foregroundColor(.secondary)
                        .font(.system(.subheadline, design: .default))
                }

                Divider()

                HStack {
                    Label(strings.fwSize, systemImage: "internaldrive")
                    Spacer()
                    Text(String(format: "%.1f GB", selectedFirmware.sizeGB))
                        .foregroundColor(.secondary)
                        .font(.system(.subheadline, design: .default))
                }

                Divider()

                HStack {
                    Label(strings.fwSignedStatus, systemImage: "checkmark.seal.fill")
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
                    Label(strings.fwSepCompatibility, systemImage: "cpu.fill")
                    Spacer()
                    Text(selectedFirmware.sepStatus(isRu: isRu))
                        .foregroundColor(.blue)
                        .font(.system(.caption, design: .default))
                        .fontWeight(.medium)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Параметры установки
    private var flashingOptionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.restoreOptionsSection)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

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
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка процесса восстановления и кнопка действия
    private var restoreEngineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.processTitle)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            if isRestoring {
                let stage = restoreStages[min(currentStageIndex, restoreStages.count - 1)]

                VStack(spacing: 12) {
                    // Текущий шаг
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isRu ? stage.titleRu : stage.titleEn)
                                .font(.system(.subheadline, design: .default))
                                .fontWeight(.bold)

                            Text(isRu ? stage.detailRu : stage.detailEn)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text("\(Int(restoreProgress * 100))%")
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }

                    // Анимированный прогресс-бар
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.blue.opacity(0.15))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(14, geo.size.width * CGFloat(restoreProgress)), height: 8)
                                .animation(.easeInOut(duration: 0.25), value: restoreProgress)
                        }
                    }
                    .frame(height: 8)

                    // Статистика скорости и объема
                    HStack {
                        Text(String(format: "%.1f MB/s", restoreSpeedMBs))
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(String(format: "%.2f / %.1f GB", restoreProgress * selectedFirmware.sizeGB, selectedFirmware.sizeGB))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    // Терминал вывода логов прошивки
                    if !terminalLogs.isEmpty {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(terminalLogs.suffix(3), id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.cyan.opacity(0.9))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.black.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(.vertical, 4)
            }

            // Кнопка запуска
            Button(action: startFlashingSequence) {
                HStack(spacing: 8) {
                    if isRestoring {
                        ProgressView()
                            .tint(.white)
                        Text(strings.simRunning)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        Text("\(strings.startDowngradeBtn) \(selectedFirmware.version)")
                    }
                }
                .font(.system(.body, design: .default))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isRestoring ? Color.gray.opacity(0.5) : Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(isRestoring)
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Сноска-дисклеймер
    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
                .font(.subheadline)
            Text(strings.disclaimerText)
                .font(.system(.caption, design: .default))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Логика восстановления

    private func startFlashingSequence() {
        isRestoring = true
        restoreProgress = 0.0
        currentStageIndex = 0
        restoreSpeedMBs = 42.5
        terminalLogs = [
            "[TSS] Connecting to gs.apple.com:443...",
            "[Futurerestore] Initializing BuildManifest for \(selectedFirmware.build)"
        ]

        restoreTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if restoreProgress < 0.2 {
                withAnimation {
                    restoreProgress += 0.04
                    currentStageIndex = 0
                    restoreSpeedMBs = Double.random(in: 38.0...52.0)
                    if terminalLogs.count < 3 {
                        terminalLogs.append("[TSS] Received ApTicket signature hash: \(selectedFirmware.sha256.prefix(12))...")
                    }
                }
            } else if restoreProgress < 0.45 {
                withAnimation {
                    restoreProgress += 0.05
                    currentStageIndex = 1
                    restoreSpeedMBs = Double.random(in: 45.0...65.0)
                    terminalLogs.append("[APFS] Mount DMG RootFS: container disk0s1s1 ready")
                }
            } else if restoreProgress < 0.70 {
                withAnimation {
                    restoreProgress += 0.05
                    currentStageIndex = 2
                    restoreSpeedMBs = Double.random(in: 50.0...70.0)
                    terminalLogs.append("[SEP] Microcode Cryptex1 matched version \(selectedFirmware.version)")
                }
            } else if restoreProgress < 0.92 {
                withAnimation {
                    restoreProgress += 0.04
                    currentStageIndex = 3
                    restoreSpeedMBs = Double.random(in: 55.0...80.0)
                    terminalLogs.append("[Restore] Writing kernel cache & snapshot com.apple.os.update-\(selectedFirmware.build)")
                }
            } else if restoreProgress < 1.0 {
                withAnimation {
                    restoreProgress = 1.0
                    currentStageIndex = 4
                    restoreSpeedMBs = 0.0
                    terminalLogs.append("[Done] Restore sequence completed. System ready!")
                }
                timer.invalidate()
                restoreTimer = nil
                isRestoring = false
                showSuccessAlert = true
            }
        }
    }
}

#Preview {
    DowngradeView()
}

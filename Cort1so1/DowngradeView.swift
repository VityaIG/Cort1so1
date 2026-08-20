import SwiftUI

/// Экран симуляции отката версии iOS («Откат iOS») в стиле iOS HIG
struct DowngradeView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @State private var selectedFirmware: FirmwareVersion = sampleFirmwares[0]
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    @State private var statusMessage: String = ""
    @State private var downloadTimer: Timer?
    @State private var showSuccessAlert = false

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Карточка выбора версии прошивки
                        firmwareSelectorCard

                        // Карточка сведений о прошивке
                        firmwareDetailsCard

                        // Карточка процесса загрузки и установки
                        processExecutionCard

                        // Карточка-сноска
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
                Text("\(strings.downgradeFinishedMsg) (\(selectedFirmware.version))")
            }
            .onAppear {
                if statusMessage.isEmpty {
                    statusMessage = strings.downgradeReadyStatus
                }
            }
        }
    }

    // MARK: - Компоненты интерфейса

    /// Карточка выбора целевой прошивки
    private var firmwareSelectorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(strings.targetFirmware)
                    .font(.system(.body, design: .default))
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .foregroundColor(.blue)
            }

            Picker(strings.targetFirmware, selection: $selectedFirmware) {
                ForEach(sampleFirmwares) { fw in
                    HStack {
                        Text(fw.version)
                        Spacer()
                        Text(fw.isSigned ? strings.fwSigned : "SHSH2")
                            .font(.caption)
                            .foregroundColor(fw.isSigned ? .green : .orange)
                    }
                    .tag(fw)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка метаданных прошивки
    private var firmwareDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.fwInfoTitle)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label(strings.fwBuild, systemImage: "number")
                Spacer()
                Text(selectedFirmware.build)
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label(strings.fwReleaseDate, systemImage: "calendar")
                Spacer()
                Text(selectedFirmware.releaseDate)
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label(strings.fwSize, systemImage: "internaldrive")
                Spacer()
                Text(String(format: "%.1f GB", selectedFirmware.sizeGB))
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label(strings.fwSignedStatus, systemImage: "checkmark.seal")
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(selectedFirmware.isSigned ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(selectedFirmware.isSigned ? strings.fwSigned : strings.fwUnsigned)
                        .foregroundColor(selectedFirmware.isSigned ? .green : .red)
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка процесса и кнопка действия
    private var processExecutionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.processTitle)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 10) {
                Text(statusMessage)
                    .font(.system(.subheadline, design: .default))
                    .foregroundColor(.secondary)

                if isDownloading {
                    ProgressView(value: downloadProgress, total: 1.0)
                        .progressViewStyle(.linear)
                        .tint(.blue)

                    HStack {
                        Text("\(Int(downloadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f / %.1f GB", downloadProgress * selectedFirmware.sizeGB, selectedFirmware.sizeGB))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Button(action: startDowngradeSimulation) {
                HStack {
                    Spacer()
                    if isDownloading {
                        ProgressView()
                            .tint(.white)
                            .padding(.trailing, 6)
                        Text(strings.simRunning)
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .padding(.trailing, 4)
                        Text("\(strings.startDowngradeBtn) \(selectedFirmware.version)")
                    }
                    Spacer()
                }
                .font(.system(.body, design: .default))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isDownloading ? Color.gray.opacity(0.5) : Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(isDownloading)
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

    // MARK: - Логика

    private func startDowngradeSimulation() {
        isDownloading = true
        downloadProgress = 0.0
        statusMessage = appLanguage == "ru" ? "Запрос подписи TSS и верификация билетов..." : "Requesting TSS tickets and signature verification..."

        downloadTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            if downloadProgress < 0.3 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    downloadProgress += 0.05
                    statusMessage = (appLanguage == "ru" ? "Загрузка манифеста IPSW" : "Downloading IPSW manifest") + " (\(selectedFirmware.version))..."
                }
            } else if downloadProgress < 0.7 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    downloadProgress += 0.08
                    statusMessage = appLanguage == "ru" ? "Распаковка разделов Secure Enclave (SEP) и Baseband..." : "Extracting SEP firmware and Baseband partitions..."
                }
            } else if downloadProgress < 0.95 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    downloadProgress += 0.06
                    statusMessage = appLanguage == "ru" ? "Валидация APFS snapshot и контрольных сумм..." : "Validating APFS snapshot and SHA-256 checksums..."
                }
            } else {
                downloadProgress = 1.0
                statusMessage = appLanguage == "ru" ? "Готово: Симуляция отката успешно завершена!" : "Done: Downgrade simulation completed successfully!"
                timer.invalidate()
                downloadTimer = nil
                isDownloading = false
                showSuccessAlert = true
            }
        }
    }
}

#Preview {
    DowngradeView()
}

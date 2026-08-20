import SwiftUI

/// Экран симуляции отката версии iOS («Откат iOS») в стиле iOS HIG
struct DowngradeView: View {
    @State private var selectedFirmware: FirmwareVersion = sampleFirmwares[0]
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    @State private var statusMessage: String = "Готов к загрузке IPSW"
    @State private var downloadTimer: Timer?
    @State private var showSuccessAlert = false

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
            .navigationTitle("Откат iOS")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Симуляция завершена", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Образ \(selectedFirmware.version) успешно распакован и проверен контрольной суммой SHA-256.")
            }
        }
    }

    // MARK: - Компоненты интерфейса

    /// Карточка выбора целевой прошивки
    private var firmwareSelectorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Целевая версия прошивки")
                    .font(.system(.body, design: .default))
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .foregroundColor(.blue)
            }

            Picker("Версия", selection: $selectedFirmware) {
                ForEach(sampleFirmwares) { fw in
                    HStack {
                        Text(fw.version)
                        Spacer()
                        Text(fw.isSigned ? "Подписана" : "SHSH2")
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
            Text("Сведения об IPSW")
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label("Сборка", systemImage: "number")
                Spacer()
                Text(selectedFirmware.build)
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label("Дата релиза", systemImage: "calendar")
                Spacer()
                Text(selectedFirmware.releaseDate)
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label("Размер файла", systemImage: "internaldrive")
                Spacer()
                Text(String(format: "%.1f ГБ", selectedFirmware.sizeGB))
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label("Статус подписи", systemImage: "checkmark.seal")
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(selectedFirmware.isSigned ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(selectedFirmware.isSigned ? "Подписана (TSS)" : "Не подписана")
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
            Text("Процесс установки")
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
                        Text(String(format: "%.2f / %.1f ГБ", downloadProgress * selectedFirmware.sizeGB, selectedFirmware.sizeGB))
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
                        Text("Выполняется симуляция...")
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .padding(.trailing, 4)
                        Text("Начать откат на \(selectedFirmware.version)")
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
            Text("Все операции производятся в безопасном демонстрационном режиме симулятора. Физическая файловая система устройства не модифицируется.")
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
        statusMessage = "Запрос подписи TSS и верификация билетов..."

        downloadTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            if downloadProgress < 0.3 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    downloadProgress += 0.05
                    statusMessage = "Загрузка манифеста IPSW (\(selectedFirmware.version))..."
                }
            } else if downloadProgress < 0.7 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    downloadProgress += 0.08
                    statusMessage = "Распаковка разделов Secure Enclave (SEP) и Baseband..."
                }
            } else if downloadProgress < 0.95 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    downloadProgress += 0.06
                    statusMessage = "Валидация APFS snapshot и контрольных сумм..."
                }
            } else {
                downloadProgress = 1.0
                statusMessage = "Готово: Симуляция отката успешно завершена!"
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

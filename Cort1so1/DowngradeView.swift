import SwiftUI

/// Экран симуляции отката версии iOS («Откат iOS») в дизайн-системе iOS 26 Liquid Glass HIG
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
                ambientBackground

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
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
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Симуляция завершена", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Образ \(selectedFirmware.version) успешно распакован и проверен контрольной суммой SHA-256.")
            }
        }
    }

    // MARK: - Фон с преломлением

    private var ambientBackground: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            Circle()
                .fill(Color.indigo.opacity(0.10))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -90, y: -140)

            Circle()
                .fill(Color.blue.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 75)
                .offset(x: 90, y: 160)
        }
    }

    // MARK: - Парящие карточки Liquid Glass

    /// Карточка выбора целевой прошивки
    private var firmwareSelectorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Целевая версия прошивки")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.accentColor)
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
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(glassBorder(cornerRadius: 14))
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    /// Карточка метаданных прошивки
    private var firmwareDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Сведения об IPSW")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label("Сборка", systemImage: "number")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text(selectedFirmware.build)
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }

            HStack {
                Label("Дата релиза", systemImage: "calendar")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text(selectedFirmware.releaseDate)
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }

            HStack {
                Label("Размер файла", systemImage: "internaldrive")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text(String(format: "%.1f ГБ", selectedFirmware.sizeGB))
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }

            HStack {
                Label("Статус подписи", systemImage: "checkmark.seal")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(selectedFirmware.isSigned ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(selectedFirmware.isSigned ? "Подписана (TSS)" : "Не подписана")
                        .foregroundColor(selectedFirmware.isSigned ? .green : .red)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    /// Карточка процесса и кнопка действия
    private var processExecutionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Процесс установки")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 10) {
                Text(statusMessage)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)

                if isDownloading {
                    ProgressView(value: downloadProgress, total: 1.0)
                        .progressViewStyle(.linear)
                        .tint(.accentColor)

                    HStack {
                        Text("\(Int(downloadProgress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f / %.1f ГБ", downloadProgress * selectedFirmware.sizeGB, selectedFirmware.sizeGB))
                            .font(.caption2)
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
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isDownloading ? Color.gray.opacity(0.6) : Color.accentColor)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.5)
                )
                .shadow(color: Color.accentColor.opacity(0.25), radius: 12, x: 0, y: 6)
            }
            .disabled(isDownloading)
            .buttonStyle(SpringPressButtonStyle())
            .padding(.top, 4)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    /// Сноска-дисклеймер
    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
                .font(.subheadline)
            Text("Все операции производятся в безопасном демонстрационном режиме симулятора. Физическая файловая система устройства не модифицируется.")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(glassBorder(cornerRadius: 18))
    }

    // MARK: - Вспомогательные функции

    private func glassBorder(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.45),
                        Color.white.opacity(0.08),
                        Color.blue.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
    }

    private func startDowngradeSimulation() {
        isDownloading = true
        downloadProgress = 0.0
        statusMessage = "Запрос подписи TSS и верификация билетов..."

        downloadTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            if downloadProgress < 0.3 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    downloadProgress += 0.05
                    statusMessage = "Загрузка манифеста IPSW (\(selectedFirmware.version))..."
                }
            } else if downloadProgress < 0.7 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    downloadProgress += 0.08
                    statusMessage = "Распаковка разделов Secure Enclave (SEP) и Baseband..."
                }
            } else if downloadProgress < 0.95 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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

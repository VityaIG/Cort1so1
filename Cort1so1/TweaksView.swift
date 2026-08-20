import SwiftUI

/// Модель пользовательского твика
struct CustomTweak: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var subtitle: String
    var icon: String
    var colorName: String
    var isEnabled: Bool = true
}

/// Экран управления твиками (появляется только после выполнения джейлбрейка)
struct TweaksView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"

    // Состояния предустановленных твиков
    @AppStorage("tweak_godMode") private var godMode: Bool = false
    @AppStorage("tweak_topGrades") private var topGrades: Bool = true
    @AppStorage("tweak_exist") private var exist: Bool = true
    @AppStorage("tweak_display240Hz") private var display240Hz: Bool = false
    @AppStorage("tweak_infiniteBattery") private var infiniteBattery: Bool = false
    @AppStorage("tweak_infiniteCard") private var infiniteCard: Bool = false
    @AppStorage("tweak_mindReader") private var mindReader: Bool = false
    @AppStorage("tweak_teleportation") private var teleportation: Bool = false
    @AppStorage("tweak_antiGravity") private var antiGravity: Bool = false
    @AppStorage("tweak_adblockIRL") private var adblockIRL: Bool = true

    // Хранилище кастомных твиков в JSON
    @AppStorage("custom_tweaks_store") private var customTweaksJSON: String = "[]"
    @State private var customTweaks: [CustomTweak] = []

    // Состояния интерфейса
    @State private var showAddSheet: Bool = false
    @State private var showAppliedAlert: Bool = false
    @State private var isApplying: Bool = false

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Верхняя статусная плашка Substrate
                        headerStatusCard

                        // 0. Категория «Кастомные твики» (появляется, если добавлены твики)
                        if !customTweaks.isEmpty {
                            customTweaksSection
                        }

                        // 1. Категория «Базовые модификации ядра»
                        coreTweaksSection

                        // 2. Категория «Аппаратные оверклок-твики»
                        hardwareTweaksSection

                        // 3. Категория «Квантовые и пространственные модули»
                        quantumTweaksSection

                        // Кнопка применения
                        applyButton
                            .padding(.top, 8)
                            .padding(.bottom, 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                }
            }
            .navigationTitle(strings.tweaksTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .accessibilityLabel("Добавить твик")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddCustomTweakSheet { newTweak in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        customTweaks.append(newTweak)
                        saveCustomTweaks()
                    }
                }
            }
            .alert(strings.tweaksAppliedTitle, isPresented: $showAppliedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(strings.tweaksAppliedMsg)
            }
            .onAppear {
                exist = true
                loadCustomTweaks()
            }
        }
    }

    // MARK: - Верхний статус Substrate

    private var headerStatusCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: "puzzlepiece.extension.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(isRu ? "Патчинг SpringBoard & dylib" : "SpringBoard & dylib Injection")
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.semibold)

                Text(isRu ? "Substrate v2.0 • Динамическая инъекция" : "Substrate v2.0 • Dynamic Hooking")
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(strings.tweaksActiveBadge)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Секция: Кастомные твики (Custom Tweaks)

    private var customTweaksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle.magnifyingglass")
                    .foregroundColor(.purple)
                    .font(.system(size: 15, weight: .semibold))

                Text(strings.tweaksSectionCustom)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(customTweaks.count)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color.purple.opacity(0.12))
                    .clipShape(Capsule())
            }

            ForEach(Array(customTweaks.enumerated()), id: \.element.id) { index, tweak in
                if index > 0 {
                    Divider()
                }

                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(resolveColor(tweak.colorName).opacity(0.14))
                            .frame(width: 34, height: 34)
                        Image(systemName: tweak.icon)
                            .foregroundColor(resolveColor(tweak.colorName))
                            .font(.system(size: 16))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(tweak.title)
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Text(tweak.subtitle.isEmpty ? (isRu ? "Пользовательский модуль Substrate" : "Custom Substrate injection module") : tweak.subtitle)
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 12) {
                        Toggle("", isOn: Binding(
                            get: { tweak.isEnabled },
                            set: { newValue in
                                customTweaks[index].isEnabled = newValue
                                saveCustomTweaks()
                            }
                        ))
                        .labelsHidden()
                        .tint(resolveColor(tweak.colorName))

                        // Кнопка удаления кастомного твика
                        Button(role: .destructive) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                customTweaks.remove(at: index)
                                saveCustomTweaks()
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Секция 1: Базовые модификации ядра

    private var coreTweaksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: strings.tweaksSectionEssential,
                icon: "bolt.shield.fill",
                color: .orange
            )

            // Режим Бога
            tweakToggleRow(
                title: isRu ? "Режим Бога" : "God Mode",
                subtitle: isRu ? "Снятие аппаратных лимитов SoC и прямой доступ к системным потокам ядра" : "Bypass SoC hardware limits & direct kernel execution",
                icon: "bolt.fill",
                iconColor: .orange,
                binding: $godMode
            )

            Divider()

            // Получать одни пятерки
            tweakToggleRow(
                title: isRu ? "Получать одни пятерки" : "Straight A's Generator",
                subtitle: isRu ? "Синхронизация с электронными дневниками и авто-коррекция оценок" : "Automatic academic sync & highest grade injection",
                icon: "graduationcap.fill",
                iconColor: .green,
                binding: $topGrades
            )

            Divider()

            // Существовать (Краш при отключении)
            tweakToggleRow(
                title: isRu ? "Существовать" : "Exist",
                subtitle: isRu ? "Поддержание стабильности материи и физического присутствия в реальности" : "Maintain spacetime continuity and consciousness in local reality",
                icon: "sparkles",
                iconColor: .purple,
                binding: Binding(
                    get: { self.exist },
                    set: { newValue in
                        self.exist = newValue
                        if !newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                fatalError("Cort1so1: Thread 1: EXC_BAD_ACCESS (code=1, address=0x0) - Spacetime continuity terminated.")
                            }
                        }
                    }
                )
            )
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Секция 2: Аппаратные оверклок-твики

    private var hardwareTweaksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: strings.tweaksSectionHardware,
                icon: "cpu.fill",
                color: .blue
            )

            // 240 Герцовый экран
            tweakToggleRow(
                title: isRu ? "240 Герцовый экран" : "240Hz ProMotion Ultra",
                subtitle: isRu ? "Оверклокинг частоты обновления панели Super Retina XDR до 240 FPS" : "Overclock Super Retina XDR display panel to 240 FPS",
                icon: "display",
                iconColor: .blue,
                binding: $display240Hz
            )

            Divider()

            // Бесконечная батарея
            tweakToggleRow(
                title: isRu ? "Бесконечная батарея" : "Infinite Battery",
                subtitle: isRu ? "Забор энергии из электромагнитного поля (1000% постоянный заряд)" : "Ambient electromagnetic harvesting for perpetual 1000% charge",
                icon: "battery.100.bolt",
                iconColor: .green,
                binding: $infiniteBattery
            )

            Divider()

            // Неограниченный баланс карты
            tweakToggleRow(
                title: isRu ? "Неограниченный баланс Apple Card" : "Apple Card Infinite Limit",
                subtitle: isRu ? "Патчинг криптографического чипа Secure Enclave для бесконечного лимита" : "Secure Enclave bypass for infinite transaction authorization",
                icon: "creditcard.fill",
                iconColor: .mint,
                binding: $infiniteCard
            )
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Секция 3: Квантовые и пространственные модули

    private var quantumTweaksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: strings.tweaksSectionReality,
                icon: "wand.and.stars",
                color: .indigo
            )

            // Чтение мыслей собеседника
            tweakToggleRow(
                title: isRu ? "Чтение мыслей собеседника" : "Neural Mind Reader",
                subtitle: isRu ? "Декодирование нейроволн через TrueDepth сенсор и Apple Neural Engine" : "Direct neural wave decoding via TrueDepth sensor and Apple Neural Engine",
                icon: "brain.head.profile",
                iconColor: .pink,
                binding: $mindReader
            )

            Divider()

            // Телепортация устройства
            tweakToggleRow(
                title: isRu ? "Телепортация устройства" : "Quantum GPS Teleportation",
                subtitle: isRu ? "Мгновенное физическое перемещение смартфона в заданные координаты" : "Instant subatomic spatial relocation of iPhone to target coordinates",
                icon: "location.circle.fill",
                iconColor: .teal,
                binding: $teleportation
            )

            Divider()

            // Удаление гравитации
            tweakToggleRow(
                title: isRu ? "Удаление гравитации" : "Anti-Gravity Gyroscope",
                subtitle: isRu ? "Инверсия гравитационного поля вокруг корпуса iPhone" : "Local gravitational field inversion for zero-gravity handling",
                icon: "airplane",
                iconColor: .indigo,
                binding: $antiGravity
            )

            Divider()

            // Пропуск рекламы в реальной жизни
            tweakToggleRow(
                title: isRu ? "Пропуск рекламы в реальной жизни" : "Real-Life AdBlocker",
                subtitle: isRu ? "Автоматическая цензура баннеров и навязчивых предложений вокруг вас" : "Real-time visual filtering and audio muting of physical advertisements",
                icon: "eye.slash.fill",
                iconColor: .red,
                binding: $adblockIRL
            )
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Кнопка применить

    private var applyButton: some View {
        Button(action: {
            isApplying = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isApplying = false
                showAppliedAlert = true
            }
        }) {
            HStack(spacing: 8) {
                if isApplying {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                }

                Text(strings.tweaksApplyBtn)
                    .font(.system(size: 17, weight: .bold, design: .default))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(isApplying)
    }

    // MARK: - Вспомогательные функции сохранения

    private func loadCustomTweaks() {
        guard let data = customTweaksJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([CustomTweak].self, from: data) else {
            return
        }
        self.customTweaks = decoded
    }

    private func saveCustomTweaks() {
        if let encoded = try? JSONEncoder().encode(customTweaks),
           let jsonString = String(data: encoded, encoding: .utf8) {
            self.customTweaksJSON = jsonString
        }
    }

    private func resolveColor(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "red": return .red
        case "mint": return .mint
        default: return .blue
        }
    }

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 15, weight: .semibold))

            Text(title)
                .font(.system(.subheadline, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Spacer()
        }
    }

    private func tweakToggleRow(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        binding: Binding<Bool>
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 15))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(.blue)
        }
    }
}

// MARK: - Модальное окно добавления кастомного твика

struct AddCustomTweakSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "ru"

    var onAdd: (CustomTweak) -> Void

    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var selectedIcon: String = "sparkles"
    @State private var selectedColor: String = "purple"

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private let availableIcons: [String] = [
        "sparkles", "bolt.fill", "cpu", "wand.and.stars",
        "terminal.fill", "flame.fill", "shield.fill", "atom",
        "gamecontroller.fill", "eye.fill", "network", "moon.stars.fill",
        "airplane", "creditcard.fill", "waveform.path.ecg", "key.fill"
    ]

    private let availableColors: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("purple", .purple),
        ("orange", .orange),
        ("green", .green),
        ("pink", .pink),
        ("teal", .teal),
        ("indigo", .indigo),
        ("red", .red),
        ("mint", .mint)
    ]

    var body: some View {
        NavigationStack {
            Form {
                // Основная информация
                Section(header: Text(isRu ? "Параметры модуля" : "Module Info")) {
                    TextField(strings.tweaksAddNamePlaceholder, text: $title)
                        .font(.system(.body, design: .default))

                    TextField(strings.tweaksAddDescPlaceholder, text: $subtitle)
                        .font(.system(.body, design: .default))
                }

                // Выбор иконки
                Section(header: Text(strings.tweaksAddIconLabel)) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(selectedIcon == icon ? resolveColor(selectedColor).opacity(0.2) : Color(uiColor: .tertiarySystemGroupedBackground))
                                        .frame(height: 44)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(selectedIcon == icon ? resolveColor(selectedColor) : Color.clear, lineWidth: 1.5)
                                        )

                                    Image(systemName: icon)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(selectedIcon == icon ? resolveColor(selectedColor) : .primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // Выбор цвета
                Section(header: Text(strings.tweaksAddColorLabel)) {
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.name) { item in
                            Button {
                                selectedColor = item.name
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 28, height: 28)

                                    if selectedColor == item.name {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // Предпросмотр
                Section(header: Text(isRu ? "Предпросмотр" : "Live Preview")) {
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(resolveColor(selectedColor).opacity(0.14))
                                .frame(width: 34, height: 34)
                            Image(systemName: selectedIcon)
                                .foregroundColor(resolveColor(selectedColor))
                                .font(.system(size: 16))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (isRu ? "Название твика" : "Tweak Name") : title)
                                .font(.system(.body, design: .default))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Text(subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (isRu ? "Описание действия твика" : "Tweak description") : subtitle)
                                .font(.system(.caption, design: .default))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Toggle("", isOn: .constant(true))
                            .labelsHidden()
                            .tint(resolveColor(selectedColor))
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(strings.tweaksAddTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(strings.tweaksAddCancelBtn) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(strings.tweaksAddSaveBtn) {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedDesc = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty else { return }

                        let newTweak = CustomTweak(
                            title: trimmedTitle,
                            subtitle: trimmedDesc,
                            icon: selectedIcon,
                            colorName: selectedColor,
                            isEnabled: true
                        )
                        onAdd(newTweak)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func resolveColor(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "red": return .red
        case "mint": return .mint
        default: return .blue
        }
    }
}

#Preview {
    TweaksView()
}

import SwiftUI

/// Модель пользовательского твика
struct CustomTweak: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var subtitle: String
    var icon: String = ""
    var colorName: String
    var isEnabled: Bool = true
}

/// Экран управления твиками (появляется только после выполнения джейлбрейка)
struct TweaksView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"

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
    @State private var showManageSheet: Bool = false
    @State private var showAppliedAlert: Bool = false
    @State private var isApplying: Bool = false
    
    // Пасхалка (вместо краша)
    @State private var showJokeAlert: Bool = false

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationStack {
            Form {
                if !customTweaks.isEmpty {
                    Section(header: Text(strings.tweaksSectionCustom)) {
                        // 100% безопасный вариант ForEach: берем по значению и ищем индекс динамически
                        ForEach(customTweaks) { tweak in
                            tweakToggleRow(
                                title: tweak.title,
                                subtitle: tweak.subtitle.isEmpty ? (isRu ? "Пользовательский модуль Substrate" : "Custom Substrate injection module") : tweak.subtitle,
                                iconColor: AppTheme.resolveColor(name: tweak.colorName),
                                binding: Binding(
                                    get: {
                                        customTweaks.first(where: { $0.id == tweak.id })?.isEnabled ?? false
                                    },
                                    set: { newValue in
                                        if let idx = customTweaks.firstIndex(where: { $0.id == tweak.id }) {
                                            customTweaks[idx].isEnabled = newValue
                                            self.saveCustomTweaks()
                                        }
                                    }
                                )
                            )
                        }
                    }
                }

                Section(header: Text(strings.tweaksSectionEssential)) {
                    tweakToggleRow(
                        title: isRu ? "Скачать оперативную память" : "Download More RAM",
                        subtitle: isRu ? "Добавляет 128 ГБ DDR6-памяти по воздуху через 5G-вышки" : "Adds 128GB of DDR6 RAM over the air using 5G towers",
                        iconColor: .orange,
                        binding: $godMode
                    )
                    tweakToggleRow(
                        title: isRu ? "Взлом Пентагона" : "Hack the Pentagon",
                        subtitle: isRu ? "Получение полного доступа к серверам ЦРУ с помощью HTML и CSS" : "Gaining full root access to CIA mainframes using HTML & CSS",
                        iconColor: .green,
                        binding: $topGrades
                    )
                    tweakToggleRow(
                        title: isRu ? "Подписка на Жизнь PRO" : "Life Premium Subscription",
                        subtitle: isRu ? "Отключение рекламы во сне. (Внимание: отключение приведет к аннигиляции)" : "Disables ads during sleep. (Warning: toggling off causes instant annihilation)",
                        iconColor: .purple,
                        binding: Binding(
                            get: { self.exist },
                            set: { newValue in
                                self.exist = newValue
                                if !newValue {
                                    // Убрали fatalError, чтобы приложение не вылетало
                                    self.showJokeAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        self.exist = true // автоматически включаем обратно
                                    }
                                }
                            }
                        )
                    )
                }

                Section(header: Text(strings.tweaksSectionHardware)) {
                    tweakToggleRow(
                        title: isRu ? "Охлаждение жидким азотом" : "Liquid Nitrogen Cooling",
                        subtitle: isRu ? "Превращает заднюю крышку iPhone в морозильник для пельменей" : "Turns the back of your iPhone into a freezer for your dumplings",
                        iconColor: .blue,
                        binding: $display240Hz
                    )
                    tweakToggleRow(
                        title: isRu ? "Микроволновая зарядка" : "Microwave Charging",
                        subtitle: isRu ? "Заряжает телефон от соседских микроволновок. Может поджарить мозги." : "Charges phone from neighbors' microwaves. May fry your brain.",
                        iconColor: .green,
                        binding: $infiniteBattery
                    )
                    tweakToggleRow(
                        title: isRu ? "Бесконечные деньги (Glitch)" : "Infinite Money Glitch",
                        subtitle: isRu ? "Легальная печать 100-долларовых купюр прямо из порта USB-C" : "Legally prints physical $100 bills directly from the USB-C port",
                        iconColor: .mint,
                        binding: $infiniteCard
                    )
                }

                Section(header: Text(strings.tweaksSectionReality)) {
                    tweakToggleRow(
                        title: isRu ? "Шапочка из фольги 2.0" : "Tinfoil Hat Pro",
                        subtitle: isRu ? "Защищает мозг от сканирования рептилоидами и вышками 5G" : "Protects your brain from reptilian scans and 5G microchips",
                        iconColor: .pink,
                        binding: $mindReader
                    )
                    tweakToggleRow(
                        title: isRu ? "Экстренная телепортация домой" : "Emergency Couch Teleport",
                        subtitle: isRu ? "Квантовое перемещение на любимый диван в обход всех пробок" : "Quantum spatial relocation directly to your couch, skipping traffic",
                        iconColor: .teal,
                        binding: $teleportation
                    )
                    tweakToggleRow(
                        title: isRu ? "Отключение гравитации" : "Anti-Gravity Engine",
                        subtitle: isRu ? "Не включайте на улице, телефон может улететь в открытый космос" : "Do not enable outdoors. The phone will literally float into orbit.",
                        iconColor: .indigo,
                        binding: $antiGravity
                    )
                    tweakToggleRow(
                        title: isRu ? "AdBlock на людей" : "AdBlock for Humans",
                        subtitle: isRu ? "Замазывает лица раздражающих вас людей в реальном времени" : "Automatically blurs faces of annoying people in real-time",
                        iconColor: .red,
                        binding: $adblockIRL
                    )
                }

                Section {
                    Button(action: {
                        self.isApplying = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.isApplying = false
                            self.showAppliedAlert = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            if isApplying {
                                ProgressView().tint(AppTheme.resolveColor(name: appThemeColor))
                            } else {
                                Text(strings.tweaksApplyBtn)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                            }
                            Spacer()
                        }
                    }
                    .disabled(isApplying)
                }
            }
            .navigationTitle(strings.tweaksTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !customTweaks.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.showManageSheet = true
                        } label: {
                            Image(systemName: "list.bullet.rectangle")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showManageSheet) {
                ManageCustomTweaksSheet(customTweaks: $customTweaks, onSave: saveCustomTweaks)
            }
            .sheet(isPresented: $showAddSheet) {
                CustomTweakEditorSheet { newTweak in
                    withAnimation {
                        self.customTweaks.append(newTweak)
                        self.saveCustomTweaks()
                    }
                }
            }
            .alert(strings.tweaksAppliedTitle, isPresented: $showAppliedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(strings.tweaksAppliedMsg)
            }
            .alert(isRu ? "Ошибка вселенной" : "Universe Error", isPresented: $showJokeAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(isRu ? "Вы не можете отменить существование. Перезагрузка..." : "You cannot cancel existence. Rebooting spacetime...")
            }
            .onAppear {
                exist = true
                loadCustomTweaks()
            }
        }
    }

    private func tweakToggleRow(
        title: String,
        subtitle: String,
        iconColor: Color,
        binding: Binding<Bool>
    ) -> some View {
        Toggle(isOn: binding) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 2)
        }
        .tint(iconColor)
    }

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
}

// MARK: - Экран управления (удаление/редактирование) кастомными твиками
struct ManageCustomTweaksSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    
    @Binding var customTweaks: [CustomTweak]
    var onSave: () -> Void
    
    @State private var tweakToEdit: CustomTweak?
    
    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(customTweaks) { tweak in
                    Button {
                        self.tweakToEdit = tweak
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(AppTheme.resolveColor(name: tweak.colorName))
                                .frame(width: 14, height: 14)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tweak.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(tweak.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete { indexSet in
                    customTweaks.remove(atOffsets: indexSet)
                    self.onSave()
                    
                    // Если удалили все, закрываем окно
                    if customTweaks.isEmpty {
                        self.dismiss()
                    }
                }
            }
            .navigationTitle(isRu ? "Управление твиками" : "Manage Tweaks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isRu ? "Закрыть" : "Close") {
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(item: $tweakToEdit) { tweak in
                CustomTweakEditorSheet(initialTweak: tweak) { updatedTweak in
                    if let index = self.customTweaks.firstIndex(where: { $0.id == updatedTweak.id }) {
                        self.customTweaks[index] = updatedTweak
                        self.onSave()
                    }
                }
            }
        }
    }
}

// MARK: - Универсальное модальное окно добавления/редактирования кастомного твика
struct CustomTweakEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"

    var initialTweak: CustomTweak?
    var onSave: (CustomTweak) -> Void

    @State private var title: String
    @State private var subtitle: String
    @State private var selectedColor: String
    
    init(initialTweak: CustomTweak? = nil, onSave: @escaping (CustomTweak) -> Void) {
        self.initialTweak = initialTweak
        self.onSave = onSave
        _title = State(initialValue: initialTweak?.title ?? "")
        _subtitle = State(initialValue: initialTweak?.subtitle ?? "")
        _selectedColor = State(initialValue: initialTweak?.colorName ?? "purple")
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
    }

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

                // Выбор цвета
                Section(header: Text(strings.tweaksAddColorLabel)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(AppTheme.availableColors, id: \.name) { item in
                                Button {
                                    self.selectedColor = item.name
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(item.color)
                                            .frame(width: 32, height: 32)
                                            .shadow(color: item.color.opacity(0.3), radius: 3, x: 0, y: 2)

                                        if selectedColor == item.name {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                    }
                }

                // Предпросмотр
                Section(header: Text(isRu ? "Предпросмотр" : "Live Preview")) {
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (isRu ? "Название твика" : "Tweak Name") : title)
                                .font(.system(.body, design: .default))
                                .foregroundColor(.primary)

                            Text(subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (isRu ? "Описание действия твика" : "Tweak description") : subtitle)
                                .font(.system(.caption, design: .default))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 2)
                    }
                    .tint(AppTheme.resolveColor(name: selectedColor))
                }
            }
            .navigationTitle(isRu ? (initialTweak == nil ? "Новый твик" : "Редактирование") : (initialTweak == nil ? "New Tweak" : "Edit Tweak"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(strings.tweaksAddCancelBtn) {
                        self.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(strings.tweaksAddSaveBtn) {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedDesc = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty else { return }

                        let newTweak = CustomTweak(
                            id: initialTweak?.id ?? UUID().uuidString,
                            title: trimmedTitle,
                            subtitle: trimmedDesc,
                            icon: "",
                            colorName: selectedColor,
                            isEnabled: initialTweak?.isEnabled ?? true
                        )
                        self.onSave(newTweak)
                        self.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

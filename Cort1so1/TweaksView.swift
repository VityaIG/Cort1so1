import SwiftUI

/// Модель пользовательского твика
struct CustomTweak: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var subtitle: String
    var icon: String = ""
    var colorName: String
    var isEnabled: Bool = true
    var alertButtonText: String = ""
    var alertTitleText: String = ""

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, icon, colorName, isEnabled, alertButtonText, alertTitleText
    }

    init(id: String = UUID().uuidString, title: String, subtitle: String, icon: String = "", colorName: String, isEnabled: Bool = true, alertButtonText: String = "", alertTitleText: String = "") {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.colorName = colorName
        self.isEnabled = isEnabled
        self.alertButtonText = alertButtonText
        self.alertTitleText = alertTitleText
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? ""
        self.colorName = try container.decodeIfPresent(String.self, forKey: .colorName) ?? "purple"
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.alertButtonText = try container.decodeIfPresent(String.self, forKey: .alertButtonText) ?? ""
        self.alertTitleText = try container.decodeIfPresent(String.self, forKey: .alertTitleText) ?? ""
    }
}

/// Типы алертов на экране твиков
enum TweaksAlertItem: Identifiable {
    case applied
    case joke

    var id: String {
        switch self {
        case .applied: return "applied"
        case .joke: return "joke"
        }
    }
}

/// Экран управления твиками (появляется только после выполнения джейлбрейка)
struct TweaksView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"

    // Состояния предустановленных твиков
    @AppStorage("tweak_godMode") private var godMode: Bool = false
    @AppStorage("tweak_topGrades") private var topGrades: Bool = true
    @AppStorage("tweak_exist") private var exist: Bool = true
    @AppStorage("tweak_wifiAnywhere") private var wifiAnywhere: Bool = false
    @AppStorage("tweak_autoHomework") private var autoHomework: Bool = false
    @AppStorage("tweak_infiniteLuck") private var infiniteLuck: Bool = true

    @AppStorage("tweak_display240Hz") private var display240Hz: Bool = false
    @AppStorage("tweak_infiniteBattery") private var infiniteBattery: Bool = false
    @AppStorage("tweak_infiniteCard") private var infiniteCard: Bool = false
    @AppStorage("tweak_coffeeMachine") private var coffeeMachine: Bool = false
    @AppStorage("tweak_laserPointer") private var laserPointer: Bool = false
    @AppStorage("tweak_waterproofForceField") private var waterproofForceField: Bool = true

    @AppStorage("tweak_mindReader") private var mindReader: Bool = false
    @AppStorage("tweak_teleportation") private var teleportation: Bool = false
    @AppStorage("tweak_antiGravity") private var antiGravity: Bool = false
    @AppStorage("tweak_adblockIRL") private var adblockIRL: Bool = true
    @AppStorage("tweak_timeRewind") private var timeRewind: Bool = false
    @AppStorage("tweak_animalSpeech") private var animalSpeech: Bool = true
    @AppStorage("tweak_invisibilityCloak") private var invisibilityCloak: Bool = false

    // Хранилище кастомных твиков в JSON
    @AppStorage("custom_tweaks_store") private var customTweaksJSON: String = "[]"
    @AppStorage("custom_apply_button_text") private var customApplyButtonText: String = ""
    @AppStorage("custom_apply_title_text") private var customApplyTitleText: String = ""
    @AppStorage("customAppBgTheme") private var customAppBgTheme: String = "default"
    @AppStorage("customBgColorHex") private var customBgColorHex: String = ""
    @State private var customTweaks: [CustomTweak] = []

    // Состояния интерфейса
    @State private var showAddSheet: Bool = false
    @State private var showManageSheet: Bool = false
    @State private var isApplying: Bool = false
    @State private var activeAlert: TweaksAlertItem? = nil

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationView {
            Form {
                // Верхняя кнопка применения для мгновенного доступа
                Section {
                    Button(action: {
                        self.applyTweaks()
                    }) {
                        HStack {
                            Spacer()
                            if isApplying {
                                ProgressView().accentColor(AppTheme.resolveColor(name: appThemeColor))
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text(strings.tweaksApplyBtn)
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(AppTheme.resolveColor(name: appThemeColor))
                            }
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                    .disabled(isApplying)
                }

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
                        title: isRu ? "Существование" : "Existence",
                        subtitle: isRu ? "Поддержание вашего базового присутствия в текущей реальности. (Отключение приведет к аннигиляции)" : "Maintains your basic presence in the current reality. (Disabling causes instant annihilation)",
                        iconColor: .purple,
                        binding: Binding(
                            get: { self.exist },
                            set: { newValue in
                                self.exist = newValue
                                if !newValue {
                                    self.activeAlert = .joke
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        self.exist = true // автоматически включаем обратно
                                    }
                                }
                            }
                        )
                    )
                    tweakToggleRow(
                        title: isRu ? "Бесплатный Wi-Fi везде" : "Free Wi-Fi Anywhere",
                        subtitle: isRu ? "Прямое подключение к спутникам Starlink на скорости 10 Гбит/с" : "Direct uplink to Starlink satellites at uncapped 10 Gbps speed",
                        iconColor: .blue,
                        binding: $wifiAnywhere
                    )
                    tweakToggleRow(
                        title: isRu ? "Авто-диплом и домашка" : "Auto Homework & Degree",
                        subtitle: isRu ? "Нейросеть пишет диплом за 3 секунды и защищает его перед комиссией" : "Neural engine writes your thesis in 3s and defends it before committee",
                        iconColor: .indigo,
                        binding: $autoHomework
                    )
                    tweakToggleRow(
                        title: isRu ? "Увеличение удачи +999%" : "Universal Luck Boost +999%",
                        subtitle: isRu ? "Патчит квантовую вероятность во всей вашей жизни на победу" : "Patches RNG in quantum probability fields for guaranteed wins",
                        iconColor: .yellow,
                        binding: $infiniteLuck
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
                    tweakToggleRow(
                        title: isRu ? "Кофемашина из динамика" : "Speaker Espresso Maker",
                        subtitle: isRu ? "Ультразвуковые волны динамика варят горячий эспрессо прямо в чашку" : "High-frequency acoustic vibrations brew fresh hot espresso on demand",
                        iconColor: .orange,
                        binding: $coffeeMachine
                    )
                    tweakToggleRow(
                        title: isRu ? "Лазерная резка вспышкой" : "Flashlight Laser Cutter",
                        subtitle: isRu ? "Разгоняет LED-вспышку до 5000 Вт, превращая её в световой меч" : "Overclocks True Tone LED flash to 5000W lightsaber mode",
                        iconColor: .red,
                        binding: $laserPointer
                    )
                    tweakToggleRow(
                        title: isRu ? "Силовое поле от падений" : "Kinetic Drop Forcefield",
                        subtitle: isRu ? "Генерирует нано-купол вокруг экрана, выдерживает падение с 9 этажа" : "Generates a kinetic nano-shield capable of surviving 9-story drops",
                        iconColor: .teal,
                        binding: $waterproofForceField
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
                    tweakToggleRow(
                        title: isRu ? "Перемотка времени назад на 5 минут" : "5-Minute Time Rewind",
                        subtitle: isRu ? "Позволяет мгновенно отменить неловкие фразы и глупые сообщения" : "Instantly undo awkward conversations and embarrassing texts",
                        iconColor: .cyan,
                        binding: $timeRewind
                    )
                    tweakToggleRow(
                        title: isRu ? "Переводчик с языка котов" : "Cat Speech Translator",
                        subtitle: isRu ? "Синхронный перевод «Мяу» на человеческий язык без цензуры" : "Real-time subtitle translation of meows into unfiltered human speech",
                        iconColor: .yellow,
                        binding: $animalSpeech
                    )
                    tweakToggleRow(
                        title: isRu ? "Режим полной невидимости" : "Full Invisibility Cloak",
                        subtitle: isRu ? "Искривляет фотоны вокруг вас, делая невидимым для камер и людей" : "Bends visible light photons around your body for total stealth",
                        iconColor: .purple,
                        binding: $invisibilityCloak
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppCustomStyle.resolveBgColor(customHex: customBgColorHex, themeId: customAppBgTheme).ignoresSafeArea())
            .navigationTitle(strings.tweaksTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !customTweaks.isEmpty {
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
                ManageCustomTweaksSheet(
                    customTweaks: $customTweaks,
                    onSave: saveCustomTweaks,
                    onApplyRequested: {
                        self.applyTweaks()
                    }
                )
            }
            .sheet(isPresented: $showAddSheet) {
                CustomTweakEditorSheet(
                    onSave: { newTweak in
                        withAnimation {
                            self.customTweaks.append(newTweak)
                            self.saveCustomTweaks()
                        }
                    },
                    onSaveAndApply: { newTweak in
                        withAnimation {
                            self.customTweaks.append(newTweak)
                            self.saveCustomTweaks()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.applyTweaks()
                        }
                    }
                )
            }
            .alert(item: $activeAlert) { alertItem in
                switch alertItem {
                case .applied:
                    return Alert(
                        title: Text(appliedAlertTitle),
                        dismissButton: .default(Text(appliedAlertButtonText))
                    )
                case .joke:
                    return Alert(
                        title: Text(isRu ? "Ошибка вселенной" : "Universe Error"),
                        message: Text(isRu ? "Вы не можете отменить существование. Перезагрузка..." : "You cannot cancel existence. Rebooting spacetime..."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .onAppear {
                exist = true
                UITableView.appearance().backgroundColor = .clear
                UICollectionView.appearance().backgroundColor = .clear
                loadCustomTweaks()
            }
        }
    }

    private func applyTweaks() {
        guard !isApplying else { return }
        self.isApplying = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isApplying = false
            self.activeAlert = .applied
        }
    }

    /// Заголовок поп-апа применения (с поддержкой кастомного текста из добавленных твиков)
    private var appliedAlertTitle: String {
        let trimmedGlobal = customApplyTitleText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedGlobal.isEmpty {
            return trimmedGlobal
        }
        if let custom = customTweaks.last(where: { $0.isEnabled && !$0.alertTitleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            return custom.alertTitleText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return strings.tweaksAppliedTitle
    }

    /// Текст на кнопке поп-апа применения (с поддержкой кастомного текста из добавленных твиков)
    private var appliedAlertButtonText: String {
        let trimmedGlobal = customApplyButtonText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedGlobal.isEmpty {
            return trimmedGlobal
        }
        if let custom = customTweaks.last(where: { $0.isEnabled && !$0.alertButtonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            return custom.alertButtonText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return strings.tweaksAppliedButton
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
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 2)
        }
        .toggleStyle(SwitchToggleStyle(tint: iconColor))
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
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    
    @Binding var customTweaks: [CustomTweak]
    var onSave: () -> Void
    var onApplyRequested: (() -> Void)? = nil
    
    @State private var tweakToEdit: CustomTweak?
    
    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationView {
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
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle(isRu ? "Управление твиками" : "Manage Tweaks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isRu ? "Закрыть" : "Close") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(item: $tweakToEdit) { tweak in
                CustomTweakEditorSheet(
                    initialTweak: tweak,
                    onSave: { updatedTweak in
                        if let index = self.customTweaks.firstIndex(where: { $0.id == updatedTweak.id }) {
                            self.customTweaks[index] = updatedTweak
                            self.onSave()
                        }
                    },
                    onSaveAndApply: { updatedTweak in
                        if let index = self.customTweaks.firstIndex(where: { $0.id == updatedTweak.id }) {
                            self.customTweaks[index] = updatedTweak
                            self.onSave()
                        }
                        self.presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.onApplyRequested?()
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Универсальное модальное окно добавления/редактирования кастомного твика
struct CustomTweakEditorSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appThemeColor") private var appThemeColor: String = "blue"

    var initialTweak: CustomTweak?
    var onSave: (CustomTweak) -> Void
    var onSaveAndApply: ((CustomTweak) -> Void)? = nil

    @State private var title: String
    @State private var subtitle: String
    @State private var selectedColor: String
    @State private var alertButtonText: String
    @State private var alertTitleText: String
    @State private var showTestAlert: Bool = false
    
    init(initialTweak: CustomTweak? = nil, onSave: @escaping (CustomTweak) -> Void, onSaveAndApply: ((CustomTweak) -> Void)? = nil) {
        self.initialTweak = initialTweak
        self.onSave = onSave
        self.onSaveAndApply = onSaveAndApply
        _title = State(initialValue: initialTweak?.title ?? "")
        _subtitle = State(initialValue: initialTweak?.subtitle ?? "")
        _selectedColor = State(initialValue: initialTweak?.colorName ?? "purple")
        _alertButtonText = State(initialValue: initialTweak?.alertButtonText ?? "")
        _alertTitleText = State(initialValue: initialTweak?.alertTitleText ?? "")
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private var isRu: Bool {
        appLanguage == "ru"
    }

    var body: some View {
        NavigationView {
            Form {
                // Основная информация
                Section(header: Text(isRu ? "Параметры модуля" : "Module Info")) {
                    TextField(strings.tweaksAddNamePlaceholder, text: $title)
                        .font(.system(.body, design: .default))

                    TextField(strings.tweaksAddDescPlaceholder, text: $subtitle)
                        .font(.system(.body, design: .default))
                }

                // Текст кнопки и поп-апа после нажатия «Применить»
                Section(
                    header: Text(isRu ? "Кнопка и поп-ап после «Применить»" : "Button & Pop-up After Apply"),
                    footer: Text(isRu ? "Настройте текст на кнопке и заголовок поп-апа, которые появятся при нажатии «Применить»" : "Customize the button label and title shown in the pop-up after clicking Apply")
                ) {
                    TextField(
                        isRu ? "Текст на кнопке (по умолч.: «\(strings.tweaksAppliedButton)»)" : "Button text (default: \"\(strings.tweaksAppliedButton)\")",
                        text: $alertButtonText
                    )
                    .font(.system(.body, design: .default))

                    TextField(
                        isRu ? "Заголовок поп-апа (по умолч.: «\(strings.tweaksAppliedTitle)»)" : "Pop-up title (default: \"\(strings.tweaksAppliedTitle)\")",
                        text: $alertTitleText
                    )
                    .font(.system(.body, design: .default))

                    Button(action: {
                        self.showTestAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                            Text(isRu ? "Проверить поп-ап (Apply)" : "Test Apply Pop-up")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppTheme.resolveColor(name: selectedColor))
                    }
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
                    .accentColor(AppTheme.resolveColor(name: selectedColor))
                }

                // Кнопка сохранения и применения внизу формы
                Section {
                    Button(action: {
                        self.saveAndApplyTweak()
                    }) {
                        HStack {
                            Spacer()
                            Text(isRu ? "Сохранить и применить" : "Save & Apply")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppTheme.resolveColor(name: selectedColor))
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle(isRu ? (initialTweak == nil ? "Новый твик" : "Редактирование") : (initialTweak == nil ? "New Tweak" : "Edit Tweak"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(strings.tweaksAddCancelBtn) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(strings.tweaksAddSaveBtn) {
                        self.saveTweak()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert(isPresented: $showTestAlert) {
                Alert(
                    title: Text(alertTitleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? strings.tweaksAppliedTitle : alertTitleText.trimmingCharacters(in: .whitespacesAndNewlines)),
                    dismissButton: .default(Text(alertButtonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? strings.tweaksAppliedButton : alertButtonText.trimmingCharacters(in: .whitespacesAndNewlines)))
                )
            }
        }
    }

    private func saveTweak() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? (isRu ? "Пользовательский твик" : "Custom Tweak") : trimmedTitle
        let trimmedDesc = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedButton = alertButtonText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAlertTitle = alertTitleText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedButton.isEmpty {
            UserDefaults.standard.set(trimmedButton, forKey: "custom_apply_button_text")
        }
        if !trimmedAlertTitle.isEmpty {
            UserDefaults.standard.set(trimmedAlertTitle, forKey: "custom_apply_title_text")
        }

        let newTweak = CustomTweak(
            id: initialTweak?.id ?? UUID().uuidString,
            title: finalTitle,
            subtitle: trimmedDesc,
            icon: "",
            colorName: selectedColor,
            isEnabled: initialTweak?.isEnabled ?? true,
            alertButtonText: trimmedButton,
            alertTitleText: trimmedAlertTitle
        )
        self.onSave(newTweak)
        self.presentationMode.wrappedValue.dismiss()
    }

    private func saveAndApplyTweak() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? (isRu ? "Пользовательский твик" : "Custom Tweak") : trimmedTitle
        let trimmedDesc = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedButton = alertButtonText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAlertTitle = alertTitleText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedButton.isEmpty {
            UserDefaults.standard.set(trimmedButton, forKey: "custom_apply_button_text")
        }
        if !trimmedAlertTitle.isEmpty {
            UserDefaults.standard.set(trimmedAlertTitle, forKey: "custom_apply_title_text")
        }

        let newTweak = CustomTweak(
            id: initialTweak?.id ?? UUID().uuidString,
            title: finalTitle,
            subtitle: trimmedDesc,
            icon: "",
            colorName: selectedColor,
            isEnabled: initialTweak?.isEnabled ?? true,
            alertButtonText: trimmedButton,
            alertTitleText: trimmedAlertTitle
        )
        if let onSaveAndApply = onSaveAndApply {
            onSaveAndApply(newTweak)
        } else {
            self.onSave(newTweak)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

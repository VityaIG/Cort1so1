import SwiftUI

/// Экран управления твиками (появляется только после выполнения джейлбрейка)
struct TweaksView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"

    // Состояния твиков
    @AppStorage("tweak_godMode") private var godMode: Bool = false
    @AppStorage("tweak_topGrades") private var topGrades: Bool = true
    @AppStorage("tweak_exist") private var exist: Bool = true
    @AppStorage("tweak_display240Hz") private var display240Hz: Bool = false
    @AppStorage("tweak_infiniteBattery") private var infiniteBattery: Bool = false
    @AppStorage("tweak_mindReader") private var mindReader: Bool = false
    @AppStorage("tweak_teleportation") private var teleportation: Bool = false
    @AppStorage("tweak_antiGravity") private var antiGravity: Bool = false
    @AppStorage("tweak_adblockIRL") private var adblockIRL: Bool = true
    @AppStorage("tweak_infiniteCard") private var infiniteCard: Bool = false

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
                        // Верхняя статусная плашка
                        headerStatusCard

                        // 1. Базовые модификации
                        coreTweaksSection

                        // 2. Аппаратные и оверклок модули
                        hardwareTweaksSection

                        // 3. Пространственные и системные модули
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
            .alert(strings.tweaksAppliedTitle, isPresented: $showAppliedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(strings.tweaksAppliedMsg)
            }
            .onAppear {
                // Опция «Существовать» всегда включена по умолчанию при входе
                exist = true
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

    // MARK: - Секция 1: Основные модификации

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
                            // Немедленный краш приложения при выключении
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

    // MARK: - Секция 2: Аппаратные твики

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

    // MARK: - Секция 3: Квантовые и пространственные твики

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
            // Небольшая задержка перед алертом для имитации процесса
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

    // MARK: - Вспомогательные элементы

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

#Preview {
    TweaksView()
}

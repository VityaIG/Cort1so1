import Foundation
import SwiftUI

/// Доступные методы джейлбрейка
enum JailbreakMethod: String, CaseIterable, Identifiable {
    case dopamine
    case cortisol
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .dopamine: return "Dopamine (Old)"
        case .cortisol: return "Cortisol (New)"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .dopamine: return "Dopamine"
        case .cortisol: return "Cortisol"
        }
    }
    
    var subtitle: String {
        switch self {
        case .dopamine: return "iOS 15.0 – 16.6.1 • Rootless Legacy"
        case .cortisol: return "iOS 17.0 – 18.x • SPTM Direct Engine"
        }
    }
    
    var badgeText: String {
        switch self {
        case .dopamine: return "v2.4 Rootless"
        case .cortisol: return "v1.2 SPTM Direct"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .dopamine:
            return Color(red: 0.10, green: 0.82, blue: 0.48) // Emerald Green
        case .cortisol:
            return Color(red: 0.00, green: 0.88, blue: 1.00) // Neon Cyan
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .dopamine:
            return Color(red: 0.05, green: 0.65, blue: 0.38)
        case .cortisol:
            return Color(red: 0.72, green: 0.22, blue: 0.98) // Electric Purple
        }
    }
    
    var accentColor: Color {
        switch self {
        case .dopamine:
            return Color(red: 0.15, green: 0.20, blue: 0.25) // Dark Slate
        case .cortisol:
            return Color(red: 0.95, green: 0.15, blue: 0.30) // Crimson
        }
    }
    
    var systemIcon: String {
        switch self {
        case .dopamine: return "drop.fill"
        case .cortisol: return "bolt.shield.fill"
        }
    }
    
    func stepDelay(verbose: Bool) -> Double {
        if verbose {
            switch self {
            case .dopamine: return 0.40
            case .cortisol: return 0.26
            }
        } else {
            switch self {
            case .dopamine: return 0.75
            case .cortisol: return 0.50
            }
        }
    }
    
    var stepDelay: Double {
        stepDelay(verbose: true)
    }
    
    func logs(isRu: Bool, verbose: Bool = true) -> [JailbreakLogStep] {
        if verbose {
            switch self {
            case .dopamine:
                return [
                    JailbreakLogStep(id: 1, titleRu: "[PhysPuppet] Поиск смещения KASLR: 0x1bc24000", titleEn: "[PhysPuppet] Resolving KASLR Slide: 0x1bc24000", isMajorPhase: false, iconName: "cpu"),
                    JailbreakLogStep(id: 2, titleRu: "[Memory] Сканирование структуры allproc (0xfffffff00938b120)...", titleEn: "[Memory] Scanning allproc struct (0xfffffff00938b120)...", isMajorPhase: false, iconName: "memorychip"),
                    JailbreakLogStep(id: 3, titleRu: "[Kernel] Поиск базы ядра: 0xfffffff007004000", titleEn: "[Kernel] Locating kernel base: 0xfffffff007004000", isMajorPhase: false, iconName: "magnifyingglass"),
                    JailbreakLogStep(id: 4, titleRu: "[tfp0] Получение порта task_for_pid(0) через PUAF", titleEn: "[tfp0] Acquiring task_for_pid(0) via PUAF", isMajorPhase: false, iconName: "lock.open.fill"),
                    JailbreakLogStep(id: 5, titleRu: "[PAC] Обход регистров PAC (XPAC/AUTDA sign)...", titleEn: "[PAC] Bypassing PAC sign registers (XPAC/AUTDA)...", isMajorPhase: false, iconName: "key.fill"),
                    JailbreakLogStep(id: 6, titleRu: "⭐️ Фаза 1: База ядра найдена, PAC обход завершен", titleEn: "⭐️ Phase 1: Kernel Base Found & PAC Bypassed", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 7, titleRu: "[libkrw] Инициализация примитивов чтения/записи памяти", titleEn: "[libkrw] Initializing kernel memory r/w primitives", isMajorPhase: false, iconName: "bolt.horizontal.fill"),
                    JailbreakLogStep(id: 8, titleRu: "[PPL] Разметка L2 PTEs и обход защиты физических страниц", titleEn: "[PPL] Mapping L2 PTEs & bypassing PPL physical pages", isMajorPhase: false, iconName: "shield.slash.fill"),
                    JailbreakLogStep(id: 9, titleRu: "[AMFI] Патчинг проверок cs_enforcement_flags", titleEn: "[AMFI] Patching AMFI cs_enforcement_flags", isMajorPhase: false, iconName: "checkmark.shield.fill"),
                    JailbreakLogStep(id: 10, titleRu: "[CoreTrust] Обход проверки хешей сертификатов CT2", titleEn: "[CoreTrust] Bypassing CoreTrust 2.0 cert validation", isMajorPhase: false, iconName: "doc.badge.gearshape"),
                    JailbreakLogStep(id: 11, titleRu: "[ElleKit] Инъекция загрузчика твиков libsubstitute", titleEn: "[ElleKit] Injecting ElleKit tweak loader", isMajorPhase: false, iconName: "cube.fill"),
                    JailbreakLogStep(id: 12, titleRu: "⭐️ Фаза 2: PPL и ElleKit успешно настроены", titleEn: "⭐️ Phase 2: PPL & ElleKit Configured", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 13, titleRu: "[APFS] Монтирование снапшота в /private/preboot/uuid", titleEn: "[APFS] Mounting APFS snapshot to /private/preboot/uuid", isMajorPhase: false, iconName: "folder.fill"),
                    JailbreakLogStep(id: 14, titleRu: "[Bootstrap] Распаковка базового контейнера Procursus (tar.zst)", titleEn: "[Bootstrap] Extracting Procursus bootstrap container", isMajorPhase: false, iconName: "archivebox.fill"),
                    JailbreakLogStep(id: 15, titleRu: "[launchd] Перехват launchd (PID: 1) через XPC-трамплин", titleEn: "[launchd] Hooking launchd (PID: 1) via XPC trampoline", isMajorPhase: false, iconName: "arrow.triangle.merge"),
                    JailbreakLogStep(id: 16, titleRu: "[Cache] Сброс записей TLB и dyld_shared_cache", titleEn: "[Cache] Flushing TLB entries and dyld_shared_cache", isMajorPhase: false, iconName: "arrow.clockwise"),
                    JailbreakLogStep(id: 17, titleRu: "⭐️ Фаза 3: Окружение Dopamine подготовлено к респрингу", titleEn: "⭐️ Phase 3: Dopamine Environment Ready for Respring", isMajorPhase: true, iconName: "sparkles")
                ]
            case .cortisol:
                return [
                    JailbreakLogStep(id: 1, titleRu: "[LandCast] Зондирование аппаратных барьеров SPTM / TXM", titleEn: "[LandCast] Probing SPTM / TXM hardware boundaries", isMajorPhase: false, iconName: "cpu"),
                    JailbreakLogStep(id: 2, titleRu: "[KASLR] Расчет динамического смещения ядра: 0x24a08000", titleEn: "[KASLR] Computing dynamic kernel slide: 0x24a08000", isMajorPhase: false, iconName: "waveform.path.ecg"),
                    JailbreakLogStep(id: 3, titleRu: "[SPTM] Перехват таблиц Phys-to-Virt (SPTM_PTE_MAP)...", titleEn: "[SPTM] Hijacking Phys-to-Virt tables (SPTM_PTE_MAP)...", isMajorPhase: false, iconName: "shield.slash.fill"),
                    JailbreakLogStep(id: 4, titleRu: "[Exclave] Обход изоляции безопасной памяти SEP/Exclave", titleEn: "[Exclave] Bypassing Secure Enclave memory isolation", isMajorPhase: false, iconName: "lock.shield.fill"),
                    JailbreakLogStep(id: 5, titleRu: "[Token] Эскалация прав процесса: UID 501 -> UID 0 (root)", titleEn: "[Token] Escalating process token: UID 501 -> UID 0 (root)", isMajorPhase: false, iconName: "crown.fill"),
                    JailbreakLogStep(id: 6, titleRu: "⚡️ Фаза 1: Аппаратный обход SPTM/TXM и Root получены", titleEn: "⚡️ Phase 1: Hardware SPTM/TXM Bypass & Root Acquired", isMajorPhase: true, iconName: "bolt.shield.fill"),
                    JailbreakLogStep(id: 7, titleRu: "[AMFI v3] Переопределение динамической базы TrustCache", titleEn: "[AMFI v3] Overriding runtime TrustCache database", isMajorPhase: false, iconName: "checkmark.shield.fill"),
                    JailbreakLogStep(id: 8, titleRu: "[CoreTrust 3] Патчинг проверок подписи кода на лету", titleEn: "[CoreTrust 3] Patching dynamic code signature verification", isMajorPhase: false, iconName: "doc.badge.gearshape"),
                    JailbreakLogStep(id: 9, titleRu: "[FakeFS] Монтирование оверлея VFS в /private/var/cort1so1", titleEn: "[FakeFS] Initializing VFS overlay at /private/var/cort1so1", isMajorPhase: false, iconName: "folder.badge.gearshape"),
                    JailbreakLogStep(id: 10, titleRu: "[Substrate] Загрузка высокоскоростного JIT-движка SubHook", titleEn: "[Substrate] Loading high-speed SubHook JIT engine", isMajorPhase: false, iconName: "bolt.fill"),
                    JailbreakLogStep(id: 11, titleRu: "[Toolchain] Развертывание пакетов Cort1so1 Core Tools (dpkg/apt)", titleEn: "[Toolchain] Deploying Cort1so1 Core Tools (dpkg/apt)", isMajorPhase: false, iconName: "shippingbox.fill"),
                    JailbreakLogStep(id: 12, titleRu: "⚡️ Фаза 2: Оверлей FakeFS и движок Substrate активированы", titleEn: "⚡️ Phase 2: FakeFS Overlay & Substrate Engine Active", isMajorPhase: true, iconName: "bolt.shield.fill"),
                    JailbreakLogStep(id: 13, titleRu: "[Daemon] Запуск системного демона: /var/run/cort1so1.sock", titleEn: "[Daemon] Spawning system daemon: /var/run/cort1so1.sock", isMajorPhase: false, iconName: "server.rack"),
                    JailbreakLogStep(id: 14, titleRu: "[launchd] Перехват libsystem_trace и posix_spawn в PID 1", titleEn: "[launchd] Hooking libsystem_trace & posix_spawn in PID 1", isMajorPhase: false, iconName: "arrow.triangle.merge"),
                    JailbreakLogStep(id: 15, titleRu: "[Cryptex] Пересборка динамического кэша общих библиотек", titleEn: "[Cryptex] Rebuilding dynamic shared library cache", isMajorPhase: false, iconName: "cpu.fill"),
                    JailbreakLogStep(id: 16, titleRu: "[Sync] Синхронизация системных дескрипторов и devicetree", titleEn: "[Sync] Syncing system file descriptors & devicetree", isMajorPhase: false, iconName: "arrow.clockwise"),
                    JailbreakLogStep(id: 17, titleRu: "⚡️ Фаза 3: Окружение Cortisol готово к активации твиков", titleEn: "⚡️ Phase 3: Cortisol Environment Ready for Tweak Activation", isMajorPhase: true, iconName: "sparkles")
                ]
            }
        } else {
            // Concise non-verbose summary steps
            switch self {
            case .dopamine:
                return [
                    JailbreakLogStep(id: 1, titleRu: "[Поиск базы ядра и обход PAC...]", titleEn: "[Resolving kernel base & bypassing PAC...]", isMajorPhase: false, iconName: "magnifyingglass"),
                    JailbreakLogStep(id: 2, titleRu: "⭐️ Фаза 1: База ядра найдена, PAC обход завершен", titleEn: "⭐️ Phase 1: Kernel Base Found & PAC Bypassed", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 3, titleRu: "[Настройка обхода PPL и инъекции ElleKit...]", titleEn: "[Configuring PPL bypass & ElleKit injection...]", isMajorPhase: false, iconName: "shield.slash.fill"),
                    JailbreakLogStep(id: 4, titleRu: "⭐️ Фаза 2: PPL и ElleKit успешно настроены", titleEn: "⭐️ Phase 2: PPL & ElleKit Configured", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 5, titleRu: "[Монтирование APFS и перехват launchd...]", titleEn: "[Mounting APFS snapshot & hooking launchd...]", isMajorPhase: false, iconName: "folder.fill"),
                    JailbreakLogStep(id: 6, titleRu: "⭐️ Фаза 3: Окружение Dopamine подготовлено к респрингу", titleEn: "⭐️ Phase 3: Dopamine Environment Ready for Respring", isMajorPhase: true, iconName: "sparkles")
                ]
            case .cortisol:
                return [
                    JailbreakLogStep(id: 1, titleRu: "[Аппаратный обход SPTM/TXM и получение Root...]", titleEn: "[Hardware SPTM/TXM bypass & acquiring Root...]", isMajorPhase: false, iconName: "shield.slash.fill"),
                    JailbreakLogStep(id: 2, titleRu: "⚡️ Фаза 1: Аппаратный обход SPTM/TXM и Root получены", titleEn: "⚡️ Phase 1: Hardware SPTM/TXM Bypass & Root Acquired", isMajorPhase: true, iconName: "bolt.shield.fill"),
                    JailbreakLogStep(id: 3, titleRu: "[Инициализация FakeFS и активация движка Substrate...]", titleEn: "[Initializing FakeFS & activating Substrate engine...]", isMajorPhase: false, iconName: "bolt.fill"),
                    JailbreakLogStep(id: 4, titleRu: "⚡️ Фаза 2: Оверлей FakeFS и движок Substrate активированы", titleEn: "⚡️ Phase 2: FakeFS Overlay & Substrate Engine Active", isMajorPhase: true, iconName: "bolt.shield.fill"),
                    JailbreakLogStep(id: 5, titleRu: "[Запуск демона сокета и синхронизация devicetree...]", titleEn: "[Spawning socket daemon & syncing devicetree...]", isMajorPhase: false, iconName: "server.rack"),
                    JailbreakLogStep(id: 6, titleRu: "⚡️ Фаза 3: Окружение Cortisol готово к активации твиков", titleEn: "⚡️ Phase 3: Cortisol Environment Ready for Tweak Activation", isMajorPhase: true, iconName: "sparkles")
                ]
            }
        }
    }
}

/// Состояния процесса джейлбрейка
enum JailbreakState: Equatable {
    case idle
    case initializing(step: Int, total: Int, description: String)
    case streamingLogs
    case respring
    case completed
}

/// Модель шага инициализации
struct PipelineStep: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
}

/// Генерация шагов пайплайна с учетом языка
func getPipelineSteps(for strings: LocalizedStrings) -> [PipelineStep] {
    return [
        PipelineStep(id: 1, title: strings.step1Title, subtitle: strings.step1Subtitle),
        PipelineStep(id: 2, title: strings.step2Title, subtitle: strings.step2Subtitle),
        PipelineStep(id: 3, title: strings.step3Title, subtitle: strings.step3Subtitle),
        PipelineStep(id: 4, title: strings.step4Title, subtitle: strings.step4Subtitle),
        PipelineStep(id: 5, title: strings.step5Title, subtitle: strings.step5Subtitle)
    ]
}

/// Доступные шаги пайплайна по умолчанию
let defaultPipelineSteps: [PipelineStep] = [
    PipelineStep(id: 1, title: "Инициализация среды", subtitle: "Проверка системных разрешений и песочницы..."),
    PipelineStep(id: 2, title: "Поиск смещений ядра", subtitle: "Вычисление KASLR slide и структуры proc_t..."),
    PipelineStep(id: 3, title: "Обход защитных механизмов", subtitle: "Патчинг проверок подписи AMFI и CoreTrust..."),
    PipelineStep(id: 4, title: "Получение привилегий tfp0", subtitle: "Установка прав суперпользователя (root)..."),
    PipelineStep(id: 5, title: "Развертывание Bootstrap", subtitle: "Развертывание Procursus и менеджеров пакетов...")
]

/// Модель прошивки для симуляции отката
struct FirmwareVersion: Identifiable {
    let id = UUID()
    let version: String
    let build: String
    let features: String
    let badgeText: String
    let badgeColor: Color
    let group: String
    let sha256: String
}

/// Список версий для экрана отката
let sampleFirmwares: [FirmwareVersion] = [
    // LATEST & BETAS
    FirmwareVersion(
        version: "iOS 27.0 Beta 4",
        build: "31A5320d",
        features: "SEP / BB Bypass",
        badgeText: "BETA",
        badgeColor: .purple,
        group: "LATEST & BETAS",
        sha256: "8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4"
    ),
    FirmwareVersion(
        version: "iOS 26.6.1",
        build: "30G82",
        features: "SEP / BB Bypass",
        badgeText: "STABLE",
        badgeColor: .cyan,
        group: "LATEST & BETAS",
        sha256: "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
    ),
    FirmwareVersion(
        version: "iOS 26.5",
        build: "30F66",
        features: "SEP / BB Bypass",
        badgeText: "STABLE",
        badgeColor: .cyan,
        group: "LATEST & BETAS",
        sha256: "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
    ),
    
    // STABLE RELEASES
    FirmwareVersion(
        version: "iOS 18.7.1",
        build: "22H374",
        features: "SEP / BB Bypass",
        badgeText: "RECOMMENDED",
        badgeColor: .green,
        group: "STABLE RELEASES",
        sha256: "4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a"
    ),
    FirmwareVersion(
        version: "iOS 18.6",
        build: "22G75",
        features: "SEP / BB Bypass",
        badgeText: "STABLE",
        badgeColor: .green,
        group: "STABLE RELEASES",
        sha256: "b6c810d29312157d62fc0bc4229ea4b4ec012826fc4933a39eaef91763b65287"
    ),
    FirmwareVersion(
        version: "iOS 18.5",
        build: "22F55",
        features: "SEP / BB Bypass",
        badgeText: "STABLE",
        badgeColor: .green,
        group: "STABLE RELEASES",
        sha256: "a1a8c889f5bc08b981442f4c9c10f84be5e1657c913532c51000f68dc9948092"
    ),
    FirmwareVersion(
        version: "iOS 18.4",
        build: "22E210",
        features: "SEP / BB Bypass",
        badgeText: "STABLE",
        badgeColor: .green,
        group: "STABLE RELEASES",
        sha256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    )
]

struct AppTheme {
    static let availableColors: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("purple", .purple),
        ("pink", .pink),
        ("red", .red),
        ("orange", .orange),
        ("green", .green),
        ("cyan", .cyan),
        ("indigo", .indigo)
    ]

    static func resolveColor(name: String) -> Color {
        if let match = availableColors.first(where: { $0.name == name }) {
            return match.color
        }
        return .blue
    }
}

/// Набор тем для кастомизации цвета фона приложения (не элементов)
struct AppBgTheme: Identifiable {
    let id: String
    let nameRu: String
    let nameEn: String
    let color: Color

    static let availableThemes: [AppBgTheme] = [
        AppBgTheme(id: "default", nameRu: "Системный (По умолчанию)", nameEn: "System Default", color: Color(uiColor: .systemGroupedBackground)),
        AppBgTheme(id: "pure_black", nameRu: "OLED Глубокий черный", nameEn: "OLED Pure Black", color: Color.black),
        AppBgTheme(id: "deep_navy", nameRu: "Темно-синий океан", nameEn: "Deep Navy", color: Color(red: 0.04, green: 0.06, blue: 0.12)),
        AppBgTheme(id: "cyber_slate", nameRu: "Кибер-Слейт", nameEn: "Cyber Slate", color: Color(red: 0.06, green: 0.09, blue: 0.14)),
        AppBgTheme(id: "crimson_dark", nameRu: "Темно-бордовый", nameEn: "Crimson Velvet", color: Color(red: 0.12, green: 0.03, blue: 0.05)),
        AppBgTheme(id: "forest_dark", nameRu: "Темный изумруд", nameEn: "Dark Emerald", color: Color(red: 0.03, green: 0.10, blue: 0.06)),
        AppBgTheme(id: "purple_midnight", nameRu: "Полночный пурпур", nameEn: "Midnight Purple", color: Color(red: 0.08, green: 0.04, blue: 0.14)),
        AppBgTheme(id: "charcoal", nameRu: "Графитовый серый", nameEn: "Charcoal Gray", color: Color(red: 0.10, green: 0.10, blue: 0.11))
    ]

    static func resolveColor(id: String) -> Color {
        if let match = availableThemes.first(where: { $0.id == id }) {
            return match.color
        }
        return Color(uiColor: .systemGroupedBackground)
    }
}

/// Утилита динамического разрешения пользовательских цветов оформления ADMIN
struct AppCustomStyle {
    static func resolveBgColor(customHex: String, themeId: String) -> Color {
        if !customHex.isEmpty && customHex != "default" {
            return Color(hex: customHex)
        }
        return AppBgTheme.resolveColor(id: themeId)
    }

    static func resolveCardColor(customHex: String) -> Color {
        if !customHex.isEmpty && customHex != "default" {
            return Color(hex: customHex)
        }
        return Color(uiColor: .secondarySystemGroupedBackground)
    }

    static func resolveTextColor(customHex: String) -> Color {
        if !customHex.isEmpty && customHex != "default" {
            return Color(hex: customHex)
        }
        return .primary
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        let uic = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if uic.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let r = Int(round(red * 255))
            let g = Int(round(green * 255))
            let b = Int(round(blue * 255))
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            var white: CGFloat = 0
            if uic.getWhite(&white, alpha: &alpha) {
                let w = Int(round(white * 255))
                return String(format: "#%02X%02X%02X", w, w, w)
            }
        }
        return "#000000"
    }
}

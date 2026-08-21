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
        case .dopamine: return "Классический метод джейлбрейка"
        case .cortisol: return "Инновационный метод джейлбрейка"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .dopamine:
            return Color(red: 0.10, green: 0.80, blue: 0.45) // Emerald Green
        case .cortisol:
            return Color(red: 0.00, green: 0.88, blue: 1.00) // Neon Cyan
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
    
    func stepDelay(verbose: Bool) -> Double {
        if verbose {
            switch self {
            case .dopamine: return 0.45
            case .cortisol: return 0.35
            }
        } else {
            switch self {
            case .dopamine: return 0.85
            case .cortisol: return 0.70
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
                    JailbreakLogStep(id: 1, titleRu: "[PhysPuppet] Инициализация KASLR slide: 0x1bc24000", titleEn: "[PhysPuppet] Resolving KASLR Slide: 0x1bc24000", isMajorPhase: false, iconName: "cpu"),
                    JailbreakLogStep(id: 2, titleRu: "[Finding kernel base at 0xfffffff007004000...]", titleEn: "[Finding kernel base at 0xfffffff007004000...]", isMajorPhase: false, iconName: "magnifyingglass"),
                    JailbreakLogStep(id: 3, titleRu: "[Scanning allproc table (0xfffffff00938b120)...]", titleEn: "[Scanning allproc table (0xfffffff00938b120)...]", isMajorPhase: false, iconName: "memorychip"),
                    JailbreakLogStep(id: 4, titleRu: "[Extracting Procursus bootstrap container...]", titleEn: "[Extracting Procursus bootstrap container...]", isMajorPhase: false, iconName: "archivebox.fill"),
                    JailbreakLogStep(id: 5, titleRu: "[Bypassing PAC & SPTM registers...]", titleEn: "[Bypassing PAC & SPTM registers...]", isMajorPhase: false, iconName: "key.fill"),
                    JailbreakLogStep(id: 6, titleRu: "[Acquiring tfp0 port: 0x0000000000001003]", titleEn: "[Acquiring tfp0 port: 0x0000000000001003]", isMajorPhase: false, iconName: "lock.open.fill"),
                    JailbreakLogStep(id: 7, titleRu: "Фаза 1: База ядра найдена, PAC обход завершен", titleEn: "Phase 1: Kernel Base Found & PAC Bypassed", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 8, titleRu: "[Initializing libkrw memory primitives...]", titleEn: "[Initializing libkrw memory primitives...]", isMajorPhase: false, iconName: "bolt.horizontal.fill"),
                    JailbreakLogStep(id: 9, titleRu: "[Setting up PPL bypass & mapping L2 PTEs...]", titleEn: "[Setting up PPL bypass & mapping L2 PTEs...]", isMajorPhase: false, iconName: "shield.slash.fill"),
                    JailbreakLogStep(id: 10, titleRu: "[Bypassing AMFI cs_enforcement hooks...]", titleEn: "[Bypassing AMFI cs_enforcement hooks...]", isMajorPhase: false, iconName: "checkmark.shield.fill"),
                    JailbreakLogStep(id: 11, titleRu: "[Patching CoreTrust 2.0 dynamic trustcache...]", titleEn: "[Patching CoreTrust 2.0 dynamic trustcache...]", isMajorPhase: false, iconName: "doc.badge.gearshape"),
                    JailbreakLogStep(id: 12, titleRu: "[Installing ElleKit tweak injection loader...]", titleEn: "[Installing ElleKit tweak injection loader...]", isMajorPhase: false, iconName: "cube.fill"),
                    JailbreakLogStep(id: 13, titleRu: "Фаза 2: PPL и ElleKit успешно настроены", titleEn: "Phase 2: PPL & ElleKit Configured", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 14, titleRu: "[Mounting APFS rootfs snapshot at /private/preboot...]", titleEn: "[Mounting APFS rootfs snapshot at /private/preboot...]", isMajorPhase: false, iconName: "folder.fill"),
                    JailbreakLogStep(id: 15, titleRu: "[Injecting launchd hooks (PID: 1)...]", titleEn: "[Injecting launchd hooks (PID: 1)...]", isMajorPhase: false, iconName: "arrow.triangle.merge"),
                    JailbreakLogStep(id: 16, titleRu: "[Flushing TLB cache and dyld_shared_cache...]", titleEn: "[Flushing TLB cache and dyld_shared_cache...]", isMajorPhase: false, iconName: "arrow.clockwise"),
                    JailbreakLogStep(id: 17, titleRu: "Джейлбрейк Dopamine подготовлен к респрингу", titleEn: "Dopamine Environment Ready for Respring", isMajorPhase: true, iconName: "sparkles")
                ]
            case .cortisol:
                return [
                    JailbreakLogStep(id: 1, titleRu: "[LandCast] Расчет смещения базы ядра: 0x24a08000", titleEn: "[LandCast] Computing kernel base slide: 0x24a08000", isMajorPhase: false, iconName: "cpu"),
                    JailbreakLogStep(id: 2, titleRu: "[Bypassing PAC/PPL & SPTM physical pages...]", titleEn: "[Bypassing PAC/PPL & SPTM physical pages...]", isMajorPhase: false, iconName: "shield.slash.fill"),
                    JailbreakLogStep(id: 3, titleRu: "[Injecting Cortisol runtime tweak loader...]", titleEn: "[Injecting Cortisol runtime tweak loader...]", isMajorPhase: false, iconName: "bolt.fill"),
                    JailbreakLogStep(id: 4, titleRu: "[Resolving proc_t: 0xffffffe28a34b210...]", titleEn: "[Resolving proc_t: 0xffffffe28a34b210...]", isMajorPhase: false, iconName: "memorychip"),
                    JailbreakLogStep(id: 5, titleRu: "[Escalating credentials: UID 501 -> UID 0 (root)]", titleEn: "[Escalating credentials: UID 501 -> UID 0 (root)]", isMajorPhase: false, iconName: "crown.fill"),
                    JailbreakLogStep(id: 6, titleRu: "Фаза 1: Смещения ядра Cortisol разрешены", titleEn: "Phase 1: Cortisol Kernel Offsets Resolved", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 7, titleRu: "[Patching CoreTrust 2.0 AMFI verification...]", titleEn: "[Patching CoreTrust 2.0 AMFI verification...]", isMajorPhase: false, iconName: "checkmark.shield.fill"),
                    JailbreakLogStep(id: 8, titleRu: "[Registering dynamic TrustCache: 0xffffffe21109a000...]", titleEn: "[Registering dynamic TrustCache: 0xffffffe21109a000...]", isMajorPhase: false, iconName: "doc.badge.gearshape"),
                    JailbreakLogStep(id: 9, titleRu: "[Mounting fakefs overlay at /private/var/cort1so1...]", titleEn: "[Mounting fakefs overlay at /private/var/cort1so1...]", isMajorPhase: false, iconName: "folder.fill"),
                    JailbreakLogStep(id: 10, titleRu: "[Deploying Procursus utilities: dpkg, apt, sh...]", titleEn: "[Deploying Procursus utilities: dpkg, apt, sh...]", isMajorPhase: false, iconName: "shippingbox.fill"),
                    JailbreakLogStep(id: 11, titleRu: "Фаза 2: Права Root получены и fakefs смонтирован", titleEn: "Phase 2: Root Privileges & FakeFS Mounted", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 12, titleRu: "[Starting Cortisol daemon: /var/run/cort1so1.sock...]", titleEn: "[Starting Cortisol daemon: /var/run/cort1so1.sock...]", isMajorPhase: false, iconName: "server.rack"),
                    JailbreakLogStep(id: 13, titleRu: "[Hooking libsystem_trace in launchd (PID: 1)...]", titleEn: "[Hooking libsystem_trace in launchd (PID: 1)...]", isMajorPhase: false, iconName: "arrow.triangle.merge"),
                    JailbreakLogStep(id: 14, titleRu: "[Syncing devicetree and file descriptors...]", titleEn: "[Syncing devicetree and file descriptors...]", isMajorPhase: false, iconName: "arrow.clockwise"),
                    JailbreakLogStep(id: 15, titleRu: "Джейлбрейк Cortisol подготовлен к респрингу", titleEn: "Cortisol Environment Ready for Respring", isMajorPhase: true, iconName: "sparkles")
                ]
            }
        } else {
            // Concise non-verbose summary steps (4 essential phases)
            switch self {
            case .dopamine:
                return [
                    JailbreakLogStep(id: 1, titleRu: "[Инициализация обхода PAC и базы ядра...]", titleEn: "[Bypassing PAC & resolving kernel base...]", isMajorPhase: false, iconName: "key.fill"),
                    JailbreakLogStep(id: 2, titleRu: "Фаза 1: База ядра найдена, права получены", titleEn: "Phase 1: Kernel Base Found & Permissions Granted", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 3, titleRu: "Фаза 2: PPL и ElleKit успешно настроены", titleEn: "Phase 2: PPL & ElleKit Configured", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 4, titleRu: "Джейлбрейк Dopamine подготовлен к респрингу", titleEn: "Dopamine Environment Ready for Respring", isMajorPhase: true, iconName: "sparkles")
                ]
            case .cortisol:
                return [
                    JailbreakLogStep(id: 1, titleRu: "[Инициализация ядра Cortisol и смещений...]", titleEn: "[Initializing Cortisol engine & resolving offsets...]", isMajorPhase: false, iconName: "shield.slash.fill"),
                    JailbreakLogStep(id: 2, titleRu: "Фаза 1: Смещения ядра Cortisol разрешены", titleEn: "Phase 1: Cortisol Kernel Offsets Resolved", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 3, titleRu: "Фаза 2: Права Root получены и fakefs смонтирован", titleEn: "Phase 2: Root Privileges & FakeFS Mounted", isMajorPhase: true, iconName: "checkmark.circle.fill"),
                    JailbreakLogStep(id: 4, titleRu: "Джейлбрейк Cortisol подготовлен к респрингу", titleEn: "Cortisol Environment Ready for Respring", isMajorPhase: true, iconName: "sparkles")
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

// MARK: - Global OS Logo Views

struct WindowsLogoView: View {
    var color: Color
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Rectangle().fill(color).frame(width: 44, height: 44)
                Rectangle().fill(color).frame(width: 44, height: 44)
            }
            HStack(spacing: 6) {
                Rectangle().fill(color).frame(width: 44, height: 44)
                Rectangle().fill(color).frame(width: 44, height: 44)
            }
        }
    }
}

struct UbuntuLogoView: View {
    var color: Color = Color(red: 0.90, green: 0.28, blue: 0.12)
    var body: some View {
        Image(systemName: "terminal.fill")
            .font(.system(size: 96, weight: .regular))
            .foregroundColor(color)
    }
}

struct AndroidRobotHead: View {
    var color: Color? = nil
    var body: some View {
        Group {
            if let image = UIImage(named: "androidlogo") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "androidlogo", ofType: "png") ?? "") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image("androidlogo")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

// MARK: - Liquid Glass System (iOS 26+)

struct LiquidGlassModifier: ViewModifier {
    @State private var touchLocation: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var isInteracting: Bool = false
    
    var cornerRadius: CGFloat = 20
    var refractionIntensity: CGFloat = 0.4
    
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Базовый стеклующийся слой Liquid Glass
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.85)
                    
                    // Хроматическое преломление и динамический блик
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(isInteracting ? 0.35 : 0.15),
                                    Color.clear
                                ]),
                                center: UnitPoint(
                                    x: touchLocation.x,
                                    y: touchLocation.y
                                ),
                                startRadius: 10,
                                endRadius: 160
                            )
                        )
                        .blendMode(.overlay)
                    
                    // Спекулярный кант
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.7), location: 0),
                                    .init(color: .white.opacity(0.1), location: 0.5),
                                    .init(color: .clear, location: 1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchLocation = CGPoint(
                            x: max(0, min(1, value.location.x / 300)),
                            y: max(0, min(1, value.location.y / 150))
                        )
                        isInteracting = true
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            touchLocation = CGPoint(x: 0.5, y: 0.5)
                            isInteracting = false
                        }
                    }
            )
    }
}

// MARK: - View Extension for Liquid Glass

extension View {
    func liquidGlassStyle(cornerRadius: CGFloat = 20, refraction: CGFloat = 0.4) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, refractionIntensity: refraction))
    }
}

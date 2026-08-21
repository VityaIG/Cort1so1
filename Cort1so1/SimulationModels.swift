import Foundation
import SwiftUI

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
struct FirmwareVersion: Identifiable, Hashable {
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

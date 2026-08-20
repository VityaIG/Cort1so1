import Foundation

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
    let releaseDateRu: String
    let releaseDateEn: String
    let isSigned: Bool
    let isBeta: Bool
    let sizeGB: Double
    let sha256: String
    let sepStatusRu: String
    let sepStatusEn: String

    func releaseDate(isRu: Bool) -> String {
        isRu ? releaseDateRu : releaseDateEn
    }

    func sepStatus(isRu: Bool) -> String {
        isRu ? sepStatusRu : sepStatusEn
    }
}

/// Список версий для экрана отката согласно спецификации
let sampleFirmwares: [FirmwareVersion] = [
    FirmwareVersion(
        version: "27.0 Beta 4",
        build: "31A512",
        releaseDateRu: "Июль 2026",
        releaseDateEn: "July 2026",
        isSigned: true,
        isBeta: true,
        sizeGB: 7.4,
        sha256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        sepStatusRu: "Совместим (Beta SEP)",
        sepStatusEn: "Compatible (Beta SEP)"
    ),
    FirmwareVersion(
        version: "26.6",
        build: "30G78",
        releaseDateRu: "Август 2025",
        releaseDateEn: "August 2025",
        isSigned: true,
        isBeta: false,
        sizeGB: 7.1,
        sha256: "8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4",
        sepStatusRu: "Совместим (Cryptex1 Match)",
        sepStatusEn: "Compatible (Cryptex1 Match)"
    ),
    FirmwareVersion(
        version: "26.0",
        build: "30A195",
        releaseDateRu: "Сентябрь 2024",
        releaseDateEn: "September 2024",
        isSigned: true,
        isBeta: false,
        sizeGB: 6.8,
        sha256: "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb",
        sepStatusRu: "Совместим (Full TSS)",
        sepStatusEn: "Compatible (Full TSS)"
    ),
    FirmwareVersion(
        version: "18.7.1",
        build: "22H310",
        releaseDateRu: "Октябрь 2024",
        releaseDateEn: "October 2024",
        isSigned: false,
        isBeta: false,
        sizeGB: 6.4,
        sha256: "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8",
        sepStatusRu: "Нужны SHSH2 + Cryptex Fix",
        sepStatusEn: "Requires SHSH2 + Cryptex Fix"
    ),
    FirmwareVersion(
        version: "18.5",
        build: "22F76",
        releaseDateRu: "Май 2024",
        releaseDateEn: "May 2024",
        isSigned: false,
        isBeta: false,
        sizeGB: 6.1,
        sha256: "4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a",
        sepStatusRu: "SHSH2 Futurerestore (Gaster)",
        sepStatusEn: "SHSH2 Futurerestore (Gaster)"
    )
]

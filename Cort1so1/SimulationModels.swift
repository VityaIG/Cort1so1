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

/// Доступные шаги пайплайна в стиле Dopamine
let defaultPipelineSteps: [PipelineStep] = [
    PipelineStep(id: 1, title: "Инициализация среды", subtitle: "Проверка системных разрешений и песочницы..."),
    PipelineStep(id: 2, title: "Поиск смещений ядра", subtitle: "Вычисление KASLR slide и структуры proc_t..."),
    PipelineStep(id: 3, title: "Обход защитных механизмов", subtitle: "Патчинг проверок подписи AMFI и CoreTrust..."),
    PipelineStep(id: 4, title: "Получение привилегий tfp0", subtitle: "Установка прав суперпользователя (root)..."),
    PipelineStep(id: 5, title: "Подготовка Bootstrap", subtitle: "Развертывание Procursus и менеджеров пакетов...")
]

/// Модель прошивки для симуляции отката
struct FirmwareVersion: Identifiable, Hashable {
    let id = UUID()
    let version: String
    let build: String
    let releaseDate: String
    let isSigned: Bool
    let sizeGB: Double
}

/// Список версий для экрана отката
let sampleFirmwares: [FirmwareVersion] = [
    FirmwareVersion(version: "iOS 26.0", build: "30A195", releaseDate: "Сентябрь 2025", isSigned: true, sizeGB: 7.1),
    FirmwareVersion(version: "iOS 25.5.1", build: "29F80", releaseDate: "Июль 2025", isSigned: true, sizeGB: 6.8),
    FirmwareVersion(version: "iOS 25.4", build: "29E210", releaseDate: "Май 2025", isSigned: false, sizeGB: 6.6),
    FirmwareVersion(version: "iOS 25.1", build: "29B120", releaseDate: "Декабрь 2024", isSigned: false, sizeGB: 6.3),
    FirmwareVersion(version: "iOS 18.0", build: "22A3354", releaseDate: "Сентябрь 2024", isSigned: false, sizeGB: 5.8)
]

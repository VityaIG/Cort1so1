import Foundation
import SwiftUI

/// Поддерживаемые языки приложения
enum AppLanguage: String, CaseIterable, Identifiable {
    case ru = "ru"
    case en = "en"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .ru: return "Русский"
        case .en: return "English"
        }
    }
}

/// Менеджер локализации интерфейса
struct LocalizedStrings {
    let lang: AppLanguage

    init(langCode: String) {
        self.lang = AppLanguage(rawValue: langCode) ?? .ru
    }

    // MARK: - Tab Bar
    var tabMain: String { lang == .ru ? "Основное" : "Main" }
    var tabDowngrade: String { lang == .ru ? "Откат iOS" : "iOS Downgrade" }
    var tabSettings: String { lang == .ru ? "Настройки" : "Settings" }

    // MARK: - Main View
    var mainTitle: String { "Cort1so1" }
    var modeTitle: String { lang == .ru ? "Режим работы" : "Execution Mode" }
    var modeRootless: String { "Rootless" }
    var modeStandard: String { lang == .ru ? "Стандарт" : "Standard" }
    var modeExpert: String { lang == .ru ? "Эксперт" : "Expert" }

    var statusTitle: String { lang == .ru ? "Состояние" : "Status" }
    var statusCompatible: String { lang == .ru ? "Совместимо" : "Compatible" }
    var statusRunning: String { lang == .ru ? "Выполняется" : "Running" }
    var statusExploit: String { lang == .ru ? "Эксплойт" : "Exploit" }
    var statusRespring: String { lang == .ru ? "Респринг" : "Respring" }
    var statusActive: String { lang == .ru ? "Активирован" : "Active" }

    var kernelTitle: String { lang == .ru ? "Ядро" : "Kernel" }
    var kernelReady: String { lang == .ru ? "Готов к запуску" : "Ready" }
    var kernelPatching: String { lang == .ru ? "Патчинг..." : "Patching..." }
    var kernelRestarting: String { lang == .ru ? "Перезапуск..." : "Restarting..." }
    var kernelRootless: String { "Rootless (tfp0)" }

    var archTitle: String { lang == .ru ? "Архитектура" : "Architecture" }
    var archValue: String { "arm64e (PPL Bypass)" }

    func readyTitle(for version: String) -> String {
        "iOS \(version) — " + (lang == .ru ? "Совместимо" : "Compatible")
    }
    var readyTitle: String { readyTitle(for: "18.0") }
    var readySubtitle: String { lang == .ru ? "Система готова к запуску симуляции." : "System is ready to begin exploitation." }

    var completedTitle: String { lang == .ru ? "Джейлбрейк выполнен!" : "Jailbroken!" }
    var completedSubtitle: String { lang == .ru ? "Пакетный менеджер Sileo готов к работе." : "Sileo package manager is ready." }

    var buttonJailbreak: String { "Jailbreak" }
    var buttonProcessing: String { lang == .ru ? "Выполнение..." : "Jailbreaking..." }
    var buttonReJailbreak: String { lang == .ru ? "Повторить (Re-Jailbreak)" : "Re-Jailbreak" }
    var buttonRespring: String { lang == .ru ? "Респринг" : "Respring" }

    // Alert
    var confirmAlertTitle: String { lang == .ru ? "Вы уверены?" : "Are you sure?" }
    var confirmAlertMessage: String { lang == .ru ? "Будет выполнен процесс джейлбрейка Cort1so1 для текущего устройства." : "The Cort1so1 jailbreak sequence will begin for this device." }
    var confirmYesBtn: String { lang == .ru ? "Да" : "Yes" }

    var stepProgress: String { lang == .ru ? "Этап" : "Step" }
    var stepOf: String { lang == .ru ? "из" : "of" }

    // MARK: - Pipeline Steps (Dopamine Style)
    var step1Title: String { lang == .ru ? "Инициализация среды" : "Initializing Environment" }
    var step1Subtitle: String { lang == .ru ? "Проверка системных разрешений и песочницы..." : "Checking system sandbox and permissions..." }

    var step2Title: String { lang == .ru ? "Поиск смещений ядра" : "Finding Kernel Offsets" }
    var step2Subtitle: String { lang == .ru ? "Вычисление KASLR slide и структуры proc_t..." : "Calculating KASLR slide and proc_t structures..." }

    var step3Title: String { lang == .ru ? "Обход защитных механизмов" : "Bypassing Mitigations" }
    var step3Subtitle: String { lang == .ru ? "Патчинг проверок подписи AMFI и CoreTrust..." : "Patching AMFI and CoreTrust signature checks..." }

    var step4Title: String { lang == .ru ? "Получение привилегий tfp0" : "Gaining tfp0 Privileges" }
    var step4Subtitle: String { lang == .ru ? "Установка прав суперпользователя (root)..." : "Acquiring root privileges and kernel task port..." }

    var step5Title: String { lang == .ru ? "Развертывание Bootstrap" : "Extracting Bootstrap" }
    var step5Subtitle: String { lang == .ru ? "Развертывание Procursus и менеджеров пакетов..." : "Deploying Procursus bootstrap & Sileo package manager..." }

    // MARK: - Downgrade View (Reimagined)
    var downgradeTitle: String { lang == .ru ? "Откат iOS" : "iOS Downgrade" }
    var downgradeSubtitle: String { lang == .ru ? "Восстановление и симуляция установки IPSW через Futurerestore / TSS" : "IPSW restore simulation engine via Futurerestore & TSS" }
    var currentDeviceHeader: String { lang == .ru ? "Текущее устройство" : "Current Device" }
    var targetFirmware: String { lang == .ru ? "Целевая версия прошивки" : "Target Firmware Version" }
    var betaBadge: String { "Beta" }
    var signedBadge: String { lang == .ru ? "Подписана" : "Signed" }
    var shshBadge: String { "SHSH2" }
    var restoreOptionsSection: String { lang == .ru ? "Параметры прошивки" : "Flashing Options" }
    var keepDataToggle: String { lang == .ru ? "Сохранение данных (Update Restore)" : "Preserve User Data (Update)" }
    var verifySepToggle: String { lang == .ru ? "Верификация SEP & Baseband (Cryptex1)" : "Verify SEP & Baseband (Cryptex1)" }
    var bypassNoncesToggle: String { lang == .ru ? "Генерация ApTicket / Nonce" : "Generate ApTicket / Nonce" }
    var fwInfoTitle: String { lang == .ru ? "Сведения об IPSW" : "IPSW Details" }
    var fwBuild: String { lang == .ru ? "Сборка" : "Build" }
    var fwReleaseDate: String { lang == .ru ? "Дата релиза" : "Release Date" }
    var fwSize: String { lang == .ru ? "Размер файла" : "File Size" }
    var fwSignedStatus: String { lang == .ru ? "Статус подписи" : "Signature Status" }
    var fwSigned: String { lang == .ru ? "Подписана (TSS)" : "Signed (TSS)" }
    var fwUnsigned: String { lang == .ru ? "Не подписана (Нужен SHSH2)" : "Unsigned (SHSH2 Required)" }
    var fwSepCompatibility: String { lang == .ru ? "Совместимость SEP" : "SEP Compatibility" }
    var processTitle: String { lang == .ru ? "Процесс установки" : "Installation Process" }
    var startDowngradeBtn: String { lang == .ru ? "Начать откат на" : "Start Downgrade to" }
    var simRunning: String { lang == .ru ? "Выполняется установка..." : "Flashing firmware..." }
    var downgradeReadyStatus: String { lang == .ru ? "Готов к загрузке IPSW" : "Ready to download IPSW" }
    var downgradeFinished: String { "Cort1so1" }
    var downgradeFinishedMsg: String { lang == .ru ? "Чтобы изменения применились, перезапустите ваше устройство" : "To apply the changes, restart your device" }
    var disclaimerText: String { lang == .ru ? "Все операции производятся в безопасном демонстрационном режиме симулятора. Физическая файловая система устройства не модифицируется." : "All operations run in a safe simulator environment. Physical device storage is not modified." }

    // MARK: - Settings View
    var settingsTitle: String { lang == .ru ? "Настройки" : "Settings" }
    var appearanceSection: String { lang == .ru ? "Внешний вид" : "Appearance" }
    var darkModeToggle: String { lang == .ru ? "Темная тема" : "Dark Mode" }
    var languageSection: String { lang == .ru ? "Язык интерфейса" : "Language" }
    var languageLabel: String { lang == .ru ? "Язык" : "Language" }

    var utilitySection: String { lang == .ru ? "Параметры утилиты" : "Utility Options" }
    var verboseLogsToggle: String { lang == .ru ? "Подробный вывод логов" : "Verbose Logging" }
    var autoRespringToggle: String { lang == .ru ? "Автоматический респринг" : "Automatic Respring" }
    var tweakInjectionToggle: String { lang == .ru ? "Инъекция твиков (Substrate)" : "Tweak Injection (Substrate)" }

    var systemSection: String { lang == .ru ? "Системное окружение" : "System Environment" }
    var deviceModelLabel: String { lang == .ru ? "Модель устройства" : "Device Model" }
    var osVersionLabel: String { lang == .ru ? "Версия ОС" : "OS Version" }
    var exploitLabel: String { lang == .ru ? "Эксплойт" : "Exploit" }

    var jbManagementSection: String { lang == .ru ? "Управление джейлбрейком" : "Jailbreak Management" }
    var removeJailbreakBtn: String { lang == .ru ? "Убрать джейлбрейк" : "Remove Jailbreak" }
    var removeJailbreakAlertTitle: String { lang == .ru ? "Удаление джейлбрейка" : "Remove Jailbreak" }
    var removeJailbreakAlertMsg: String { lang == .ru ? "Вы действительно хотите сбросить состояние джейлбрейка и вернуть систему в исходное состояние?" : "Are you sure you want to remove the jailbreak state and restore system status?" }
    var removeConfirmBtn: String { lang == .ru ? "Убрать" : "Remove" }
    var cancelBtn: String { lang == .ru ? "Отмена" : "Cancel" }
    var jbRemovedSuccess: String { lang == .ru ? "Джейлбрейк успешно удален" : "Jailbreak successfully removed" }

    var aboutSection: String { lang == .ru ? "О программе" : "About" }
    var appNameLabel: String { lang == .ru ? "Название" : "App Name" }
    var versionLabel: String { lang == .ru ? "Версия" : "Version" }
    var packageManagerLabel: String { lang == .ru ? "Пакетный менеджер" : "Package Manager" }
    var creatorLabel: String { lang == .ru ? "Создатель" : "Creator" }
    var aboutDisclaimer: String { lang == .ru ? "Cort1so1 — развлекательное демонстрационное приложение-симулятор. Проект создан исключительно в ознакомительных целях." : "Cort1so1 is an educational demonstration simulator. Created solely for entertainment and learning purposes." }

    // MARK: - Respring & Logs
    var respringText: String { lang == .ru ? "Перезапуск SpringBoard..." : "Restarting SpringBoard..." }
    var terminalHeader: String { "CORT1SO1 EXPLOIT ENGINE — iOS 26.0" }
}

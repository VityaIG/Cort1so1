# Cort1so1 (v1.0.5)

<p align="center">
  <img src="Cort1so1/icon.svg" width="130" height="130" alt="Cort1so1 Icon" style="border-radius: 28px;" />
</p>

<p align="center">
  <b>Универсальная системная утилита и симулятор джейлбрейка / отката iOS в нативном стиле Apple HIG</b>
</p>

<p align="center">
  <a href="https://github.com/VityaIG/Cort1so1/releases/latest"><img src="https://img.shields.io/github/v/release/VityaIG/Cort1so1?style=flat-square&color=007AFF&label=Release" alt="Release" /></a>
  <a href="https://github.com/VityaIG/Cort1so1/actions"><img src="https://img.shields.io/github/actions/workflow/status/VityaIG/Cort1so1/build.yml?style=flat-square&label=Build%20IPA" alt="Build Status" /></a>
  <a href="https://t.me/VityaV"><img src="https://img.shields.io/badge/Telegram-@VityaV-229ED9?style=flat-square&logo=telegram" alt="Telegram" /></a>
  <img src="https://img.shields.io/badge/iOS-15.0+-black?style=flat-square&logo=apple" alt="iOS Support" />
  <img src="https://img.shields.io/badge/Swift-5.9%20%7C%20SwiftUI-F05138?style=flat-square&logo=swift" alt="Swift" />
</p>

---

## 📱 О проекте

**Cort1so1** — нативное iOS-приложение, сочетающее в себе интерактивную симуляцию джейлбрейка в стилистике Dopamine v2 и высокоточный движок симуляции отката прошивок iOS (60-секундный процесс с реалистичными логами `Futurerestore`, проверкой TSS, ApTicket, разделов Cryptex1 и Secure Enclave).

Интерфейс спроектирован в строгом соответствии с **Apple Human Interface Guidelines (HIG)** с поддержкой русской и английской локализации, светлой/темной темы, тактильного отклика (Haptics) и плавной анимации.

---

## ✨ Ключевые возможности

### 1. ⚡ Движок джейлбрейка (Dopamine Process Experience)
- **3-фазный цикл выполнения**:
  - `Фаза 1`: Инициализация ядра, проверка смещений и совместимости.
  - `Фаза 2`: Проверка стабильности и обход защит PPL/PAC.
  - `Фаза 3`: Проверка вероятности бутлупа и подготовка окружения.
- **Точные тайминги и кинематика**:
  - Вывод логов с анимацией статусов `[X/7]` и тактильным откликом `UIFeedbackGenerator`.
  - Появление белого логотипа Apple.
  - **Ровно 1.0 секунда** чистого черного экрана (`blackScreen`).
  - Появление красного логотипа Apple (инициализация kfd/tfp0).
  - Нативный экран респринга SpringBoard со спиннером и переходом в активный статус.

### 2. ⏱️ 60-секундный движок отката («Откат iOS»)
- **Каталог IPSW прошивок**: от новейших iOS 27 Beta и iOS 26.6 до стабильных iOS 26.0, iOS 18.7.1 и iOS 18.5 с отображением статуса подписи Apple (TSS Signed / SHSH2 blobs).
- **Ровно 1 минута выполнения (00:00 → 01:00)** с динамическим расчетом прогресса, переданных данных (GB) и скорости (MB/s).
- **5 детализированных этапов восстановления**:
  1. `0s – 10s`: **TSS & ApTicket** (проверка генератора nonce `0x1111111111111111`).
  2. `10s – 25s`: **RootFS & Cryptex1 OS** (монтирование системного DMG `disk0s1s1`, верификация TrustCache).
  3. `25s – 40s`: **SEP & Baseband Microcode** (отправка подписанного микрокода Secure Enclave).
  4. `40s – 52s`: **APFS Snapshot & KernelCache** (создание снимка `com.apple.os.update`).
  5. `52s – 60s`: **NVRAM, boot-args & SHA-256** (финализация и подготовка к перезагрузке).
- **Интерактивный терминал Futurerestore**: вывод реальных консольных логов в реальном времени.

### 3. ⚙️ Настройки в нативном стиле Apple HIG
- **Профиль и брендинг**: Новая фирменная иконка приложения с центрированной буквой «C» и градиентным фоном.
- **Карточка разработчика**: Прямой переход к автору проекта **[@VityaV 🇷🇺](https://t.me/VityaV)** в Telegram.
- **Внешний вид и язык**: Быстрое переключение темной темы и локализации (Русский / English).
- **Параметры утилиты**: Подробные логи ядра, авто-респринг, инъекция твиков Substrate/ElleKit и безопасный режим (Safe Mode).
- **Опасная зона**: Функция безопасного сброса и удаления джейлбрейка (`Restore RootFS`).

---

## 📂 Архитектура и структура файлов

```
Cort1so1/
├── .github/
│   └── workflows/
│       └── build.yml               # CI/CD: сборка IPA на macOS и авто-релиз
├── Cort1so1/
│   ├── Assets.xcassets/            # Каталог ассетов (AppIcon 1024x1024, AccentColor)
│   ├── icon.svg                    # Мастер-вектор иконки с центрированной «C»
│   ├── Cort1so1App.swift           # Главная точка входа приложения (@main)
│   ├── ContentView.swift           # Корневой координатор навигации и TabView
│   ├── MainView.swift              # Главный экран утилиты
│   ├── DopamineProcessView.swift   # Экран процесса джейлбрейка с анимациями
│   ├── DowngradeView.swift          # 60-секундный движок отката прошивок
│   ├── SettingsView.swift          # Экран настроек в стиле Apple HIG
│   ├── LocalizationManager.swift   # Менеджер двуязычной локализации (RU / EN)
│   ├── SimulationModels.swift      # Модели данных и типы состояний
│   ├── LogData.swift               # Логи и структуры сообщений ядра
│   ├── LogStreamView.swift         # Терминальный логгер
│   ├── NeoSpringView.swift         # Оверлей симуляции респринга SpringBoard
│   └── Info.plist                  # Системный манифест приложения
├── Cort1so1.xcodeproj/             # Конфигурация проекта Xcode
└── README.md
```

---

## 🚀 Установка

Готовый собранный файл `.ipa` доступен в разделе [Releases](https://github.com/VityaIG/Cort1so1/releases/latest).

Установить приложение можно любым удобным способом:
1. **TrollStore** *(рекомендуется для поддерживаемых версий iOS без необходимости переподписи каждые 7 дней)*.
2. **AltStore / SideStore** (через учетную запись Apple ID).
3. **Sideloadly / Scarlet / 3uTools** (напрямую с компьютера).

---

## 🛠️ Сборка из исходников

### Требования
- macOS 14.0+
- Xcode 15.0+
- iOS 15.0+ Deployment Target

```bash
# Клонирование репозитория
git clone https://github.com/VityaIG/Cort1so1.git
cd Cort1so1

# Открытие в Xcode
open Cort1so1.xcodeproj
```

---

## 👤 Автор и контакты

- **Разработчик**: [Виктор (@VityaV)](https://t.me/VityaV) 🇷🇺
- **Telegram канал / связь**: [@VityaV](https://t.me/VityaV)
- **GitHub**: [@VityaIG](https://github.com/VityaIG)

---

## ⚠️ Отказ от ответственности (Disclaimer)

*Приложение **Cort1so1** является симулятором и демонстрационным проектом. Приложение не содержит вредоносного кода, не модифицирует реальные системные разделы вашего устройства без вашего ведома и создано в образовательных и эстетических целях.*

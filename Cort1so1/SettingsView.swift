import SwiftUI

/// Экран настроек приложения «Cort1so1» в стиле iOS HIG
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    @AppStorage("tweakInjection") private var tweakInjection: Bool = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Секция оформления и тем
                        appearanceCard

                        // Секция параметров симулятора
                        utilityOptionsCard

                        // Секция системного окружения
                        systemEnvironmentCard

                        // Секция «О приложении»
                        aboutCard
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Компоненты интерфейса

    /// Карточка темы оформления
    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Внешний вид")
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Toggle(isOn: $isDarkMode) {
                Label {
                    Text("Темная тема")
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.indigo)
                }
            }
            .tint(.blue)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка параметров работы
    private var utilityOptionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Параметры утилиты")
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Toggle(isOn: $verboseLogs) {
                Label {
                    Text("Подробный вывод логов")
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "terminal.fill")
                        .foregroundColor(.blue)
                }
            }
            .tint(.blue)

            Divider()

            Toggle(isOn: $autoRespring) {
                Label {
                    Text("Автоматический респринг")
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .tint(.blue)

            Divider()

            Toggle(isOn: $tweakInjection) {
                Label {
                    Text("Инъекция твиков (Substrate)")
                        .font(.system(.body, design: .default))
                } icon: {
                    Image(systemName: "puzzlepiece.extension.fill")
                        .foregroundColor(.orange)
                }
            }
            .tint(.blue)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка системного окружения
    private var systemEnvironmentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Системное окружение")
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label("Версия ОС", systemImage: "iphone")
                Spacer()
                Text("iOS 26.0")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label("Архитектура", systemImage: "cpu")
                Spacer()
                Text("arm64e")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label("Эксплойт", systemImage: "bolt.fill")
                Spacer()
                Text("PhysPuppet")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Карточка «О программе»
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("О программе")
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label("Название", systemImage: "app.fill")
                Spacer()
                Text("Cort1so1")
                    .fontWeight(.bold)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label("Версия", systemImage: "info.circle.fill")
                Spacer()
                Text("1.0.5 (iOS Native HIG)")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label("Пакетный менеджер", systemImage: "shippingbox.fill")
                Spacer()
                Text("Sileo v2.6")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .default))
            }

            HStack {
                Label {
                    Text("Создатель")
                } icon: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                Spacer()
                Link(destination: URL(string: "https://t.me/VityaV") ?? URL(string: "https://telegram.org")!) {
                    HStack(spacing: 4) {
                        Text("@VityaV 🇷🇺")
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            }

            Divider()

            Text("Cort1so1 — развлекательное демонстрационное приложение-симулятор. Проект создан исключительно в ознакомительных целях.")
                .font(.system(.caption, design: .default))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    SettingsView()
}

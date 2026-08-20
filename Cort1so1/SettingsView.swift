import SwiftUI

/// Экран настроек приложения «Cort1so1» в дизайн-системе iOS 26 Liquid Glass HIG
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    @AppStorage("tweakInjection") private var tweakInjection: Bool = true

    var body: some View {
        NavigationStack {
            ZStack {
                ambientBackground

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
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
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Фон с преломлением

    private var ambientBackground: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            Circle()
                .fill(Color.purple.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 100, y: -120)

            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -80, y: 140)
        }
    }

    // MARK: - Парящие карточки Liquid Glass

    /// Карточка темы оформления
    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Внешний вид")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Toggle(isOn: $isDarkMode) {
                Label {
                    Text("Темная тема")
                        .font(.system(.body, design: .rounded))
                } icon: {
                    Image(systemName: "moon.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.indigo)
                }
            }
            .tint(.accentColor)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    /// Карточка параметров работы
    private var utilityOptionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Параметры утилиты")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Toggle(isOn: $verboseLogs) {
                Label {
                    Text("Подробный вывод логов")
                        .font(.system(.body, design: .rounded))
                } icon: {
                    Image(systemName: "terminal.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }
            }
            .tint(.accentColor)

            Divider()
                .opacity(0.6)

            Toggle(isOn: $autoRespring) {
                Label {
                    Text("Автоматический респринг")
                        .font(.system(.body, design: .rounded))
                } icon: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.green)
                }
            }
            .tint(.accentColor)

            Divider()
                .opacity(0.6)

            Toggle(isOn: $tweakInjection) {
                Label {
                    Text("Инъекция твиков (Substrate)")
                        .font(.system(.body, design: .rounded))
                } icon: {
                    Image(systemName: "puzzlepiece.extension.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.orange)
                }
            }
            .tint(.accentColor)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    /// Карточка системного окружения
    private var systemEnvironmentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Системное окружение")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label("Версия ОС", systemImage: "iphone")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text("iOS 26.0")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }

            HStack {
                Label("Архитектура", systemImage: "cpu.fill")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text("arm64e")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }

            HStack {
                Label("Эксплойт", systemImage: "bolt.fill")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text("PhysPuppet")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    /// Карточка «О программе»
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("О программе")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Label("Название", systemImage: "app.fill")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text("Cort1so1")
                    .fontWeight(.bold)
                    .font(.system(.body, design: .rounded))
            }

            HStack {
                Label("Версия", systemImage: "info.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text("1.0.0 (Liquid Glass HIG)")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }

            HStack {
                Label("Пакетный менеджер", systemImage: "shippingbox.fill")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text("Sileo v2.6")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded))
            }

            Divider()
                .opacity(0.6)

            Text("Cort1so1 — развлекательное демонстрационное приложение-симулятор. Проект создан исключительно в ознакомительных целях.")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(glassBorder(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    // MARK: - Вспомогательные функции

    private func glassBorder(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.45),
                        Color.white.opacity(0.08),
                        Color.blue.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
    }
}

#Preview {
    SettingsView()
}

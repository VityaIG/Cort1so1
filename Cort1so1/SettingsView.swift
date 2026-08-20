import SwiftUI
import UIKit

/// Полностью переработанный экран настроек «Cort1so1» в нативном стиле Apple iOS HIG
struct SettingsView: View {
    @Binding var jailbreakState: JailbreakState
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("isJailbroken") private var isJailbroken: Bool = false
    @AppStorage("verboseLogs") private var verboseLogs: Bool = true
    @AppStorage("autoRespring") private var autoRespring: Bool = true
    @AppStorage("tweakInjection") private var tweakInjection: Bool = true
    @AppStorage("safeMode") private var safeMode: Bool = false

    @State private var showRemoveJailbreakAlert: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    private var isRu: Bool {
        appLanguage == "ru"
    }

    private var strings: LocalizedStrings {
        LocalizedStrings(langCode: appLanguage)
    }

    private let telegramColor = Color(red: 0.165, green: 0.67, blue: 0.94)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        // 1. Профиль приложения и разработчика
                        appHeaderCard

                        // 2. Внешний вид и язык
                        appearanceSectionCard

                        // 3. Параметры джейлбрейка
                        utilitySectionCard

                        // 4. Системные сведения
                        systemDiagnosticsCard

                        // 5. Управление джейлбрейком (Опасная зона)
                        jailbreakManagementCard

                        // 6. О программе и сообщество
                        aboutProjectCard
                            .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(strings.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            // Подтверждение удаления джейлбрейка
            .alert(strings.removeJailbreakAlertTitle, isPresented: $showRemoveJailbreakAlert) {
                Button(strings.cancelBtn, role: .cancel) { }
                Button(strings.removeConfirmBtn, role: .destructive) {
                    removeJailbreak()
                }
            } message: {
                Text(strings.removeJailbreakAlertMsg)
            }
        }
    }

    // MARK: - 1. Профиль приложения и разработчика

    private var appHeaderCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                // Новая фирменная иконка приложения
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )

                    Cort1so1IconShape()
                        .fill(Color(red: 0.08, green: 0.09, blue: 0.10))
                        .frame(width: 32, height: 32)
                }
                .fixedSize()

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .center, spacing: 6) {
                        Text("Cort1so1")
                            .font(.system(size: 19, weight: .bold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .layoutPriority(2)

                        Text("v1.1")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(Capsule())
                            .fixedSize(horizontal: true, vertical: false)
                    }

                    Text("iOS Jailbreak & IPSW Utility")
                        .font(.system(size: 12, design: .default))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                // Статус джейлбрейка
                HStack(spacing: 4) {
                    Circle()
                        .fill(isJailbroken || jailbreakState == .completed ? Color.green : Color.secondary.opacity(0.4))
                        .frame(width: 6, height: 6)

                    Text(isJailbroken || jailbreakState == .completed ? (isRu ? "Активен" : "Active") : (isRu ? "Не активен" : "Stock"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isJailbroken || jailbreakState == .completed ? .green : .secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isJailbroken || jailbreakState == .completed ? Color.green : Color.secondary).opacity(0.12))
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)
            }

            Divider()

            // Карточка создателя с переходом в Telegram
            Link(destination: URL(string: "https://t.me/VityaV") ?? URL(string: "https://telegram.org")!) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(telegramColor.opacity(0.15))
                            .frame(width: 34, height: 34)
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 15))
                            .foregroundColor(telegramColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(isRu ? "Создатель & Разработчик" : "Creator & Developer")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        Text("@VityaV 🇷🇺")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(telegramColor)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(telegramColor)
                }
                .padding(10)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 2. Внешний вид и язык

    private var appearanceSectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.appearanceSection, icon: "paintbrush.fill", color: .purple)

            Toggle(isOn: $isDarkMode) {
                settingRowLabel(title: strings.darkModeToggle, icon: "moon.fill", color: .indigo)
            }
            .tint(.blue)

            Divider()

            HStack {
                settingRowLabel(title: strings.languageLabel, icon: "globe", color: .blue)

                Spacer()

                Picker("", selection: $appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(.blue)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 3. Параметры джейлбрейка

    private var utilitySectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.utilitySection, icon: "gearshape.fill", color: .blue)

            Toggle(isOn: $verboseLogs) {
                settingRowLabel(title: strings.verboseLogsToggle, icon: "terminal.fill", color: .slateColor)
            }
            .tint(.blue)

            Divider()

            Toggle(isOn: $autoRespring) {
                settingRowLabel(title: strings.autoRespringToggle, icon: "arrow.clockwise.circle.fill", color: .green)
            }
            .tint(.blue)

            Divider()

            Toggle(isOn: $tweakInjection) {
                settingRowLabel(title: strings.tweakInjectionToggle, icon: "puzzlepiece.extension.fill", color: .orange)
            }
            .tint(.blue)

            Divider()

            Toggle(isOn: $safeMode) {
                settingRowLabel(title: isRu ? "Безопасный режим (Safe Mode)" : "Safe Mode Fallback", icon: "shield.lefthalf.filled", color: .cyan)
            }
            .tint(.blue)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 4. Системные сведения

    private var systemDiagnosticsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.systemSection, icon: "cpu.fill", color: .teal)

            infoRow(title: strings.deviceModelLabel, value: UIDevice.current.model, icon: "ipad.and.iphone", color: .blue)
            Divider()
            infoRow(title: strings.osVersionLabel, value: "iOS \(UIDevice.current.systemVersion)", icon: "iphone", color: .indigo)
            Divider()
            infoRow(title: strings.archTitle, value: "arm64e (PPL & PAC Bypass)", icon: "cpu", color: .teal)
            Divider()
            infoRow(title: strings.exploitLabel, value: "PhysPuppet / LandCast", icon: "bolt.fill", color: .orange)
            Divider()
            infoRow(title: strings.packageManagerLabel, value: "Sileo v2.6 (Procursus)", icon: "shippingbox.fill", color: .cyan)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 5. Управление джейлбрейком (Danger Zone)

    private var jailbreakManagementCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.jbManagementSection, icon: "exclamationmark.shield.fill", color: .red)

            Button(role: .destructive, action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                showRemoveJailbreakAlert = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 30, height: 30)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }

                    Text(strings.removeJailbreakBtn)
                        .font(.system(.body, design: .default))
                        .fontWeight(.semibold)
                        .foregroundColor(.red)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 6. О программе

    private var aboutProjectCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: strings.aboutSection, icon: "info.circle.fill", color: .blue)

            HStack {
                Text(strings.appNameLabel)
                    .font(.system(.subheadline, design: .default))
                Spacer()
                Text("Cort1so1")
                    .fontWeight(.bold)
                    .font(.system(.subheadline, design: .default))
            }

            Divider()

            HStack {
                Text(strings.versionLabel)
                    .font(.system(.subheadline, design: .default))
                Spacer()
                Text("1.1.3 (Build 26B101)")
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .monospaced))
            }

            Divider()

            Text(strings.aboutDisclaimer)
                .font(.system(.caption, design: .default))
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Вспомогательные компоненты разметки

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(.caption, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
    }

    private func settingRowLabel(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                    .frame(width: 30, height: 30)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(.system(.body, design: .default))
        }
    }

    private func infoRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            settingRowLabel(title: title, icon: icon, color: color)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.system(.subheadline, design: .default))
        }
    }

    // MARK: - Логика действий

    private func removeJailbreak() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)

        withAnimation(.easeInOut(duration: 0.25)) {
            isJailbroken = false
            jailbreakState = .idle
        }
    }
}

extension Color {
    static let slateColor = Color(red: 0.35, green: 0.45, blue: 0.55)
}

/// Векторная форма фирменной центрированной буквы «C» Cort1so1
struct Cort1so1IconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = rect.width * (310.0 / 1024.0)
        let innerRadius = rect.width * (220.0 / 1024.0)
        
        let cutOffsetY = rect.height * (95.0 / 1024.0)
        let topCutY = center.y - cutOffsetY
        let bottomCutY = center.y + cutOffsetY
        
        let outerXOffset = sqrt(max(0, outerRadius * outerRadius - cutOffsetY * cutOffsetY))
        let innerXOffset = sqrt(max(0, innerRadius * innerRadius - cutOffsetY * cutOffsetY))
        
        let outerTop = CGPoint(x: center.x + outerXOffset, y: topCutY)
        let innerTop = CGPoint(x: center.x + innerXOffset, y: topCutY)
        let outerBottom = CGPoint(x: center.x + outerXOffset, y: bottomCutY)
        let innerBottom = CGPoint(x: center.x + innerXOffset, y: bottomCutY)
        
        let startAngleOuter = atan2(-cutOffsetY, outerXOffset)
        let endAngleOuter = atan2(cutOffsetY, outerXOffset)
        let startAngleInner = atan2(cutOffsetY, innerXOffset)
        let endAngleInner = atan2(-cutOffsetY, innerXOffset)
        
        path.move(to: outerTop)
        path.addLine(to: innerTop)
        path.addArc(center: center, radius: innerRadius, startAngle: Angle(radians: Double(endAngleInner)), endAngle: Angle(radians: Double(startAngleInner)), clockwise: true)
        path.addLine(to: outerBottom)
        path.addArc(center: center, radius: outerRadius, startAngle: Angle(radians: Double(endAngleOuter)), endAngle: Angle(radians: Double(startAngleOuter)), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    SettingsView(jailbreakState: .constant(.completed))
}

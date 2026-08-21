import sys

with open('Cort1so1/MainView.swift', 'r') as f:
    content = f.read()

# Replace the layout
old_layout = """                        // Кнопки основного действия
                        actionButtonsSection
                            .padding(.top, 6)
                            .padding(.bottom, 48)"""

new_layout = """                        // Кнопки основного действия
                        actionButtonsSection
                            .padding(.top, 6)
                            
                        // Инфо об устройстве
                        deviceInfoCard
                            .padding(.bottom, 48)"""

content = content.replace(old_layout, new_layout)

# Add the new card below actionButtonsSection
old_func = """    // MARK: - Вспомогательные свойства"""

new_func = """    private var deviceInfoCard: some View {
        VStack(spacing: 0) {
            infoRow(title: isRu ? "Модель" : "Model", value: UIDevice.current.friendlyModelName, isLast: false)
            infoRow(title: isRu ? "Версия iOS" : "iOS Version", value: UIDevice.current.systemVersion, isLast: false)
            infoRow(title: isRu ? "Идентификатор" : "Identifier", value: UIDevice.current.hardwareIdentifier, isLast: false)
            infoRow(title: "ECID", value: "0x0000001234ABCDEF", isLast: false)
            infoRow(title: "APNonce", value: "0x1111111111111111", isLast: true)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func infoRow(title: String, value: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(.subheadline, design: .default))
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
                    .font(.system(.subheadline, design: .default))
            }
            .padding(.vertical, 12)
            
            if !isLast {
                Divider()
            }
        }
    }

    // MARK: - Вспомогательные свойства"""

content = content.replace(old_func, new_func)

with open('Cort1so1/MainView.swift', 'w') as f:
    f.write(content)

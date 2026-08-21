import sys

with open('Cort1so1/DowngradeView.swift', 'r') as f:
    content = f.read()

old_section = """                Section(header: Text(isRu ? "Устройство" : "Device Info")) {
                    HStack {
                        Text(isRu ? "Модель" : "Model")
                        Spacer()
                        Text(UIDevice.current.friendlyModelName)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(isRu ? "Версия iOS" : "iOS Version")
                        Spacer()
                        Text(UIDevice.current.systemVersion)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(isRu ? "Идентификатор" : "Identifier")
                        Spacer()
                        Text(UIDevice.current.hardwareIdentifier)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("ECID")
                        Spacer()
                        Text("0x0000001234ABCDEF")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("APNonce")
                        Spacer()
                        Text("0x1111111111111111")
                            .foregroundColor(.secondary)
                    }
                }"""

new_section = """                Section(header: Text(isRu ? "Профиль устройства" : "Device Profile")) {
                    HStack(spacing: 16) {
                        Image(systemName: "iphone")
                            .font(.system(size: 38, weight: .light))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(UIDevice.current.friendlyModelName)
                                .font(.system(size: 16, weight: .semibold))
                            Text("iOS \(UIDevice.current.systemVersion)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }"""

content = content.replace(old_section, new_section)

with open('Cort1so1/DowngradeView.swift', 'w') as f:
    f.write(content)

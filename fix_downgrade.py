path = "Cort1so1/DowngradeView.swift"
with open(path, "r") as f:
    code = f.read()

target1 = """                            Circle()
                                .fill(isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor.opacity(0.2) : Color.clear))
                                .stroke(isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor : Color(white: 0.3)), lineWidth: 1.5)
                                .frame(width: 14, height: 14)"""
replacement1 = """                            let fColor: Color = isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor.opacity(0.2) : Color.clear)
                            let sColor: Color = isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor : Color(white: 0.3))
                            Circle()
                                .foregroundColor(fColor)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(sColor, lineWidth: 1.5)
                                )"""

if target1 in code:
    code = code.replace(target1, replacement1)
    with open(path, "w") as f:
        f.write(code)
    print("Fixed DowngradeView.swift target1")
else:
    print("Could not find target1 in DowngradeView.swift")

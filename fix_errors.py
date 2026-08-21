import re

# 1. Fix DowngradeView.swift fill and stroke
path = "Cort1so1/DowngradeView.swift"
with open(path, "r") as f:
    code = f.read()

target1 = """                            Circle()
                                .fill(isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor.opacity(0.2) : Color.clear))
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(isCompleted ? firmware.badgeColor : (isActive ? firmware.badgeColor : Color(white: 0.3)), lineWidth: 1.5)
                                )"""
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

# 2. Fix DopamineProcessView.swift phase assignment
path2 = "Cort1so1/DopamineProcessView.swift"
with open(path2, "r") as f:
    code2 = f.read()

target2 = """        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.showAppleLogo = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.appleWhiteOpacity = 1.0
                        self.appleWhiteScale = 1.0
                    }
                    self.triggerHaptic(isMajor: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeIn(duration: 1.5)) {
                            self.appleRedOpacity = 1.0
                            self.appleRedScale = 1.2
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            self.onFinished()
                        }
                    }
                }
            }
        }"""
replacement2 = """        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.phase = .appleWhite
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.appleWhiteOpacity = 1.0
                        self.appleWhiteScale = 1.0
                    }
                    self.triggerHaptic(isMajor: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.phase = .appleRed
                        }
                        withAnimation(.easeIn(duration: 1.5)) {
                            self.appleRedOpacity = 1.0
                            self.appleRedScale = 1.2
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.phase = .respring
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                self.onFinished()
                            }
                        }
                    }
                }
            }
        }"""

if target2 in code2:
    code2 = code2.replace(target2, replacement2)
    with open(path2, "w") as f:
        f.write(code2)
    print("Fixed DopamineProcessView.swift")
else:
    print("Could not find target2 in DopamineProcessView.swift")

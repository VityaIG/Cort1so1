import SwiftUI

/// Расширение и модификатор для поддержки формата LiquidGlass (iOS 26+)
public struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                )
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground).opacity(0.85))
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
}

extension View {
    /// Применяет концептуальный формат LiquidGlass (iOS 26+)
    public func glassEffect(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}

/// Плавающий нативный плашка-таббар в формате LiquidGlass (iOS 26+)
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    var isJailbroken: Bool
    var lastJailbreakMethod: String
    var strings: LocalizedStrings
    var appThemeColor: String

    var body: some View {
        HStack(spacing: 4) {
            tabButton(tag: 0, title: strings.tabMain, icon: "lock.open.fill")

            if isJailbroken {
                tabButton(tag: 1, title: strings.tabTweaks, icon: "hammer.fill")
            }

            if isJailbroken && lastJailbreakMethod == "cortisol" {
                tabButton(tag: 4, title: strings.tabTerminal, icon: "terminal.fill")
            }

            tabButton(tag: 2, title: strings.tabDowngrade, icon: "arrow.counterclockwise.circle.fill")
            tabButton(tag: 3, title: strings.tabSettings, icon: "gearshape.fill")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.75))
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.45), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tabButton(tag: Int, title: String, icon: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTab = tag
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: selectedTab == tag ? 15 : 14, weight: selectedTab == tag ? .bold : .medium))
                    .foregroundColor(selectedTab == tag ? AppTheme.resolveColor(name: appThemeColor) : .gray)

                if selectedTab == tag {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, selectedTab == tag ? 14 : 10)
            .background(
                Group {
                    if selectedTab == tag {
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.resolveColor(name: appThemeColor).opacity(0.3), lineWidth: 0.5)
                            )
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

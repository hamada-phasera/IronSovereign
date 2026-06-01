import SwiftUI

struct IronTheme {
    // Spacing
    static let spacing4: CGFloat  = 4
    static let spacing8: CGFloat  = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32

    // Radius
    static let radiusSmall:  CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge:  CGFloat = 16
    static let radiusXL:     CGFloat = 24

    // Shadow
    static func emberShadow(radius: CGFloat = 10) -> some View {
        Rectangle().shadow(color: Color.ironEmber.opacity(0.15), radius: radius)
    }
}

// View modifier for Iron-style background
struct IronBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient.darkGradient.ignoresSafeArea())
    }
}

extension View {
    func ironBackground() -> some View {
        modifier(IronBackground())
    }
}

import SwiftUI

extension AnyTransition {
    static var ironSlide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    static var ironFade: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95))
    }

    static var ironRise: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
}

struct SlideInFromBottom: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .offset(y: isPresented ? 0 : 80)
            .opacity(isPresented ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isPresented)
    }
}

extension View {
    func slideInFromBottom(isPresented: Bool) -> some View {
        modifier(SlideInFromBottom(isPresented: isPresented))
    }
}

import SwiftUI

struct CompletionAnimation: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    let message: String
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🔥")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                    .shadow(color: .ironEmber, radius: 20)

                Text(message)
                    .font(IronTypography.epic)
                    .foregroundColor(.ironGold)
                    .multilineTextAlignment(.center)
                    .opacity(opacity)
                    .shadow(color: .ironGold.opacity(0.5), radius: 10)

                Text("CONQUERED")
                    .font(IronTypography.caption)
                    .foregroundColor(.ironStone)
                    .tracking(6)
                    .opacity(subtitleOpacity)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.1
                opacity = 1
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
                subtitleOpacity = 1
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8).delay(0.5)) {
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                onComplete()
            }
        }
    }
}

struct SetCompletedFlash: View {
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        Text("✓")
            .font(.system(size: 60, weight: .black))
            .foregroundColor(.ironVictory)
            .opacity(opacity)
            .offset(y: offset)
            .shadow(color: .ironVictory.opacity(0.6), radius: 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 1
                    offset = -20
                }
                withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                    opacity = 0
                }
            }
    }
}

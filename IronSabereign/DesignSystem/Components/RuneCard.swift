import SwiftUI

struct RuneCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(IronTheme.spacing20)
            .background(Color.ironDark)
            .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: IronTheme.radiusLarge)
                    .stroke(
                        LinearGradient(
                            colors: [Color.ironAsh.opacity(0.4), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.ironEmber.opacity(0.05), radius: 10, y: 5)
    }
}

import SwiftUI

struct GlowingDivider: View {
    var color: Color = .ironEmber
    var opacity: Double = 0.4

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, color.opacity(opacity), Color.clear],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(height: 1)
            .shadow(color: color.opacity(opacity * 0.8), radius: 3)
    }
}

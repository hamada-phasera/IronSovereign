import SwiftUI

struct EmberProgressBar: View {
    let value: Double    // 0.0 - 1.0
    let height: CGFloat

    init(value: Double, height: CGFloat = 8) {
        self.value = min(max(value, 0), 1)
        self.height = height
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.ironElevated)
                    .frame(height: height)

                // Fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(LinearGradient.emberGradient)
                    .frame(width: geo.size.width * value, height: height)
                    .shadow(color: Color.ironEmber.opacity(0.6), radius: 4)
            }
        }
        .frame(height: height)
    }
}

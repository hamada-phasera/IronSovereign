import SwiftUI

struct ForgeBanner: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("⚔️")
                    .font(.title2)
                Text("IRON SOVEREIGN")
                    .font(IronTypography.caption)
                    .foregroundColor(.ironStone)
                    .tracking(3)
                Spacer()
            }

            HStack {
                Text(title)
                    .font(IronTypography.heading)
                    .foregroundColor(.ironBone)
                Spacer()
            }

            if let sub = subtitle {
                HStack {
                    Text(sub)
                        .font(IronTypography.caption)
                        .foregroundColor(.ironStone)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, IronTheme.spacing16)
        .padding(.vertical, IronTheme.spacing12)
    }
}

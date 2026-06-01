import SwiftUI

struct RestTimerView: View {
    let remaining: Int
    let total: Int
    let onSkip: () -> Void

    private var progress: Double {
        total > 0 ? 1.0 - Double(remaining) / Double(total) : 1
    }

    private var minutes: Int { remaining / 60 }
    private var seconds: Int { remaining % 60 }

    var body: some View {
        VStack(spacing: 20) {
            Text("インターバル")
                .font(IronTypography.caption)
                .foregroundColor(.ironStone)
                .tracking(2)

            ZStack {
                Circle()
                    .stroke(Color.ironElevated, lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient.emberGradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: remaining)

                VStack(spacing: 2) {
                    Text(String(format: "%d:%02d", minutes, seconds))
                        .font(IronTypography.number)
                        .foregroundColor(remaining <= 10 ? .ironCaution : .ironBone)
                    Text("秒")
                        .font(IronTypography.small)
                        .foregroundColor(.ironStone)
                }
            }

            Button(action: onSkip) {
                Text("スキップ →")
                    .font(IronTypography.caption)
                    .foregroundColor(.ironStone)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color.ironDark)
        .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: IronTheme.radiusLarge)
                .stroke(Color.ironAsh.opacity(0.3), lineWidth: 1)
        )
    }
}

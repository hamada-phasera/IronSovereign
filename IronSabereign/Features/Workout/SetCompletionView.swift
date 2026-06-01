import SwiftUI

struct SetCompletionView: View {
    let set: ExerciseSet
    let onComplete: (SetStatus) -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 目標表示
            VStack(spacing: 8) {
                Text("目標")
                    .font(IronTypography.caption)
                    .foregroundColor(.ironStone)
                    .tracking(2)

                HStack(alignment: .bottom, spacing: 8) {
                    Text(String(format: "%.1f", set.targetWeight))
                        .font(IronTypography.bigNum)
                        .foregroundColor(.ironGold)
                    Text("kg")
                        .font(IronTypography.subhead)
                        .foregroundColor(.ironStone)
                        .padding(.bottom, 8)

                    Text("×")
                        .font(IronTypography.heading)
                        .foregroundColor(.ironFade)
                        .padding(.bottom, 4)

                    Text("\(set.targetReps)")
                        .font(IronTypography.bigNum)
                        .foregroundColor(.ironGold)
                    Text("rep")
                        .font(IronTypography.subhead)
                        .foregroundColor(.ironStone)
                        .padding(.bottom, 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.ironSurface)
            .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusMedium))

            // 達成 / 未達成ボタン
            HStack(spacing: 12) {
                SovereignButton(title: "✓  達成", style: .victory) {
                    onComplete(.completed)
                }

                SovereignButton(title: "✗  未達成", style: .defeat) {
                    onComplete(.failed)
                }
            }
        }
    }
}

import SwiftUI

struct ExerciseCardView: View {
    let exerciseName: String
    let sets: [ExerciseSet]
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(exerciseName)
                    .font(IronTypography.subhead)
                    .foregroundColor(isActive ? .ironGold : .ironBone)
                Spacer()
                completionBadge
            }

            // セット一覧
            HStack(spacing: 8) {
                ForEach(sets.filter { !$0.isWarmup }) { set in
                    setChip(set)
                }
            }
        }
        .padding(IronTheme.spacing16)
        .background(isActive ? Color.ironElevated : Color.ironDark)
        .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: IronTheme.radiusMedium)
                .stroke(isActive ? Color.ironEmber.opacity(0.6) : Color.ironFade.opacity(0.3), lineWidth: 1)
        )
    }

    private var completionBadge: some View {
        let completed = sets.filter { !$0.isWarmup && $0.status == .completed }.count
        let total = sets.filter { !$0.isWarmup }.count
        let allDone = sets.filter { !$0.isWarmup }.allSatisfy { $0.status != .pending }

        return Group {
            if allDone {
                Text("✓")
                    .font(IronTypography.subhead)
                    .foregroundColor(.ironVictory)
            } else {
                Text("\(completed)/\(total)")
                    .font(IronTypography.caption)
                    .foregroundColor(.ironStone)
            }
        }
    }

    private func setChip(_ set: ExerciseSet) -> some View {
        let color: Color = {
            switch set.status {
            case .completed: return .ironVictory
            case .failed:    return .ironDefeat
            case .pending:   return .ironFade
            case .skipped:   return .ironStone
            }
        }()

        return RoundedRectangle(cornerRadius: 4)
            .fill(color.opacity(set.status == .pending ? 0.2 : 0.5))
            .frame(width: 28, height: 28)
            .overlay(
                Text(set.status == .pending ? "\(set.setNumber)" : (set.status == .completed ? "✓" : "✗"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(set.status == .pending ? .ironStone : .white)
            )
    }
}

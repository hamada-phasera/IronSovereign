import SwiftUI

struct SovereignButton: View {
    let title: String
    let style: SovereignButtonStyle
    let action: () -> Void

    enum SovereignButtonStyle {
        case primary   // 炎グラデーション
        case victory   // 達成（緑）
        case defeat    // 未達成（赤）
        case ghost     // 枠線のみ
        case gold      // ゴールド
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(IronTypography.subhead)
                .foregroundColor(.ironBone)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundView)
                .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusMedium))
                .overlay(
                    RoundedRectangle(cornerRadius: IronTheme.radiusMedium)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient.emberGradient
        case .victory:
            Color.ironVictory.opacity(0.85)
        case .defeat:
            Color.ironDefeat.opacity(0.85)
        case .ghost:
            Color.clear
        case .gold:
            LinearGradient.goldGradient
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:  return .ironEmber.opacity(0.5)
        case .victory:  return .ironVictory
        case .defeat:   return .ironDefeat
        case .ghost:    return .ironAsh.opacity(0.5)
        case .gold:     return .ironGold.opacity(0.5)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SovereignButton(title: "鍛錬を開始する", style: .primary) {}
        SovereignButton(title: "✓ 達成", style: .victory) {}
        SovereignButton(title: "✗ 未達成", style: .defeat) {}
    }
    .padding()
    .background(Color.ironAbyss)
}

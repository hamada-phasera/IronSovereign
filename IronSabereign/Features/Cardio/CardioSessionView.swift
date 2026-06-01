import SwiftUI
import SwiftData

struct CardioSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var vm: CardioViewModel

    init(cardioSession: CardioSession) {
        _vm = State(initialValue: CardioViewModel(cardioSession: cardioSession))
    }

    private var remainingMin: Int { vm.remainingSeconds / 60 }
    private var remainingSec: Int { vm.remainingSeconds % 60 }

    var body: some View {
        ZStack {
            LinearGradient.darkGradient.ignoresSafeArea()

            if vm.isCompleted {
                completedView
            } else {
                activeView
            }
        }
        .onDisappear { vm.pause() }
    }

    private var activeView: some View {
        VStack(spacing: 32) {
            ForgeBanner("有酸素セッション", subtitle: vm.cardioSession.cardioType.displayName)

            GlowingDivider()

            // タイマーサークル
            ZStack {
                Circle()
                    .stroke(Color.ironElevated, lineWidth: 12)
                    .frame(width: 200, height: 200)
                Circle()
                    .trim(from: 0, to: vm.progress)
                    .stroke(LinearGradient.emberGradient,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: vm.elapsedSeconds)

                VStack(spacing: 4) {
                    Text(String(format: "%d:%02d", remainingMin, remainingSec))
                        .font(IronTypography.number)
                        .foregroundColor(.ironBone)
                    Text("残り").font(IronTypography.small).foregroundColor(.ironStone)
                }
            }

            // 心拍目標
            RuneCard {
                VStack(spacing: 8) {
                    Text("目標心拍数").font(IronTypography.caption).foregroundColor(.ironStone)
                    Text("\(vm.cardioSession.targetHeartRateLow) - \(vm.cardioSession.targetHeartRateHigh) bpm")
                        .font(IronTypography.heading).foregroundColor(.ironGold)
                }
            }
            .padding(.horizontal, 32)

            // コントロール
            HStack(spacing: 16) {
                SovereignButton(title: vm.isRunning ? "一時停止" : "▶ 開始", style: .primary) {
                    vm.isRunning ? vm.pause() : vm.start()
                }
                SovereignButton(title: "完了", style: .victory) {
                    vm.completeCardio(context: modelContext)
                }
            }
            .padding(.horizontal, 32)

            SovereignButton(title: "スキップ", style: .ghost) { dismiss() }
                .padding(.horizontal, 64)

            Spacer()
        }
    }

    private var completedView: some View {
        VStack(spacing: 24) {
            Text("🔥").font(.system(size: 80))
            Text("有酸素完了！")
                .font(IronTypography.epic).foregroundColor(.ironGold)

            RuneCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("実施時間").foregroundColor(.ironStone)
                        Spacer()
                        Text("\(vm.cardioSession.actualDurationMin)分").foregroundColor(.ironBone)
                    }
                    HStack {
                        Text("推定消費カロリー").foregroundColor(.ironStone)
                        Spacer()
                        Text("\(Int(vm.cardioSession.caloriesEstimated)) kcal").foregroundColor(.ironBone)
                    }
                }
                .font(IronTypography.body)
            }
            .padding(.horizontal, 32)

            SovereignButton(title: "← 戻る", style: .primary) { dismiss() }
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var vm: WorkoutViewModel
    @State private var showCardio = false

    init(session: WorkoutSession) {
        _vm = State(initialValue: WorkoutViewModel(session: session))
    }

    var body: some View {
        ZStack {
            LinearGradient.darkGradient.ignoresSafeArea()

            if vm.sessionCompleted {
                sessionSummaryView
            } else {
                mainContent
            }

            // 種目クリアアニメーション
            if vm.showCompletionAnimation {
                CompletionAnimation(message: vm.completionMessage) {
                    vm.showCompletionAnimation = false
                }
                .zIndex(10)
            }
        }
        .sheet(isPresented: $showCardio) {
            if let cardio = vm.session.cardioSession {
                CardioSessionView(cardioSession: cardio)
            }
        }
    }

    // MARK: - メインコンテンツ

    private var mainContent: some View {
        VStack(spacing: 0) {
            // ヘッダー
            header

            GlowingDivider()

            // インターバルタイマー（休憩中）
            if vm.isResting {
                RestTimerView(
                    remaining: vm.restSecondsRemaining,
                    total: vm.restTotalSeconds,
                    onSkip: { vm.stopRest() }
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .transition(.ironFade)
            }

            ScrollView {
                VStack(spacing: 12) {
                    // 種目一覧
                    ForEach(vm.exerciseGroups, id: \.id) { group in
                        ExerciseCardView(
                            exerciseName: group.name,
                            sets: group.sets,
                            isActive: group.id == vm.currentExerciseId
                        )
                    }
                    .padding(.horizontal, 16)

                    // 現在のセット操作UI
                    if !vm.isResting, let currentSet = vm.currentSet {
                        activeSetSection(currentSet)
                            .padding(.horizontal, 16)
                    }

                    // 全種目完了 → 有酸素セクション
                    if vm.allExerciseSetsCompleted && vm.session.cardioSession != nil {
                        cardioPrompt
                            .padding(.horizontal, 16)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.top, 16)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.ironStone)
                    .padding(10)
                    .background(Color.ironSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            VStack {
                Text(vm.session.sessionType.displayName)
                    .font(IronTypography.subhead).foregroundColor(.ironBone)
                Text(vm.session.sessionType.primaryMuscles)
                    .font(IronTypography.small).foregroundColor(.ironStone)
            }

            Spacer()

            // 完了率
            let done = vm.completedExerciseCount
            let total = vm.exerciseGroups.count
            Text("\(done)/\(total)")
                .font(IronTypography.caption).foregroundColor(.ironEmber)
                .padding(10)
                .background(Color.ironSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func activeSetSection(_ set: ExerciseSet) -> some View {
        VStack(spacing: 16) {
            GlowingDivider()

            if let group = vm.currentGroup {
                let pending = group.sets.filter { $0.status == .pending }
                Text("SET \(set.setNumber) / \(group.sets.filter { !$0.isWarmup }.count)")
                    .font(IronTypography.caption).foregroundColor(.ironStone).tracking(2)

                Text(group.name)
                    .font(IronTypography.heading).foregroundColor(.ironBone)

                Text("残り \(pending.count) セット")
                    .font(IronTypography.small).foregroundColor(.ironStone)
            }

            SetCompletionView(set: set) { status in
                vm.completeSet(set, status: status, context: modelContext)
            }
        }
        .padding(.vertical, 8)
    }

    private var cardioPrompt: some View {
        RuneCard {
            VStack(spacing: 12) {
                Text("🏃 有酸素セクション")
                    .font(IronTypography.subhead).foregroundColor(.ironGold)
                if let cardio = vm.session.cardioSession {
                    Text("\(cardio.cardioType.displayName)  \(cardio.targetDurationMin)分")
                        .font(IronTypography.body).foregroundColor(.ironBone)
                    Text("目標心拍: \(cardio.targetHeartRateLow)-\(cardio.targetHeartRateHigh) bpm")
                        .font(IronTypography.small).foregroundColor(.ironStone)
                }
                HStack(spacing: 12) {
                    SovereignButton(title: "開始する", style: .primary) { showCardio = true }
                    SovereignButton(title: "スキップ", style: .ghost) {
                        vm.session.cardioSession?.isCompleted = true
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    // MARK: - セッション完了サマリー

    private var sessionSummaryView: some View {
        VStack(spacing: 24) {
            Text("🏆")
                .font(.system(size: 80))
                .shadow(color: .ironGold.opacity(0.5), radius: 20)

            Text("MISSION COMPLETE")
                .font(IronTypography.epic)
                .foregroundColor(.ironGold)
                .multilineTextAlignment(.center)

            let completed = vm.session.exerciseSets.filter { !$0.isWarmup && $0.status == .completed }.count
            let total = vm.session.exerciseSets.filter { !$0.isWarmup }.count
            let rate = total > 0 ? Int(Double(completed) / Double(total) * 100) : 0
            let volume = Int(vm.session.totalVolume)
            let mins = vm.session.totalDurationSeconds / 60

            RuneCard {
                VStack(spacing: 12) {
                    summaryRow("合計ボリューム", value: "\(volume) kg")
                    summaryRow("達成率", value: "\(rate)%")
                    summaryRow("所要時間", value: "\(mins) 分")
                    if let cardio = vm.session.cardioSession, cardio.isCompleted {
                        summaryRow("有酸素", value: "\(cardio.cardioType.displayName)")
                    }
                }
            }
            .padding(.horizontal, 32)

            SovereignButton(title: "← ホームに戻る", style: .primary) {
                dismiss()
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.ironStone)
            Spacer()
            Text(value).foregroundColor(.ironBone).fontWeight(.semibold)
        }
        .font(IronTypography.body)
    }
}

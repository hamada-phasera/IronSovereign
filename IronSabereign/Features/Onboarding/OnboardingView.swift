import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            LinearGradient.darkGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                ForgeBanner("IRON SOVEREIGN", subtitle: "鍛錬者よ、汝の力を示せ")
                    .padding(.top, 20)

                GlowingDivider()

                EmberProgressBar(value: vm.progress)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)

                Text("STEP \(vm.currentStep + 1) / \(vm.totalSteps)")
                    .font(IronTypography.small)
                    .foregroundColor(.ironStone)
                    .tracking(2)

                Group {
                    switch vm.currentStep {
                    case 0: StepNameView(name: $vm.name)
                    case 1: StepWeightView(weight: $vm.bodyWeightKg)
                    case 2: StepGenderView(gender: $vm.gender)
                    case 3: StepExperienceView(level: $vm.experienceLevel)
                    case 4: StepGoalView(goal: $vm.goal)
                    case 5: StepFrequencyView(days: $vm.trainingDaysPerWeek)
                    default: StepEquipmentView()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .transition(.ironSlide)
                .animation(.easeInOut(duration: 0.3), value: vm.currentStep)

                Spacer()

                HStack(spacing: 12) {
                    if vm.currentStep > 0 {
                        SovereignButton(title: "← 戻る", style: .ghost) { vm.back() }
                            .frame(width: 100)
                    }

                    if vm.currentStep < vm.totalSteps - 1 {
                        SovereignButton(title: "次へ →", style: .primary) { vm.advance() }
                            .disabled(!vm.canAdvance)
                            .opacity(vm.canAdvance ? 1 : 0.5)
                    } else {
                        SovereignButton(title: "⚔️ 鍛錬を開始する", style: .gold) {
                            let profile = vm.saveProfile(context: modelContext)
                            appState.completeOnboarding(profile: profile)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Step Views

private struct StepNameView: View {
    @Binding var name: String
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("汝の名は？")
                .font(IronTypography.heading).foregroundColor(.ironBone)
            TextField("名前を入力", text: $name)
                .font(IronTypography.body).foregroundColor(.ironBone)
                .padding()
                .background(Color.ironSurface)
                .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusMedium))
                .overlay(RoundedRectangle(cornerRadius: IronTheme.radiusMedium)
                    .stroke(Color.ironAsh.opacity(0.5), lineWidth: 1))
        }
    }
}

private struct StepWeightView: View {
    @Binding var weight: Float
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("現在の体重")
                .font(IronTypography.heading).foregroundColor(.ironBone)
            HStack {
                Text(String(format: "%.1f", weight))
                    .font(IronTypography.number).foregroundColor(.ironGold)
                Text("kg").font(IronTypography.subhead).foregroundColor(.ironStone)
            }
            .frame(maxWidth: .infinity)
            Slider(
                value: Binding(get: { Double(weight) }, set: { weight = Float($0) }),
                in: 40...150, step: 0.5
            )
            .accentColor(.ironEmber)
        }
    }
}

private struct StepGenderView: View {
    @Binding var gender: Gender
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("性別").font(IronTypography.heading).foregroundColor(.ironBone)
            HStack(spacing: 16) {
                ForEach([Gender.male, Gender.female], id: \.self) { g in
                    Button { gender = g } label: {
                        VStack(spacing: 8) {
                            Text(g == .male ? "⚔️" : "🛡️").font(.system(size: 40))
                            Text(g.displayName)
                                .font(IronTypography.subhead)
                                .foregroundColor(gender == g ? .ironGold : .ironStone)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(gender == g ? Color.ironElevated : Color.ironSurface)
                        .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusLarge))
                        .overlay(RoundedRectangle(cornerRadius: IronTheme.radiusLarge)
                            .stroke(gender == g ? Color.ironGold : Color.ironFade, lineWidth: 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

private struct StepExperienceView: View {
    @Binding var level: ExperienceLevel
    private let options: [(ExperienceLevel, String, String)] = [
        (.beginner,     "🌱", "筋トレ歴1年未満"),
        (.intermediate, "⚔️", "筋トレ歴1〜3年"),
        (.advanced,     "🔥", "筋トレ歴3年以上"),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("トレーニング経験")
                .font(IronTypography.heading).foregroundColor(.ironBone)
            ForEach(options, id: \.0) { exp, icon, desc in
                Button { level = exp } label: {
                    HStack {
                        Text(icon).font(.title)
                        VStack(alignment: .leading) {
                            Text(exp.displayName).font(IronTypography.subhead)
                                .foregroundColor(level == exp ? .ironGold : .ironBone)
                            Text(desc).font(IronTypography.small).foregroundColor(.ironStone)
                        }
                        Spacer()
                        if level == exp { Image(systemName: "checkmark.circle.fill").foregroundColor(.ironGold) }
                    }
                    .padding()
                    .background(level == exp ? Color.ironElevated : Color.ironSurface)
                    .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusMedium))
                    .overlay(RoundedRectangle(cornerRadius: IronTheme.radiusMedium)
                        .stroke(level == exp ? Color.ironGold : Color.ironFade, lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

private struct StepGoalView: View {
    @Binding var goal: TrainingGoal
    private let options: [(TrainingGoal, String, String)] = [
        (.cutting,  "🔥", "体脂肪を落としながら筋量を維持"),
        (.bulking,  "💪", "筋肉量を最大化する"),
        (.strength, "⚡", "最大筋力を高める"),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("トレーニング目標")
                .font(IronTypography.heading).foregroundColor(.ironBone)
            ForEach(options, id: \.0) { g, icon, desc in
                Button { goal = g } label: {
                    HStack {
                        Text(icon).font(.title)
                        VStack(alignment: .leading) {
                            Text(g.displayName).font(IronTypography.subhead)
                                .foregroundColor(goal == g ? .ironGold : .ironBone)
                            Text(desc).font(IronTypography.small).foregroundColor(.ironStone)
                        }
                        Spacer()
                        if goal == g { Image(systemName: "checkmark.circle.fill").foregroundColor(.ironGold) }
                    }
                    .padding()
                    .background(goal == g ? Color.ironElevated : Color.ironSurface)
                    .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusMedium))
                    .overlay(RoundedRectangle(cornerRadius: IronTheme.radiusMedium)
                        .stroke(goal == g ? Color.ironGold : Color.ironFade, lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

private struct StepFrequencyView: View {
    @Binding var days: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("週トレーニング日数")
                .font(IronTypography.heading).foregroundColor(.ironBone)
            HStack(spacing: 12) {
                ForEach([3, 4, 5], id: \.self) { d in
                    Button { days = d } label: {
                        VStack(spacing: 8) {
                            Text("\(d)").font(IronTypography.bigNum)
                                .foregroundColor(days == d ? .ironGold : .ironBone)
                            Text("日/週").font(IronTypography.caption).foregroundColor(.ironStone)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(days == d ? Color.ironElevated : Color.ironSurface)
                        .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusLarge))
                        .overlay(RoundedRectangle(cornerRadius: IronTheme.radiusLarge)
                            .stroke(days == d ? Color.ironGold : Color.ironFade, lineWidth: 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

private struct StepEquipmentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("利用可能な器具")
                .font(IronTypography.heading).foregroundColor(.ironBone)
            RuneCard {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(["✅ フリーウェイトエリア", "✅ マシンエリア", "✅ ケーブルマシン", "✅ 有酸素マシン"], id: \.self) {
                        Text($0).foregroundColor(.ironBone).font(IronTypography.body)
                    }
                }
            }
            Text("本アプリはジム完備環境を前提にプランを生成します")
                .font(IronTypography.small).foregroundColor(.ironStone)
        }
    }
}

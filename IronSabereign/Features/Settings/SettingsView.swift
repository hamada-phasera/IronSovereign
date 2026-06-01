import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var vm = SettingsViewModel()

    var body: some View {
        ZStack {
            LinearGradient.darkGradient.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    ForgeBanner("設定", subtitle: "アプリの設定").padding(.top, 8)
                    GlowingDivider()

                    if let profile = profiles.first { profileSection(profile: profile) }
                    aiSection
                    disclaimerSection

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            if let profile = profiles.first { vm.bodyWeightInput = profile.bodyWeight }
        }
    }

    private func profileSection(profile: UserProfile) -> some View {
        RuneCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("プロフィール").font(IronTypography.subhead).foregroundColor(.ironGold)

                profileRow("名前", value: profile.name)
                profileRow("経験レベル", value: profile.experienceLevel.displayName)
                profileRow("目標", value: profile.goal.displayName)
                profileRow("週トレーニング日数", value: "\(profile.trainingDaysPerWeek)日")

                GlowingDivider()

                Text("体重を記録").font(IronTypography.caption).foregroundColor(.ironStone)
                HStack {
                    Text(String(format: "%.1f", vm.bodyWeightInput))
                        .font(IronTypography.number).foregroundColor(.ironGold)
                    Text("kg").font(IronTypography.subhead).foregroundColor(.ironStone)
                    Spacer()
                }
                Slider(
                    value: Binding(get: { Double(vm.bodyWeightInput) }, set: { vm.bodyWeightInput = Float($0) }),
                    in: 40...150, step: 0.5
                )
                .accentColor(.ironEmber)
                SovereignButton(title: "体重を保存", style: .ghost) {
                    vm.updateBodyWeight(profile: profile, context: modelContext)
                }
            }
        }
    }

    private func profileRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.ironStone)
            Spacer()
            Text(value).foregroundColor(.ironBone)
        }
        .font(IronTypography.body)
    }

    private var aiSection: some View {
        RuneCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI最適化（任意）").font(IronTypography.subhead).foregroundColor(.ironGold)
                Text("Claude APIキーを設定すると、オンライン時にAIがトレーニングプランを最適化します。")
                    .font(IronTypography.small).foregroundColor(.ironStone)
                SecureField("sk-ant-api03-...", text: $vm.claudeAPIKey)
                    .font(IronTypography.small).foregroundColor(.ironBone)
                    .padding()
                    .background(Color.ironSurface)
                    .clipShape(RoundedRectangle(cornerRadius: IronTheme.radiusMedium))
                SovereignButton(
                    title: vm.showAPIKeySaved ? "✓ 保存しました" : "APIキーを保存",
                    style: vm.showAPIKeySaved ? .victory : .ghost
                ) { vm.saveAPIKey() }
            }
        }
    }

    private var disclaimerSection: some View {
        RuneCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("免責事項").font(IronTypography.caption).foregroundColor(.ironStone)
                Text("本アプリのトレーニング提案は一般的な情報提供を目的としており、医学的アドバイスではありません。トレーニングの実施にあたっては自己責任のもとで行い、必要に応じて医師やトレーナーに相談してください。怪我や身体の異常を感じた場合は直ちに中止してください。")
                    .font(IronTypography.small).foregroundColor(.ironFade)
            }
        }
    }
}

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var profiles: [UserProfile]
    @State private var vm = DashboardViewModel()
    @State private var selectedTab: Int = 0
    @State private var showWorkout = false

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.darkGradient.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                homeContent.tag(0)
                ProgressDashboardView().tag(1)
                SettingsView().tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            ironTabBar
        }
        .onAppear {
            vm.loadData(context: modelContext)
            if let profile = profiles.first {
                vm.generatePlanIfNeeded(profile: profile, context: modelContext)
            }
        }
        .fullScreenCover(isPresented: $showWorkout) {
            if let session = vm.todaySession {
                WorkoutSessionView(session: session)
                    .onDisappear { vm.loadData(context: modelContext) }
            }
        }
    }

    // MARK: - Home Tab

    private var homeContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForgeBanner(
                    profiles.first.map { "WELCOME BACK, \($0.name.uppercased())" } ?? "IRON SOVEREIGN",
                    subtitle: vm.quoteOfDay
                )
                .padding(.top, 8)

                GlowingDivider()

                todayMissionCard.padding(.horizontal, 16)

                HStack(spacing: 12) {
                    weeklyStatsCard
                    weightChangeCard
                }
                .padding(.horizontal, 16)

                Spacer().frame(height: 100)
            }
        }
        .scrollIndicators(.hidden)
    }

    private var todayMissionCard: some View {
        RuneCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🔥 今日のミッション")
                        .font(IronTypography.caption)
                        .foregroundColor(.ironEmber)
                        .tracking(1)
                    Spacer()
                }

                if let session = vm.todaySession {
                    Text(session.sessionType.displayName)
                        .font(IronTypography.heading).foregroundColor(.ironBone)
                    Text(session.sessionType.primaryMuscles)
                        .font(IronTypography.caption).foregroundColor(.ironStone)

                    let workSets = session.exerciseSets.filter { !$0.isWarmup }
                    Text("[\(workSets.count)セット\(session.cardioSession != nil ? " + 有酸素" : "")]")
                        .font(IronTypography.small).foregroundColor(.ironStone)

                    SovereignButton(title: "⚔️ 鍛錬を開始する", style: .primary) {
                        showWorkout = true
                    }
                    .padding(.top, 8)
                } else if vm.currentPlan != nil {
                    Text("今日のトレーニングはありません")
                        .font(IronTypography.heading).foregroundColor(.ironStone)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("プランが設定されていません")
                            .font(IronTypography.heading).foregroundColor(.ironStone)
                        Text("オンボーディングを完了するとトレーニングプランが自動生成されます。")
                            .font(IronTypography.small).foregroundColor(.ironFade)
                    }
                }
            }
        }
    }

    private var weeklyStatsCard: some View {
        RuneCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("今週の達成").font(IronTypography.small).foregroundColor(.ironStone)
                let completed = vm.currentPlan?.completedSessionsCount ?? 0
                let total = vm.currentPlan?.sessions.count ?? 3
                Text("\(completed)/\(total)")
                    .font(IronTypography.number).foregroundColor(.ironGold)
                EmberProgressBar(value: vm.weeklyCompletionRate)
            }
        }
    }

    private var weightChangeCard: some View {
        RuneCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("体重変化").font(IronTypography.small).foregroundColor(.ironStone)
                let sign = vm.recentWeightChange >= 0 ? "+" : ""
                Text("\(sign)\(String(format: "%.1f", vm.recentWeightChange))kg")
                    .font(IronTypography.number)
                    .foregroundColor(vm.recentWeightChange <= 0 ? .ironVictory : .ironCaution)
                Text("今週").font(IronTypography.small).foregroundColor(.ironStone)
            }
        }
    }

    // MARK: - Tab Bar

    private var ironTabBar: some View {
        HStack {
            tabBarItem(icon: "house.fill",                  label: "ホーム",  index: 0)
            tabBarItem(icon: "chart.line.uptrend.xyaxis",   label: "記録",    index: 1)
            tabBarItem(icon: "gearshape.fill",              label: "設定",    index: 2)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.ironDark.opacity(0.95))
        .overlay(GlowingDivider().frame(maxHeight: 1), alignment: .top)
    }

    private func tabBarItem(icon: String, label: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20))
                    .foregroundColor(selectedTab == index ? .ironEmber : .ironStone)
                Text(label).font(IronTypography.small)
                    .foregroundColor(selectedTab == index ? .ironEmber : .ironStone)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

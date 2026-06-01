import SwiftUI
import SwiftData
import Charts

struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = ProgressViewModel()

    var body: some View {
        ZStack {
            LinearGradient.darkGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForgeBanner("成長記録", subtitle: "FORGE YOUR LEGACY")
                        .padding(.top, 8)

                    GlowingDivider()

                    // 期間選択
                    periodPicker.padding(.horizontal, 16)

                    // 種目選択
                    exercisePicker.padding(.horizontal, 16)

                    // 推定1RMグラフ
                    RuneCard {
                        ExerciseChartView(
                            records: vm.currentExerciseRecords,
                            exerciseName: vm.currentExerciseName
                        )
                    }
                    .padding(.horizontal, 16)

                    // 体重推移グラフ
                    RuneCard {
                        BodyweightChartView(records: vm.bodyWeightRecords)
                    }
                    .padding(.horizontal, 16)

                    // 週間ボリュームグラフ
                    if !vm.weeklyVolumes.isEmpty {
                        RuneCard {
                            weeklyVolumeChart
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer().frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear { vm.loadData(context: modelContext) }
        .onChange(of: vm.selectedPeriod) { vm.loadData(context: modelContext) }
    }

    private var periodPicker: some View {
        HStack(spacing: 8) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button {
                    vm.selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(IronTypography.caption)
                        .foregroundColor(vm.selectedPeriod == period ? .ironGold : .ironStone)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(vm.selectedPeriod == period ? Color.ironElevated : Color.ironSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(vm.selectedPeriod == period ? Color.ironGold.opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var exercisePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.availableExercises, id: \.self) { exId in
                    let name = ExerciseDatabase.shared.exercise(by: exId)?.name ?? exId
                    Button {
                        vm.selectedExerciseId = exId
                    } label: {
                        Text(name)
                            .font(IronTypography.small)
                            .foregroundColor(vm.selectedExerciseId == exId ? .ironGold : .ironStone)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(vm.selectedExerciseId == exId ? Color.ironElevated : Color.ironSurface)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var weeklyVolumeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間総ボリューム")
                .font(IronTypography.subhead).foregroundColor(.ironBone)

            Chart(vm.weeklyVolumes, id: \.0) { date, vol in
                BarMark(
                    x: .value("週", date, unit: .weekOfYear),
                    y: .value("ボリューム", vol)
                )
                .foregroundStyle(LinearGradient.emberGradient)
                .cornerRadius(4)
            }
            .chartYAxisLabel("kg")
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear, count: 2)) {
                    AxisValueLabel(format: .dateTime.month().day())
                        .foregroundStyle(Color.ironStone)
                }
                AxisMarks { AxisGridLine().foregroundStyle(Color.ironFade.opacity(0.4)) }
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel().foregroundStyle(Color.ironStone)
                    AxisGridLine().foregroundStyle(Color.ironFade.opacity(0.4))
                }
            }
            .frame(height: 160)
            .chartPlotStyle { plot in
                plot.background(Color.ironSurface.opacity(0.3))
            }
        }
    }
}

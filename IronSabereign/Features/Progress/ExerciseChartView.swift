import SwiftUI
import Charts

struct ExerciseChartView: View {
    let records: [ProgressRecord]
    let exerciseName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exerciseName)
                .font(IronTypography.subhead)
                .foregroundColor(.ironBone)

            if records.isEmpty {
                emptyState
            } else {
                Chart(records) { record in
                    LineMark(
                        x: .value("日付", record.recordDate),
                        y: .value("推定1RM", record.estimatedOneRepMax)
                    )
                    .foregroundStyle(Color.ironEmber)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("日付", record.recordDate),
                        y: .value("推定1RM", record.estimatedOneRepMax)
                    )
                    .foregroundStyle(Color.ironGold)
                    .symbolSize(40)
                }
                .chartYAxisLabel("推定1RM (kg)")
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) {
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
                .frame(height: 180)
                .chartPlotStyle { plot in
                    plot.background(Color.ironSurface.opacity(0.3))
                }
            }
        }
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Text("📊").font(.title)
                Text("データなし").font(IronTypography.caption).foregroundColor(.ironStone)
            }
            Spacer()
        }
        .frame(height: 120)
    }
}

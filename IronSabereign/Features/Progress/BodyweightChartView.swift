import SwiftUI
import Charts

struct BodyweightChartView: View {
    let records: [ProgressRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("体重推移")
                .font(IronTypography.subhead).foregroundColor(.ironBone)

            let bwRecords = records.compactMap { r -> (Date, Float)? in
                guard let bw = r.bodyWeight else { return nil }
                return (r.recordDate, bw)
            }

            if bwRecords.isEmpty {
                emptyState
            } else {
                Chart {
                    ForEach(bwRecords, id: \.0) { date, weight in
                        LineMark(
                            x: .value("日付", date),
                            y: .value("体重", weight)
                        )
                        .foregroundStyle(Color.ironFlame)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("日付", date),
                            y: .value("体重", weight)
                        )
                        .foregroundStyle(Color.ironGold)
                        .symbolSize(30)
                    }
                }
                .chartYAxisLabel("体重 (kg)")
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
                .frame(height: 160)
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
                Text("⚖️").font(.title)
                Text("体重データなし — 設定から記録できます")
                    .font(IronTypography.caption).foregroundColor(.ironStone)
            }
            Spacer()
        }
        .frame(height: 100)
    }
}

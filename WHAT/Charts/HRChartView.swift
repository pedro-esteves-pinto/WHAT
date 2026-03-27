import Charts
import SwiftUI

struct HRChartView: View {
    let heartRateSamples: [HeartRateSample]
    let cycles: [CycleRecord]
    let sessionStart: Date
    let totalDuration: TimeInterval

    private var dataPoints: [HRChartData.DataPoint] {
        HRChartData.dataPoints(from: heartRateSamples, sessionStart: sessionStart)
    }

    private var phaseBands: [HRChartData.PhaseBand] {
        HRChartData.phaseBands(from: cycles, sessionStart: sessionStart)
    }

    var body: some View {
        if dataPoints.isEmpty {
            ContentUnavailableView(
                "No Heart Rate Data",
                systemImage: "heart.slash",
                description: Text("Pair an Apple Watch to record heart rate during sessions.")
            )
            .frame(height: 200)
        } else {
            chart
                .frame(height: 220)
        }
    }

    private var chart: some View {
        Chart {
            // Phase overlay rectangles
            ForEach(phaseBands) { band in
                RectangleMark(
                    xStart: .value("Start", band.startSeconds),
                    xEnd: .value("End", band.endSeconds),
                    yStart: nil,
                    yEnd: nil
                )
                .foregroundStyle(band.phase.color)
            }

            // HR line
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Time", point.seconds),
                    y: .value("BPM", point.bpm)
                )
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let seconds = value.as(Double.self) {
                    AxisValueLabel {
                        Text(formatAxisTime(seconds))
                    }
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                if let bpm = value.as(Double.self) {
                    AxisValueLabel {
                        Text("\(Int(bpm))")
                    }
                    AxisGridLine()
                }
            }
        }
        .chartYAxisLabel("BPM", position: .leading)
        .chartLegend(position: .bottom) {
            HStack(spacing: 16) {
                ForEach([HRChartData.PhaseType.powerBreathing, .retention, .recovery], id: \.rawValue) { phase in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(phase.color)
                            .frame(width: 10, height: 10)
                        Text(phase.rawValue)
                            .font(.caption2)
                    }
                }
            }
        }
    }

    private func formatAxisTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

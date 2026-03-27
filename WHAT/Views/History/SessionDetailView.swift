import SwiftUI

struct SessionDetailView: View {
    let session: Session

    var body: some View {
        List {
            Section("Configuration") {
                LabeledContent("Cycles", value: "\(session.numberOfCycles)")
                LabeledContent("Breaths per Cycle", value: "\(session.breathsPerCycle)")
                LabeledContent("Cadence", value: String(format: "%.1f bps", session.cadence))
                LabeledContent("Total Duration", value: formatTime(session.totalDurationSeconds))
            }

            Section("Retention Times") {
                let sortedCycles = session.cycles.sorted { $0.cycleIndex < $1.cycleIndex }
                ForEach(sortedCycles, id: \.cycleIndex) { cycle in
                    LabeledContent(
                        "Cycle \(cycle.cycleIndex + 1)",
                        value: formatTime(cycle.retentionDurationSeconds)
                    )
                }
            }

            Section("Heart Rate") {
                HRChartView(
                    heartRateSamples: session.heartRateSamples,
                    cycles: session.cycles,
                    sessionStart: session.date,
                    totalDuration: session.totalDurationSeconds
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
        }
        .navigationTitle(session.date.formatted(date: .abbreviated, time: .omitted))
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

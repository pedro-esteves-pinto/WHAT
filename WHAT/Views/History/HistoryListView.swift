import SwiftData
import SwiftUI

struct HistoryListView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]

    var body: some View {
        List {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "wind",
                    description: Text("Complete a breathing session to see it here.")
                )
            } else {
                ForEach(sessions, id: \.id) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.date, style: .date)
                                .font(.headline)
                            Text(session.date, style: .time)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            let summary = "\(session.numberOfCycles) cycles · "
                                + "\(session.breathsPerCycle) breaths · "
                                + formatTime(session.totalDurationSeconds)
                            Text(summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

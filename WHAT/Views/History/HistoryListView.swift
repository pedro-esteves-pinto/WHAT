import SwiftData
import SwiftUI

struct HistoryListView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Environment(\.modelContext) private var modelContext

    private var groupedSessions: [(date: Date, sessions: [Session])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, sessions: $0.value) }
    }

    var body: some View {
        List {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "wind",
                    description: Text("Complete a breathing session to see it here.")
                )
            } else {
                ForEach(groupedSessions, id: \.date) { group in
                    Section(header: Text(group.date, style: .date)) {
                        ForEach(group.sessions, id: \.id) { session in
                            NavigationLink {
                                SessionDetailView(session: session)
                            } label: {
                                SessionRowView(session: session)
                            }
                        }
                        .onDelete { offsets in
                            deleteSessions(from: group.sessions, at: offsets)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }

    private func deleteSessions(from groupSessions: [Session], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(groupSessions[index])
        }
        try? modelContext.save()
    }
}

// MARK: - Session Row

private struct SessionRowView: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.date, style: .time)
                .font(.headline)

            let summary = "\(session.numberOfCycles) cycles · "
                + "\(session.breathsPerCycle) breaths · "
                + formatTime(session.totalDurationSeconds)
            Text(summary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

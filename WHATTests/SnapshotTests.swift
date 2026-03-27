@testable import WHAT
import SnapshotTesting
import SwiftData
import SwiftUI
import XCTest

final class SnapshotTests: XCTestCase {
    func testConfigViewSnapshot() {
        let view = ConfigView(config: .constant(.default))
            .frame(width: 390)
            .padding()

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }

    func testBreathingCircleEmptySnapshot() {
        let view = BreathingCircle(progress: 0.0)
            .frame(width: 200, height: 200)

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(size: CGSize(width: 220, height: 220)))
    }

    func testBreathingCircleFullSnapshot() {
        let view = BreathingCircle(progress: 1.0)
            .frame(width: 200, height: 200)

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(size: CGSize(width: 220, height: 220)))
    }

    func testHeartRateDisplayWithBPM() {
        let view = HeartRateDisplay(bpm: 72)
            .padding()

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(size: CGSize(width: 200, height: 50)))
    }

    func testHeartRateDisplayNoBPM() {
        let view = HeartRateDisplay(bpm: nil)
            .padding()

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(size: CGSize(width: 200, height: 50)))
    }

    // MARK: - SessionDetailView Snapshots

    @MainActor
    func testSessionDetailViewSnapshot() throws {
        let schema = Schema([Session.self, CycleRecord.self, HeartRateSample.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let session = Session(
            date: Date(timeIntervalSince1970: 1_700_000_000),
            numberOfCycles: 3, breathsPerCycle: 35, cadence: 1.0, totalDurationSeconds: 420
        )
        context.insert(session)

        for i in 0..<3 {
            let cycle = CycleRecord(cycleIndex: i, retentionDurationSeconds: Double(45 + i * 10))
            cycle.session = session
            context.insert(cycle)
        }
        try context.save()

        let view = NavigationStack {
            SessionDetailView(session: session)
        }
        .modelContainer(container)

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }

    // MARK: - HistoryListView Snapshots

    @MainActor
    func testHistoryListViewEmptySnapshot() throws {
        let schema = Schema([Session.self, CycleRecord.self, HeartRateSample.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])

        let view = NavigationStack {
            HistoryListView()
        }
        .modelContainer(container)

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }

    @MainActor
    func testHistoryListViewWithSessionsSnapshot() throws {
        let schema = Schema([Session.self, CycleRecord.self, HeartRateSample.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let today = Date(timeIntervalSince1970: 1_700_000_000)
        let yesterday = today.addingTimeInterval(-86400)

        let s1 = Session(date: today, numberOfCycles: 3, breathsPerCycle: 35, cadence: 1.0, totalDurationSeconds: 420)
        let s2 = Session(date: yesterday, numberOfCycles: 1, breathsPerCycle: 25, cadence: 2.0, totalDurationSeconds: 90)
        context.insert(s1)
        context.insert(s2)
        try context.save()

        let view = NavigationStack {
            HistoryListView()
        }
        .modelContainer(container)

        let controller = UIHostingController(rootView: view)
        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }
}

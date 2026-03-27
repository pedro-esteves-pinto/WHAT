@testable import WHAT
import SwiftData
import XCTest

final class SwiftDataIntegrationTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    @MainActor
    override func setUp() {
        super.setUp()
        do {
            let schema = Schema([Session.self, CycleRecord.self, HeartRateSample.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [config])
            context = container.mainContext
        } catch {
            XCTFail("Failed to create in-memory ModelContainer: \(error)")
        }
    }

    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Session CRUD

    @MainActor
    func testInsertAndFetchSession() throws {
        let session = Session(numberOfCycles: 3, breathsPerCycle: 35, cadence: 1.0, totalDurationSeconds: 120)
        context.insert(session)
        try context.save()

        let descriptor = FetchDescriptor<Session>()
        let sessions = try context.fetch(descriptor)
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions[0].numberOfCycles, 3)
        XCTAssertEqual(sessions[0].breathsPerCycle, 35)
        XCTAssertEqual(sessions[0].cadence, 1.0)
        XCTAssertEqual(sessions[0].totalDurationSeconds, 120)
    }

    // MARK: - Relationships

    @MainActor
    func testSessionCycleRelationship() throws {
        let session = Session(numberOfCycles: 2, breathsPerCycle: 30, cadence: 1.5)
        context.insert(session)

        let cycle1 = CycleRecord(cycleIndex: 0, retentionDurationSeconds: 45)
        let cycle2 = CycleRecord(cycleIndex: 1, retentionDurationSeconds: 60)
        cycle1.session = session
        cycle2.session = session
        context.insert(cycle1)
        context.insert(cycle2)
        try context.save()

        let descriptor = FetchDescriptor<Session>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched[0].cycles.count, 2)

        let sorted = fetched[0].cycles.sorted { $0.cycleIndex < $1.cycleIndex }
        XCTAssertEqual(sorted[0].retentionDurationSeconds, 45)
        XCTAssertEqual(sorted[1].retentionDurationSeconds, 60)
    }

    @MainActor
    func testSessionHeartRateRelationship() throws {
        let session = Session(numberOfCycles: 1, breathsPerCycle: 30, cadence: 1.0)
        context.insert(session)

        let sample1 = HeartRateSample(bpm: 72)
        let sample2 = HeartRateSample(bpm: 85)
        sample1.session = session
        sample2.session = session
        context.insert(sample1)
        context.insert(sample2)
        try context.save()

        let descriptor = FetchDescriptor<Session>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched[0].heartRateSamples.count, 2)
    }

    // MARK: - Cascade Delete

    @MainActor
    func testCascadeDeleteRemovesCycles() throws {
        let session = Session(numberOfCycles: 1, breathsPerCycle: 30, cadence: 1.0)
        context.insert(session)

        let cycle = CycleRecord(cycleIndex: 0, retentionDurationSeconds: 30)
        cycle.session = session
        context.insert(cycle)
        try context.save()

        context.delete(session)
        try context.save()

        let sessionDescriptor = FetchDescriptor<Session>()
        let cycleDescriptor = FetchDescriptor<CycleRecord>()
        XCTAssertEqual(try context.fetch(sessionDescriptor).count, 0)
        XCTAssertEqual(try context.fetch(cycleDescriptor).count, 0)
    }

    @MainActor
    func testCascadeDeleteRemovesHeartRateSamples() throws {
        let session = Session(numberOfCycles: 1, breathsPerCycle: 30, cadence: 1.0)
        context.insert(session)

        let sample = HeartRateSample(bpm: 72)
        sample.session = session
        context.insert(sample)
        try context.save()

        context.delete(session)
        try context.save()

        let sessionDescriptor = FetchDescriptor<Session>()
        let sampleDescriptor = FetchDescriptor<HeartRateSample>()
        XCTAssertEqual(try context.fetch(sessionDescriptor).count, 0)
        XCTAssertEqual(try context.fetch(sampleDescriptor).count, 0)
    }

    // MARK: - Multiple Sessions

    @MainActor
    func testMultipleSessionsWithIndependentData() throws {
        let session1 = Session(numberOfCycles: 1, breathsPerCycle: 25, cadence: 2.0)
        let session2 = Session(numberOfCycles: 3, breathsPerCycle: 45, cadence: 1.0)
        context.insert(session1)
        context.insert(session2)

        let cycle = CycleRecord(cycleIndex: 0, retentionDurationSeconds: 40)
        cycle.session = session1
        context.insert(cycle)
        try context.save()

        XCTAssertEqual(session1.cycles.count, 1)
        XCTAssertEqual(session2.cycles.count, 0)

        context.delete(session1)
        try context.save()

        let descriptor = FetchDescriptor<Session>()
        let remaining = try context.fetch(descriptor)
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining[0].numberOfCycles, 3)
    }

    // MARK: - Session Ordering and Deletion

    @MainActor
    func testSessionsFetchedInReverseChronologicalOrder() throws {
        let older = Session(
            date: Date(timeIntervalSince1970: 1_000_000),
            numberOfCycles: 1, breathsPerCycle: 25, cadence: 1.0, totalDurationSeconds: 60
        )
        let newer = Session(
            date: Date(timeIntervalSince1970: 2_000_000),
            numberOfCycles: 3, breathsPerCycle: 35, cadence: 1.0, totalDurationSeconds: 180
        )
        context.insert(older)
        context.insert(newer)
        try context.save()

        var descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let sessions = try context.fetch(descriptor)
        XCTAssertEqual(sessions.count, 2)
        XCTAssertEqual(sessions[0].date, newer.date)
        XCTAssertEqual(sessions[1].date, older.date)
    }

    @MainActor
    func testDeleteSessionRemovesFromStore() throws {
        let session = Session(numberOfCycles: 1, breathsPerCycle: 25, cadence: 1.0, totalDurationSeconds: 60)
        let cycle = CycleRecord(cycleIndex: 0, retentionDurationSeconds: 30)
        cycle.session = session
        context.insert(session)
        context.insert(cycle)
        try context.save()

        context.delete(session)
        try context.save()

        let sessions = try context.fetch(FetchDescriptor<Session>())
        let cycles = try context.fetch(FetchDescriptor<CycleRecord>())
        XCTAssertEqual(sessions.count, 0)
        XCTAssertEqual(cycles.count, 0)
    }

    @MainActor
    func testSessionsGroupByDate() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let s1 = Session(date: today, numberOfCycles: 1, breathsPerCycle: 25, cadence: 1.0, totalDurationSeconds: 60)
        let s2 = Session(date: today.addingTimeInterval(3600), numberOfCycles: 1, breathsPerCycle: 25, cadence: 1.0, totalDurationSeconds: 90)
        let s3 = Session(date: yesterday, numberOfCycles: 1, breathsPerCycle: 25, cadence: 1.0, totalDurationSeconds: 45)
        context.insert(s1)
        context.insert(s2)
        context.insert(s3)
        try context.save()

        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let sessions = try context.fetch(descriptor)

        // Group by calendar day
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        XCTAssertEqual(grouped.count, 2)
        XCTAssertEqual(grouped[today]?.count, 2)
        XCTAssertEqual(grouped[yesterday]?.count, 1)
    }

    // MARK: - CycleRecord Timestamps

    @MainActor
    func testCycleRecordTimestampsPersist() throws {
        let session = Session(numberOfCycles: 1, breathsPerCycle: 30, cadence: 1.0)
        context.insert(session)

        let now = Date()
        let cycle = CycleRecord(cycleIndex: 0, startTimestamp: now)
        cycle.retentionStartTimestamp = now.addingTimeInterval(30)
        cycle.retentionEndTimestamp = now.addingTimeInterval(75)
        cycle.retentionDurationSeconds = 45
        cycle.recoveryEndTimestamp = now.addingTimeInterval(90)
        cycle.session = session
        context.insert(cycle)
        try context.save()

        let descriptor = FetchDescriptor<CycleRecord>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].retentionDurationSeconds, 45)
        XCTAssertNotNil(fetched[0].retentionStartTimestamp)
        XCTAssertNotNil(fetched[0].retentionEndTimestamp)
        XCTAssertNotNil(fetched[0].recoveryEndTimestamp)
    }
}

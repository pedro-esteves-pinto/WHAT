@testable import WHAT
import XCTest

final class HRChartDataTests: XCTestCase {

    // MARK: - Phase Band Computation

    func testPhaseBandsFromSingleCycle() {
        let sessionStart = Date(timeIntervalSince1970: 1000)

        let cycle = CycleRecord(cycleIndex: 0, startTimestamp: sessionStart)
        cycle.retentionStartTimestamp = sessionStart.addingTimeInterval(30)
        cycle.retentionEndTimestamp = sessionStart.addingTimeInterval(75)
        cycle.recoveryEndTimestamp = sessionStart.addingTimeInterval(90)

        let bands = HRChartData.phaseBands(from: [cycle], sessionStart: sessionStart)

        XCTAssertEqual(bands.count, 3)

        // Power breathing: 0–30s
        XCTAssertEqual(bands[0].phase, .powerBreathing)
        XCTAssertEqual(bands[0].startSeconds, 0, accuracy: 0.1)
        XCTAssertEqual(bands[0].endSeconds, 30, accuracy: 0.1)

        // Retention: 30–75s
        XCTAssertEqual(bands[1].phase, .retention)
        XCTAssertEqual(bands[1].startSeconds, 30, accuracy: 0.1)
        XCTAssertEqual(bands[1].endSeconds, 75, accuracy: 0.1)

        // Recovery: 75–90s
        XCTAssertEqual(bands[2].phase, .recovery)
        XCTAssertEqual(bands[2].startSeconds, 75, accuracy: 0.1)
        XCTAssertEqual(bands[2].endSeconds, 90, accuracy: 0.1)
    }

    func testPhaseBandsFromMultipleCycles() {
        let sessionStart = Date(timeIntervalSince1970: 1000)

        let cycle0 = CycleRecord(cycleIndex: 0, startTimestamp: sessionStart)
        cycle0.retentionStartTimestamp = sessionStart.addingTimeInterval(30)
        cycle0.retentionEndTimestamp = sessionStart.addingTimeInterval(75)
        cycle0.recoveryEndTimestamp = sessionStart.addingTimeInterval(90)

        let cycle1 = CycleRecord(cycleIndex: 1, startTimestamp: sessionStart.addingTimeInterval(90))
        cycle1.retentionStartTimestamp = sessionStart.addingTimeInterval(120)
        cycle1.retentionEndTimestamp = sessionStart.addingTimeInterval(170)
        cycle1.recoveryEndTimestamp = sessionStart.addingTimeInterval(185)

        let bands = HRChartData.phaseBands(from: [cycle0, cycle1], sessionStart: sessionStart)

        XCTAssertEqual(bands.count, 6)
        // Cycle 0
        XCTAssertEqual(bands[0].phase, .powerBreathing)
        XCTAssertEqual(bands[1].phase, .retention)
        XCTAssertEqual(bands[2].phase, .recovery)
        // Cycle 1
        XCTAssertEqual(bands[3].phase, .powerBreathing)
        XCTAssertEqual(bands[4].phase, .retention)
        XCTAssertEqual(bands[5].phase, .recovery)
    }

    func testPhaseBandsWithMissingTimestampsSkipsIncomplete() {
        let sessionStart = Date(timeIntervalSince1970: 1000)

        // Cycle with no retention timestamps (incomplete)
        let cycle = CycleRecord(cycleIndex: 0, startTimestamp: sessionStart)

        let bands = HRChartData.phaseBands(from: [cycle], sessionStart: sessionStart)

        // Should only produce what it can — no bands if timestamps are missing
        XCTAssertTrue(bands.isEmpty)
    }

    // MARK: - HR Data Points

    func testHRDataPointsFromSamples() {
        let sessionStart = Date(timeIntervalSince1970: 1000)
        let samples = [
            HeartRateSample(timestamp: sessionStart.addingTimeInterval(5), bpm: 72),
            HeartRateSample(timestamp: sessionStart.addingTimeInterval(10), bpm: 85),
            HeartRateSample(timestamp: sessionStart.addingTimeInterval(15), bpm: 90),
        ]

        let points = HRChartData.dataPoints(from: samples, sessionStart: sessionStart)

        XCTAssertEqual(points.count, 3)
        XCTAssertEqual(points[0].seconds, 5, accuracy: 0.1)
        XCTAssertEqual(points[0].bpm, 72)
        XCTAssertEqual(points[1].seconds, 10, accuracy: 0.1)
        XCTAssertEqual(points[1].bpm, 85)
        XCTAssertEqual(points[2].seconds, 15, accuracy: 0.1)
        XCTAssertEqual(points[2].bpm, 90)
    }

    func testEmptySamplesReturnsEmptyPoints() {
        let points = HRChartData.dataPoints(from: [], sessionStart: Date())
        XCTAssertTrue(points.isEmpty)
    }
}

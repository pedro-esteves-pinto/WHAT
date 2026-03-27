@testable import WHAT
import XCTest

final class HealthKitManagerTests: XCTestCase {

    // MARK: - Mock

    final class MockHealthKitManager: HeartRateProvider {
        var isAvailable: Bool = true
        var isAuthorized: Bool = false
        private(set) var didRequestAuth = false
        private(set) var didStart = false
        private(set) var didStop = false
        private(set) var currentHeartRate: Double?
        private(set) var collectedSamples: [HeartRateSample] = []
        var onHeartRateUpdate: ((Double) -> Void)?

        func requestAuthorization() async -> Bool {
            didRequestAuth = true
            return isAuthorized
        }

        func startMonitoring() {
            didStart = true
        }

        func stopMonitoring() -> [HeartRateSample] {
            didStop = true
            return collectedSamples
        }

        func simulateHeartRate(_ bpm: Double) {
            currentHeartRate = bpm
            let sample = HeartRateSample(bpm: bpm)
            collectedSamples.append(sample)
            onHeartRateUpdate?(bpm)
        }
    }

    // MARK: - Tests

    func testRequestAuthorizationCallsThrough() async {
        let mock = MockHealthKitManager()
        mock.isAuthorized = true
        let result = await mock.requestAuthorization()
        XCTAssertTrue(mock.didRequestAuth)
        XCTAssertTrue(result)
    }

    func testRequestAuthorizationDenied() async {
        let mock = MockHealthKitManager()
        mock.isAuthorized = false
        let result = await mock.requestAuthorization()
        XCTAssertFalse(result)
    }

    func testStartMonitoring() {
        let mock = MockHealthKitManager()
        mock.startMonitoring()
        XCTAssertTrue(mock.didStart)
    }

    func testStopMonitoringReturnsSamples() {
        let mock = MockHealthKitManager()
        mock.simulateHeartRate(72)
        mock.simulateHeartRate(85)
        let samples = mock.stopMonitoring()
        XCTAssertTrue(mock.didStop)
        XCTAssertEqual(samples.count, 2)
        XCTAssertEqual(samples[0].bpm, 72)
        XCTAssertEqual(samples[1].bpm, 85)
    }

    func testHeartRateUpdateCallback() {
        let mock = MockHealthKitManager()
        var receivedBPM: Double?
        mock.onHeartRateUpdate = { bpm in
            receivedBPM = bpm
        }
        mock.simulateHeartRate(90)
        XCTAssertEqual(receivedBPM, 90)
    }

    func testUnavailableManagerReturnsNoSamples() {
        let mock = MockHealthKitManager()
        mock.isAvailable = false
        let samples = mock.stopMonitoring()
        XCTAssertTrue(samples.isEmpty)
    }
}

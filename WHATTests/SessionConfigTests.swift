@testable import WHAT
import XCTest

final class SessionConfigTests: XCTestCase {
    func testDefaultValues() {
        let config = SessionConfig.default
        XCTAssertEqual(config.numberOfCycles, 3)
        XCTAssertEqual(config.breathsPerCycle, 35)
        XCTAssertEqual(config.cadence, 1.0)
    }

    func testCodableRoundTrip() throws {
        let config = SessionConfig(numberOfCycles: 4, breathsPerCycle: 55, cadence: 0.5)
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(SessionConfig.self, from: data)
        XCTAssertEqual(config, decoded)
    }

    func testOptionArrays() {
        XCTAssertEqual(SessionConfig.cycleOptions, [1, 3, 4])
        XCTAssertEqual(SessionConfig.breathOptions, [25, 35, 45, 55])
        XCTAssertEqual(SessionConfig.cadenceOptions, [2.0, 1.5, 1.0, 0.5])
    }
}

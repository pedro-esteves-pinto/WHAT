@testable import WHAT
import XCTest

final class UserDefaultsStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "lastSessionConfig")
    }

    func testLoadReturnsDefaultWhenEmpty() {
        let config = UserDefaultsStore.load()
        XCTAssertEqual(config, .default)
    }

    func testSaveAndLoad() {
        let config = SessionConfig(numberOfCycles: 4, breathsPerCycle: 55, cadence: 0.5)
        UserDefaultsStore.save(config)

        let loaded = UserDefaultsStore.load()
        XCTAssertEqual(loaded, config)
    }

    func testOverwritesPreviousConfig() {
        let first = SessionConfig(numberOfCycles: 1, breathsPerCycle: 25, cadence: 2.0)
        UserDefaultsStore.save(first)

        let second = SessionConfig(numberOfCycles: 3, breathsPerCycle: 45, cadence: 1.0)
        UserDefaultsStore.save(second)

        let loaded = UserDefaultsStore.load()
        XCTAssertEqual(loaded, second)
    }
}

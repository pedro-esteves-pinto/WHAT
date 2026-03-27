import XCTest

final class WHATUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testHomeScreenShowsConfigAndStartButton() {
        XCTAssertTrue(app.staticTexts["WHAT"].exists)
        XCTAssertTrue(app.buttons["Start Session"].exists)
        XCTAssertTrue(app.links["History"].exists || app.buttons["History"].exists)
    }

    func testConfigPickersExist() {
        XCTAssertTrue(app.staticTexts["Cycles"].exists)
        XCTAssertTrue(app.staticTexts["Breaths per Cycle"].exists)
        XCTAssertTrue(app.staticTexts["Cadence (breaths/sec)"].exists)
    }
}

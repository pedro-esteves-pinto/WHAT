@testable import WHAT
import SnapshotTesting
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
}

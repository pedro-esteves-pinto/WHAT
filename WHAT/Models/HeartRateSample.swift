import Foundation
import SwiftData

@Model
final class HeartRateSample {
    var timestamp: Date
    var bpm: Double

    var session: Session?

    init(timestamp: Date = Date(), bpm: Double) {
        self.timestamp = timestamp
        self.bpm = bpm
    }
}

import Foundation
import SwiftData

@Model
final class CycleRecord {
    var cycleIndex: Int
    var retentionDurationSeconds: Double
    var startTimestamp: Date
    var retentionStartTimestamp: Date?
    var retentionEndTimestamp: Date?
    var recoveryEndTimestamp: Date?

    var session: Session?

    init(
        cycleIndex: Int,
        startTimestamp: Date = Date(),
        retentionDurationSeconds: Double = 0
    ) {
        self.cycleIndex = cycleIndex
        self.startTimestamp = startTimestamp
        self.retentionDurationSeconds = retentionDurationSeconds
    }
}

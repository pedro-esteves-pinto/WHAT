import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID
    var date: Date
    var numberOfCycles: Int
    var breathsPerCycle: Int
    var cadence: Double
    var totalDurationSeconds: Double

    @Relationship(deleteRule: .cascade, inverse: \CycleRecord.session)
    var cycles: [CycleRecord]

    @Relationship(deleteRule: .cascade, inverse: \HeartRateSample.session)
    var heartRateSamples: [HeartRateSample]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        numberOfCycles: Int,
        breathsPerCycle: Int,
        cadence: Double,
        totalDurationSeconds: Double = 0
    ) {
        self.id = id
        self.date = date
        self.numberOfCycles = numberOfCycles
        self.breathsPerCycle = breathsPerCycle
        self.cadence = cadence
        self.totalDurationSeconds = totalDurationSeconds
        self.cycles = []
        self.heartRateSamples = []
    }
}

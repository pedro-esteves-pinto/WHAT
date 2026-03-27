import Foundation

struct SessionConfig: Codable, Equatable {
    var numberOfCycles: Int
    var breathsPerCycle: Int
    var cadence: Double

    static let cycleOptions = [1, 3, 4]
    static let breathOptions = [25, 35, 45, 55]
    static let cadenceOptions = [2.0, 1.5, 1.0, 0.5]

    static let `default` = SessionConfig(
        numberOfCycles: 3,
        breathsPerCycle: 35,
        cadence: 1.0
    )
}

import Foundation
import SwiftUI

enum HRChartData {

    // MARK: - Types

    enum PhaseType: String {
        case powerBreathing = "Breathing"
        case retention = "Retention"
        case recovery = "Recovery"

        var color: Color {
            switch self {
            case .powerBreathing: .blue.opacity(0.2)
            case .retention: .orange.opacity(0.2)
            case .recovery: .green.opacity(0.2)
            }
        }
    }

    struct PhaseBand: Identifiable {
        let id = UUID()
        let phase: PhaseType
        let startSeconds: Double
        let endSeconds: Double
        let cycleIndex: Int
    }

    struct DataPoint: Identifiable {
        let id = UUID()
        let seconds: Double
        let bpm: Double
    }

    // MARK: - Computation

    static func phaseBands(from cycles: [CycleRecord], sessionStart: Date) -> [PhaseBand] {
        let sorted = cycles.sorted { $0.cycleIndex < $1.cycleIndex }
        var bands: [PhaseBand] = []

        for cycle in sorted {
            guard let retentionStart = cycle.retentionStartTimestamp,
                  let retentionEnd = cycle.retentionEndTimestamp,
                  let recoveryEnd = cycle.recoveryEndTimestamp else {
                continue
            }

            let cycleStart = cycle.startTimestamp.timeIntervalSince(sessionStart)
            let retStart = retentionStart.timeIntervalSince(sessionStart)
            let retEnd = retentionEnd.timeIntervalSince(sessionStart)
            let recEnd = recoveryEnd.timeIntervalSince(sessionStart)

            bands.append(PhaseBand(
                phase: .powerBreathing,
                startSeconds: cycleStart,
                endSeconds: retStart,
                cycleIndex: cycle.cycleIndex
            ))
            bands.append(PhaseBand(
                phase: .retention,
                startSeconds: retStart,
                endSeconds: retEnd,
                cycleIndex: cycle.cycleIndex
            ))
            bands.append(PhaseBand(
                phase: .recovery,
                startSeconds: retEnd,
                endSeconds: recEnd,
                cycleIndex: cycle.cycleIndex
            ))
        }

        return bands
    }

    static func dataPoints(from samples: [HeartRateSample], sessionStart: Date) -> [DataPoint] {
        samples
            .sorted { $0.timestamp < $1.timestamp }
            .map { sample in
                DataPoint(
                    seconds: sample.timestamp.timeIntervalSince(sessionStart),
                    bpm: sample.bpm
                )
            }
    }
}

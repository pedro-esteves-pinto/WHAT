import SwiftUI

struct RecoveryView: View {
    let stateMachine: SessionStateMachine

    private var cycleIndex: Int {
        if case let .recovery(idx) = stateMachine.phase { return idx }
        return 0
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Cycle \(cycleIndex + 1) of \(stateMachine.config.numberOfCycles)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Recovery Breath")
                .font(.title.weight(.semibold))

            Text("Breathe in deeply and hold for 15 seconds")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("\(Int(ceil(stateMachine.recoveryTimeRemaining)))")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.green)
        }
    }
}

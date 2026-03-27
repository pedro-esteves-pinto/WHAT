import SwiftUI

struct PowerBreathingView: View {
    let stateMachine: SessionStateMachine

    private var cycleIndex: Int {
        if case let .powerBreathing(idx) = stateMachine.phase { return idx }
        return 0
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Cycle \(cycleIndex + 1) of \(stateMachine.config.numberOfCycles)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Power Breathing")
                .font(.title.weight(.semibold))

            BreathingCircle(progress: stateMachine.breathProgress)
                .frame(width: 200, height: 200)

            Text("\(stateMachine.breathCount) / \(stateMachine.config.breathsPerCycle)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
    }
}

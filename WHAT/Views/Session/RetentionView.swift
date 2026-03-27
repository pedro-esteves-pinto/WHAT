import SwiftUI

struct RetentionView: View {
    let stateMachine: SessionStateMachine

    private var cycleIndex: Int {
        if case let .retention(idx) = stateMachine.phase { return idx }
        return 0
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Cycle \(cycleIndex + 1) of \(stateMachine.config.numberOfCycles)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Hold Your Breath")
                .font(.title.weight(.semibold))

            Text(formatTime(stateMachine.retentionTime))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            Button {
                stateMachine.endRetention()
            } label: {
                Text("I Breathed")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal, 40)
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

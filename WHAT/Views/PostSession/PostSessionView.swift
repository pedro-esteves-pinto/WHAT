import SwiftUI

struct PostSessionView: View {
    let stateMachine: SessionStateMachine
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Session Complete")
                .font(.largeTitle.weight(.bold))

            VStack(spacing: 12) {
                ForEach(stateMachine.cycleRecords.indices, id: \.self) { index in
                    let record = stateMachine.cycleRecords[index]
                    HStack {
                        Text("Cycle \(index + 1)")
                            .font(.headline)
                        Spacer()
                        Text("Retention: \(formatTime(record.retentionDurationSeconds))")
                            .monospacedDigit()
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
            .padding(.horizontal)

            Text("Total: \(formatTime(stateMachine.totalDuration))")
                .font(.title3.weight(.semibold))

            Button {
                onDismiss()
            } label: {
                Text("Done")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

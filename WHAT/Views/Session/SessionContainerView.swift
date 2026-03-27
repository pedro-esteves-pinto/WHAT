import SwiftData
import SwiftUI

struct SessionContainerView: View {
    let config: SessionConfig
    @Binding var isPresented: Bool
    @State private var stateMachine: SessionStateMachine
    @Environment(\.modelContext) private var modelContext

    init(config: SessionConfig, isPresented: Binding<Bool>) {
        self.config = config
        self._isPresented = isPresented
        self._stateMachine = State(initialValue: SessionStateMachine(config: config))
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("End") {
                    stateMachine.stop()
                }
                .padding()
            }

            Spacer()

            switch stateMachine.phase {
            case .notStarted:
                Text("Preparing...")
                    .onAppear {
                        stateMachine.start()
                    }
            case .powerBreathing:
                PowerBreathingView(stateMachine: stateMachine)
            case .retention:
                RetentionView(stateMachine: stateMachine)
            case .recovery:
                RecoveryView(stateMachine: stateMachine)
            case .completed:
                PostSessionView(stateMachine: stateMachine, onDismiss: {
                    saveSession()
                    isPresented = false
                })
            }

            Spacer()
        }
        .background(Color(.systemBackground))
    }

    private func saveSession() {
        let session = Session(
            numberOfCycles: config.numberOfCycles,
            breathsPerCycle: config.breathsPerCycle,
            cadence: config.cadence,
            totalDurationSeconds: stateMachine.totalDuration
        )
        if let start = stateMachine.sessionStart {
            session.date = start
        }
        modelContext.insert(session)

        for record in stateMachine.cycleRecords {
            record.session = session
            modelContext.insert(record)
        }

        try? modelContext.save()
    }
}

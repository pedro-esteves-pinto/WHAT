import SwiftData
import SwiftUI

struct SessionContainerView: View {
    let config: SessionConfig
    @Binding var isPresented: Bool
    @State private var stateMachine: SessionStateMachine
    @State private var heartRateManager: HealthKitManager
    @State private var currentBPM: Double?
    @State private var heartRateSamples: [HeartRateSample] = []
    @Environment(\.modelContext) private var modelContext

    init(config: SessionConfig, isPresented: Binding<Bool>) {
        self.config = config
        self._isPresented = isPresented
        self._stateMachine = State(initialValue: SessionStateMachine(config: config))
        self._heartRateManager = State(initialValue: HealthKitManager())
    }

    var body: some View {
        VStack {
            HStack {
                HeartRateDisplay(bpm: currentBPM)
                Spacer()
                Button("End") {
                    stopSession()
                }
                .padding()
            }
            .padding(.horizontal)

            Spacer()

            switch stateMachine.phase {
            case .notStarted:
                Text("Preparing...")
                    .onAppear {
                        startSession()
                    }
            case .powerBreathing:
                PowerBreathingView(stateMachine: stateMachine)
            case .retention:
                RetentionView(stateMachine: stateMachine)
            case .recovery:
                RecoveryView(stateMachine: stateMachine)
            case .completed:
                PostSessionView(stateMachine: stateMachine, heartRateSamples: heartRateSamples, onDismiss: {
                    saveSession()
                    isPresented = false
                })
            }

            Spacer()
        }
        .background(Color(.systemBackground))
    }

    private func startSession() {
        heartRateManager.onHeartRateUpdate = { bpm in
            currentBPM = bpm
        }
        heartRateManager.startMonitoring()
        stateMachine.start()
    }

    private func stopSession() {
        heartRateSamples = heartRateManager.stopMonitoring()
        stateMachine.stop()
    }

    private func saveSession() {
        if heartRateSamples.isEmpty {
            heartRateSamples = heartRateManager.stopMonitoring()
        }

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

        for sample in heartRateSamples {
            sample.session = session
            modelContext.insert(sample)
        }

        try? modelContext.save()
    }
}

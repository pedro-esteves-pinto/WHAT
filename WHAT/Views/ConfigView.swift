import SwiftUI

struct ConfigView: View {
    @Binding var config: SessionConfig

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cycles")
                    .font(.headline)
                Picker("Cycles", selection: $config.numberOfCycles) {
                    ForEach(SessionConfig.cycleOptions, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Breaths per Cycle")
                    .font(.headline)
                Picker("Breaths", selection: $config.breathsPerCycle) {
                    ForEach(SessionConfig.breathOptions, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Cadence (breaths/sec)")
                    .font(.headline)
                Picker("Cadence", selection: $config.cadence) {
                    ForEach(SessionConfig.cadenceOptions, id: \.self) { rate in
                        Text(String(format: "%.1f", rate)).tag(rate)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ConfigView(config: .constant(.default))
}

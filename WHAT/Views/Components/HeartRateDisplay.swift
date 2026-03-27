import SwiftUI

struct HeartRateDisplay: View {
    let bpm: Double?

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
            if let bpm {
                Text("\(Int(bpm))")
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                Text("BPM")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No HR data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack {
        HeartRateDisplay(bpm: 72)
        HeartRateDisplay(bpm: nil)
    }
}

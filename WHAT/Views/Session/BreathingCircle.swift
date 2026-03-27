import SwiftUI

struct BreathingCircle: View {
    let progress: Double

    private var scale: Double {
        // Ease-in-out: 3t² - 2t³
        let eased = progress * progress * (3.0 - 2.0 * progress)
        return 0.3 + 0.7 * eased
    }

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.blue.opacity(0.8), .cyan.opacity(0.4)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
            )
            .scaleEffect(scale)
    }
}

#Preview {
    BreathingCircle(progress: 0.5)
        .frame(width: 200, height: 200)
}

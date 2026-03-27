import SwiftUI

/// Placeholder for Phase 5 — Swift Charts HR visualization
struct HRChartView: View {
    let session: Session

    var body: some View {
        ContentUnavailableView(
            "HR Chart",
            systemImage: "chart.xyaxis.line",
            description: Text("Heart rate chart will be available in a future update.")
        )
    }
}

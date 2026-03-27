import SwiftUI

struct HomeView: View {
    @State private var config = UserDefaultsStore.load()
    @State private var isSessionActive = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text("WHAT")
                    .font(.system(size: 48, weight: .bold, design: .rounded))

                Text("Wim Hof Auto Tracker")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Spacer()

                ConfigView(config: $config)

                Button {
                    UserDefaultsStore.save(config)
                    isSessionActive = true
                } label: {
                    Text("Start Session")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)

                NavigationLink("History") {
                    HistoryListView()
                }
                .padding(.bottom)
            }
            .fullScreenCover(isPresented: $isSessionActive) {
                SessionContainerView(config: config, isPresented: $isSessionActive)
            }
        }
    }
}

#Preview {
    HomeView()
}

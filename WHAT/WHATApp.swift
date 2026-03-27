import SwiftData
import SwiftUI

@main
struct WHATApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: Session.self)
    }
}

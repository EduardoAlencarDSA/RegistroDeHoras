import SwiftUI
import SwiftData

@main
struct RegistrodeHorasApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: WorkEntry.self) // SwiftData local
    }
}

import SwiftUI

@main
struct MoyFitnessPROApp: App {
    @StateObject private var store = WorkoutStore()

    var body: some Scene {
        WindowGroup {
            AppLockView {
                MainTabView()
                    .environmentObject(store)
            }
        }
    }
}

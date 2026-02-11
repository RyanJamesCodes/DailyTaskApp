import SwiftUI

@main
struct DailyTaskTrackerApp: App {
    @StateObject private var viewModel = DailyTaskViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark) // force dark theme
        }
    }
}
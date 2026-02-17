import SwiftUI

@main
struct DailyTaskTrackerApp: App {
    @StateObject private var viewModel = DailyTaskViewModel()
    
    init() {
        // Ask for notification permission and schedule a daily 6am reminder
        NotificationManager.shared.requestAuthorizationAndScheduleDailyReminder()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark) // force dark theme
        }
    }
}
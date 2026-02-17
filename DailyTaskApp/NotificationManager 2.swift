import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorizationAndScheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted, error == nil else { return }
            self.scheduleDailyReminder()
        }
    }
    
    private func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        
        // Replace any existing reminder with the same identifier
        let identifier = "daily_task_reminder"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Plan your day"
        content.body = "Set your tasks for today in Daily Task Tracker."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 6
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
    }
}


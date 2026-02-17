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
            self.scheduleProgressNotifications(percentage: 0)
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
    
    func scheduleProgressNotifications(percentage: Int) {
        let center = UNUserNotificationCenter.current()
        
        let times: [Int] = [8, 12, 16, 20] // 8am, 12pm, 4pm, 8pm
        let identifiers = [
            "daily_task_progress_8",
            "daily_task_progress_12",
            "daily_task_progress_16",
            "daily_task_progress_20"
        ]
        
        // Clear existing progress notifications
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        
        for (index, hour) in times.enumerated() {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let content = UNMutableNotificationContent()
            content.title = "Daily Task Progress"
            content.body = "You're \(percentage)% done with today's tasks in Daily Task Tracker."
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifiers[index], content: content, trigger: trigger)
            
            center.add(request, withCompletionHandler: nil)
        }
    }
}


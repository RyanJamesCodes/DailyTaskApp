import Foundation
import SwiftUI
import Combine

struct DailyTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

@MainActor
final class DailyTaskViewModel: ObservableObject {
    @Published var tasks: [DailyTask] = []
    @Published private(set) var streakCount: Int = 0
    
    private let tasksKey = "daily_tasks"
    private let lastResetDateKey = "last_reset_date"
    private let streakKey = "daily_streak"
    
    init() {
        loadStreak()
        loadTasks()
        resetIfNeeded()
        updateProgressNotifications()
    }
    
    var completionProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
    
    func addTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(DailyTask(title: trimmed))
        saveTasks()
        updateProgressNotifications()
    }
    
    func toggleTask(_ task: DailyTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        saveTasks()
        updateProgressNotifications()
    }
    
    func resetTasks() {
        tasks.removeAll()
        saveTasks()
        saveLastResetDate(Date())
        updateProgressNotifications()
    }
    
    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
        updateProgressNotifications()
    }
    
    // MARK: - Persistence
    
    private func loadStreak() {
        streakCount = UserDefaults.standard.integer(forKey: streakKey)
    }
    
    private func saveStreak() {
        UserDefaults.standard.set(streakCount, forKey: streakKey)
    }
    
    private func loadTasks() {
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([DailyTask].self, from: data) {
            tasks = decoded
        } else {
            // Start with an empty task list on first launch
            tasks = []
        }
    }
    
    private func saveTasks() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(tasks) {
            defaults.set(data, forKey: tasksKey)
        }
    }
    
    private func resetIfNeeded() {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = defaults.object(forKey: lastResetDateKey) as? Date {
            if !calendar.isDate(lastDate, inSameDayAs: today) {
                // A new day has started – update streak based on yesterday's completion
                updateStreakForPreviousDay()
                resetTasks()
            }
        } else {
            // First launch – set last reset to today
            saveLastResetDate(today)
        }
    }
    
    private func saveLastResetDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: lastResetDateKey)
    }
    
    private func updateStreakForPreviousDay() {
        let hadTasks = !tasks.isEmpty
        let allCompleted = hadTasks && tasks.allSatisfy { $0.isCompleted }
        
        if allCompleted {
            streakCount += 1
        } else {
            streakCount = 0
        }
        
        saveStreak()
    }
    
    private func updateProgressNotifications() {
        let percentage = Int(completionProgress * 100)
        NotificationManager.shared.scheduleProgressNotifications(percentage: percentage)
    }
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

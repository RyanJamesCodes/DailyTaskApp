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
    }
    
    func toggleTask(_ task: DailyTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        saveTasks()
    }
    
    func resetTasks() {
        for index in tasks.indices {
            tasks[index].isCompleted = false
        }
        saveTasks()
        saveLastResetDate(Date())
    }
    
    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
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
}
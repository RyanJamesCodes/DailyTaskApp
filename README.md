# Daily Task Tracker (iOS)

A simple, dark-themed daily task tracker for iPhone built with SwiftUI.

You can:
- Add tasks for the current day
- Tap tasks to mark them as complete (they turn green)
- See a progress bar for today’s completion
- Track your daily streak (only increases when **all** tasks are completed)
- Automatically clear all tasks at the start of a new day (local time)
- Swipe to delete tasks you don’t need anymore

---

## Features

- **Dark theme**  
  The app runs in a dark color scheme by default, using green highlights for completed tasks.

- **Daily tasks**  
  - Add tasks via the text field and `+` button.  
  - Tap a task row to toggle completion; completed tasks turn green and get a strikethrough.

- **Progress bar**  
  - Shows the percentage of tasks completed for the current day.

- **Streak tracking**  
  - If you finish **all tasks** for the day, your streak increases by 1 on the next day.
  - If you don’t complete all tasks, the streak resets to 0.
  - Streak is stored locally in `UserDefaults`.

- **Automatic daily reset (midnight)**  
  - On first launch after midnight (local time), the app:
    - Uses yesterday’s task completion to update the streak.
    - Clears all tasks so you can define a fresh list for the new day.

- **Delete tasks**  
  - Swipe left on a task row and tap **Delete** to remove it.

---

## Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Platform**: iOS
- **Persistence**: `UserDefaults` (JSON-encoded tasks and streak count)

---

## Project Structure

- `DailyTaskTrackerApp.swift`  
  App entry point. Sets up `DailyTaskViewModel` and enforces dark mode.

- `ContentView.swift`  
  Main UI:
  - Progress bar and streak display
  - Input row for adding tasks
  - Task list with tap-to-complete and swipe-to-delete

- `TaskViewModel.swift`  
  `ObservableObject` handling:
  - Task list state (`[DailyTask]`)
  - Streak count
  - Add / toggle / delete / reset logic
  - Persistence in `UserDefaults`
  - New-day detection and streak updates

---

## Running the App (Simulator)

1. Open the `.xcodeproj` in Xcode.
2. Select an iOS Simulator (e.g. iPhone 15) from the device picker.
3. Press **Run (▶)**.

---

## Running on a Real Device

1. Connect your iPhone to your Mac.
2. In Xcode, open the project and select the app target.
3. Go to **Signing & Capabilities**:
   - Check **Automatically manage signing**.
   - Select your **Apple ID / Personal Team**.
   - Set a unique **Bundle Identifier** (e.g. `com.yourname.DailyTaskApp`).
4. Choose your iPhone from the device picker.
5. Press **Run (▶)**.

> Note: With a free Apple ID, the app will typically need to be re-installed from Xcode after about 7 days.

---

## Future Ideas

- Notifications/reminders for incomplete tasks
- iCloud sync between devices
- Home screen widgets for quick task and streak view

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: DailyTaskViewModel
    @State private var newTaskTitle: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ProgressView(value: viewModel.completionProgress)
                        .tint(.green)
                    
                    Text(progressLabel)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Streak: \(viewModel.streakCount) day\(viewModel.streakCount == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.15))
                .cornerRadius(12)
                
                // Add task row
                HStack {
                    TextField("Add new task…", text: $newTaskTitle)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color(.systemGray6).opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    Button {
                        viewModel.addTask(title: newTaskTitle)
                        newTaskTitle = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                
                // Task list
                List {
                    ForEach(viewModel.tasks) { task in
                        Button {
                            viewModel.toggleTask(task)
                        } label: {
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                                
                                Text(task.title)
                                    .foregroundColor(task.isCompleted ? .green : .white)
                                    .strikethrough(task.isCompleted, color: .green)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color(.systemGray6).opacity(0.2))
                    }
                    .onDelete(perform: viewModel.deleteTasks)
                }
                .scrollContentBackground(.hidden)
            }
            .padding(.top)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Daily Tasks")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
    
    private var progressLabel: String {
        let percent = Int(viewModel.completionProgress * 100)
        return "\(percent)% complete"
    }
}

#Preview {
    ContentView()
        .environmentObject(DailyTaskViewModel())
        .preferredColorScheme(.dark)
}
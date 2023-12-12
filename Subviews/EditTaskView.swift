//
//  EditTaskView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class EditTaskViewModel : ObservableObject {
    @Published var title: String = ""
    @Published var taskDetails: String = ""
    @Published var dueDate: Date = Date()
    @Published var taskIsComplete: Double = 0
    
    func getCurrentTaskDetails(task: TaskModel) {
        self.title = task.taskTitle
        self.taskDetails = task.details ?? ""
        self.dueDate = task.dueDate ?? Date()
        self.taskIsComplete = task.isComplete
    }
    
    func getTaskDetailsCount () -> Int {
        return self.taskDetails.count
    }
    
    func save (task: TaskItem) {
        guard !self.title.isEmpty else {return}
        let manager = CoreDataPersistence.shared
        let prevFolder = task.folder
        manager.deleteTaskItem(task)
        let taskItem = TaskItem(context: manager.persistentContainer.viewContext)
        taskItem.taskTitle = self.title
        taskItem.details = self.taskDetails
        taskItem.dueDate = self.dueDate
        taskItem.isComplete = self.taskIsComplete
        taskItem.folder = prevFolder
        manager.save()
    }
    
    func saveWithoutDueDate (task: TaskItem) {
        guard !self.title.isEmpty else {return}
        let manager = CoreDataPersistence.shared
        let prevFolder = task.folder
        manager.deleteTaskItem(task)
        let taskItem = TaskItem(context: manager.persistentContainer.viewContext)
        taskItem.taskTitle = self.title
        taskItem.details = self.taskDetails
        taskItem.dueDate = nil
        taskItem.isComplete = task.isComplete
        taskItem.folder = prevFolder
        manager.save()
    }
}

struct EditTaskView: View {
    let task: TaskModel
    @StateObject var viewModel: EditTaskViewModel = EditTaskViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea()
            VStack {
                TextField("Task name", text: $viewModel.title)
                    .frame(width: 300, height: 10)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }.shadow(radius: 5)
                    .padding(.top, 60)
                Spacer()
                Text("Add task details below (optional)")

                TextEditor(text: $viewModel.taskDetails)
                    .frame(width: 300, height: 50)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }

                
                HStack {
                    DatePicker(selection: $viewModel.dueDate, displayedComponents: .date) {
                        Text("Due Date (optional)")
                    }
                }.padding()
                
                Spacer()
                
                    VStack(spacing: 30) {
                        Button(action: {
                            viewModel.save(task: task.task)
                            self.dismiss()
                        }, label: {
                            Text("SAVE Due On: \(viewModel.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                }
                        })
                        
                        Button(action: {
                            viewModel.saveWithoutDueDate(task: task.task)
                            self.dismiss()
                        }, label: {
                            Text("SAVE Without Due Date")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                }
                        })
                    }.shadow(radius: 1)
                    Spacer()
            }
            .onAppear() {
                viewModel.getCurrentTaskDetails(task: task)
            }
        }.preferredColorScheme(.light)
    }
}

struct EditTaskView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let taskItem = TaskItem(context: context)
        taskItem.taskTitle = "Sample Task"
        taskItem.dueDate = Date()
        taskItem.isComplete = 0.0
        taskItem.details = "Sample Details"

        let taskModel = TaskModel(task: taskItem)

        return EditTaskView(task: taskModel)
            .environment(\.managedObjectContext, context)
    }
}


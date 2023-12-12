//
//  TaskForList.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

struct TaskForList: View {
    let task: TaskModel
    @StateObject var viewModel: TasksAndFoldersViewModel
    @State var goToTaskDetails: Bool = false
    @State var goToEditTask: Bool = false
    var callback: ( () -> ()?)?
    var body: some View {
            HStack {
                Text(task.taskTitle)
                    .foregroundStyle(Color.white)
                
                Spacer()
                if task.dueDate != nil {
                    Text((task.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? ""))
                        .foregroundStyle(Color.yellow)
                }
                
                Button(action: {
                    self.goToTaskDetails = true
                    viewModel.seeOptions = false
                }, label: {
                    Image(systemName: "note.text")
                        .foregroundStyle(Color.white, Color.yellow)
                }).buttonStyle(.plain)
                
                    .swipeActions {
                        
                        Button(action: {
                            viewModel.deleteTask(task: task)
                            
                            withAnimation {
                                viewModel.showCheckmark = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                                withAnimation {
                                    viewModel.showCheckmark = false
                                }
                            })
                            
                            callback?()
                        }, label: {
                            Image(systemName: "checkmark.rectangle")
                                .foregroundStyle(Color.white)
                                .bold()
                        }).tint(Color.green)
                    }
                
                    .swipeActions {
                        Button(role: .none) {
                            goToEditTask = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                
            }.preferredColorScheme(.light)
        
            .sheet(isPresented: $goToTaskDetails, onDismiss: {
                callback?()
            }, content: {
                TaskDetailsView(task: task, viewModel: viewModel)
            })
        
        .sheet(isPresented: $goToEditTask, onDismiss: {
            viewModel.getAllTasks()
        }, content: {
            EditTaskView(task: task)
        })
    }
}

struct TaskForList_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let taskItem = TaskItem(context: context)
        taskItem.taskTitle = "Sample Task"
        taskItem.dueDate = Date()
        taskItem.isComplete = 0.0
        taskItem.details = "Sample Details"

        let taskModel = TaskModel(task: taskItem)

        return TaskForList(task: taskModel, viewModel: TasksAndFoldersViewModel())
            .environment(\.managedObjectContext, context)
    }
}

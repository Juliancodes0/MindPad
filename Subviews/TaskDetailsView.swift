//
//  TaskDetailsView.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import SwiftUI

struct TaskDetailsView: View {
    let task: TaskModel
    @State var goToEditTask: Bool = false
    @State var goToFolderOptionsView: Bool = false
    @StateObject var viewModel: TasksAndFoldersViewModel
    @Environment(\.dismiss) private var dismiss
    @State var originalId: String = ""
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)

            VStack(alignment: .leading, spacing: 20) {
                Text(task.taskTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)

                if task.dueDate != nil {
                    TaskDetailRow(title: "Due Date", value: task.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                }
                TaskDetailRow(title: "Details", value: task.details ?? "None")
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        goToFolderOptionsView = true
                    }, label: {
                        HStack {
                            Text(self.task.task.folder?.uniqueId == "Default:08UI:COREDATA26910E_FOLDER033Q:Z[]" ? "Add to folder" : "Folder options")
                                .padding()
                                .foregroundStyle(Color.offWhite)
                            Image(systemName: "folder.fill")
                                .foregroundStyle(Color.white)
                                .padding()
                        }.bold().shadow(radius: 35).background() {
                            RoundedRectangle(cornerRadius: 5)

                        }
                    })
                    Spacer()
                }
                
                Spacer()
            }
            .padding(20)
        }.preferredColorScheme(.light)
            .sheet(isPresented: $goToFolderOptionsView, onDismiss: {
                if task.task.folder?.uniqueId != originalId {
                    self.dismiss()
                }
            }, content: {
                FolderOptionsView(task: task)
            })
            .onAppear() {
                self.originalId = task.task.folder?.uniqueId ?? ""
            }
    }
}

struct TaskDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            Text(value)
                .font(.body)
                .foregroundColor(.black)
        }
    }
}


struct TaskDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let taskItem = TaskItem(context: context)
        taskItem.taskTitle = "Do Some Coding"
        taskItem.dueDate = Date()
        taskItem.isComplete = 0.0
        taskItem.details = "You want to make sure that you are getting enough daily coding in your routine. You know you love Swift!"

        let taskModel = TaskModel(task: taskItem)

        return TaskDetailsView(task: taskModel, viewModel: TasksAndFoldersViewModel())
            .environment(\.managedObjectContext, context)
    }
}


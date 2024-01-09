//
//  SomeFolderWithTasksView.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import SwiftUI

struct SomeFolderWithTasksView: View {
    @StateObject var viewModel: TasksAndFoldersViewModel
    @State var goToAddTaskForSomeFolder: Bool = false
    @Environment(\.dismiss) var dismiss
    var completion: ( () -> ()?)?
    let folder: FolderModel
    var body: some View {
            ZStack {
                Color.lightMintColor.ignoresSafeArea()
                VStack {
                    VStack {
                        HStack {
                            xbutton.padding()
                            Spacer()
                            
                            HStack {
                                if viewModel.showCheckmark == true {
                                    Image(systemName: "checkmark")
                                        .padding(1)
                                        .foregroundStyle(Color.green)
                                        .background {
                                            RoundedRectangle(cornerRadius: 5)
                                                .foregroundStyle(Color.black)
                                        }
                                }
                            }.padding()
                            
                        }
                    }
                    HStack {
                        Text(folder.title).padding(.leading)
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    if viewModel.getTaskCountForFolder(folder: folder) > 0 {
                        switch UserManager.shared.sortsTasksBy {
                        case .title:
                            taskListViewSortedByTitle

                        case .dueDate:
                            tasksSortedByDueDate
                        }
                    }

                    if viewModel.getTaskCountForFolder(folder: self.folder) == 0 {
                        List {
                            Button(action: {
                                goToAddTaskForSomeFolder = true
                            }, label: {
                                Text("Add Task")
                                    .foregroundStyle(Color.blue)
                                    .bold()
                            }).listRowBackground(Color.black)
                        }.listStyle(.plain)
                    }
                    HStack {
                        plusButton
                            .padding()
                    }
                }
            }
        .preferredColorScheme(.light)
        .onAppear() {
            viewModel.getAllTasks()
        }
        .sheet(isPresented: $goToAddTaskForSomeFolder, onDismiss: {
            viewModel.getAllTasks()
            completion?()
        }, content: {
            AddTaskInSpecficFolderView(folder: folder)
        })
    }
}

extension SomeFolderWithTasksView {
    var tasksSortedByDueDate: some View {
        List {
            ForEach(viewModel.tasks.sorted(by: {$0.dueDate ?? Date() < $1.dueDate ?? Date()}), id: \.id) { task in
                if task.task.folder == self.folder.folder {
                    TaskForList(task: task, viewModel: viewModel, callback: {
                        viewModel.getAllTasks()
                    }) .listRowBackground(Color.black)
                }
            }
        }.listStyle(.plain)
    }
    
    var taskListViewSortedByTitle: some View {
        List {
            ForEach(viewModel.tasks.sorted(by: {$0.taskTitle < $1.taskTitle}), id: \.id) { task in
                if task.task.folder == self.folder.folder {
                    TaskForList(task: task, viewModel: viewModel, callback: {
                        viewModel.getAllTasks()
                    }) .listRowBackground(Color.black)
                }
            }
        }.listStyle(.plain)
    }
}

extension SomeFolderWithTasksView {
    var plusButton: some View {
        HStack {
            Spacer()
            Button(action: {
                goToAddTaskForSomeFolder = true
            }, label: {
                Image(systemName: "plus")
                    .padding()
                    .foregroundStyle(Color.white)
                    .background() {
                        Circle()
                            .foregroundStyle(Color.black)
                        
                    }
            })
        }
    }
    
    var xbutton: some View {
        Button(action: {
            self.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .foregroundStyle(Color.black)
        })
    }
}

struct SomeFolderWithTasksViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let folder = Folder(context: context)
        folder.title = "Sample Folder"

        let folderModel = FolderModel(folder: folder)

        return SomeFolderWithTasksView(viewModel: TasksAndFoldersViewModel(), folder: folderModel)
            .environment(\.managedObjectContext, context)
    }
}

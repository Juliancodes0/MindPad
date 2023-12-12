//
//  ContentView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class TasksAndFoldersViewModel: ObservableObject {
    @Published var goToAddTask: Bool = false
    @Published var goToCreateFolder: Bool = false
    @Published var goToCreateStickyView: Bool = false
    @Published var goToAllNotes: Bool = false
    @Published var goToMenuView: Bool = false
    @Published var seeOptions: Bool = false
    @Published var tasks: [TaskModel] = []
    @Published var folders: [FolderModel] = []
    @Published var showCheckmark: Bool = false
    
    let defaultFolderid: String = "Default:08UI:COREDATA26910E_FOLDER033Q:Z[]"
    
    func getAllTasks () {
        let tasks = CoreDataPersistence.shared.getAllTasks()
        DispatchQueue.main.async {
            self.tasks = tasks.map(TaskModel.init)
        }
    }
    
    func getAllFolders () {
        let folders = CoreDataPersistence.shared.getAllFolders()
        DispatchQueue.main.async {
            self.folders = folders.map(FolderModel.init)
        }
    }
    
    func getTaskCount () -> Int {
        var count: Int = 0
        for _ in self.tasks {
            count += 1
        }
        return count
    }
    
    func getFolderCount () -> Int {
        var count: Int = 0
        for _ in self.folders {
            count += 1
        }
        return count
    }
    
    func deleteTask(task: TaskModel) {
        guard let task = CoreDataPersistence.shared.getTaskById(task.id) else {return}
        CoreDataPersistence.shared.deleteTaskItem(task)
        self.getAllTasks()
    }
    
    func deleteFolder(folder: FolderModel) {
        guard let folderToDelete = CoreDataPersistence.shared.getFolderById(folder.id) else {return}
        
        if let taskItems = folderToDelete.taskItems as? Set<TaskItem> {
            taskItems.forEach { taskItem in
                taskItem.folder = CoreDataPersistence.shared.getAllFolders().first(where: { $0.uniqueId == defaultFolderid})
            }
        }

        
        CoreDataPersistence.shared.deleteFolder(folderToDelete)
        self.getAllFolders()
    }
    
    func getTaskCountForFolder(folder: FolderModel) -> Int {
        var count: Int = 0
        for taskItem in self.tasks {
            if taskItem.task.folder == folder.folder {
                count += 1
            }
        }
        return count
    }
}

struct TasksAndFolders: View {
    @StateObject var viewModel: TasksAndFoldersViewModel = TasksAndFoldersViewModel()
    @State var showTasksAll: Bool = true
    @State var showTasksText: Bool = true
    var body: some View {
        ZStack {
            ZStack {
                Color.lightMintColor.ignoresSafeArea()
                VStack {
                    HStack {
                        linesTab.padding()
                        Spacer()
                        HStack {
                            if viewModel.showCheckmark == true {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.green)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundStyle(Color.black)
                                    }
                            }
                        }.padding()
                    }
                    Spacer()
                    
                    HStack {
                        Text(showTasksText ? "Tasks" : "Folders").padding()
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    
                    if showTasksAll && viewModel.getTaskCount() > 0 {
                        switch UserManager.shared.sortsTasksBy {
                        case .title:
                            taskListViewSortedByTitle
                                .transition(.move(edge: .leading))

                        case .dueDate:
                            tasksSortedByDueDate
                                .transition(.move(edge: .leading))
                        }
                    }
                    
                    if showTasksAll && viewModel.getTaskCount() == 0 {
                        addTaskWhenNoTasks
                            .transition(.move(edge: .leading))
                    }
                        
                        if !showTasksAll {
                            foldersListView
                                .transition(.move(edge: .trailing))
                        }
                        
                        if viewModel.seeOptions {
                            VStack {
                                HStack {
                                    Spacer()
                                    optionsView
                                }
                                .offset(x: -50, y: -100)
                            }
                        }
                    
                        HStack {
                            Spacer()
                            VStack {
                                if !viewModel.seeOptions {
                                    TransitionArrowButton {
                                        withAnimation(.spring()) {
                                            showTasksAll.toggle()
                                        }
                                        if showTasksAll {
                                            showTasksText = true
                                        } else if !showTasksAll {
                                            showTasksText = false
                                        }
                                    }
                                    .rotationEffect(Angle(degrees: showTasksAll ? 0 : 180))
                                    .background() {
                                        Circle()
                                            .frame(width: 40, height: 40)
                                            .shadow(color: .black, radius: 2)
                                    }
                                    .padding()
                                    
                                    plusButton
                                        .padding()
                                    notesButtonView
                            }
                        }
                    }
                }
            }
            .preferredColorScheme(.light)
            .sheet(isPresented: $viewModel.goToAddTask, onDismiss: {
                viewModel.getAllFolders()
                viewModel.getAllTasks()
                viewModel.seeOptions = false
            }, content: {
                AddTaskView()
            })
            .sheet(isPresented: $viewModel.goToCreateFolder, onDismiss: {
                viewModel.getAllFolders()
            }, content: {
                AddFolderView()
            })
            .fullScreenCover(isPresented: $viewModel.goToCreateStickyView, onDismiss: {
            }, content: {
                CreateNoteView()
            })
            .fullScreenCover(isPresented: $viewModel.goToMenuView, onDismiss: {
                viewModel.getAllFolders()
                viewModel.getAllTasks()
                UserManager.shared.getDecodedTaskSortingOption()
            }, content: {
                SettingsMenuView()
            })
            .fullScreenCover(isPresented: $viewModel.goToAllNotes, onDismiss: {}, content: {
                AllNotesView()
            })
            .onAppear() {
                viewModel.getAllFolders()
                viewModel.getAllTasks()
                UserManager.shared.getDecodedTaskSortingOption()
            }
        }
    }
}

extension TasksAndFolders {
    var plusButton: some View {
            Button {
                withAnimation {
                    viewModel.seeOptions.toggle()
                }
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(Color.white)
                    .padding()
                    .background() {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color.black)
                            .frame(width: 40, height: 40)
                            .shadow(color: .black, radius: 2)
                    }
            }
    }
    
    var linesTab: some View {
        Button(action: {
            viewModel.goToMenuView = true
        }, label: {
            Image(systemName: "line.3.horizontal")
                .resizable()
                .frame(width: 22, height: 14)
                .bold()
                .foregroundStyle(Color.black)
        })
    }
    
    var foldersListView: some View {
        VStack {
            if viewModel.getFolderCount() > 1 {
                List {
                    ForEach(viewModel.folders.filter({$0.uniqueId != viewModel.defaultFolderid}).sorted(by: {$0.title < $1.title}), id: \.id) { folder in
                        Button(action: {
                        }, label: {
                            FolderView(folder: folder, viewModel: viewModel)
                        }).listRowBackground(Color.black)
                    }
                }
                .listStyle(.plain)
                .listRowSpacing(1)
            } else if viewModel.getFolderCount() == 1 {
                List {
                    Button(action: {
                        viewModel.goToCreateFolder = true
                    }, label: {
                        Text("Create Folder")
                            .foregroundStyle(Color.blue)
                            .bold()
                    }).listRowBackground(Color.black)
                }.listStyle(.plain)
            }
        }
    }
    
    var taskListViewSortedByTitle: some View {
            List {
                ForEach(viewModel.tasks.sorted(by: {$0.taskTitle < $1.taskTitle}), id: \.self) { task in
                    TaskForList(task: task, viewModel: viewModel) {
                        viewModel.getAllTasks()
                    }
                }.listRowBackground(Color.black)
            }.listStyle(.plain)
                .ignoresSafeArea(.all)
    }
    
    var tasksSortedByDueDate: some View {
        List {
            ForEach(viewModel.tasks.sorted(by: {$0.dueDate ?? Date() < $1.dueDate ?? Date()}), id: \.self) { task in
                TaskForList(task: task, viewModel: viewModel)  {
                    viewModel.getAllTasks()
                }
            }.listRowBackground(Color.black)
        }.listStyle(.plain)
            .ignoresSafeArea(.all)
    }
    
    var addTaskWhenNoTasks: some View {
        List {
            Button(action: {
                viewModel.goToAddTask = true
            }, label: {
                Text("Add Task")
                    .foregroundStyle(Color.blue)
                    .bold()
            }).listRowBackground(Color.black)
        }.listStyle(.plain)
    }
    
    var notesButtonView: some View {
        Button(action: {
            viewModel.goToAllNotes = true
        }, label: {
            Image(systemName: "note.text")
                .foregroundStyle(Color.yellow, Color.white)
                .background() {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 50, height: 40)
                        .foregroundStyle(Color.black)
                        .shadow(color: .white, radius: 6)
                }
            
        }).padding()
    }
    
    var optionsView: some View {
        
        VStack(spacing: 20) {
            Button(action: {
                viewModel.goToAddTask = true
                viewModel.seeOptions = false
            }, label: {
                HStack {
                    Image(systemName: "list.bullet.circle")
                    Text("Add Task")
                }
            })
            Button(action: {
                viewModel.goToCreateStickyView = true
                viewModel.seeOptions = false
            }, label: {
                HStack {
                    Image(systemName: "note.text.badge.plus")
                    Text("New Note")
                }
            })
            
            Button(action: {
                viewModel.goToCreateFolder = true
                viewModel.seeOptions = false
            }, label: {
                HStack {
                    Image(systemName: "folder.badge.plus")
                    Text("Create Folder")
                }
            })
            
            Button(action: {
                viewModel.seeOptions = false
            }, label: {
                Text("CLOSE MENU ")
                    .foregroundStyle(Color.blue)
                    .bold()
            })
    }
        .foregroundStyle(Color.white)
        .background() {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(Color.black)
                .frame(width: 190, height: 200)
        }
        
        .padding()
    }
    
}

struct TaskViewMain_Tabs_Previews: PreviewProvider {
    static var previews: some View {
        TasksAndFolders()
    }
}

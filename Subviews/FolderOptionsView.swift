//
//  FolderOptionsView.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import SwiftUI

class FolderOptionsViewModel: ObservableObject {
    @Published var folders: [FolderModel] = []
    @Published var showAddedText: Bool = false
    
    init () {
        self.getAllFolders()
    }
    
    func moveTaskToFolder(task: TaskModel, folder: FolderModel) {
        print("Current task.folder = \(task.task.folder?.title ?? "")")
        print(task.taskTitle)
        task.task.folder = folder.folder
        CoreDataPersistence.shared.save()
    } //seems issue is that wrong task is being selected

    func getAllFolders () {
        let folders = CoreDataPersistence.shared.getAllFolders()
        DispatchQueue.main.async {
            self.folders = folders.map(FolderModel.init)
        }
    }
    
    func getFolderCount () -> Int {
        return self.folders.count
    }
}

struct FolderOptionsView: View {
    let task: TaskModel
    @StateObject var viewModel: FolderOptionsViewModel = FolderOptionsViewModel()
    @Environment(\.dismiss) private var dismiss
    let defaultFolderid: String = "Default:08UI:COREDATA26910E_FOLDER033Q:Z[]"
    @State var idDidChange: Bool = false
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea()
            if viewModel.getFolderCount() > 0 {
                VStack {
                    if viewModel.showAddedText {
                        Spacer()
                        Text("Added")
                            .padding()
                            .foregroundStyle(Color.green)
                            .background() {
                                RoundedRectangle(cornerRadius: 5)
                            }
                    }
                    Spacer()
                    
                    List {
                        ForEach(viewModel.folders.filter({$0.uniqueId != self.defaultFolderid}).sorted(by: {$0.title < $1.title}), id: \.id) { folder in
                            Button(action: {
                                idDidChange = true
                                viewModel.moveTaskToFolder(task: self.task, folder: folder)
                                withAnimation {
                                    viewModel.showAddedText = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                                    self.dismiss()
                                })
                            }, label: {
                                HStack {
                                    Image(systemName: "folder.circle")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(Color.blue, Color.yellow)
                                    Text(folder.title)
                                        .font(.headline)
                                        .foregroundStyle(Color.white)
                                        .bold()
                                    Spacer()
                                    Image(systemName: "plus.rectangle.on.folder.fill")
                                        .foregroundStyle(Color.blue)
                                }
                            }).listRowBackground(Color.black)
                        }
                    }.listStyle(.plain)
                        .listRowSpacing(0.4)
                        .opacity(viewModel.showAddedText ? 0.5 : 1)
                    
                    if task.task.folder?.uniqueId != self.defaultFolderid && viewModel.getFolderCount() > 1 && idDidChange == false {
                        VStack {
                            Spacer()
                            Spacer()
                            Button(action: {
                                task.task.folder = CoreDataPersistence.shared.getAllFolders().first(where: {$0.uniqueId == self.defaultFolderid})
                                CoreDataPersistence.shared.save()
                                self.dismiss()
                            }, label: {
                                Text("Remove task from folder")
                                    .bold()
                                    .padding()
                                    .background() {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundStyle(Color.offWhite)
                                            .frame(height: 35)
                                    }
                            })
                            Spacer()
                        }
                    }
                    
                }
            }
            if viewModel.getFolderCount() == 1 {
                   VStack {
                       Text("No folders to display")
                           .font(.headline)
                           .foregroundStyle(Color.offWhite)
                       Spacer()
                }
            }
        }.preferredColorScheme(.light)
    }
}

struct FolderOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let taskItem = TaskItem(context: context)
        taskItem.taskTitle = "Shop"
        taskItem.dueDate = Date()
        taskItem.isComplete = 0
        taskItem.details = "Tofu, Fruit, Veggies"
        let taskModel = TaskModel(task: taskItem)
        
        return FolderOptionsView(task: taskModel)
            .environment(\.managedObjectContext, context)
    }
}

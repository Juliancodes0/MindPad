//
//  AddTaskInSpecficFolderView.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import SwiftUI

class AddTaskInSpecficFolderViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var date: Date = Date()
    @Published var taskDetails: String = ""
    @Published var dueDate: Date = Date()
    
    func saveWithDueDate (_ completion: (() -> Void)? = nil, folder: FolderModel) {
        guard self.title != "" else {return}
        let manager = CoreDataPersistence.shared
        let task = TaskItem(context: manager.persistentContainer.viewContext)
        task.taskTitle = title
        if self.taskDetails != "" {
            task.details = self.taskDetails
        } else {
            task.details = nil
        }
        task.dueDate = dueDate
        task.folder = folder.folder
        manager.save()
        completion?()
    }
    
    func saveWithoutDueDate (_ completion: (() -> ())? = nil, folder: FolderModel) {
        guard self.title != "" else {return}
        let manager = CoreDataPersistence.shared
        let task = TaskItem(context: manager.persistentContainer.viewContext)
        task.taskTitle = title
        if self.taskDetails != "" {
            task.details = self.taskDetails
        } else {
            task.details = nil
        }
        task.dueDate = nil
        task.folder = folder.folder
        manager.save()
        completion?()
    }
}

struct AddTaskInSpecficFolderView: View {
    let folder: FolderModel
    @StateObject var viewModel: AddTaskInSpecficFolderViewModel = AddTaskInSpecficFolderViewModel()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea()
            VStack {
                
                HStack {
                    Text(folder.title).padding(.leading)
                        .font(.title)
                        .bold()
                    Spacer()
                }
                
                TextField("Task name", text: $viewModel.title)
                    .frame(width: 300, height: 10)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 60)
                
                Spacer()
                Text("Add details below (optional)")
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
                            viewModel.saveWithDueDate({
                                dismiss()
                            }, folder: self.folder)
                        }, label: {
                            Text("SAVE Due On: \(viewModel.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                }
                        })
                        
                        Button(action: {
                            viewModel.saveWithoutDueDate({
                                dismiss()
                            }, folder: self.folder)
                        }, label: {
                            Text("SAVE Without Due Date")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                }
                        })
                    }
                
                    Spacer()
            }
        }
        .preferredColorScheme(.light)
    }
}


struct AddTaskInSpecficFolderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let folder = Folder(context: context)
        folder.title = "Sample Folder"
        let folderModel = FolderModel(folder: folder)
        
      return  AddTaskInSpecficFolderView(folder: folderModel)
            .environment(\.managedObjectContext, context)
    }
}

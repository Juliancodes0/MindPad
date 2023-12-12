//
//  AddTaskView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class AddTaskViewModel : ObservableObject {
    @Published var title: String = ""
    @Published var date: Date = Date()
    @Published var taskDetails: String = ""
    @Published var dueDate: Date = Date()
    let defaultFolderId: String = "Default:08UI:COREDATA26910E_FOLDER033Q:Z[]"
    
    func saveWithDueDate (_ completion: (() -> Void)? = nil ) {
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
        task.folder = manager.getAllFolders().first(where: {$0.uniqueId == defaultFolderId})
        manager.save()
        completion?()
    }
    
    func saveWithoutDueDate (_ completion: (() -> ())? = nil) {
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
        task.folder = manager.getAllFolders().first(where: {$0.uniqueId == defaultFolderId})
        manager.save()
        completion?()
    }
}

struct AddTaskView: View {
    @StateObject var vm: AddTaskViewModel = AddTaskViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea()
            VStack {
                TextField("Task name", text: $vm.title)
                    .frame(width: 300, height: 10)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 60)
                    .shadow(radius: 5)

                Spacer()
                Text("Add details below (optional)")
                TextEditor(text: $vm.taskDetails)
                    .frame(width: 300, height: 50)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }
                
                
                HStack {
                    DatePicker(selection: $vm.dueDate, displayedComponents: .date) {
                        Text("Due Date (optional)")
                    }
                }.padding()
                
                Spacer()
                
                    VStack(spacing: 30) {
                        Button(action: {
                            vm.saveWithDueDate({
                                dismiss()
                            })
                        }, label: {
                            Text("SAVE Due On: \(vm.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                }
                        })
                        
                        Button(action: {
                            vm.saveWithoutDueDate({
                                dismiss()
                            })
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
        }.preferredColorScheme(.light)
    }
}


struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}

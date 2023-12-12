//
//  EditFolderNameView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class EditFolderNameViewModel : ObservableObject {
    @Published var title: String = ""
    @Published var showError: Bool = false
    @Published var shakeText: Bool = false
    
    func saveEditedFolder (folder: Folder, completion: ( ()->())) {
        guard !self.title.isEmpty else {
            self.showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.showError = false
            })
            return
        }
        let manager = CoreDataPersistence.shared
        folder.title = self.title
        manager.save()
        completion()
    } /*
       Saves edited folder without deleted the previous folder. Simply renames the title.
       */
    
    func getFolderInfo(folder: FolderModel) {
        self.title = folder.title
    }
}

struct EditFolderNameView: View {
    @StateObject var viewModel: EditFolderNameViewModel = EditFolderNameViewModel()
    @Environment(\.dismiss) private var dismiss
    let folder: FolderModel
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)
            VStack {
                
                if viewModel.showError {
                    VStack {
                        Text("Folder must have a name")
                            .padding()
                            .bold()
                            .foregroundStyle(Color.white)
                            .background() {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 240, height: 40)
                            }
                    }.padding(.bottom, 20)
                        .onAppear() {
                            viewModel.shakeText = true
                        }
                        .shake($viewModel.shakeText)
                }
                
                
        
                TextField("Folder name", text: $viewModel.title)
                    .frame(width: 300, height: 10)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }
                
                
                Button(action: {
                    viewModel.saveEditedFolder(folder: folder.folder, completion: {
                        self.dismiss()
                    })
                }, label: {
                    Text("Save")
                        .bold()
                        .padding()
                        .foregroundStyle(Color.white)
                        .background() {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(Color.blue)
                                .frame(width: 50, height: 35)
                        }
                })
            }
        }.preferredColorScheme(.light)
            .onAppear() {
                viewModel.getFolderInfo(folder: folder)
            }
    }
}

struct EditFolderNameView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let folder = Folder(context: context)
        folder.title = "Today"
        let folderModel = FolderModel(folder: folder)
        return EditFolderNameView(folder: folderModel)            .environment(\.managedObjectContext, context)
    }
}


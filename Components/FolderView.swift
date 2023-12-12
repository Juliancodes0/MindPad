//
//  FolderView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

struct FolderView: View {
    let folder: FolderModel
    @StateObject var viewModel: TasksAndFoldersViewModel
    @State var goToSomeFolderWithTasksView: Bool = false
    @State var goToEditFolder: Bool = false
    var completion: ( () -> ()?)?
    var body: some View {
        
        Button(action: {
            self.goToSomeFolderWithTasksView = true
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
            }
        })
        
        .swipeActions(edge: .trailing, content: {
            
            Button {
                goToEditFolder = true
            } label: {
                Image(systemName: "pencil")
            }
            
            Button(role: .destructive) {
                viewModel.deleteFolder(folder: folder)
            } label: {
                Text("DELETE")
            }
        })
        
        .fullScreenCover(isPresented: $goToSomeFolderWithTasksView, onDismiss: {
            completion?()
        }, content: {
            SomeFolderWithTasksView(viewModel: viewModel, folder: folder)
        })
        .sheet(isPresented: self.$goToEditFolder, onDismiss: {
            viewModel.getAllFolders()
        }, content: {
            EditFolderNameView(folder: folder)
        })
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let folder = Folder(context: context)
        folder.title = "Sample Task"
        let folderModel = FolderModel(folder: folder)

        return FolderView(folder: folderModel, viewModel: TasksAndFoldersViewModel())
            .environment(\.managedObjectContext, context)
    }
}

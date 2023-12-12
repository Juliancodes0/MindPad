//
//  CreateNoteView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class CreateNoteViewModel : ObservableObject {
    @Published var lastEditedDate: Date = Date()
    @Published var noteTitle: String = ""
    @Published var noteText: String = ""
    
    func save () {
        guard !self.noteTitle.isEmpty else {
            return
        }
        let manager = CoreDataPersistence.shared
        let note = Note(context: manager.persistentContainer.viewContext)
        note.lastEditedDate = self.lastEditedDate
        note.note = self.noteText
        note.title = self.noteTitle
        manager.save()
    }
}

struct CreateNoteView : View {
    @StateObject var viewModel: CreateNoteViewModel = CreateNoteViewModel()
    @Environment (\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.yellow.ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: {
                            self.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.black)
                    }).padding(10)
                    Spacer()
                    
                    Button(action: {
                        viewModel.save()
                        dismiss()
                    }, label: {
                        Text("SAVE")
                            .bold()
                            .foregroundStyle(Color.blue)
                    }).padding(10)
                }
                
                Text("Create note")

                TextField("Title", text: $viewModel.noteTitle)
                    .frame(width: 300, height: 10)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }
                
                    .foregroundStyle(Color.black)
                TextEditor(text: $viewModel.noteText)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(Color.white)
                    }
            }
        }.preferredColorScheme(.light)
    }
}


struct CreateNoteView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNoteView()
    }
}

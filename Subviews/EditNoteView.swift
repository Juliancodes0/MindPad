//
//  EditNoteView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class EditNoteViewModel : ObservableObject {
    @Published var lastEditedDate: Date = Date()
    @Published var noteTitle: String = ""
    @Published var noteText: String = ""

    func getDataForNote (note: NoteModel) {
        self.lastEditedDate = Date()
        self.noteTitle = note.title
        self.noteText = note.noteText
    }
    
    func save (note: Note) {
        guard !self.noteTitle.isEmpty else {return}
        let manager = CoreDataPersistence.shared
        manager.deleteNote(note)
        let editedNote = Note(context: manager.persistentContainer.viewContext)
        editedNote.title = self.noteTitle
        editedNote.note = self.noteText
        editedNote.lastEditedDate = Date()
        manager.save()
    }
}

struct EditNoteView: View {
    let note: NoteModel
    @StateObject var viewModel: EditNoteViewModel = EditNoteViewModel()
    @Environment (\.dismiss) private var dismiss
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
                            viewModel.save(note: note.note)
                        dismiss()
                    }, label: {
                        Text("DONE")
                            .bold()
                            .foregroundStyle(Color.blue)
                    }).padding(10)
                }
                

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
        .onAppear() {
            viewModel.getDataForNote(note: note)
        }
    }
}

struct EditNoteView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataPersistence.shared.persistentContainer.viewContext
        let note = Note(context: context)
        note.title = "My Note Title"
        note.lastEditedDate = Date()
        note.note = "Apples, Oranges, Coffee, Bread, Eggs, Coffee Creamer, Fruit Cups"
        let noteModel = NoteModel(note: note)
        return EditNoteView(note: noteModel)
            .environment(\.managedObjectContext, context)
    }
}

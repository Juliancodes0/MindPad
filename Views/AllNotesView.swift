//
//  AllNotesView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class AllNotesViewModel : ObservableObject {
    
    let user = UserManager.shared

    @Published var notes: [NoteModel] = []

    @Published var userHasPasscode: Bool = false
    @Published var notesUnlocked: Bool = false
    @Published var passcodeEntryAttempt: String = ""
    @Published var showWrongPasscode: Bool = false
    
    func getAllNotes () {
        let notes = CoreDataPersistence.shared.getAllNotes()
        DispatchQueue.main.async {
            self.notes = notes.map(NoteModel.init)
        }
    }
    
    func getNoteCount () -> Int {
        var count: Int = 0
        for _ in self.notes {
            count += 1
        }
        return count
    }
    
    func deleteNote(note: NoteModel) {
         let note = CoreDataPersistence.shared.getNoteById(note.id)
        if let note {
            CoreDataPersistence.shared.deleteNote(note)
            self.getAllNotes()
        }
    }
    
    func getPasscodeStatus () {
        self.userHasPasscode = user.getUserHasPasscodeStatus()
    }
    
    @discardableResult
    func testPasscode () -> Bool {
        user.getNotesPasscode()
        if self.passcodeEntryAttempt == user.notePasscode {
            self.notesUnlocked = true
            return true
        } else {
            self.notesUnlocked = false
            return false
        }
    }
    
    func startDeletingText<T>(for keyPath: WritableKeyPath<AllNotesViewModel, T>) {
       guard var mutableSelf = self as? AllNotesViewModel,
             let originalValue = mutableSelf[keyPath: keyPath] as? String,
             !originalValue.isEmpty
       else {
           return
       }

       var stringValue = originalValue
       Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
           if !stringValue.isEmpty {
               stringValue.removeLast()
               mutableSelf[keyPath: keyPath] = stringValue as! T
           } else {
               timer.invalidate()
           }
       }
   }
}

struct AllNotesView: View {
    @StateObject var viewModel: AllNotesViewModel = AllNotesViewModel()
    @Environment (\.dismiss) private var dismiss
    @State var goToCreateNote: Bool = false
    @State var shake: Bool = false
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)
            
            if viewModel.userHasPasscode == false {
                notesUnlocked
            }
            if viewModel.notesUnlocked {
                notesUnlocked
            } else if viewModel.userHasPasscode && !viewModel.notesUnlocked {
                notesLocked
            }
            
            
        }.preferredColorScheme(.light)
        .onAppear() {
            viewModel.getAllNotes()
            viewModel.getPasscodeStatus()
            UserManager.shared.getDecodedNoteSortingOption()
        }
        .fullScreenCover(isPresented: $goToCreateNote, onDismiss: {viewModel.getAllNotes()}, content: {
            CreateNoteView()
        })
    }
}


extension AllNotesView {
    var notesUnlocked: some View {
        VStack {
            HStack {
                Button(action: {
                    self.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.black)
                }).padding()
                Spacer()
            }
            if viewModel.getNoteCount() > 0 {
                switch UserManager.shared.sortNotesBy {
                case .creationDate:
                    notesListSortedByCreation
                case .title:
                    notesListSortedByTitle
                }
            } else {
                List {
                    Button(action: {
                        self.goToCreateNote = true
                    }, label: {
                        Text("Create Note")
                            .bold()
                            .foregroundStyle(Color.blue)
                    }).listRowBackground(Color.black)
                }.listStyle(.plain)
            }
            HStack {
                Spacer()
                Button(action: {
                    goToCreateNote = true
                }, label: {
                    Image(systemName: "plus")
                        .padding()
                        .bold()
                        .foregroundStyle(Color.white)
                        .background() {
                            Circle()
                                .fill(Color.black)
                        }
                })
            }.padding()
        }
    }
    
    var notesLocked: some View {
            VStack {
                HStack {
                    Button(action: {
                        self.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.black)
                    }).padding()
                    Spacer()
                }.padding()
                Text("Enter Passcode")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
                if viewModel.showWrongPasscode {
                    Text("WRONG PASSCODE")
                        .foregroundColor(.black)
                        .bold()
                        .padding()
                }
                TextBox(text: $viewModel.passcodeEntryAttempt)
                    .shake($shake)
                CustomKeyboard(text: $viewModel.passcodeEntryAttempt, completion: {
                    guard viewModel.testPasscode() == true else {
                        withAnimation {
                            viewModel.showWrongPasscode = true
                            shake = true
                            viewModel.startDeletingText(for: \.passcodeEntryAttempt)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                            viewModel.showWrongPasscode = false
                        })
                        return
                    }
                })
            }
        .preferredColorScheme(.light)
    }
}

extension AllNotesView {
    var notesListSortedByCreation: some View {
        List {
            ForEach(viewModel.notes.sorted(by: {$0.creationDate > $1.creationDate}), id: \.id) { note in
                NotePadView(note: note, viewModel: viewModel)
            }
        }.listStyle(.plain)
    }
    
    var notesListSortedByTitle: some View {
        List {
            ForEach(viewModel.notes.sorted(by: {$0.title < $1.title}), id: \.id) { note in
                NotePadView(note: note, viewModel: viewModel)
            }
        }.listStyle(.plain)
    }
}

struct AllNotesView_Previews: PreviewProvider {
    static var previews: some View {
        AllNotesView()
    }
}

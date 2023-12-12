//
//  NotePadView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

struct NotePadView: View {
    let note: NoteModel
    @State var goToEditNote: Bool = false
    @StateObject var viewModel: AllNotesViewModel
    var body: some View {
        HStack {
            Button(action: {
                goToEditNote = true
            }, label: {
                VStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.yellow)
                        .overlay {
                            HStack {
                                Text(note.title)
                                    .padding()
                                Spacer()
                                Text(note.creationDate.formatted(date: .abbreviated, time: .omitted))
                                    .padding()
                                    .foregroundStyle(Color.gray)
                                    .opacity(0.8)
                            }
                        }
                }
            })
            .swipeActions {
                Button(role: .destructive) {
                    viewModel.deleteNote(note: note)
                    viewModel.getAllNotes()
                } label: {
                    Text("DELETE")
                }
            }
        }
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $goToEditNote, onDismiss: {
            viewModel.getAllNotes()
        }, content: {
            EditNoteView(note: note)
        })
    }
}

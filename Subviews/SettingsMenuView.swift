//
//  SettingsMenuView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

class SettingsMenuViewModel: ObservableObject {
    @Published var sortNoteByTitle: Bool = false
    @Published var sortNoteByCreationDate: Bool = false
    @Published var sortTaskByTitle: Bool = false
    @Published var sortTaskByDueDate: Bool = false
    @Published var changesMade: Bool = false
    @Published var goToLockNotes: Bool = false
    @Published var goToRemovePasscode: Bool = false
    @Published var goToResetPasscode: Bool = false
    @Published var customRedSelected: Bool = false
    @Published var lightMintSelected: Bool = false
    
    func save (_ completion: () -> ()) {
        if sortNoteByTitle {
            UserManager.shared.saveNoteSortingOption(.title)
        }
        if sortNoteByCreationDate {
            UserManager.shared.saveNoteSortingOption(.creationDate)
        }
        if sortTaskByTitle {
            UserManager.shared.saveTaskSortingOption(.title)
        }
        if sortTaskByDueDate {
            UserManager.shared.saveTaskSortingOption(.dueDate)
        }
        completion()
    }
    
    func sortNotesByTitle () {
        withAnimation {
            self.sortNoteByTitle = true
            self.sortNoteByCreationDate = false
            changesMade = true
        }
    }
    
    func sortNotesByCreationDate () {
        withAnimation {
            self.sortNoteByTitle = false
            self.sortNoteByCreationDate = true
            changesMade = true
        }
    }
    
    func sortTasksByDueDate () {
        withAnimation {
            self.sortTaskByTitle = false
            self.sortTaskByDueDate = true
            changesMade = true
        }
    }
    
    func sortTasksByTitle () {
        withAnimation {
            self.sortTaskByTitle = true
            self.sortTaskByDueDate = false
            changesMade = true
        }
    }
    
    func removeLock () {
        let user = UserManager.shared
        user.removePasscode()
    }
    
    func userHasPasscode () -> Bool {
        let user = UserManager.shared
        return user.getUserHasPasscodeStatus()
    }
}


struct SettingsMenuView: View {
    @StateObject var viewModel: SettingsMenuViewModel = SettingsMenuViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.lightMintColor.edgesIgnoringSafeArea(.all).opacity(0.77)
                VStack {
                    VStack {
                        HStack {
                            xButton
                            Spacer()
                        }.padding()
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 100) {
                                sortNotesByOptions
                                sortTasksByOptions
                                setPasscodeOption
                            }
                            
                            Spacer()
                        }
                        
                        Button {
                            viewModel.save {
                                self.dismiss()
                            }
                        } label: {
                            Text("SAVE")
                                .foregroundColor(.white)
                                .padding()
                                .bold()
                                .background() {
                                    RoundedRectangle(cornerRadius: 20)
                                }
                        }.disabled(viewModel.changesMade ? false : true)
                        Spacer()
                    }
                }
        }
        .sheet(isPresented: $viewModel.goToLockNotes, onDismiss: {
        }, content: {
            SetPasscodeView()
        })
        .sheet(isPresented: $viewModel.goToResetPasscode, onDismiss: {
        }, content: {
            ChangePasscodeView()
        })
        .sheet(isPresented: $viewModel.goToRemovePasscode, content: {
            RemovePasscodeView()
        })
        .sheet(isPresented: $viewModel.goToResetPasscode, content: {
            ResetPasscodeView()
        })
        .preferredColorScheme(.light)
    }
}

extension SettingsMenuView {
    
    var xButton: some View {
        Button {
            self.dismiss()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(.black)
                .frame(width: 15, height: 15)
        }
    }
    
    var sortNotesByOptions: some View {
        HStack(spacing: 30) {
            Text("Sort notes by: ")
                .font(.custom("custom", fixedSize: 22))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            VStack {
                Button {
                    viewModel.sortNotesByCreationDate()
                } label: {
                    Text("Last Edited")
                        .frame(width: 120, height: 1)
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(viewModel.sortNoteByCreationDate ? .black : .blue)
                                
                        }
                }
                Button {
                    viewModel.sortNotesByTitle()
                } label: {
                    Text("Title")
                        .frame(width: 120, height: 1)
                        .foregroundColor(.white)
                        .padding()
                        .background() {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(viewModel.sortNoteByTitle ? .black : .blue)
                                
                        }
                }.padding()
            }
        }
    }
    
    var sortTasksByOptions: some View {
        HStack(spacing: 30) {
            Text("Sort tasks by:")
                .font(.custom("custom", fixedSize: 22))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            VStack {
                Button {
                    viewModel.sortTasksByDueDate()
                } label: {
                    Text("Due Date")
                        .frame(width: 120, height: 1)
                        .foregroundColor(.white)
                        .padding()
                        .background() {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(viewModel.sortTaskByDueDate ? .black : .blue)
                    }
                }.padding()
                
                Button {
                    viewModel.sortTasksByTitle()
                } label: {
                    Text("Title")
                        .frame(width: 120, height: 1)
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(viewModel.sortTaskByTitle ? .black : .blue)
                        }
                }
            }
        }
    }
    
    var setPasscodeOption: some View {
        HStack(spacing: 30) {
            Text("Lock notes:")
                .font(.custom("custom", fixedSize: 22))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            VStack {
                Button {
                    guard !viewModel.userHasPasscode() else {return}
                    viewModel.goToLockNotes = true
                } label: {
                    Text("Set passcode")
                        .frame(width: 120, height: 1)
                        .foregroundColor(.white)
                        .padding()
                        .background() {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(viewModel.userHasPasscode() ? .gray : .blue)
                                .opacity(viewModel.userHasPasscode() ? 0.5 : 1)
                    }
                }.padding()
                    .disabled(viewModel.userHasPasscode() ? true : false)
                
                Button {
                    guard viewModel.userHasPasscode() else {return}
                    viewModel.goToRemovePasscode = true
                } label: {
                    Text("Remove lock")
                        .frame(width: 120, height: 1)
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(viewModel.userHasPasscode() ? .blue : .gray)
                                .opacity(viewModel.userHasPasscode() ? 1 : 0.5)
                    }
                }.disabled(viewModel.userHasPasscode() ? false : true)
                
                Button {
                    guard viewModel.userHasPasscode() else {return}
                    viewModel.goToResetPasscode = true
                } label: {
                    Text("Reset")
                        .frame(width: 120, height: 1)
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(viewModel.userHasPasscode() ? .blue : .gray)
                                .opacity(viewModel.userHasPasscode() ? 1 : 0.5)
                    }
                }.padding()
                    .disabled(viewModel.userHasPasscode() ? false : true)
            }
        }
    }
}

struct SettingsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenuView()
    }
}

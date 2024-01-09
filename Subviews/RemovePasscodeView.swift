//
//  RemovePasscodeView.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import SwiftUI

final class RemovePasscodeViewModel : ObservableObject {
    
    @Published var passcodeEntryAttempt: String = ""
    @Published var passcodeValidated: Bool = false
    @Published var showWarning: Bool = false
    @Published var showWrongPasscode: Bool = false
    
    func getCurrentPasscode () -> String {
        return UserManager.shared.notePasscode ?? ""
    }
    
    func removePasscode () {
        UserManager.shared.notePasscode = nil
        UserManager.shared.saveUserHasPasscode(hasPasscode: false)
    }
    
    func forgotPassword () {
        UserManager.shared.notePasscode = nil
        UserManager.shared.saveUserHasPasscode(hasPasscode: false)
        let manager = CoreDataPersistence.shared
        manager.deleteAllNotes()
    }
    
    func startDeletingText<T>(for keyPath: WritableKeyPath<RemovePasscodeViewModel, T>) {
       guard var mutableSelf = self as? RemovePasscodeViewModel,
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

struct RemovePasscodeView: View {
    @StateObject var vm: RemovePasscodeViewModel = RemovePasscodeViewModel()
    @Environment(\.dismiss) var dismiss
    @State var shake: Bool = false
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)
            VStack {
                if !vm.passcodeValidated {
                    Text("REMOVE PASSCODE")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundStyle(Color.black)
                    
                    if vm.showWrongPasscode {
                        Text("INCORRECT PASSCODE")
                            .foregroundColor(.black)
                            .bold()
                    }
                    
                    Spacer()
                    TextBox(text: $vm.passcodeEntryAttempt)
                        .shake($shake)
                    CustomKeyboard(text: $vm.passcodeEntryAttempt, completion: {
                        guard vm.getCurrentPasscode() == vm.passcodeEntryAttempt else {
                            withAnimation {
                                vm.showWrongPasscode = true
                                shake = true
                                vm.startDeletingText(for: \.passcodeEntryAttempt)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                withAnimation {
                                    vm.showWrongPasscode = false
                                }
                            })
                            return
                        }
                        vm.removePasscode()
                        withAnimation {
                            vm.passcodeValidated = true
                        }
                    })
                }
                if vm.passcodeValidated {
                    Button {
                        dismiss.callAsFunction()
                    } label: {
                        HStack {
                            Text("DONE")
                                .frame(width: 70, height: 35)
                                .foregroundColor(.white)
                                .bold()
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.blue)
                            }
                        }
                    }
                }
                if !vm.showWarning && !vm.passcodeValidated  {
                    Button {
                        withAnimation {
                            vm.showWarning = true
                        }
                    } label: {
                        Text("FORGOT PASSCODE")
                            .padding(2)
                            .bold()
                            .background() {
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(.white)
                            }
                    }
                }
                
                if vm.showWarning {
                    VStack(spacing: 20) {
                        Text("Remove passcode and lose all notes")
                            .foregroundColor(.black)
                            .bold()
                        VStack(spacing: 20) {
                            Button {
                                vm.forgotPassword()
                                dismiss.callAsFunction()
                            } label: {
                                Text("YES")
                                    .padding(2)
                                    .foregroundColor(.blue)
                                    .bold()
                                    .background() {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.white)
                                    }
                            }
                            
                            Button {
                                withAnimation {
                                    vm.showWarning = false
                                }
                            } label: {
                                Text("NO")
                                    .padding(2)
                                    .foregroundColor(.blue)
                                    .bold()
                                    .background() {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.white)
                                    }
                            }
                        }
                    }
                }

            }
        }.preferredColorScheme(.light)
    }
}

struct RemovePasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        RemovePasscodeView()
    }
}

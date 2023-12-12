//
//  ChangePasscodeView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

final class ChangePasscodeViewModel: ObservableObject {
    @Published var passcodeEntryAttempt: String = ""
    @Published var showWrongPasscode: Bool = false
    @Published var passcodeValidated: Bool = false
    @Published var newPasscode: String = ""
    
    func getCurrentPassode () -> String {
        let user = UserManager.shared
        return user.notePasscode ?? ""
    }
    
    func setPasscode () {
        let user = UserManager.shared
        user.saveNotePasscode(self.newPasscode)
        user.saveUserHasPasscode(hasPasscode: true)
    }
    
    func startDeletingText<T>(for keyPath: WritableKeyPath<ChangePasscodeViewModel, T>) {
       guard var mutableSelf = self as? ChangePasscodeViewModel,
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

struct ChangePasscodeView: View {
    @StateObject var vm: ChangePasscodeViewModel = ChangePasscodeViewModel()
    @Environment(\.dismiss) var dismiss
    @State var shake: Bool = false
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)
            VStack {
                if vm.showWrongPasscode {
                    Text("INCORRECT PASSCODE")
                        .padding()
                        .font(.body)
                        .foregroundColor(.black)
                        .bold()
                }
                
                if !vm.passcodeValidated {
                    Text("Current Passcode")
                        .foregroundStyle(Color.black)
                        .bold()
                        .padding()
                        .opacity(vm.showWrongPasscode ? 0 : 1)
                    
                    TextBox(text: $vm.passcodeEntryAttempt)
                        .shake($shake)

                    CustomKeyboard(text: $vm.passcodeEntryAttempt, completion: {
                        guard vm.passcodeEntryAttempt == vm.getCurrentPassode() else {
                            withAnimation {
                                vm.showWrongPasscode = true
                                shake = true
                                vm.startDeletingText(for: \.passcodeEntryAttempt)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                withAnimation {
                                    vm.showWrongPasscode = false
                                }
                            })
                            return
                        }
                        vm.passcodeValidated = true
                    })
                } else if vm.passcodeValidated {
                    Text("New Passcode")
                        .padding()
                    TextBox(text: $vm.newPasscode)
                    CustomKeyboard(text: $vm.newPasscode, completion: {
                        vm.setPasscode()
                        dismiss.callAsFunction()
                    })
                }
            }
        }.preferredColorScheme(.light)
    }
}

struct ChangePasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasscodeView()
    }
}

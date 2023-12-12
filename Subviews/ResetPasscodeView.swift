//
//  ResetPasscodeView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//


import SwiftUI

final class ResetPasscodeViewModel : ObservableObject {
    @Published var passcodeEntryAttempt: String = ""
    @Published var newPasscode: String = ""
    @Published var showWrongPasscode: Bool = false
    @Published var userPassedValidation: Bool = false
    @Published var showWriteDown: Bool = false
    
    func getCorrectPasscode () -> String {
        let user = UserManager.shared
        return user.notePasscode ?? ""
    }
    
    func validate () -> Bool? {
        guard self.passcodeEntryAttempt == self.getCorrectPasscode() else {return false}
        if self.passcodeEntryAttempt == self.getCorrectPasscode() {
            return true
        }
        return nil
    }
    
    func resetPasscode () {
        let user = UserManager.shared
        user.saveNotePasscode(self.newPasscode)
        user.saveUserHasPasscode(hasPasscode: true)
    }
    
     func startDeletingText<T>(for keyPath: WritableKeyPath<ResetPasscodeViewModel, T>) {
        guard var mutableSelf = self as? ResetPasscodeViewModel,
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

struct ResetPasscodeView: View {
    @StateObject var vm: ResetPasscodeViewModel = ResetPasscodeViewModel()
    @Environment (\.dismiss) var dismiss
    @State var shake: Bool = false
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)
            if !vm.userPassedValidation {
                validationView
            } else if vm.userPassedValidation {
                newPasscodeView
            }
        }
    }
}

extension ResetPasscodeView {
    var validationView: some View {
        VStack {
            if vm.showWrongPasscode {
                Text("INCORRECT PASSCODE").padding()
                    .foregroundStyle(Color.black)
                    .bold()
            }
            
            TextBox(text: $vm.passcodeEntryAttempt)
                .shake($shake)
            
            CustomKeyboard(text: $vm.passcodeEntryAttempt, completion: {
                guard self.vm.validate() == true else {
                    withAnimation {
                        vm.showWrongPasscode = true
                        self.shake = true
                        vm.startDeletingText(for: \.passcodeEntryAttempt)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15, execute: {
                            withAnimation {
                                vm.showWrongPasscode = false
                            }
                        })
                    }
                    return
                }
            })
        }
    }
    
    var newPasscodeView: some View {
        VStack {
            TextBox(text: $vm.passcodeEntryAttempt)
            CustomKeyboard(text: $vm.newPasscode, completion: {
                guard self.vm.newPasscode.count > 0 else {return}
                withAnimation {
                    vm.showWriteDown = true
                }
                vm.resetPasscode()
            })
            if vm.showWriteDown {
                VStack {
                    Text("Save your passcode somewhere safe. If you ever forget it, you may lose your notes.").padding()
                    Button {
//                        dismiss.callAsFunction()
                    } label: {
                        Text("OK")
                            .foregroundColor(.blue)
                    }

                }
            }
        }
    }
}

struct ResetPasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasscodeView()
    }
}

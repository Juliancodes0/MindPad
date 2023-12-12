//
//  SetPasscodeView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

final class SetPasscodeViewModel : ObservableObject {
    @Published var passcode: String = ""
    @Published var showWarning: Bool = false
    
    func setPasscode () {
        guard passcode.isOnlyNumbers() else {return}
        let user = UserManager.shared
        self.showWarning = true
        user.notePasscode = self.passcode
        user.saveNotePasscode(self.passcode)
        user.saveUserHasPasscode(hasPasscode: true)
    }
    
    func startDeletingText<T>(for keyPath: WritableKeyPath<SetPasscodeViewModel, T>) {
       guard var mutableSelf = self as? SetPasscodeViewModel,
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

struct SetPasscodeView: View {
    let user = UserManager.shared
    @StateObject var vm: SetPasscodeViewModel = SetPasscodeViewModel()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)
            VStack {
                Text("Create Passcode")
                    .font(.largeTitle)
                    .foregroundStyle(Color.black)
                    .bold()
                    .padding()
                Spacer()
                TextBox(text: $vm.passcode)
                
                if vm.showWarning {
                    Spacer()
                    VStack {
                        Text("Save your passcode somewhere safe. If you ever forget it, you may lose your notes.")
                            .bold()
                            .padding()
                        Button {
                            dismiss.callAsFunction()
                        } label: {
                            Text("OK")
                                .foregroundColor(.blue)
                                .bold()
                        }
                    }
                    Spacer()
                }
                
                if vm.showWarning == false {
                    CustomKeyboard(text: $vm.passcode) {
                        vm.setPasscode()
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

struct TextBox: View {
    @Binding var text: String
    var body: some View {
        VStack {
            Text(text.count == 0 ? "" : text)
                .bold()
                .background() {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .frame(width: 150, height: 20)
                }
        }
    }
}

struct SetPasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        SetPasscodeView()
    }
}

struct CustomKeyboard: View {
    @Binding var text: String
    var completion: (() -> Void)?
    
    let keyboardRows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["Done", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(keyboardRows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            handleKeyTap(key: key)
                        }) {
                            Text(key)
                                .font(.title)
                                .frame(width: 90, height: 70)
                                .foregroundColor(.white)
                                .bold()
                                .padding(5)
                                .background(content: {
                                    Circle()
                                        .foregroundStyle(Color.black)
                                })
                        }
                    }
                }
            }
        }
        .padding(50)
    }
    
    private func handleKeyTap(key: String) {
        if key == "⌫" {
            // Handle backspace key
            if !text.isEmpty {
                text.removeLast()
            }
        } else if key == "Done" {
            // Handle "Done" key
            completion?()
        } else if key == "" {
            // Handle the action for other special keys, if any
            // ...
        } else {
            // Append the tapped key to the text
            if text.count < 9 {
                text += key
            }
        }
    }
}

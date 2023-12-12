//
//  AddFolderView.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

struct Shake<Content: View>: View {
    /// Set to true in order to animate
    @Binding var shake: Bool
    /// How many times the content will animate back and forth
    var repeatCount = 3
    /// Duration in seconds
    var duration = 0.8
    /// Range in pixels to go back and forth
    var offsetRange = 10.0

    @ViewBuilder let content: Content
    var onCompletion: (() -> Void)?

    @State private var xOffset = 0.0

    var body: some View {
        content
            .offset(x: xOffset)
            .onChange(of: shake) { shouldShake in
                guard shouldShake else { return }
                Task {
                    let start = Date()
                    await animate()
                    let end = Date()
                    print(end.timeIntervalSince1970 - start.timeIntervalSince1970)
                    shake = false
                    onCompletion?()
                }
            }
    }

    // Obs: sum of factors must be 1.0.
    private func animate() async {
        let factor1 = 0.9
        let eachDuration = duration * factor1 / CGFloat(repeatCount)
        for _ in 0..<repeatCount {
            await backAndForthAnimation(duration: eachDuration, offset: offsetRange)
        }

        let factor2 = 0.1
        await animate(duration: duration * factor2) {
            xOffset = 0.0
        }
    }

    private func backAndForthAnimation(duration: CGFloat, offset: CGFloat) async {
        let halfDuration = duration / 2
        await animate(duration: halfDuration) {
            self.xOffset = offset
        }

        await animate(duration: halfDuration) {
            self.xOffset = -offset
        }
    }
}

extension View {
    func shake(_ shake: Binding<Bool>,
               repeatCount: Int = 3,
               duration: CGFloat = 0.8,
               offsetRange: CGFloat = 10,
               onCompletion: (() -> Void)? = nil) -> some View {
        Shake(shake: shake,
              repeatCount: repeatCount,
              duration: duration,
              offsetRange: offsetRange) {
            self
        } onCompletion: {
            onCompletion?()
        }
    }

    func animate(duration: CGFloat, _ execute: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                execute()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
}

class AddFolderViewModel : ObservableObject {
    @Published var title: String = ""
    @Published var showError: Bool = false
    @Published var shakeText: Bool = false
    
    
    func save (completion: ( () -> ())) {
        guard !self.title.isEmpty else {
            self.showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.showError = false
            })
            return
        }
        let manager = CoreDataPersistence.shared
        let folder = Folder(context: manager.persistentContainer.viewContext)
        folder.title = self.title
        folder.uniqueId = UUID().uuidString
        manager.save()
        completion()
    }
}

struct AddFolderView: View {
    @StateObject var viewModel: AddFolderViewModel = AddFolderViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(0.8)
            VStack {
                
                if viewModel.showError {
                    VStack {
                        Text("Folder must have a name")
                            .padding()
                            .bold()
                            .foregroundStyle(Color.white)
                            .background() {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 240, height: 40)
                            }
                    }.padding(.bottom, 20)
                        .onAppear() {
                            viewModel.shakeText = true
                        }
                        .shake($viewModel.shakeText)
                }
                
                
        
                TextField("Folder name", text: $viewModel.title)
                    .frame(width: 300, height: 10)
                    .padding()
                    .foregroundColor(.black)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                    }
                
                
                Button(action: {
                    viewModel.save {
                        self.dismiss()
                    }
                }, label: {
                    Text("Save")
                        .bold()
                        .padding()
                        .foregroundStyle(Color.white)
                        .background() {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(Color.blue)
                                .frame(width: 50, height: 35)
                        }
                })
            }
        }.preferredColorScheme(.light)
    }
}

struct AddFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AddFolderView()
    }
}

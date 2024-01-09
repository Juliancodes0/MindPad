//
//  ApplicationOnboardPreviews.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import SwiftUI

class ApplicationOnboardPreviewsViewModel : ObservableObject {
    @Published var goToTasksAndFolders: Bool = false
    @Published var imageText: String = "img1prev"
    @Published var tapCount: Int = 0

    func changePreview (completion: ( ()->())) {
        self.tapCount += 1
        if tapCount == 1 {
            self.imageText = "img2prev"
        }
        if tapCount == 2 {
            self.imageText = "img3prev"
        }
        if tapCount == 3 {
            completion()
        }
    }
}

struct ApplicationOnboardPreviews: View {
    @StateObject var viewModel: ApplicationOnboardPreviewsViewModel = ApplicationOnboardPreviewsViewModel()
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
            
                Image(viewModel.imageText)
                    .resizable()
                    .opacity(0.7)
                    .scaledToFit()
                    .overlay {
                        Button(action: {
                            viewModel.changePreview(completion: {
                                UserManager.shared.saveUserIsOnboarded(true)
                                viewModel.goToTasksAndFolders = true
                            })
                        }, label: {
                            Text("NEXT")
                                .padding()
                                .bold()
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundStyle(Color.white)
                                }
                        }).shadow(radius: 10)
                        Spacer()
                    }
            }
        }
        .fullScreenCover(isPresented: $viewModel.goToTasksAndFolders, content: {
            TasksAndFolders()
        })
    }
}

struct ApplicationOnboardPreviews_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationOnboardPreviews()
    }
}

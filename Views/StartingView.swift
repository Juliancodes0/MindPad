//
//  ContentView.swift
//  BrainPadV2NewCode
//
//  Created by Julian Burton on 11/26/23.
//

import SwiftUI

class StartingViewModel: ObservableObject {
    @Published var goToIntro: Bool = false
    @Published var viewFinishedAnimation: Bool = false
    @Published var goToTaskAndFoldersView: Bool = false
    
    
    func goToIntroView () {
        guard self.viewFinishedAnimation == true else {return}
        self.goToIntro = true
    }
}


struct StartingView: View {
    @StateObject var viewModel: StartingViewModel = StartingViewModel()
    @State var viewOpacity: Double = 0.5
    var body: some View {
            mainViewComponents

        .onAppear(perform: {
            UserManager.shared.userIsOnboarded()
            UserManager.shared.getDecodedTaskSortingOption()
            UserManager.shared.getDecodedNoteSortingOption()
            
            initialSetup()
            
            if UserManager.shared.userIsOnboarded {
                viewModel.goToTaskAndFoldersView = true
            } else {
                withAnimation(.easeIn.delay(0.5)) {
                    viewOpacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                    viewModel.viewFinishedAnimation = true
                })
            }
        })
        .fullScreenCover(isPresented: $viewModel.goToIntro, content: {
            IntroView()
        })
        .fullScreenCover(isPresented: $viewModel.goToTaskAndFoldersView, content: {
            TasksAndFolders()
        })
    }
}

extension StartingView {
    func initialSetup () {
        let manager = CoreDataPersistence.shared
        let idToFind = "Default:08UI:COREDATA26910E_FOLDER033Q:Z[]"
        if let existingFolder = manager.getAllFolders().first(where: {$0.uniqueId == idToFind}) {
            return
        }
        
        let defaultFolder = Folder(context: manager.persistentContainer.viewContext)
        defaultFolder.title = "DefaultFolder-AppDevOnly"
        defaultFolder.uniqueId = "Default:08UI:COREDATA26910E_FOLDER033Q:Z[]"
        manager.save()
    }
}

struct StartingView_Previews: PreviewProvider {
    static var previews: some View {
        StartingView()
    }
}

extension StartingView {
    var mainViewComponents: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea(.all).opacity(viewOpacity)
            VStack {
               Text("MindPad")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.black)
                Spacer()
            }
            .padding()
            
            nextArrow
                .opacity(viewOpacity)
        }
    }
}

extension StartingView {
    var nextArrow: some View {
        Button(action: {viewModel.goToIntroView()}, label: {
            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.black)
        })           .disabled(viewModel.viewFinishedAnimation == true ? false : true)
    }
}


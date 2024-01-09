//
//  IntroView.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import SwiftUI

struct IntroView: View {
    @StateObject var vm = IntroViewModel()
    @State var timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    var body: some View {
        ZStack {
            Color.lightMintColor.ignoresSafeArea().opacity(1)
            VStack {
                VStack {
                Text("Save tasks")
                    .font(.title)
                    .foregroundStyle(Color.black)
                    Text("Keep organized")
                        .font(.title2)
                        .foregroundStyle(Color.black)
                Text("Save notes")
                    .font(.title3)
                    .foregroundStyle(Color.black)
                }.padding()
                    if vm.isDoneAnimating {
                    Spacer()
                }
                
                
                if vm.isDoneAnimating && vm.showClickHereToContinue {
                    VStack {
                        Button(action: {
                            vm.goToAppPreview = true
                        }, label: {
                            Image(systemName: "arrow.right")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.black)
                                .scaleEffect(vm.arrowCGZSize)
                            Text("Continue")
                                .foregroundStyle(Color.black)
                                .bold()
                        })
                    }
                    Spacer()
                }
                
                Text("Welcome to MindPad")
                    .opacity(vm.isDoneAnimating ? 1 : 0)
                    .foregroundStyle(Color.black)
                    .bold()
                    .font(.footnote)
                    .scaleEffect(CGSize(width: 2.0, height: 2.0))
                    .padding()
            }
        }
        .onAppear() {
            withAnimation(.spring.delay(0.4)) {
                vm.isDoneAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                vm.showClickHereToContinue = true
            })
        }
        .onReceive(timer, perform: { _ in
            withAnimation(.easeInOut(duration: 2.9)) {
                if vm.arrowCGZSize == CGSize(width: 1.0, height: 1.0) {
                    vm.arrowCGZSize = CGSize(width: 0.5, height: 0.5)
                }
                    else {
                        vm.arrowCGZSize = CGSize(width: 1.0, height: 1.0)
                    }
            }
        })
        .fullScreenCover(isPresented: $vm.goToAppPreview, content: {
            ApplicationOnboardPreviews()
        })
    }
}

class IntroViewModel : ObservableObject {
    @Published var saveTasksOffset: CGFloat = 0
    @Published var isDoneAnimating: Bool = false
    @Published var showClickHereToContinue: Bool = false
    @Published var arrowCGZSize: CGSize = CGSize(width: 1.0, height: 1.0)
    @Published var goToAppPreview: Bool = false
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}

//
//  TransitionArrowButton.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import SwiftUI

struct TransitionArrowButton: View {
    var action:  () -> ()
    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.white)
                .bold()
        })
    }
}

#Preview {
    TransitionArrowButton(action: { })
        .background {
            Color.black
        }
}

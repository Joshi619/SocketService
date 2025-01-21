//
//  ToastModifier.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let duration: Double

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                VStack {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        isShowing = false
                    }
                }
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowing)
    }
}

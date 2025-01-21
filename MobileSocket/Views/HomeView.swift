//
//  ContentView.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .center,spacing: 20) {
            HStack(alignment: .center) {
                Spacer()
                Text("Mobile Socket")
                    .font(.title)
                Spacer()
                Text("Status: \(viewModel.connectionStatus?.title ?? "")")
            }
            HStack {
                Spacer()
                Text("Setup Confiuration").font(.largeTitle)
                Spacer()
            }
            VStack {
                TextField("Enter Host Address", text: $viewModel.host)
                TextField("Enter Port Number", text: $viewModel.port)
                
                Button(action: {
                    viewModel.connectionStatus = nil
                    viewModel.startConnection()
                }) {
                    Text("Connect")
                }.disabled(viewModel.connectionStatus == .connected ? true: false)
            }
        }
        .padding()
        .onChange(of: viewModel.host) { oldValue, newValue in
            CommonDefine.hostAddress = newValue
        }
        .onChange(of: viewModel.port) { oldValue, newValue in
            CommonDefine.ipPort = Int(newValue) ?? 0
        }
        .onChange(of: viewModel.showErrorAlert, { oldValue, newValue in
            showAlert = newValue
        })
        .modifier(ToastModifier(isShowing: $showAlert, message: viewModel.errorMessage, duration: 2.0))
    }
}

#Preview {
    HomeView()
}

//
//  ContentView.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.
//

import SwiftUI
import AlertToast

struct HomeView: View {
    
    @StateObject var viewModel: HomeViewModel
    @State var successAlert: Bool = false
    @State var errorAlert: Bool = false
    
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
                    viewModel.validationForConnection()
                }) {
                    Text("Connect")
                }.disabled(viewModel.connectionStatus == .connected ? true: false)
            }
        }
        .padding()
        .onChange(of: viewModel.host) { oldValue, newValue in
            CommonDefine.shared.hostAddress = newValue
        }
        .onChange(of: viewModel.port) { oldValue, newValue in
            CommonDefine.shared.ipPort = Int(newValue) ?? 0
        }
        .onChange(of: viewModel.showSuccessAlert, { oldValue, newValue in
            successAlert = newValue
        })
        .onChange(of: viewModel.showErrorAlert, { oldValue, newValue in
            errorAlert = newValue
        })
        .onDisappear(perform: {
//            AppDelegate.shared.hideDockIcon()
        })
        .onAppear(perform: {
            viewModel.intialSetup()
        })
        .toast(isPresenting: $successAlert){
            switch viewModel.alertType {
            case .alert:
                // `.alert` is the default displayMode
                AlertToast(type: .regular, title: "Message Sent!")
            case .hudProgress:
                //Choose .hud to toast alert from the top of the screen
                AlertToast(displayMode: .hud, type: .regular, title: "Message Sent!")
            case .banner, .side:
                //Choose .banner to slide/pop alert from the bottom of the screen
                AlertToast(displayMode: .banner(.slide), type: .regular, title: "Message Sent!")
            }
        }
        .toast(isPresenting: $errorAlert){
            switch viewModel.alertType {
            case .alert:
                AlertToast(displayMode: .alert, type: .error(Color.red), title: viewModel.errorMessage)
            case .hudProgress:
                AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.errorMessage)
            case .banner, .side:
                AlertToast(displayMode: .banner(.slide), type: .error(Color.red), title: viewModel.errorMessage)
            }
        }
        
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

//
//  ContentView.swift
//  SwiftUICombine
//
//  Created by Grigor Keshishyan on 08.06.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userModel = UsserViewModel()
    
    var body: some View {
        Form {
            Section() {
                TextField("Username", text: $userModel.userName).autocapitalization(.none)
            }
            Section() {
                TextField("Password", text: $userModel.password).autocapitalization(.sentences)
                TextField("Passwordagain", text: $userModel.passwordAgain)
            }
            Section {
                Button(action: {
                    
                }, label: {
                    Text("Sign UP")
                }).disabled(!userModel.isValid)
            } 
                 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

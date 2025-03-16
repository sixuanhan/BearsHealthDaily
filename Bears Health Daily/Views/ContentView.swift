//
//  ContentView.swift
//
//  Created by xuanxuan on 3/14/25.
//

import SwiftUI
import CoreData
import Firebase
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                Text("Loading...")
            } else if viewModel.userSession != nil {
                AppView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUser()
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}

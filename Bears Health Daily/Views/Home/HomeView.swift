//
//  HomeView.swift
//
//  Created by xuanxuan on 3/15/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var currentUser: User?

    var body: some View {
        NavigationView {
            if let currentUser = currentUser {
                MyMedicationView(user: Binding($currentUser)!)
                    .navigationTitle("Home")
            } else {
                Text("Loading...")
                    .navigationTitle("Home")
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUser()
                if let user = viewModel.currentUser {
                    self.currentUser = user
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
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
            VStack {
                if let currentUser = currentUser {
                    medicationStatusSection
                    MyMedicationView(user: Binding($currentUser)!)
                        .navigationTitle("Home")
                } else {
                    Text("Loading...")
                        .navigationTitle("Home")
                }
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

    private var medicationStatusSection: some View {
        VStack {
            if let currentUser = currentUser {
                if allMedicationsFinished(for: currentUser) {
                    Text("Good job! You have taken all meds.")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Text("You still have meds to take.")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
    }

    private func allMedicationsFinished(for user: User) -> Bool {
        for medication in user.medications {
            if medication.actualTimes.count < medication.expectedTimes.count {
                return false
            }
        }
        return true
    }
}

#Preview {
    HomeView()
}
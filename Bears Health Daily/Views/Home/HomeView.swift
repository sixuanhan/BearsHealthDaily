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
                        .navigationTitle("我的主页")
                } else {
                    Text("正在加载...")
                        .navigationTitle("我的主页")
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
                    Text("太棒了！今天的药物已经全部服用完毕。")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Text("今天还有药物未服用，请记得完成。")
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
        .environmentObject(AuthViewModel())
}
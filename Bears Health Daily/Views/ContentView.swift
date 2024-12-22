//
//  ContentView.swift
//  Bears Health Daily
//
//  Created by xuanxuan on 12/19/24.
//

import SwiftUI

struct ContentView: View {
    @State private var users: [User] = UserDefaultsManager.shared.loadUsers()

    var body: some View {
        TabView {
            ForEach(users.indices, id: \.self) { index in
                MedicationListView(user: $users[index], users: $users)
                    .tabItem {
                        Label(users[index].name, systemImage: "person.circle")
                    }
            }
        }
        .onAppear {
           if users.isEmpty {
                addSampleData()
           }
        }
        .onChange(of: users) { 
            UserDefaultsManager.shared.saveUsers(users)
            print("Content: Saved")
        }
    }

    private func addSampleData() {
        users = [
            User(id: UUID(), name: "爸爸", medications: [
                Medication(id: UUID(), name: "Medication 1", brand: "brand 1", description: "Description 1", dosage: 10.0, dosageUnit: "mg", startDate: Date(), howBought: "暂无", expectedTimes: ["早", "晚"], actualTimes: [], cycle: 1)
            ]),
            User(id: UUID(), name: "妈妈", medications: [
                Medication(id: UUID(), name: "Medication 2", brand: "brand 2", description: "Description 2", dosage: 5.0, dosageUnit: "ml", startDate: Date(), howBought: "暂无", expectedTimes: ["中午"], actualTimes: [], cycle: 7)
            ]),
            User(id: UUID(), name: "宝宝", medications: [
                Medication(id: UUID(), name: "Medication 3", brand: "brand 3", description: "Description 3", dosage: 20.0, dosageUnit: "mg", startDate: Date(), howBought: "暂无", expectedTimes: ["早", "中", "晚"], actualTimes: [], cycle: 3)
            ])
        ]
    }
}

#Preview {
    ContentView()
}

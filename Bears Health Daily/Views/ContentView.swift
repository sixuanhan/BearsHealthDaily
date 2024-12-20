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
                MedicationListView(user: $users[index])
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
        .onChange(of: users) { newValue in
            UserDefaultsManager.shared.saveUsers(newValue)
        }
    }

    private func addSampleData() {
        users = [
            User(id: UUID(), name: "A", medications: [
                Medication(id: UUID(), name: "Medication 1", description: "Description 1", dosage: 10.0, dosageUnit: "mg", expectedTimes: [], actualTimes: [], cycle: 1)
            ]),
            User(id: UUID(), name: "B", medications: [
                Medication(id: UUID(), name: "Medication 2", description: "Description 2", dosage: 5.0, dosageUnit: "ml", expectedTimes: [], actualTimes: [], cycle: 7)
            ]),
            User(id: UUID(), name: "C", medications: [
                Medication(id: UUID(), name: "Medication 3", description: "Description 3", dosage: 20.0, dosageUnit: "mg", expectedTimes: [], actualTimes: [], cycle: 3)
            ])
        ]
    }
}

#Preview {
    ContentView()
}

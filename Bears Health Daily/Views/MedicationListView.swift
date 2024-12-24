import SwiftUI

struct MedicationListView: View {
    @Binding var user: User
    @Binding var users: [User]

    @State private var isPresentingAddMedication = false
    @State private var isPresentingEditMedication = false
    @State private var newMedication = Medication(id: UUID(), name: "", brand: "")
    @State private var selectedMedication: Medication?
    @State private var editableMedication = Medication(id: UUID(), name: "", brand: "")
    @State private var isEditMode = false
    @State private var navigationSelection: Medication?

    var body: some View {
        NavigationStack {
            VStack {
                MedicationList(user: $user, isEditMode: $isEditMode, navigationSelection: $navigationSelection, selectedMedication: $selectedMedication, editableMedication: $editableMedication, isPresentingEditMedication: $isPresentingEditMedication)
                Spacer()
                ActionButtons(isEditMode: $isEditMode, isPresentingAddMedication: $isPresentingAddMedication)
            }
            .navigationTitle(user.name)
            .onAppear {
                checkAndClearActualTimes()
            }
            .sheet(isPresented: $isPresentingAddMedication) {
                MedicationFormView(medication: $newMedication, onSave: {
                    addMedication()
                    isPresentingAddMedication = false
                }, onCancel: {
                    isPresentingAddMedication = false
                }, users: $users)
            }
            .sheet(isPresented: $isPresentingEditMedication) {
                MedicationFormView(medication: $editableMedication, onSave: {
                    saveMedication()
                    isPresentingEditMedication = false
                }, onCancel: {
                    isPresentingEditMedication = false
                }, users: $users)
            }
        }
    }

    // modify the new medication and add it to the list
    private func addMedication() {
        user.medications.append(newMedication)
        newMedication = Medication(id: UUID(), name: "", brand: "")
    }

    // modify the selected medication
    private func saveMedication() {
        if let index = user.medications.firstIndex(where: { $0.id == selectedMedication?.id }) {
            user.medications[index] = editableMedication
        }
    }

    private func checkAndClearActualTimes() {
        let now = roundToMidnight(date: Date())
        for index in user.medications.indices {
            let medication = user.medications[index]
            let daysSinceLastClearedDate = Calendar.current.dateComponents([.day], from: medication.lastClearedDate, to: now ?? Date()).day ?? 0
            if daysSinceLastClearedDate >= medication.cycle {
                user.medications[index].actualTimes.removeAll()
                user.medications[index].lastClearedDate = now!
            }
        }
    }

    private func roundToMidnight(date: Date) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
}

struct MedicationList: View {
    @Binding var user: User
    @Binding var isEditMode: Bool
    @Binding var navigationSelection: Medication?
    @Binding var selectedMedication: Medication?
    @Binding var editableMedication: Medication
    @Binding var isPresentingEditMedication: Bool

var body: some View {
        List {
            ForEach(user.medications.indices, id: \.self) { index in
                let medication = user.medications[index]
                MedicationRowView(medication: $user.medications[index])
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        handleTapGesture(for: medication)
                    }
            }
            .onDelete(perform: isEditMode ? deleteMedications : nil)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private func handleTapGesture(for medication: Medication) {
        if isEditMode {
            selectedMedication = medication
            editableMedication = medication
            isPresentingEditMedication = true
        } else {
            navigationSelection = medication
        }
    }

    private func deleteMedications(at offsets: IndexSet) {
        user.medications.remove(atOffsets: offsets)
    }
}

struct ActionButtons: View {
    @Binding var isEditMode: Bool
    @Binding var isPresentingAddMedication: Bool

    var body: some View {
        HStack {
            Spacer()
            Button(action: { 
                isPresentingAddMedication = true 
            }) {
                Label("添加新药", systemImage: "plus")
            }
            Spacer()
            Button(action: { 
                isEditMode.toggle() 
            }) {
                Label(isEditMode ? "编辑中" : "浏览中", systemImage: isEditMode ? "pencil" : "eye")
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var sampleUser = User(id: UUID(), name: "Sample User", medications: [
        Medication(id: UUID(), name: "神奇的药", brand: "梦工厂"),
        Medication(id: UUID(), name: "Medication 2", brand: "brand 2")
    ])
    @Previewable @State var allUsers = [
        User(id: UUID(), name: "Sample User", medications: []),
        User(id: UUID(), name: "User B", medications: []),
        User(id: UUID(), name: "User C", medications: [])
    ]
    MedicationListView(user: $sampleUser, users: $allUsers)
}

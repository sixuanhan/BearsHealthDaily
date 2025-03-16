import SwiftUI

struct MyMedicationView: View {
    @Binding var user: User
    @EnvironmentObject var viewModel: AuthViewModel

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
                MedicationListView(
                    user: $user,
                    isEditMode: $isEditMode,
                    navigationSelection: $navigationSelection,
                    selectedMedication: $selectedMedication,
                    editableMedication: $editableMedication,
                    isPresentingEditMedication: $isPresentingEditMedication
                )
                ActionButtons(
                    isEditMode: $isEditMode,
                    isPresentingAddMedication: $isPresentingAddMedication,
                    clearAllActualTimes: clearAllActualTimes
                )
            }
            .navigationDestination(for: Medication.self) { medication in
                MedicationDetailsView(medication: medication)
            }
            .onAppear {
                checkAndClearActualTimes()
            }
            .sheet(isPresented: $isPresentingAddMedication) {
                MedicationFormView(medication: $newMedication, onSave: {
                    addMedication()
                    isPresentingAddMedication = false
                }, onCancel: {
                    isPresentingAddMedication = false
                }, onDelete: {
                    deleteMedication(editableMedication)
                    isPresentingEditMedication = false
                })
            }
            .sheet(isPresented: $isPresentingEditMedication) {
                MedicationFormView(medication: $editableMedication, onSave: {
                    saveMedication()
                    isPresentingEditMedication = false
                }, onCancel: {
                    isPresentingEditMedication = false
                }, onDelete: {
                    deleteMedication(editableMedication)
                    isPresentingEditMedication = false
                })
            }
            .onChange(of: user) { newUser in
                Task {
                    await viewModel.updateUserInFirestore(newUser)
                }
            }
        }
    }

    // modify the new medication and add it to the list
    private func addMedication() {
        user.medications.append(newMedication)
        newMedication = Medication(id: UUID(), name: "", brand: "")
    }

    private func deleteMedications(at offsets: IndexSet) {
        user.medications.remove(atOffsets: offsets)
    }

    // modify the selected medication
    private func saveMedication() {
        if let index = user.medications.firstIndex(where: { $0.id == selectedMedication?.id }) {
            user.medications[index] = editableMedication
        }
    }

    private func deleteMedication(_ medication: Medication) {
        if let index = user.medications.firstIndex(where: { $0.id == medication.id }) {
            user.medications.remove(at: index)
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

    private func clearAllActualTimes() {
        let now = roundToMidnight(date: Date())
        for index in user.medications.indices {
            user.medications[index].actualTimes.removeAll()
            user.medications[index].lastClearedDate = now!
        }
    }
}

struct ActionButtons: View {
    @Binding var isEditMode: Bool
    @Binding var isPresentingAddMedication: Bool
    var clearAllActualTimes: () -> Void

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
                clearAllActualTimes()
            }) {
                Label("服用记录归零", systemImage: "trash")
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    MyMedicationView(user: .constant(User(id: UUID().uuidString, username: "some username", email: "some email", medications: [Medication(id: UUID(), name: "some name", brand: "some brand")])))
    .environmentObject(AuthViewModel())
}
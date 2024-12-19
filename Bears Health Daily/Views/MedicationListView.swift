import SwiftUI

struct MedicationListView: View {
    @Binding var user: User

    @State private var isPresentingAddMedication = false
    @State private var isPresentingEditMedication = false
    @State private var newMedication = Medication(id: UUID(), name: "", description: "", dosage: 0.0, dosageUnit: "", expectedTimes: [], actualTimes: [])
    @State private var selectedMedication: Medication?
    @State private var editableMedication = Medication(id: UUID(), name: "", description: "", dosage: 0.0, dosageUnit: "", expectedTimes: [], actualTimes: [])
    @State private var isEditMode = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(user.medications) { medication in
                        MedicationRowView(medication: medication)
                            .onTapGesture {
                                if isEditMode {
                                    selectedMedication = medication
                                    editableMedication = medication
                                    isPresentingEditMedication = true
                                }
                            }
                    }
                    .onDelete(perform: isEditMode ? deleteMedications : nil)
                }
                HStack {
                    Spacer()
                    Button(action: { isPresentingAddMedication = true }) {
                        Label("Add Medication", systemImage: "plus")
                    }
                    Spacer()
                    Button(action: { isEditMode.toggle() }) {
                        Label(isEditMode ? "Done" : "Edit", systemImage: isEditMode ? "checkmark" : "pencil")
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(user.name)
            .sheet(isPresented: $isPresentingAddMedication) {
                MedicationFormView(medication: $newMedication, onSave: {
                    addMedication()
                    isPresentingAddMedication = false
                }, onCancel: {
                    
                    isPresentingAddMedication = false
                })
            }
            .sheet(isPresented: $isPresentingEditMedication) {
                MedicationFormView(medication: $editableMedication, onSave: {
                    saveMedication()
                    isPresentingEditMedication = false
                }, onCancel: {
                    isPresentingEditMedication = false
                })
            }
        }
    }

    // modify the new medication and add it to the list
    private func addMedication() {
        user.medications.append(newMedication)
        newMedication = Medication(id: UUID(), name: "", description: "", dosage: 0.0, dosageUnit: "", expectedTimes: [], actualTimes: [])
    }

    // modify the selected medication
    private func saveMedication() {
        if let index = user.medications.firstIndex(where: { $0.id == selectedMedication?.id }) {
            user.medications[index] = editableMedication
        }
    }

    private func deleteMedications(at offsets: IndexSet) {
        user.medications.remove(atOffsets: offsets)
    }
}

#Preview {
    @Previewable @State var sampleUser = User(id: UUID(), name: "Sample User", medications: [
        Medication(id: UUID(), name: "Medication 1", description: "Description 1", dosage: 10.0, dosageUnit: "mg", expectedTimes: ["08:00, 12:00, 19:00"], actualTimes: []),
        Medication(id: UUID(), name: "Medication 2", description: "Description 2", dosage: 5.0, dosageUnit: "ml", expectedTimes: ["12:00, 19:00"], actualTimes: [])
    ])
    MedicationListView(user: $sampleUser)
}

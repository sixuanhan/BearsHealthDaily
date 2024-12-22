import SwiftUI

struct MedicationListView: View {
    @Binding var user: User
    @Binding var users: [User]

    @State private var isPresentingAddMedication = false
    @State private var isPresentingEditMedication = false
    @State private var newMedication = Medication(id: UUID(), name: "", brand: "", description: "", dosage: 0.0, dosageUnit: "", startDate: Date(), howBought: "", expectedTimes: [], actualTimes: [], cycle: 1)
    @State private var selectedMedication: Medication?
    @State private var editableMedication = Medication(id: UUID(), name: "", brand: "", description: "", dosage: 0.0, dosageUnit: "", startDate: Date(), howBought: "", expectedTimes: [], actualTimes: [], cycle: 1)
    @State private var isEditMode = false
    @State private var navigationSelection: Medication?

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(user.medications) { medication in
                        MedicationRowView(medication: medication)
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                if isEditMode {
                                    selectedMedication = medication
                                    editableMedication = medication
                                    isPresentingEditMedication = true
                                } else {
                                    navigationSelection = medication
                                }
                            }
                            .background(
                                NavigationLink(
                                    destination: MedicationDetailsView(medication: medication),
                                    tag: medication,
                                    selection: $navigationSelection,
                                    label: { EmptyView() }
                                )
                                .hidden()
                            )
                    }
                    .onDelete(perform: isEditMode ? deleteMedications : nil)
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
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
        newMedication = Medication(id: UUID(), name: "", brand: "", description: "", dosage: 0.0, dosageUnit: "", startDate: Date(), howBought: "", expectedTimes: [], actualTimes: [], cycle: 1)
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

    private func checkAndClearActualTimes() {
        let now = Date()
        for index in user.medications.indices {
            let medication = user.medications[index]
            if let lastTime = medication.actualTimes.last {
                let daysSinceLastTime = Calendar.current.dateComponents([.day], from: lastTime, to: now).day ?? 0
                if daysSinceLastTime >= medication.cycle {
                    user.medications[index].actualTimes.removeAll()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var sampleUser = User(id: UUID(), name: "Sample User", medications: [
        Medication(id: UUID(), name: "神奇的药", brand: "梦工厂", description: "我瞎编的", dosage: 1, dosageUnit: "粒", startDate: Date(), howBought: "买不到", expectedTimes: ["早", "中", "晚"], actualTimes: [], cycle: 1),
        Medication(id: UUID(), name: "Medication 2", brand: "brand 2", description: "Description 2", dosage: 5.0, dosageUnit: "ml", startDate: Date(), howBought: "", expectedTimes: ["12:00, 19:00"], actualTimes: [], cycle: 1)
    ])
    @Previewable @State var allUsers = [
        User(id: UUID(), name: "Sample User", medications: []),
        User(id: UUID(), name: "User B", medications: []),
        User(id: UUID(), name: "User C", medications: [])
    ]
    MedicationListView(user: $sampleUser, users: $allUsers)
}

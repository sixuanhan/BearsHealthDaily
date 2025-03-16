import SwiftUI

struct MedicationListView: View {
    @Binding var user: User
    @Binding var isEditMode: Bool
    @Binding var navigationSelection: Medication?
    @Binding var selectedMedication: Medication?
    @Binding var editableMedication: Medication
    @Binding var isPresentingEditMedication: Bool

    var body: some View {
        List {
            ForEach(sortedMedications, id: \.id) { medication in
                MedicationRowView(
                    medication: binding(for: medication),
                    isEditMode: $isEditMode,
                    navigationSelection: $navigationSelection,
                    selectedMedication: $selectedMedication,
                    editableMedication: $editableMedication,
                    isPresentingEditMedication: $isPresentingEditMedication
                )
                    .listRowBackground(Color.clear)
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
    }

    private var sortedMedications: [Medication] {
        let sortedMedications = user.medications.sorted {
            ($0.actualTimes.count < $0.expectedTimes.count) && !($1.actualTimes.count < $1.expectedTimes.count)
        }
        print("sortedMedications: \(sortedMedications)")
        return sortedMedications
    }

    private func deleteMedications(at offsets: IndexSet) {
        user.medications.remove(atOffsets: offsets)
    }

    private func binding(for medication: Medication) -> Binding<Medication> {
        guard let index = user.medications.firstIndex(where: { $0.id == medication.id }) else {
            fatalError("Medication not found")
        }
        return $user.medications[index]
    }
}

#Preview {
    MedicationListView(
        user: .constant(User(id: UUID().uuidString, username: "some username", email: "some email", medications: [Medication(id: UUID(), name: "some name", brand: "some brand")])),
        isEditMode: .constant(false),
        navigationSelection: .constant(nil),
        selectedMedication: .constant(nil),
        editableMedication: .constant(Medication(id: UUID(), name: "some name", brand: "some brand")),
        isPresentingEditMedication: .constant(false)
    )
}
import SwiftUI

struct SimpleListView: View {
    @Binding var user: User
    @Binding var navigationSelection: Medication?

    var body: some View {
        List {
            ForEach(sortedMedications, id: \.id) { medication in
                SimpleRowView(medication: binding(for: medication), navigationSelection: $navigationSelection)
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

    private func binding(for medication: Medication) -> Binding<Medication> {
        guard let medicationIndex = user.medications.firstIndex(where: { $0.id == medication.id }) else {
            fatalError("Can't find medication in user's medications")
        }
        return $user.medications[medicationIndex]
    }
}

#Preview {
    SimpleListView(user: .constant(User(id: UUID().uuidString, username: "some username", email: "some email", medications: [Medication(id: UUID(), name: "some name1", brand: "some brand1"), Medication(id: UUID(), name: "some name2", brand: "some brand2")])), navigationSelection: .constant(nil))
}

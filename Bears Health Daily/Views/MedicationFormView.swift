import SwiftUI

struct MedicationFormView: View {
    @Binding var medication: Medication
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var dosage: Double = 1.0
    @State private var dosageUnit: String = ""
    @State private var expectedTimes: [String] = []
    @State private var actualTimes: [Date] = []
    @State private var cycle: Int = 1

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    MedicationTextFieldsView(name: $name, description: $description, dosage: $dosage, dosageUnit: $dosageUnit, cycle: $cycle)
                    ExpectedTimesView(expectedTimes: $expectedTimes)
                    ActualTimesView(actualTimes: $actualTimes)
                }
                HStack {
                    Spacer()
                    Button("Cancel") {
                        onCancel()
                    }
                    Spacer()
                    Button("Save") {
                        saveMedication()
                        onSave()
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Medication Form")
            .onAppear {
                loadMedication()
            }
        }
    }

    private func loadMedication() {
        name = medication.name
        description = medication.description
        dosage = medication.dosage
        dosageUnit = medication.dosageUnit
        expectedTimes = medication.expectedTimes
        actualTimes = medication.actualTimes
        cycle = medication.cycle
    }

    private func saveMedication() {
        medication.name = name
        medication.description = description
        medication.dosage = dosage
        medication.dosageUnit = dosageUnit
        medication.expectedTimes = expectedTimes
        medication.actualTimes = actualTimes
        medication.cycle = cycle
    }
}

#Preview {
    MedicationFormView(medication: .constant(Medication(id: UUID(), name: "test med", description: "this is test", dosage: 0.5, dosageUnit: "pill", expectedTimes: [], actualTimes: [], cycle: 1)), onSave: {}, onCancel: {})
}

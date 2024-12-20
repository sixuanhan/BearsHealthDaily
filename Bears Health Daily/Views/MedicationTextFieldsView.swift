import SwiftUI

struct MedicationTextFieldsView: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var dosage: Double
    @Binding var dosageUnit: String
    @Binding var cycle: Int


    var body: some View {
        Section {
            TextField("Name", text: $name)
            TextField("Description", text: $description)
            TextField("Dosage", value: $dosage, format: .number)
            TextField("Dosage Unit", text: $dosageUnit)
            TextField("Cycle", value: $cycle, format: .number)
        }
    }
}
import SwiftUI

struct MedicationTextFieldsView: View {
    @Binding var name: String
    @Binding var brand: String
    @Binding var description: String
    @Binding var dosage: Double
    @Binding var dosageUnit: String
    @Binding var startDate: Date
    @Binding var howBought: String
    @Binding var cycle: Int


    var body: some View {
        Section {
            TextField("Name", text: $name)
            TextField("Brand", text: $brand)
            TextField("Description", text: $description)
            TextField("Dosage", value: $dosage, format: .number)
            TextField("Dosage Unit", text: $dosageUnit)
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            TextField("How Bought", text: $howBought)
            TextField("Cycle", value: $cycle, format: .number)
        }
    }
}
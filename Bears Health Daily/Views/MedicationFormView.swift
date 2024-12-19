import SwiftUI
import CoreData

struct MedicationFormView: View {
    @Binding var medication: Medication
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var dosage: Double = 0.0
    @State private var dosageUnit: String = ""
    @State private var timesAday: Int = 0
    @State private var timestamp: Date = Date()

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Dosage", value: $dosage, format: .number)
                    TextField("Dosage Unit", text: $dosageUnit)
                    TextField("Times a Day", value: $timesAday, format: .number)
                    DatePicker("Timestamp", selection: $timestamp, displayedComponents: .date)
                }
            }
            .navigationTitle("Medication Form")
            .onAppear {
                loadMedication()
            }
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
    }

    private func loadMedication() {
        name = medication.name
        description = medication.description
        dosage = medication.dosage
        dosageUnit = medication.dosageUnit
        timesAday = Int(medication.timesAday)
        timestamp = medication.timestamp
    }

    private func saveMedication() {
        medication.name = name
        medication.description = description
        medication.dosage = dosage
        medication.dosageUnit = dosageUnit
        medication.timesAday = timesAday
        medication.timestamp = timestamp
    }
}

#Preview {
    MedicationFormView(medication: .constant(Medication(id: UUID(), name: "", description: "", dosage: 0.0, dosageUnit: "", timesAday: 0, timestamp: Date())), onSave: {}, onCancel: {})
}
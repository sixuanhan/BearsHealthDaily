import SwiftUI
import CoreData

struct MedicationRowView: View {
    var medication: Medication

    var body: some View {
        VStack(alignment: .leading) {
            Text(medication.name)
                .font(.headline)
            Text(medication.description)
                .font(.subheadline)
            Text("Dosage: \(medication.dosage) \(medication.dosageUnit)")
            Text("Times a day: \(medication.timesAday)")
            Text("Timestamp: \(medication.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        }
        .contentShape(Rectangle())
    }
}

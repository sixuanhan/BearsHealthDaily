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
            Text("When to take: \(medication.expectedTimes.joined(separator: ", "))")
            Text("Timestamp: \(medication.actualTimes.map { $0.description }.joined(separator: ", "))")
        }
        .contentShape(Rectangle())
    }
}

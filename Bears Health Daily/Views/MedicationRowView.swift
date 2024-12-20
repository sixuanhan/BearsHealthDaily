import SwiftUI

struct MedicationRowView: View {
    var medication: Medication

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(medication.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Dosage: \(String(format: "%.1f", medication.dosage)) \(medication.dosageUnit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("When to take: \(medication.expectedTimes.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ForEach(medication.actualTimes, id: \.self) { time in
                    Text("Time: \(time, formatter: timeFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(medication.actualTimes.count)/\(medication.expectedTimes.count)")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
        .contentShape(Rectangle())
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    MedicationRowView(medication: Medication(id: UUID(), name: "Medication Name", description: "Medication Description", dosage: 1, dosageUnit: "pill", expectedTimes: ["Morning", "Afternoon", "Evening"], actualTimes: [Date()]))
        .previewLayout(.sizeThatFits)
        .padding()
}

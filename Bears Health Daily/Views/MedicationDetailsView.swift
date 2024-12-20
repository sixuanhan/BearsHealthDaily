import SwiftUI

struct MedicationDetailsView: View {
    var medication: Medication

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(medication.brand)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(medication.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Dosage: \(String(format: "%.1f", medication.dosage)) \(medication.dosageUnit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Start Date: \(medication.startDate, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Days Till Now: \(Calendar.current.dateComponents([.day], from: medication.startDate, to: Date()).day ?? 0)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("How Bought: \(medication.howBought)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("When to take: \(medication.expectedTimes.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Time: \(medication.actualTimes.map { timeFormatter.string(from: $0) }.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Cycle: \(medication.cycle)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }
}

#Preview {
    MedicationDetailsView(medication: Medication(id: UUID(), name: "神奇的药", brand: "梦工厂", description: "我瞎编的", dosage: 1, dosageUnit: "粒", startDate: Date(), howBought: "买不到", expectedTimes: ["早", "中", "晚"], actualTimes: [], cycle: 1))
        .padding()
}

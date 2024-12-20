import SwiftUI

struct MedicationRowView: View {
    var medication: Medication

    var body: some View {
        // NavigationLink(destination: MedicationDetailsView(medication: medication)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.headline)
                    Text("何时服用: \(medication.expectedTimes.joined(separator: ", "))")
                        .font(.subheadline)
                }
                Spacer()
                Text("\(medication.actualTimes.count)/\(medication.expectedTimes.count)")
                    .font(.headline)
                }
                .contentShape(Rectangle())
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                )
        // }
    }
}

#Preview {
    NavigationView {
        MedicationRowView(medication: Medication(id: UUID(), name: "神奇的药", brand: "梦工厂", description: "我瞎编的", dosage: 1, dosageUnit: "粒", startDate: Date(), howBought: "买不到", expectedTimes: ["早", "中", "晚"], actualTimes: [], cycle: 1))
            .padding()
    }
}

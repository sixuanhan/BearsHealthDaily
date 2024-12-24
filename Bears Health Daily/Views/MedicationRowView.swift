import SwiftUI

struct MedicationRowView: View {
    @Binding var medication: Medication
    @State private var showAlert = false

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
                VStack {
                    Button(action: {
                        if medication.actualTimes.count < medication.expectedTimes.count {
                            medication.actualTimes.append(Date())
                        } else {
                            showAlert = true
                        }
                    }) {
                        Text("服用")
                    }
                    Spacer()
                    Text("\(medication.actualTimes.count)/\(medication.expectedTimes.count)")
                        .font(.headline)
                }
                }
                .contentShape(Rectangle())
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("警告"),
                        message: Text("你不需要再吃药了"),
                        primaryButton: .default(Text("确定")),
                        secondaryButton: .destructive(Text("依然吃药"), action: {
                            medication.actualTimes.append(Date())
                        })
                    )
                }
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
        MedicationRowView(medication: .constant(Medication(id: UUID(), name: "Paracetamol", brand: "Generic")))
            .padding()
    }
}

import SwiftUI

struct MedicationRowView: View {
    @Binding var medication: Medication
    @Binding var isEditMode: Bool
    @Binding var navigationSelection: Medication?
    @Binding var selectedMedication: Medication?
    @Binding var editableMedication: Medication
    @Binding var isPresentingEditMedication: Bool
    @State private var showAlert = false

    var body: some View {
        VStack {
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

            Spacer()
            
            HStack {
                Button(action: {
                    navigationSelection = medication
                }) {
                    Text("查看")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 1.5)
                        .padding(.horizontal, 16)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }

                Spacer()

                Button(action: {
                    selectedMedication = medication
                    editableMedication = medication
                    isPresentingEditMedication = true
                }) {
                    Text("编辑")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 1.5)
                        .padding(.horizontal, 16)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }

                Spacer()

                Button(action: {
                    if medication.actualTimes.count < medication.expectedTimes.count {
                        medication.actualTimes.append(Date())
                    } else {
                        showAlert = true
                    }
                }) {
                    Text("服用")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 1.5)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
            }
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
            .buttonStyle(BorderlessButtonStyle())
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
    }
}

#Preview {
    NavigationView {
        MedicationRowView(
            medication: .constant(Medication(id: UUID(), name: "Medication Name", brand: "Brand")),
            isEditMode: .constant(false),
            navigationSelection: .constant(nil),
            selectedMedication: .constant(nil),
            editableMedication: .constant(Medication(id: UUID(), name: "", brand: "")),
            isPresentingEditMedication: .constant(false)
        )
    }
}

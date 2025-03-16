import SwiftUI

struct SimpleRowView: View {
    @Binding var medication: Medication
    @Binding var navigationSelection: Medication?

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
            .padding()
            .background(Color.clear)

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
    SimpleRowView(medication: .constant(Medication(id: UUID(), name: "some name", brand: "some brand")), navigationSelection: .constant(nil))
}
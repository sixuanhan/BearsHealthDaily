import SwiftUI

struct ExpectedTimesView: View {
    @Binding var expectedTimes: [String]

    var body: some View {
        Section(header: Text("规定吃药时间")) {
            List {
                ForEach(expectedTimes.indices, id: \.self) { index in
                    TextField("Time \(index + 1)", text: $expectedTimes[index])
                }
                .onDelete(perform: deleteExpectedTimes)
                Button(action: {
                    expectedTimes.append("")
                }) {
                    Label("增加规定吃药时间", systemImage: "plus")
                }
            }
        }
    }

    private func deleteExpectedTimes(at offsets: IndexSet) {
        expectedTimes.remove(atOffsets: offsets)
    }
}


struct ActualTimesView: View {
    @Binding var actualTimes: [Date]
    var expectedTimes: [String]

var body: some View {
        Section(header: Text("实际服用时间")) {
            List {
                ForEach(actualTimes.indices, id: \.self) { index in
                    DatePicker("次数 \(index + 1)", selection: $actualTimes[index], displayedComponents: .hourAndMinute)
                }
                .onDelete(perform: deleteActualTimes)
            }
            AddNowView(actualTimes: $actualTimes, expectedTimes: expectedTimes)
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    private func deleteActualTimes(at offsets: IndexSet) {
        actualTimes.remove(atOffsets: offsets)
    }
}

struct AddNowView: View {
    @Binding var actualTimes: [Date]
    var expectedTimes: [String]
    @State private var showAlert = false

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                if actualTimes.count < expectedTimes.count {
                    actualTimes.append(Date())
                } else {
                    showAlert = true
                }
            }) {
                Label("记录吃药时间", systemImage: "plus")
            }
            Spacer()
            Spacer()
            Button(action: {
                if actualTimes.count < expectedTimes.count {
                    actualTimes.append(Date())
                } else {
                    showAlert = true
                }
            }) {
                Label("现在就吃", systemImage: "clock")
            }
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("警告"),
                message: Text("你不需要再吃药了"),
                primaryButton: .default(Text("确定")),
                secondaryButton: .destructive(Text("依然吃药"), action: {
                    actualTimes.append(Date())
                })
            )
        }
    }
}

#Preview {
    AddNowView(actualTimes: .constant([]), expectedTimes: ["Morning", "Afternoon", "Evening"])
}

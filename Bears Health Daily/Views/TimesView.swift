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

var body: some View {
        Section(header: Text("实际服用时间")) {
            List {
                ForEach(actualTimes.indices, id: \.self) { index in
                    DatePicker("次数 \(index + 1)", selection: $actualTimes[index], displayedComponents: .hourAndMinute)
                }
                .onDelete(perform: deleteActualTimes)
            }
            AddNowView(actualTimes: $actualTimes)
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    private func deleteActualTimes(at offsets: IndexSet) {
        actualTimes.remove(atOffsets: offsets)
    }
}

struct AddNowView: View {
    @Binding var actualTimes: [Date]
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                actualTimes.append(Date())
            }) {
                Label("记录吃药时间", systemImage: "plus")
            }
            Spacer()
            Spacer()
            Button(action: {
                actualTimes.append(Date())
            }) {
                Label("现在就吃", systemImage: "clock")
            }
            Spacer()
        }
    }
}

#Preview {
    AddNowView(actualTimes: .constant([]))
}

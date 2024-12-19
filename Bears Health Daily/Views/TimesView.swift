import SwiftUI

struct ExpectedTimesView: View {
    @Binding var expectedTimes: [String]

    var body: some View {
        Section(header: Text("Expected Times")) {
            List {
                ForEach(expectedTimes.indices, id: \.self) { index in
                    TextField("Time \(index + 1)", text: $expectedTimes[index])
                }
                .onDelete(perform: deleteExpectedTimes)
                Button(action: {
                    expectedTimes.append("")
                }) {
                    Label("Add Expected Time", systemImage: "plus")
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
        Section(header: Text("Actual Times")) {
            List {
                ForEach(actualTimes.indices, id: \.self) { index in
                    DatePicker("Time \(index + 1)", selection: $actualTimes[index], displayedComponents: .hourAndMinute)
                }
                .onDelete(perform: deleteActualTimes)
                Button(action: {
                    actualTimes.append(Date())
                }) {
                    Label("Add Actual Time", systemImage: "plus")
                }
            }
        }
    }

    private func deleteActualTimes(at offsets: IndexSet) {
        actualTimes.remove(atOffsets: offsets)
    }
}
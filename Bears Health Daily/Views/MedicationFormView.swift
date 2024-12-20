import SwiftUI

struct MedicationFormView: View {
    @Binding var medication: Medication
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var description: String = ""
    @State private var dosage: Double = 1.0
    @State private var dosageUnit: String = ""
    @State private var startDate: Date = Date()
    @State private var howBought: String = ""
    @State private var expectedTimes: [String] = []
    @State private var actualTimes: [Date] = []
    @State private var cycle: Int = 1

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Medication Details").font(.headline)) {
                        AlignedLabelTextField(label: "Name", text: $name)
                        AlignedLabelTextField(label: "Brand", text: $brand)
                        AlignedLabelTextField(label: "Description", text: $description)
                        AlignedLabelValueField(label: "Dosage", value: $dosage, formatter: NumberFormatter())
                        AlignedLabelTextField(label: "Dosage Unit", text: $dosageUnit)
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        AlignedLabelTextField(label: "How Bought", text: $howBought)
                        AlignedLabelIntValueField(label: "Cycle (days)", value: $cycle, formatter: NumberFormatter())
                    }
                    ExpectedTimesView(expectedTimes: $expectedTimes)
                    ActualTimesView(actualTimes: $actualTimes)
                }
                HStack {
                    Spacer()
                    Button("Cancel") {
                        onCancel()
                        print("clicked cancel")
                    }
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                    Button("Save") {
                        saveMedication()
                        onSave()
                        print("clicked save")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Medication Form")
            .onAppear {
                loadMedication()
            }
        }
    }

    private func loadMedication() {
        name = medication.name
        brand = medication.brand
        description = medication.description
        dosage = medication.dosage
        dosageUnit = medication.dosageUnit
        startDate = medication.startDate
        howBought = medication.howBought
        expectedTimes = medication.expectedTimes
        actualTimes = medication.actualTimes
        cycle = medication.cycle
    }

    private func saveMedication() {
        medication.name = name
        medication.brand = brand
        medication.description = description
        medication.dosage = dosage
        medication.dosageUnit = dosageUnit
        medication.startDate = startDate
        medication.howBought = howBought
        medication.expectedTimes = expectedTimes
        medication.actualTimes = actualTimes
        medication.cycle = cycle
    }
}

struct AlignedLabelTextField: View {
    var label: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            TextField("Enter \(label.lowercased())", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct AlignedLabelValueField: View {
    var label: String
    @Binding var value: Double
    var formatter: NumberFormatter

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            TextField("Enter \(label.lowercased())", value: $value, formatter: formatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct AlignedLabelIntValueField: View {
    var label: String
    @Binding var value: Int
    var formatter: NumberFormatter

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            TextField("Enter \(label.lowercased())", value: $value, formatter: formatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    MedicationFormView(medication: .constant(Medication(id: UUID(), name: "test med", brand: "some brand", description: "this is test", dosage: 0.5, dosageUnit: "pill", startDate: Date(), howBought: "wo maide", expectedTimes: [], actualTimes: [], cycle: 1)), onSave: {}, onCancel: {})
}

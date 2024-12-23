import SwiftUI

struct MedicationFormView: View {
    @Binding var medication: Medication
    var onSave: () -> Void
    var onCancel: () -> Void
    @Binding var users: [User]

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
    @State private var selectedUser: User?
    @State private var showMessage: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("药物明细").font(.headline)) {
                        AlignedLabelTextField(label: "名称", text: $name)
                        AlignedLabelTextField(label: "品牌", text: $brand)
                        AlignedLabelTextField(label: "描述", text: $description)
                        AlignedLabelValueField(label: "用量", value: $dosage, formatter: NumberFormatter())
                        AlignedLabelTextField(label: "用量单位", text: $dosageUnit)
                        DatePicker("起始日期", selection: $startDate, displayedComponents: .date)
                        AlignedLabelTextField(label: "购买渠道", text: $howBought)
                        AlignedLabelIntValueField(label: "周期（天）", value: $cycle, formatter: NumberFormatter())
                    }
                    ExpectedTimesView(expectedTimes: $expectedTimes)
                    ActualTimesView(actualTimes: $actualTimes, expectedTimes: expectedTimes)
                    Section(header: Text("复制药物").font(.headline)) {
                        Picker("选择用户", selection: $selectedUser) {
                            ForEach(users) { user in
                                Text(user.name).tag(user as User?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        Button("确认复制") {
                            copyMedication()
                        }
                        .disabled(selectedUser == nil)
                    }
                }
                HStack {
                    Spacer()
                    Button("取消") {
                        onCancel()
                    }
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                    Button("保存") {
                        saveMedication()
                        onSave()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
                .padding()
                .alert(isPresented: $showMessage) {
                    Alert(title: Text("复制成功"), message: Text("成功复制给了: \(selectedUser?.name ?? "")"), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("增/改药物")
            .onAppear {
                loadMedication()
                if selectedUser == nil, let firstUser = users.first {
                    selectedUser = firstUser
                }
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

    private func copyMedication() {
        guard let selectedUser = selectedUser else { return }
        if let index = users.firstIndex(where: { $0.id == selectedUser.id }) {
            var copiedMedication = medication
            copiedMedication.id = UUID()
            users[index].medications.append(copiedMedication)
            withAnimation {
                showMessage = true
            }
        }
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
    MedicationFormView(medication: .constant(Medication(id: UUID(), name: "test med", brand: "some brand")), onSave: {}, onCancel: {}, users: .constant([User(id: UUID(), name: "Test User", medications: [])]))
}

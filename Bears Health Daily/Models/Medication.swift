import Foundation

struct Medication: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var brand: String
    var description: String
    var dosage: Double
    var dosageUnit: String
    var startDate: Date
    var howBought: String
    var expectedTimes: [String]
    var actualTimes: [Date]
    var cycle: Int
    var lastClearedDate: Date

    init(id: UUID = UUID(), name: String, brand: String) {
        self.id = id
        self.name = name
        self.brand = brand
        self.description = ""
        self.dosage = 1
        self.dosageUnit = "粒"
        self.startDate = Date()
        self.howBought = ""
        self.expectedTimes = []
        self.actualTimes = []
        self.cycle = 1
        self.lastClearedDate = startDate
    }

    static func == (lhs: Medication, rhs: Medication) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
                lhs.brand == rhs.brand &&
               lhs.description == rhs.description &&
               lhs.dosage == rhs.dosage &&
               lhs.dosageUnit == rhs.dosageUnit &&
                lhs.startDate == rhs.startDate &&
                lhs.howBought == rhs.howBought &&
               lhs.expectedTimes == rhs.expectedTimes &&
               lhs.actualTimes == rhs.actualTimes &&
                lhs.cycle == rhs.cycle &&
                lhs.lastClearedDate == rhs.lastClearedDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

import Foundation

struct Medication: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var description: String
    var dosage: Double
    var dosageUnit: String
    var expectedTimes: [String]
    var actualTimes: [Date]
    var cycle: Int

    static func == (lhs: Medication, rhs: Medication) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.dosage == rhs.dosage &&
               lhs.dosageUnit == rhs.dosageUnit &&
               lhs.expectedTimes == rhs.expectedTimes &&
               lhs.actualTimes == rhs.actualTimes &&
                lhs.cycle == rhs.cycle
    }
}
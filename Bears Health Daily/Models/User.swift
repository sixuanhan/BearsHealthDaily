import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var medications: [Medication]

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.medications == rhs.medications
    }
}
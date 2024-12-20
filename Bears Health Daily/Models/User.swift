import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var medications: [Medication]

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.medications == rhs.medications
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
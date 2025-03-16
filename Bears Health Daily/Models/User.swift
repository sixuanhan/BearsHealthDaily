import SwiftUI

struct User: Identifiable, Codable, Hashable {
    var id: String
    var username: String
    var email: String
    var medications: [Medication]
}
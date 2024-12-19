import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let usersKey = "users"
    
    func saveUsers(_ users: [User]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(users) {
            UserDefaults.standard.set(encoded, forKey: usersKey)
        }
    }
    
    func loadUsers() -> [User] {
        if let savedUsers = UserDefaults.standard.object(forKey: usersKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedUsers = try? decoder.decode([User].self, from: savedUsers) {
                return loadedUsers
            }
        }
        return []
    }
}
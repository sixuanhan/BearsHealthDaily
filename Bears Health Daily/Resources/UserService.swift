//
//  UserService.swift
//  Flex
//
//  Created by Kevin Cao on 3/2/25.
//

import Foundation
import Firebase

struct UserService {
    
    @MainActor
    static func fetchAllUsers() async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()

        var users: [User] = []
        for document in snapshot.documents {
            // Manually extract the fields and create User objects
            let data = document.data()
            
            if let fullname = data["username"] as? String,
               let email = data["email"] as? String,
               let medicationsData = data["medications"] as? [[String: Any]] {
                // Deserialize medications
                let medications = medicationsData.compactMap { dict -> Medication? in
                    guard let id = dict["id"] as? String,
                          let name = dict["name"] as? String,
                          let brand = dict["brand"] as? String else {
                        return nil
                    }
                    return Medication(id: UUID(uuidString: id) ?? UUID(), name: name, brand: brand)
                }
                
                // Create the user object manually from the data
                let user = User(id: document.documentID, username: fullname, email: email, medications: medications)
                users.append(user)
            } else {
                print("Failed to parse user data for document: \(document.documentID)")
            }
        }

        return users
    } 
}


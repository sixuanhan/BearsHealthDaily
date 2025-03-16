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
               let medications = data["medications"] as? [Medication] {
                // Create the user object manually from the data
                let user = User(id: document.documentID, username: fullname, email: email, medications: medications)
                users.append(user)
            }
        }

        return users
    } 
}
 

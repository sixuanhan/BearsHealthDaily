//
//  AuthViewModel.swift
//  Flex
//
//  Created by Kevin Cao on 1/12/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    @Published var needsProfileCompletion = false       // Tracks if user still needs to register a Google account
    @Published var alertMessage: AlertMessage?
    
    @Published var loginError: String?

    init() {
        self.userSession = Auth.auth().currentUser
    
        Task {
            await updateUsersWithMedicationsField()
            await fetchUser()
        }
         
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.loginError = nil
            await fetchUser()
        } catch let error as NSError {
            
            print("DEBUG: Firebase Error Code: \(error.code)")
            print("DEBUG: Error Message: \(error.localizedDescription)")
            
            DispatchQueue.main.async {
                switch error.code {
                case 17004, 17008:
                    self.loginError = "Incorrect username or password."
                    
                case 17010:
                    self.loginError = "Too many attempts. Please try again later."
                    
                default:
                    self.loginError = "An unexpected error occurred. Please try again later."
                }
            }
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
    }
    
    private func checkIfUserExists(uid: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userSession = Auth.auth().currentUser
                Task { await self.fetchUser() }
            } else {
                self.alertMessage = AlertMessage(message: "No account found for this Google login. Please sign up first.")
                self.needsProfileCompletion = true
                
                // Capture the current user before signing out so we can delete it
                guard let user = Auth.auth().currentUser else { return }
                
                // Sign the user out immediately
                Task {
                    do {
                        
                        try await user.delete()
                        
                        try Auth.auth().signOut()
                        self.userSession = nil
                        
                        
                    } catch {
                        print("DEBUG: Failed to sign out user: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, username: fullname, email: email, medications: [])
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch let error as NSError {
            if let authError = AuthErrorCode(rawValue: error._code) {
                switch authError {
                case .emailAlreadyInUse:
                    throw AuthError.emailAlreadyInUse
                case .invalidEmail:
                    throw AuthError.invalidEmail
                default:
                    throw AuthError.unknown(error.localizedDescription)
                }
            } else  {
                throw AuthError.unknown(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()   // signs out user on backend
            self.userSession = nil      // wipes out user session and takes us back to login screen
            self.currentUser = nil      // wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user is currently signed in.")
            return
        }
        
        let providerID = user.providerData.first?.providerID
        
        if providerID == "password" {
            
            let alert = UIAlertController(title: "Re-authenticate", message: "Please enter your password to confirm account deletion.", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [weak alert] _ in
                guard let password = alert?.textFields?.first?.text, !password.isEmpty else {
                    print("DEBUG: Password cannot be empty.")
                    return
                }
                
                // Re-authenticate the user with their email and password
                let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
                
                user.reauthenticate(with: credential) { result, error in
                    if let error = error {
                        print("DEBUG: Failed to reauthenticate user: \(error.localizedDescription)")
                        return
                    }
                    
                    // Now proceed with account deletion
                    Task {
                        do {
                            self.userSession = nil
                            self.currentUser = nil
                            
                            let uid = user.uid
                            try await Firestore.firestore().collection("users").document(uid).delete()
                            
                            try await user.delete()
                            
                            print("DEBUG: Account deleted successfully.")
                        } catch {
                            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
                            self.signOut()
                        }
                    }
                }
            }
            alert.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("DEBUG: Account deletion canceled.")
            }
            cancelAction.setValue(UIColor.blue, forKey: "titleTextColor")
            alert.addAction(cancelAction)
            
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
            
        }        
    }
    
    // Only for Google authenticated users
    private func performAccountDeletion() {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No authenticated user found.")
            return
        }

        Task {
            do {
                let uid = user.uid

                // Remove user data from Firestore
                try await Firestore.firestore().collection("users").document(uid).delete()

                // Delete Firebase Authentication account
                try await user.delete()

                // Reset user session
                self.userSession = nil
                self.currentUser = nil

                print("DEBUG: Account deleted successfully.")
            } catch {
                print("DEBUG: Failed to delete account: \(error.localizedDescription)")
                self.signOut()
            }
        }
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        do {
            
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
            
        } catch let error as NSError {
            
            print("DEBUG: Failed to update password: \(error.localizedDescription)")
            
            if error.code == AuthErrorCode.wrongPassword.rawValue {
                throw NSError(domain: "", code: AuthErrorCode.wrongPassword.rawValue,
                              userInfo: [NSLocalizedDescriptionKey: "The current password you entered is incorrect."])
            } else {
                throw error
            }
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No current user ID found.")
            return
        }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            guard let data = snapshot.data() else {
                print("DEBUG: No data found for user ID \(uid).")
                return
            }
            print("DEBUG: Fetched user data: \(data)")
            self.currentUser = try snapshot.data(as: User.self)
            print("DEBUG: Current user is \(String(describing: self.currentUser))")
        } catch {
            print("DEBUG: Error fetching user: \(error.localizedDescription)")
        }
    }

    func updateUsersWithMedicationsField() async {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        do {
            let snapshot = try await usersCollection.getDocuments()
            for document in snapshot.documents {
                var data = document.data()
                if data["medications"] == nil {
                    data["medications"] = [] // Add default empty array for medications
                    try await usersCollection.document(document.documentID).setData(data, merge: true)
                    print("Updated user \(document.documentID) with medications field.")
                }
            }
        } catch {
            print("Error updating users: \(error.localizedDescription)")
        }
    }

    func updateUserInFirestore(_ user: User) async {
        guard let uid = userSession?.uid else {
            print("DEBUG: No current user ID found.")
            return
        }
        do {
            try await Firestore.firestore().collection("users").document(uid).setData(from: user)
            print("DEBUG: User data updated successfully.")
        } catch {
            print("DEBUG: Error updating user data: \(error.localizedDescription)")
        }
    }
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case invalidEmail
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "This email is already in use."
        case .invalidEmail:
            return "Invalid email format. Please enter a valid email."
        case .unknown(let message):
            return message
        }
    }
}

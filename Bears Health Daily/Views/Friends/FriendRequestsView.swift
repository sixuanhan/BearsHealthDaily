//
//  FriendRequestsView.swift
//  Flex
//
//  Created by Kevin Cao on 3/3/25.
//

import SwiftUI

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct FriendRequestsView: View {
    @State private var friendRequests: [User] = [] // Users who sent requests
    
    var body: some View {
        VStack {
            Text("好友申请")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
             

            // If there are no friend requests
            if friendRequests.isEmpty {
                VStack {
                    Image(systemName: "person.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("没有好友申请")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                   
                }
            } else {
                // List of friend requests
                ScrollView {
                    LazyVStack(spacing: 3) {
                        ForEach(friendRequests) { user in
                            NavigationLink(destination: OtherProfileView(user: user)) {
                                HStack {
                                    // User Info
                                    VStack(alignment: .leading) {
                                        Text(user.username)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Text(user.email)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading, 20)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            
                                // Accept and Reject buttons
                                HStack {
                                    Button(action: {
                                        acceptFriendRequest(userId: user.id)
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.green)
                                    }
                                    Button(action: {
                                        rejectFriendRequest(userId: user.id)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.trailing, 12)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarTitle("好友申请", displayMode: .inline)
        .onAppear {
            Task {
                await fetchFriendRequests()
            }
        }
    }
    
    // Fetch friend requests for the current user
    func fetchFriendRequests() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No current user ID found.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Fetch all users who have sent a request to the current user
        let receivedRequests = db.collection("users")
            .document(currentUserId)
            .collection("receivedRequests")
        
        do {
            let snapshot = try await receivedRequests.getDocuments()
            var users: [User] = []

            // Fetch user data for each friend request
            for document in snapshot.documents {
                let userId = document.documentID
                
                // Fetch user data from the 'users' collection using the UserID
                let userDoc = db.collection("users").document(userId)
                let userSnapshot = try await userDoc.getDocument()
                
                if let userData = try? userSnapshot.data(as: User.self) {
                    users.append(userData)
                }
            }
            
            // Update the state
            DispatchQueue.main.async {
                self.friendRequests = users
            }
            
            // Debug line to check if users are populated
            // print("Friend requests: \(users)")
            
        } catch {
            print("Error fetching friend requests: \(error)")
        }
    }

    // Accept a friend request
    func acceptFriendRequest(userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        // Move to the "friends" collection
        db.collection("users").document(currentUserId).collection("friends").document(userId).setData([:]) { error in
            if let error = error {
                print("Error accepting friend request: \(error)")
            } else {
                // Add to the other user's friends collection as well
                db.collection("users").document(userId).collection("friends").document(currentUserId).setData([:]) { error2 in
                    if let error2 = error2 {
                        print("Erroring accepting friend request: \(error2)")
                    }
                }
                
                // Remove from the receivedRequests and sentRequests collections
                db.collection("users").document(currentUserId).collection("receivedRequests").document(userId).delete() { error2 in
                    if let error2 = error2 {
                        print("Erroring removing friend request: \(error2)")
                    }
                }
                db.collection("users").document(userId).collection("sentRequests").document(currentUserId).delete() { error2 in
                    if let error2 = error2 {
                        print("Erroring removing friend request: \(error2)")
                    }
                }
                
                // Update the UI quicker
                DispatchQueue.main.async {
                    if let index = friendRequests.firstIndex(where: { $0.id == userId }) {
                        friendRequests.remove(at: index)
                    }
                } 
            }
        }
    }
    
    // Reject a friend request
    func rejectFriendRequest(userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        // Remove from the receivedRequests and sentRequests collections
        db.collection("users").document(currentUserId).collection("receivedRequests").document(userId).delete() { error2 in
            if let error2 = error2 {
                print("Erroring rejecting friend request: \(error2)")
            }
        }
        
        db.collection("users").document(userId).collection("sentRequests").document(currentUserId).delete() { error2 in
            if let error2 = error2 {
                print("Erroring rejecting friend request: \(error2)")
            }
        }
        
        // Update the UI quicker
        DispatchQueue.main.async {
            if let index = friendRequests.firstIndex(where: { $0.id == userId }) {
                friendRequests.remove(at: index)
            }
        }
    }
}

#Preview {
    FriendRequestsView()
}

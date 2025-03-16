//
//  FriendsView.swift
//  Flex
//
//  Created by Kevin Cao on 3/2/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct FriendsView: View {
    @State private var isSearchViewPresented = false
    @State private var isFriendRequestsViewPresented = false
    @State private var unreadRequestsCount: Int = 0
    @State private var friends: [User] = []    
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {      
                searchField
                
                if friends.isEmpty {
                    noFriendsPlaceholder
                } else {
                    friendsList
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FriendRequestsView(), isActive: $isFriendRequestsViewPresented) {
                        Button(action: {
                            isFriendRequestsViewPresented.toggle()
                        }) {
                            Image(systemName: "bell")
                                .imageScale(.large)
                                .foregroundColor(.blue)
                                .overlay(
                                    Group {
                                        if unreadRequestsCount > 0 {
                                            Text("\(unreadRequestsCount)")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .padding(3)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                                .offset(x: 9, y: -12)
                                        }
                                    }
                                )
                        }
                    }
                    
                    NavigationLink(destination: SearchView(), isActive: $isSearchViewPresented) {
                        Button(action: {
                            isSearchViewPresented.toggle()
                        }) {
                            Image(systemName: "person.badge.plus")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                Task {
                    await fetchFriends(query: searchText)
                }
            }
            .onAppear {
                Task {
                    await fetchFriendRequestCount()
                    await fetchFriends(query: "")
                }
            }
        }
    }
    
    private var searchField: some View {
        HStack {
            TextField("Search...", text: $searchText)
                .padding(7)
                .padding(.leading, 40)  // Add space for the magnifying glass
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.leading, 0)
                )
                .frame(width: 360)
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 15)
    }
    
    private var noFriendsPlaceholder: some View {
        VStack {   
            Spacer(minLength: 40)
            
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)
            
            Text("No friends found!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.top, 20)
            
            Text("Explore other accounts to connect with.")
                .foregroundColor(.gray)
                .font(.system(size: 15))
                .padding(.top, 3)
            
            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 20)
        .multilineTextAlignment(.center)
    }
    
    private var friendsList: some View {
        ScrollView {
            LazyVStack(spacing: 3) {
                ForEach(friends) { friend in
                    NavigationLink(destination: OtherProfileView(user: friend)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(friend.username)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Text(friend.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            .padding(.leading, 20) // Add padding to the leading edge
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    func fetchFriendRequestCount() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No current user found.")
            return
        }
        
        let db = Firestore.firestore()
        let receivedRequests = db.collection("users").document(currentUserId).collection("receivedRequests")
        
        do {
            let snapshot = try await receivedRequests.getDocuments()
            self.unreadRequestsCount = snapshot.documents.count // Set the number of friend requests
            print("\(unreadRequestsCount)")
        } catch {
            print("Error fetching friend requests count: \(error)")
        }
    }
    
    func fetchFriends(query: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No current user found.")
            return
        }
        
        let db = Firestore.firestore()
        let friendsCollection = db.collection("users").document(currentUserId).collection("friends")
        
        do {
            let snapshot = try await friendsCollection.getDocuments()
            var users: [User] = []
            
            for document in snapshot.documents {
                let userId = document.documentID
                let userDoc = db.collection("users").document(userId)
                
                // Fetch user data for each friend using the user ID
                let userSnapshot = try await userDoc.getDocument()
                
                if let userData = try? userSnapshot.data(as: User.self) {
                    
                    if query.isEmpty || userData.username.lowercased().contains(query.lowercased()) || userData.email.lowercased().contains(query.lowercased()) {
                        
                        users.append(userData)
                    }
                }
            }
            
            // Update the friends list
            DispatchQueue.main.async {
                self.friends = users
            }
            
            print("Friends: \(users)")
            
        } catch {
            print("Error fetching friends: \(error)")
        }
    }
}

#Preview {
    FriendsView()
}

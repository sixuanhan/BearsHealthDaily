//
//  SearchView.swift
//  Flex
//
//  Created by Kevin Cao on 3/2/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct SearchView: View {
    @State private var searchText = ""
    @State private var users: [User] = []

    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {     
            TextField("搜索...", text: $searchText)
                .padding(7)
                .padding(.leading, 35)  // Add space for the magnifying glass
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
           
            if searchText.isEmpty {
                
                Spacer(minLength: 100)
                
                Text("输入电子邮箱或用户名来搜索...")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                
                // Optionally add a magnifying glass icon to suggest search functionality
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 40))
                    .padding(.top, 10)
                
                Spacer(minLength: 100)            
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(users) { user in
                            NavigationLink(destination: OtherProfileView(user: user)) {
                                HStack {                                    
                                    VStack(alignment: .leading) {
                                        Text(user.email)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Text(user.username)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .font(.footnote)
                                    .padding(.leading, 20)
                                    
                                    Spacer()
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
            }
        }
        .navigationBarTitle("添加好友", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .onChange(of: searchText) { newValue in
            Task {
                await searchUsers(query: newValue)
            }
        }
        .onAppear {
            Task {
                await searchUsers(query: "")
            }
        }
    }
    
    func searchUsers(query: String) async {
        do {
            let allUsers = try await UserService.fetchAllUsers()
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            let filteredUsers = allUsers.filter { $0.id != currentUserId }      // Don't include the user
            if query.isEmpty {
                users = filteredUsers
            } else {
                users = filteredUsers.filter { $0.username.lowercased().contains(query.lowercased()) || $0.email.lowercased().contains(query.lowercased()) }
            }
        } catch {
            print("Error fetching users: \(error)")
        }
    }
}

#Preview {
    SearchView()
}

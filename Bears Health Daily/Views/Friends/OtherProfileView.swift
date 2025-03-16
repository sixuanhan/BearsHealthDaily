//
//  OtherProfileView.swift
//  Flex
//
//  Created by Kevin Cao on 3/3/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Charts

struct OtherProfileView: View {
    @State private var friendStatus: String = "发送好友申请"
    @State private var isFriendRequestPending: Bool = false
    @State private var isUnfriendConfirmationPresented: Bool = false
    @State private var userState: User
    @State private var navigationSelection: Medication?
    var user: User
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    init(user: User) {
        self.user = user
        self._userState = State(initialValue: user)
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Basic profile info
                VStack(alignment: .center, spacing: 10) {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 3)
                
                // Friend request status
                Button(action: {
                    handleFriendRequest()
                }) {               
                    Text(friendStatus)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(friendStatus == "已是好友" ? Color.green : (friendStatus == "发送好友申请" ? Color.blue : Color.gray))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                 if friendStatus == "已是好友" {
                    SimpleListView(user: $userState, navigationSelection: $navigationSelection)
                    .navigationDestination(for: Medication.self) { medication in
                        MedicationDetailsView(medication: medication)
                    }
                 } else {
                     Spacer()
                     VStack {
                         Image(systemName: "lock.fill")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 90, height: 90)
                             .foregroundColor(.gray)
                        
                         Text("添加好友以查看药物")
                             .font(.headline)
                             .foregroundColor(.gray)
                             .padding(.top, 10)
                     }
                     .padding(.horizontal)
                     Spacer()
                 }
            }
            .onAppear {
                Task {
                    await checkFriendStatus(for: user.id)
                }
            }
            .confirmationDialog("确定要移除 \(user.username) 吗?", isPresented: $isUnfriendConfirmationPresented, titleVisibility: .visible) {
                Button("移除好友", role: .destructive) {
                    unfriendUser(db: Firestore.firestore(), currentUserId: Auth.auth().currentUser?.uid ?? "")
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
    
    // Check if there's an active friend request or already a friend
    func checkFriendStatus(for userId: String) async {
        let db = Firestore.firestore()
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Fetch sent and received requests
        let sentRequestDoc = db.collection("users").document(currentUserId).collection("sentRequests").document(userId)
        let receivedRequestDoc = db.collection("users").document(currentUserId).collection("receivedRequests").document(userId)
        let friendsDoc = db.collection("users").document(currentUserId).collection("friends").document(userId)
        
        let sentRequest = try? await sentRequestDoc.getDocument()
        let receivedRequest = try? await receivedRequestDoc.getDocument()
        let isFriend = try? await friendsDoc.getDocument()
        
        DispatchQueue.main.async {
            if let _ = isFriend?.data() {
                friendStatus = "已是好友"
            } else if let _ = sentRequest?.data() {
                friendStatus = "等待对方接受好友申请"
            } else if let _ = receivedRequest?.data() {
                friendStatus = "接受好友申请"
            } else {
                friendStatus = "发送好友申请"
            }
        }
    }
    
    func handleFriendRequest() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No current user found.")
            return
        }
        
        let db = Firestore.firestore()

        if friendStatus == "发送好友申请" {
            // Send a request
            sendFriendRequest(db: db, currentUserId: currentUserId)
        } else if friendStatus == "等待对方接受好友申请" {
            // Cancel request
            cancelFriendRequest(db: db, currentUserId: currentUserId)
        } else if friendStatus == "接受好友申请" {
            // Accept request
            acceptFriendRequest(db: db, currentUserId: currentUserId)
        } else if friendStatus == "已是好友" {
            // Unfriend
            // unfriendUser(db: db, currentUserId: currentUserId)
            isUnfriendConfirmationPresented = true
        }
    }

         
    func sendFriendRequest(db: Firestore, currentUserId: String) {
        db.collection("users").document(currentUserId).collection("sentRequests").document(user.id).setData([:]) { error in
            if let error = error {
                print("Error sending friend request: \(error)")
            } else {
                // Add to the receivedRequests of the other user
                db.collection("users").document(user.id).collection("receivedRequests").document(currentUserId).setData([:]) { error2 in
                    if let error2 = error2 {
                        print("Erroring receiving friend request: \(error2)")
                    }
                }
                // Update friendStatus on the main thread
                DispatchQueue.main.async {
                    self.friendStatus = "等待对方接受好友申请"
                }
            }
        }
    }
    
    func cancelFriendRequest(db: Firestore, currentUserId: String) {
        db.collection("users").document(currentUserId).collection("sentRequests").document(user.id).delete { error in
            if let error = error {
                print("Error canceling friend request: \(error)")
            } else {
                // Remove from the receivedRequests of the other user
                db.collection("users").document(user.id).collection("receivedRequests").document(currentUserId).delete() { error2 in
                    if let error2 = error2 {
                        print("Erroring receiving canceling of friend request: \(error2)")
                    }
                }
                // Update friendStatus on the main thread
                DispatchQueue.main.async {
                    self.friendStatus = "发送好友申请"
                }
            }
        }
    }
    
    func acceptFriendRequest(db: Firestore, currentUserId: String) {
        db.collection("users").document(currentUserId).collection("friends").document(user.id).setData([:]) { error in
            if let error = error {
                print("Error adding friend: \(error)")
            } else {
                // Add to the other user's friends collection
                db.collection("users").document(user.id).collection("friends").document(currentUserId).setData([:]) { error2 in
                    if let error2 = error2 {
                        print("Erroring confirming friend request: \(error2)")
                    }
                }
                // Remove from sent and received requests
                db.collection("users").document(currentUserId).collection("receivedRequests").document(user.id).delete() { error2 in
                    if let error2 = error2 {
                        print("Erroring removing friend request: \(error2)")
                    }
                }
                db.collection("users").document(user.id).collection("sentRequests").document(currentUserId).delete() { error2 in
                    if let error2 = error2 {
                        print("Erroring receiving friend request: \(error2)")
                    }
                }
                // Update friendStatus on the main thread
                DispatchQueue.main.async {
                    self.friendStatus = "已是好友"
                }
            }
        }
    }
    
    func unfriendUser(db: Firestore, currentUserId: String) {
        // Remove from friends collection for both users
        db.collection("users").document(currentUserId).collection("friends").document(user.id).delete { error in
            if let error = error {
                print("Error removing friend: \(error)")
            } else {
                // Also remove the other user from the current user's friends collection
                db.collection("users").document(user.id).collection("friends").document(currentUserId).delete { error2 in
                    if let error2 = error2 {
                        print("Error removing friend from other user's collection: \(error2)")
                    }
                }
                         
                // Update friendStatus on the main thread
                DispatchQueue.main.async {
                    self.friendStatus = "发送好友申请"  // After unfriending, the option goes back to "Send Friend Request"
                }
            }
        }
    }
}

#Preview {
    OtherProfileView(user: User(id: "123", username: "kevin", email: "kevin@example.com", medications: [Medication(id: UUID(), name: "some name", brand: "some brand"), Medication(id: UUID(), name: "some name2", brand: "some brand2")]))
        .environmentObject(AuthViewModel())
}

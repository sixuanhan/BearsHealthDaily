//
//  ProfileView.swift
//  Flex
//
//  Created by Selena Han on 10/14/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct ProfileView: View {
    @State private var showDeleteAccountAlert = false
    @State private var navigateToLoginView = false
    @State private var alertMessage: String? = nil
    
    @State private var showSignOutAlert = false
    
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationView {
            if let user = viewModel.currentUser {
                Form {         
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(user.username)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section("Account") {
                        NavigationLink(destination: ChangePasswordView()) {
                            SettingsRowView(imageName: "key.fill",
                                            title: "Change Password",
                                            textColor: .primary)
                        }
                        
                        Button {
                            showSignOutAlert = true
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill",
                                            title: "Sign Out",
                                            textColor: .primary)
                        }
                        .alert(isPresented: $showSignOutAlert) {
                            Alert(
                                title: Text("Sign Out"),
                                message: Text("Are you sure you want to sign out?"),
                                primaryButton: .destructive(Text("Sign Out")) {
                                    viewModel.signOut()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                        Button {
                            showDeleteAccountAlert = true
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill",
                                            title: "Delete Account",
                                            tintColor: .red,
                                            textColor: .red)
                        }
                        .alert(isPresented: $showDeleteAccountAlert) {
                            Alert(
                                title: Text("Delete Account"),
                                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    viewModel.deleteAccount()
                                    navigateToLoginView = true
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .navigationBarTitle("Profile")
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func showAlert(title: String, message: String) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        rootViewController.present(alert, animated: true, completion: nil)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

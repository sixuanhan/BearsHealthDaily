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
                    
                    Section("账号") {
                        NavigationLink(destination: ChangePasswordView()) {
                            SettingsRowView(imageName: "key.fill",
                                            title: "更改密码",
                                            textColor: .primary)
                        }
                        
                        Button {
                            showSignOutAlert = true
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill",
                                            title: "登出账号",
                                            textColor: .primary)
                        }
                        .alert(isPresented: $showSignOutAlert) {
                            Alert(
                                title: Text("登出"),
                                message: Text("确定要登出吗？"),
                                primaryButton: .destructive(Text("登出")) {
                                    viewModel.signOut()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                        Button {
                            showDeleteAccountAlert = true
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill",
                                            title: "删除账号",
                                            tintColor: .red,
                                            textColor: .red)
                        }
                        .alert(isPresented: $showDeleteAccountAlert) {
                            Alert(
                                title: Text("删除账号"),
                                message: Text("确定要删除账号吗？此操作不可逆。"),
                                primaryButton: .destructive(Text("删除")) {
                                    viewModel.deleteAccount()
                                    navigateToLoginView = true
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .navigationBarTitle("账号")
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

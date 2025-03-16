//
//  ChangePasswordView.swift
//  Flex
//
//  Created by Kevin Cao on 2/18/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var passwordErrorMessage = ""
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false
    @State private var showIncorrectPasswordAlert = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            Text("更改密码")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 9)

            VStack(alignment: .leading, spacing: 9) {
                InputView(text: $currentPassword,
                          title: "当前密码",
                          placeholder: "请输入当前的密码",
                          isSecureField: true)

                VStack(alignment: .leading, spacing: 9) {
                    InputView(text: $newPassword,
                              title: "新密码",
                              placeholder: "请输入新的密码",
                              isSecureField: true)
                    .onChange(of: newPassword) {
                        validatePassword()
                    }
                    
                    if !passwordErrorMessage.isEmpty {
                        Text(passwordErrorMessage)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .transition(.opacity)
                            .animation(.easeInOut, value: passwordErrorMessage)
                    }
                }
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "确认新密码",
                              placeholder: "请再次输入新密码",
                              isSecureField: true)
                    
                    if !newPassword.isEmpty && !confirmPassword.isEmpty {
                        if newPassword == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            Button {
                Task {
                    await changePassword()
                }
            } label: {
                HStack {
                    Text("更新密码")
                        .fontWeight(.semibold)
                    Image(systemName: "lock.rotation")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)

            Spacer()
        }
        .padding()
        .alert("密码错误", isPresented: $showIncorrectPasswordAlert, actions: {
            Button("Close", role: .cancel) {}
        }, message: {
            Text("请重试")
        })
        .alert("已更新密码", isPresented: $showSuccessAlert, actions: {
            Button("关闭") { dismiss() }
        }, message: {
            Text("你的密码已经成功更新")
        })
    }

    private func validatePassword() {
        if newPassword.count < 6 {
            passwordErrorMessage = "Password must be at least 6 characters."
        } else {
            passwordErrorMessage = ""
        }
        
        if newPassword.isEmpty {
            passwordErrorMessage = ""
        }
    }

    private func changePassword() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "用户未登录"
            clearFields()
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "密码不匹配"
            return
        }

        do {
            try await viewModel.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
            clearFields()
            showSuccessAlert = true
            errorMessage = ""
        } catch {
            clearFields()
            showIncorrectPasswordAlert = true
        }
    }

    private var formIsValid: Bool {
        return !currentPassword.isEmpty &&
               !newPassword.isEmpty &&
               !confirmPassword.isEmpty &&
               newPassword.count >= 6
    }
    
    private func clearFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
    
}

#Preview {
    ChangePasswordView()
}

//
//  RegistrationView.swift
//  Flex
//
//  Created by Kevin Cao on 1/12/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordErrorMessage = ""
    @State private var emailErrorMessage = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            InputView(text: $email,
                      title: "电子邮箱",
                      placeholder: "name@example.com")
            .autocapitalization(.none)
            .onChange(of: email) {
                emailErrorMessage = ""  // Clear error when user types
            }
            
            if !emailErrorMessage.isEmpty {
                Text(emailErrorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .transition(.opacity)
                    .animation(.easeInOut, value: emailErrorMessage)
            }
            
            InputView(text: $fullname,
                      title: "姓名",
                      placeholder: "张伟")
            
            VStack(alignment: .leading, spacing: 9) {
                InputView(text: $password,
                          title: "密码",
                          placeholder: "123456",
                          isSecureField: true)
                .onChange(of: password) {
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
                          title: "确认密码",
                          placeholder: "请确认密码",
                          isSecureField: true)
                
                if !password.isEmpty && !confirmPassword.isEmpty {
                    if password == confirmPassword {
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
        
        Button {
            Task {
                do {
                    try await viewModel.createUser(withEmail: email,
                                                   password: password,
                                                   fullname: fullname)
                } catch let error as AuthError {
                    switch error {
                    case .emailAlreadyInUse:
                        emailErrorMessage = error.localizedDescription
                    case .invalidEmail:
                        emailErrorMessage = error.localizedDescription
                    case .unknown(let message):
                        emailErrorMessage = message // Generic error message
                    }
                }
            }
        } label: {
            HStack {
                Text("注册")
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
        }
        .background(Color(.systemBlue))
        .disabled(!formIsValid)
        .opacity(formIsValid ? 1.0 : 0.5)
        .cornerRadius(10)
        .padding(.top, 24)
        .alert(item: $viewModel.alertMessage) { alert in
            Alert(title: Text("注册失败"),
                  message: Text(alert.message))
        }
        
        Spacer()
        
        Button {
            dismiss()
        } label: {
            HStack(spacing: 3) {
                Text("已经有了账号？")
                Text("登入")
                    .fontWeight(.bold)
            }
            .font(.system(size: 14))
        }
        
    }
    
    private func validatePassword() {
        if password.count < 6 {
            passwordErrorMessage = "密码至少需要6个字符"
        } else {    // Consider adding more logic here
            passwordErrorMessage = ""
        }
        
        if password.isEmpty {
            passwordErrorMessage = ""
        }
    }
    
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}

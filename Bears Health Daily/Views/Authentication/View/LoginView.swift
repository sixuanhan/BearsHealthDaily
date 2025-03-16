//
//  LoginView.swift
//  Flex
//
//  Created by Kevin Cao on 1/12/25.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "电子邮箱",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    .onChange(of: email) {
                        viewModel.loginError = nil
                    }
                    
                    InputView(text: $password,
                              title: "密码",
                              placeholder: "123456",
                              isSecureField: true)
                    .onChange(of: password) {
                        viewModel.loginError = nil
                    }
                    
                    if let errorMessage = viewModel.loginError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // sign in button
                Button {
                    Task {
                        do {
                            try await viewModel.signIn(withEmail: email, password: password)
                        } catch {
                            if viewModel.loginError == "邮箱或密码不正确" {
                                email = ""
                                password = ""
                            }
                        }
                        email = ""
                        password = ""
                    }
                } label: {
                    HStack {
                        Text("登入")
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
                 
                Spacer()
                
                // sign up button
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                        .environment(\.colorScheme, .light) // Force light mode for this view
                } label: {
                    HStack(spacing: 3) {
                        Text("没有账号？")
                        Text("注册")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
                
            }
        }
        .alert(item: $viewModel.alertMessage) { alert in
            Alert(title: Text("登入失败"),
                  message: Text(alert.message))
        }
        .environment(\.colorScheme, .light) // Force light mode for this view
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

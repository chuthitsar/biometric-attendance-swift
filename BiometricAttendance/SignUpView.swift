//
//  SignUpView.swift
//  BiometricAttendance
//
//  Created by Chu Thit Sar on 8/6/24.
//

import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var isEmailValid = false
    @State private var navigateToPasswordSetup = false
    @State private var navigateToSignIn = false

    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: email) { newValue in
                    isEmailValid = isValidEmail(email)
                }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            NavigationLink(destination: PasswordSetUpView(name: name, email: email), isActive: $navigateToPasswordSetup) {
                Button(action: {
                    if name.isEmpty || email.isEmpty {
                        errorMessage = "All fields are required"
                        return
                    }
                    if !isEmailValid {
                        errorMessage = "Invalid email address"
                        return
                    }
                    navigateToPasswordSetup = true
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Text("OR")
            
            NavigationLink(destination: SignInView(), isActive: $navigateToSignIn) {
                Button(action: {
                    navigateToSignIn = true
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}


#Preview {
    SignUpView()
}

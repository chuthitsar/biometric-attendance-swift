//
//  PasswordSetUpView.swift
//  BiometricAttendance
//
//  Created by Chu Thit Sar on 8/6/24.
//

import SwiftUI
import CoreData

struct PasswordSetUpView: View {
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var navigateToSignIn = false
    @Environment(\.managedObjectContext) private var viewContext

    var name: String
    var email: String

    var body: some View {
        VStack {
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                if password.isEmpty || confirmPassword.isEmpty {
                    errorMessage = "All fields are required"
                    return
                }
                if password != confirmPassword {
                    errorMessage = "Passwords do not match"
                    return
                }
                saveUser(name: name, email: email, password: password)
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            NavigationLink(destination: SignInView(), isActive: $navigateToSignIn) {
                EmptyView()
            }
        }
        .padding()
    }

    func saveUser(name: String, email: String, password: String) {
        let newUser = User(context: viewContext)
        newUser.name = name
        newUser.email = email
        newUser.password = password
        newUser.biometricRegistered = false

        do {
            try viewContext.save()
            navigateToSignIn = true // Navigate to SignInView after successful signup
        } catch {
            let nsError = error as NSError
            errorMessage = "Unresolved error \(nsError), \(nsError.userInfo)"
        }
    }
}

#Preview {
    PasswordSetUpView(name: "Liz", email: "liz@gmail.com")
}

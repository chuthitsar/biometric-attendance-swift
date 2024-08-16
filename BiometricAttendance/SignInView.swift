//
//  SignInView.swift
//  BiometricAttendance
//
//  Created by Chu Thit Sar on 8/6/24.
//

import SwiftUI
import CoreData

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var navigateToHome = false
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentUserEmail = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: signIn) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            NavigationLink(destination: HomeView(currentUserEmail: currentUserEmail), isActive: $navigateToHome) {
                EmptyView()
            }
        }
        .padding()
    }

    func signIn() {
        // Validate credentials against CoreData
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)

        do {
            let users = try viewContext.fetch(fetchRequest)
            if let user = users.first {
                // Credentials are valid, navigate to HomeView
                currentUserEmail = user.email ?? ""
                navigateToHome = true
            } else {
                // Invalid credentials
                errorMessage = "Invalid email or password"
            }
        } catch {
            errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
        }
    }
}


#Preview {
    SignInView()
}

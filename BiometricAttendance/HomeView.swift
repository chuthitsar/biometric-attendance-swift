//
//  HomeView.swift
//  BiometricAttendance
//
//  Created by Chu Thit Sar on 8/6/24.
//

import SwiftUI
import LocalAuthentication
import CoreLocation
import CoreData
import Combine

struct HomeView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var locationManager = LocationManager.shared
    @State private var currentUser: User?
    @State private var hasCheckedIn = false
    @State private var hasCheckedOut = false
    @State var tokens: Set<AnyCancellable> = []
    @State var coordinates: (lat: Double, lon: Double) = (0, 0)

    var currentUserEmail: String

    var body: some View {
        VStack {
            Button(action: checkIn) {
                Text("Check In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom)

            Button(action: checkOut) {
                Text("Check Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            fetchCurrentUser()
            checkAttendanceStatus()
        }
    }

    func fetchCurrentUser() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", currentUserEmail)

        do {
            let users = try viewContext.fetch(fetchRequest)
            currentUser = users.first
        } catch {
            alertMessage = "Failed to fetch user data: \(error.localizedDescription)"
            showAlert = true
        }
    }

    func checkAttendanceStatus() {
        guard let user = currentUser else { return }

        let fetchRequest: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@ AND timestamp >= %@ AND timestamp < %@", user, startOfDay() as NSDate, endOfDay() as NSDate)

        do {
            let attendances = try viewContext.fetch(fetchRequest)
            hasCheckedIn = attendances.contains { $0.type == "Check-In" }
            hasCheckedOut = attendances.contains { $0.type == "Check-Out" }
        } catch {
            print("Failed to fetch attendance data: \(error.localizedDescription)")
        }
    }
    
    func observeCoordinateUpdates() {
            locationManager.coordinatesPublisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print("Handle \(completion) for error and finished subscription.")
                } receiveValue: { coordinates in
                    self.coordinates = (coordinates.latitude, coordinates.longitude)
                }
                .store(in: &tokens)
        }

        func observeDeniedLocationAccess() {
            locationManager.deniedLocationAccessPublisher
                .receive(on: DispatchQueue.main)
                .sink {
                    print("Handle access denied event, possibly with an alert.")
                }
                .store(in: &tokens)
        }

    func checkIn() {
      guard let user = currentUser else {
        alertMessage = "User not found"
        showAlert = true
        return
      }

      if hasCheckedIn {
        alertMessage = "You have already checked in for the day"
        showAlert = true
        return
      }

      if user.biometricRegistered {
        authenticateUser { success, error in // Case 2
          if success {
            observeCoordinateUpdates()
            observeDeniedLocationAccess()
            locationManager.requestLocationUpdates()
              if verifyLocation(latitude: coordinates.lat, longitude: coordinates.lon) { // Check location
                  saveAttendance(type: "Check-In", latitude: coordinates.lat, longitude: coordinates.lon)
                alertMessage = "Check-In successful"
                hasCheckedIn = true
              } else {
                alertMessage = "You are not at the office location. Cannot Check-In!"
              }
          } else {
            alertMessage = "Biometric authentication failed" // Biometric mismatch (Case 2b)
          }
          showAlert = true
        }
      } else {
        promptForBiometricRegistration { success in // Case 1
          if success {
            user.biometricRegistered = true
            saveUser(user)
            alertMessage = "Biometric registered successfully. Please try to check in again."
          } else {
            alertMessage = "Biometric registration failed."
          }
          showAlert = true
        }
      }
    }

    func checkOut() {
        guard let user = currentUser else {
            alertMessage = "User not found"
            showAlert = true
            return
        }

        if hasCheckedOut {
            alertMessage = "You have already checked out for the day"
            showAlert = true
            return
        }

        if user.biometricRegistered {
            authenticateUser { success, error in
                if success {
                    observeCoordinateUpdates()
                    observeDeniedLocationAccess()
                    locationManager.requestLocationUpdates()
                      if verifyLocation(latitude: coordinates.lat, longitude: coordinates.lon) { // Check location
                          saveAttendance(type: "Check-Out", latitude: coordinates.lat, longitude: coordinates.lon)
                        alertMessage = "Check-Out successful"
                        hasCheckedOut = true
                      } else {
                        alertMessage = "You are not at the office location. Cannot Check-Out!"
                      }
                } else {
                    alertMessage = "Biometric authentication failed"
                }
                showAlert = true
            }
        } else {
            promptForBiometricRegistration { success in
                if success {
                    user.biometricRegistered = true
                    saveUser(user) // Save the user's biometric registration status to the database
                    alertMessage = "Biometric registered successfully. Please try to check out again."
                } else {
                    alertMessage = "Biometric registration failed."
                }
                showAlert = true
            }
        }
    }

    func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to mark attendance."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success, authenticationError)
                }
            }
        } else {
            completion(false, error)
        }
    }
    
    func promptForBiometricRegistration(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            print("Biometric authentication is not available: \(error?.localizedDescription ?? "Unknown error")")
            completion(false)
        }

    }

    func verifyLocation(latitude: Double, longitude: Double) -> Bool {
        let officeLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Actual office location
        let distance = CLLocation(latitude: latitude, longitude: longitude).distance(from: CLLocation(latitude: officeLocation.latitude, longitude: officeLocation.longitude))
        return distance < 100 // Allowable distance in meters
    }

    func saveAttendance(type: String, latitude: Double, longitude: Double) {
        let newAttendance = Attendance(context: viewContext)
        newAttendance.timestamp = Date()
        newAttendance.type = type
        newAttendance.latitude = latitude
        newAttendance.longitude = longitude
        newAttendance.user = currentUser

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func saveUser(_ user: User) {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }

    func endOfDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: startOfDay())!
    }
}

#Preview {
    HomeView(currentUserEmail: "liz@gmail.com")
}



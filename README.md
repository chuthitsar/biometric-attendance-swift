# Biometric Attendance iOS App

A SwiftUI-based iOS application designed to manage employee attendance using biometric authentication. This project includes features like signup, sign-in, check-in/check-out functionality, and error handling for common networking issues.

## Features

- **Signup and Sign-in:** 
  - Users can sign up with their name, email, and password.
  - Email validation is implemented to ensure the entered email is valid.
  - User data is stored securely using Core Data.

- **Biometric Authentication:** 
  - Users can register their biometric data (Face ID/Touch ID).
  - Biometric data is used for check-in/check-out actions, ensuring secure attendance marking.

- **Check-in/Check-out:**
  - Users can check-in or check-out once their biometric data is verified.
  - Location-based verification ensures users are on office premises.

- **Error Handling:**
  - Custom error messages are shown using alerts.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/biometric-attendance-ios.git
    cd biometric-attendance-ios
    ```

2. Open the project in Xcode:
    ```bash
    open BiometricAttendance.xcodeproj
    ```

3. Build and run the app on a simulator or physical device.

## Project Structure

- `ContentViewModel.swift`: The view model containing the business logic for fetching data, handling errors, and managing the app's state.
- `ContentView.swift`: The main SwiftUI view where the UI is defined, displaying posts and handling user interaction.
- `Post.swift`: The model for representing posts fetched from the API.
- `CoreData`: Core Data implementation for storing user data locally.

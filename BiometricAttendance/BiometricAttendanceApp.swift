//
//  BiometricAttendanceApp.swift
//  BiometricAttendance
//
//  Created by Chu Thit Sar on 8/6/24.
//

import SwiftUI

@main
struct BiometricAttendanceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

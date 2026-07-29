//
//  UnstuckApp.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/6/26.
//

import SwiftUI
import SwiftData
import FirebaseAuth
import FirebaseCore

@main
struct UnstuckApp: App {
    init() {
        FirebaseApp.configure()
        // Local-first auth is the source of truth; clear any older Firebase session.
        try? Auth.auth().signOut()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: [
            LocalProfile.self,
            LocalWeeklyCheckin.self
        ])
    }
}

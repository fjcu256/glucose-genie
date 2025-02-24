//
//  GlucoseGenieApp.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 2/17/25.
//

import SwiftUI
import SwiftData
import Amplify

@main
struct GlucoseGenieApp: App {
    init() {
        configureAmplify()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func configureAmplify() {
        do {
            try Amplify.configure()
            print("Amplify sucessfully configured")
        } catch {
            print("Could not configure Amplify")
        }
    }
}

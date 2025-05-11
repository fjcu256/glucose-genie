//
//  GlucoseGenieApp.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 2/17/25.

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin

@main
struct GlucoseGenieApp: App {
    init() {
        configureAmplify()
    }

    // Make AuthenticationService a @StateObject so its state
    // (isSignedIn) persists across the entire app.
    @StateObject private var authService = AuthenticationService()
    @StateObject private var recipeStore = RecipeStore()

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(authService)
                .environmentObject(recipeStore)
        }
    }

    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            print("Amplify successfully configured")
        } catch {
            print("Could not configure Amplify")
        }
    }
}

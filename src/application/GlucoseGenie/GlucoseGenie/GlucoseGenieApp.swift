//
//  GlucoseGenieApp.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 2/17/25.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin

@main
struct GlucoseGenieApp: App {
    init() {
        configureAmplify()
    }

    var body: some Scene {
        WindowGroup {
            LandingView().environmentObject(AuthenticationService())
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

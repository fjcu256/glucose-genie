//
//  AuthenticationService.swift
//  GlucoseGenie
//
//  Created by Francisco Cruz-Urbanc on 2/23/25.

import Amplify
import AuthenticationServices
import AWSCognitoAuthPlugin
import SwiftUI

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isSignedIn = false

    // Fetch the current auth session and update `isSignedIn`
    func fetchSession() async {
        do {
            let result = try await Amplify.Auth.fetchAuthSession()
            isSignedIn = result.isSignedIn
            print("Fetch session completed. isSignedIn = \(isSignedIn)")
        } catch {
            print("Fetch Session failed with error: \(error)")
        }
    }

    // Show the Hosted UI if *not* already signed in
    func signIn(presentationAnchor: ASPresentationAnchor) async {
        guard !isSignedIn else {
            print("Already signed in; skipping signIn()")
            return
        }
        do {
            let result = try await Amplify.Auth.signInWithWebUI(
                presentationAnchor: presentationAnchor,
                options: .preferPrivateSession()
            )
            isSignedIn = result.isSignedIn
            print("Sign In completed. isSignedIn = \(isSignedIn)")
        } catch {
            print("Sign In failed with error: \(error)")
        }
    }

    // Sign out the current user
    func signOut() async {
        guard let result = await Amplify.Auth.signOut() as? AWSCognitoSignOutResult else {
            return
        }
        switch result {
        case .complete, .partial:
            isSignedIn = false
        case .failed:
            break
        }
        print("Sign Out completed. isSignedIn = \(isSignedIn)")
    }
}

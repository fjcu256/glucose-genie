//
//  AuthenticationService.swift
//  GlucoseGenie
//

import Amplify
import AuthenticationServices
import AWSCognitoAuthPlugin
import SwiftUI

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isSignedIn = false

    func fetchSession() async {
        #if DEBUG_BYPASS_AUTH
        isSignedIn = true
        return
        #endif

        do {
            let result = try await Amplify.Auth.fetchAuthSession()
            isSignedIn = result.isSignedIn
        } catch {
            print("Fetch Session failed with error: \(error)")
        }
    }

    func signIn(presentationAnchor: ASPresentationAnchor) async {
        #if DEBUG_BYPASS_AUTH
        isSignedIn = true
        return
        #endif

        guard !isSignedIn else { return }
        do {
            let result = try await Amplify.Auth.signInWithWebUI(
                presentationAnchor: presentationAnchor,
                options: .preferPrivateSession()
            )
            isSignedIn = result.isSignedIn
        } catch {
            print("Sign In failed with error: \(error)")
        }
    }

    func signOut() async {
        #if DEBUG_BYPASS_AUTH
        isSignedIn = false
        return
        #endif

        guard let result = await Amplify.Auth.signOut() as? AWSCognitoSignOutResult else { return }
        switch result {
        case .complete, .partial: isSignedIn = false
        case .failed: break
        }
    }
}

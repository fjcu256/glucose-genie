//
//  LandingView.swift
//  GlucoseGenie
//
//  Created by Francisco Cruz-Urbanc on 2/23/25.
//

import AuthenticationServices
import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    @State private var isLoading = true
    
    //testing purposes
    @State private var startScreen: String = ProcessInfo.processInfo.environment["UITestStartScreen"] ?? "home"


    var body: some View {
        //depending on startScreen env variable, shortcut to test screen, or go to sign in page
            switch startScreen {
            case "map":
                GroceryStoreView()
            default:
                ZStack {
                    if isLoading {
                        ProgressView()
                    }
                    Group {
                        if authenticationService.isSignedIn {
                            MainView()
                        } else {
                            Button("Sign in") {
                                Task {
                                    await authenticationService.signIn(presentationAnchor: window)
                                }
                            }
                        }
                    }
                    .opacity(isLoading ? 0.5 : 1)
                    .disabled(isLoading)
                }
                .task {
                    isLoading = true
                    await authenticationService.fetchSession()
                    // Only invoke web sign-in if we're not already signed in
                    if !authenticationService.isSignedIn {
                        await authenticationService.signIn(presentationAnchor: window)
                    }
                    isLoading = false
                }
            }
    }

    // We need an ASPresentationAnchor for the WebUI flow.
    private var window: ASPresentationAnchor {
        if let delegate = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.delegate as? UIWindowSceneDelegate,
           let window = delegate.window as? UIWindow {
            return window
        }
        return ASPresentationAnchor()
    }
}

#if DEBUG
struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
            .environmentObject(AuthenticationService())
            .environmentObject(RecipeStore())
    }
}
#endif

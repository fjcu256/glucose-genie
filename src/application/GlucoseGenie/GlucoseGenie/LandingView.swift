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

    var body: some View {
        ZStack {
            
            Color.orangeMain.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            }
            Group {
                if authenticationService.isSignedIn {
                    MainView()
                } else {
                    VStack {
                        // Add Logo to Screen.
                        Image("GlucoseGenieBanner")
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height:100)
                            .offset(y:  -12) // Show only the middle section of square banner
                            .clipped()
                        
                        // Sign in button.
                        Button("Sign in") {
                            Task {
                                await authenticationService.signIn(presentationAnchor: window)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    }
                    .padding()
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

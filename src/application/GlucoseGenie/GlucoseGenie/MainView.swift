//
//  MainView.swift
//  GlucoseGenie
//
//  Created by Francisco Cruz-Urbanc on 2/23/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    
    var body: some View {
        VStack {
            Text("This is the main view :)")
            Button("Sign out") {
                Task {
                    await authenticationService.signOut()
                }
            }
        }
    }
}

#Preview {
    MainView()
}

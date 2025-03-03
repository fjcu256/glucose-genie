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
        NavigationView {
            VStack {
                Text("This is the main view :)")
                NavigationLink(destination: SettingsUIView()) {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        
    }
}

#Preview {
    MainView()
}

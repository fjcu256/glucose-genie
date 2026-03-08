//
//  SettingsUIView.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 2/17/25.
//

import SwiftUI

struct SettingsUIView: View {
    @State private var viewModel = SettingsUIViewModel()
    @EnvironmentObject private var authenticationService: AuthenticationService
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        NavigationView {
            ZStack {
                Color.eggWhite.ignoresSafeArea()
                Form {
                    Section("Language") {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("Recipe Language")
                            Spacer()
                            Picker("", selection: $store.language) {
                                Text("English").tag("en")
                                Text("Español").tag("es")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        }
                    }

                    #if DEBUG
                    Section("Developer") {
                        NavigationLink(destination: APITestView()) {
                            HStack {
                                Image(systemName: "network")
                                    .foregroundColor(.blue)
                                Text("API Test")
                            }
                        }
                    }
                    #endif

                    Section {
                        Button(action: handleLogOut) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                Text("Log Out")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.eggWhite)
            }
            .navigationTitle("Settings")
        }
    }

    private func handleLogOut() {
        Task {
            await authenticationService.signOut()
        }
    }
}

struct SettingsUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsUIView()
            .environmentObject(AuthenticationService())
            .environmentObject(RecipeStore())
    }
}

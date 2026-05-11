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
    @State private var showClearCacheConfirmation = false

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
                        Button {
                            showClearCacheConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.orange)
                                Text("Clear Recipe Cache")
                                    .foregroundColor(.orange)
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
            .alert("Clear Recipe Cache?", isPresented: $showClearCacheConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    store.clearCache()
                }
            } message: {
                Text("Recipes will be re-fetched from Spoonacular next time you visit the Recipes tab.")
            }
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

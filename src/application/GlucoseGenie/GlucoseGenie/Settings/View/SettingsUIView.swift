//
//  SettingsUIView.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 2/17/25.
//

import SwiftUI

struct SettingsUIView: View {
    @State private var viewModel = SettingsUIViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $viewModel.isNotificationsEnabled) {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                Section(header: Text("Language")) {
                    Picker("Select Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.languages, id: \.self) { language in
                            Text(language)
                        }
                    }
                    .pickerStyle(PalettePickerStyle())
                }
                
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
            .navigationTitle("Settings")
        }
        
    }
    
    private func handleLogOut() {
        print("User logged out")
    }
    
}

struct SettingsUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsUIView()
    }
}

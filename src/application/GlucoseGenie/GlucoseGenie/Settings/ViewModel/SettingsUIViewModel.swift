//
//  SettingsUIViewModel.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 2/17/25.
//

import Foundation

extension SettingsUIView {
    @Observable
    class SettingsUIViewModel {
        var isNotificationsEnabled = true
        var selectedLanguage = "English"
        
        let languages = ["English", "Spanish"]
    }
}

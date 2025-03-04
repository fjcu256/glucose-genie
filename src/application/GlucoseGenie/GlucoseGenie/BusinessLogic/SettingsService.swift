import Foundation

/// Manages user-specific settings using local persistence (UserDefaults).
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Section 5.2 – methods: updateSettings, fetchSetting)
public class SettingsService {
    public static let shared = SettingsService()
    
    private init() {}
    
    /// Updates a user setting.
    public func updateSettings(settingKey: String, value: Any) {
        UserDefaults.standard.set(value, forKey: settingKey)
    }
    
    /// Retrieves a user setting.
    public func fetchSetting(settingKey: String) -> Any? {
        return UserDefaults.standard.value(forKey: settingKey)
    }
}
import Foundation

/// Represents a user account in the Glucose Genie application.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Section 5.2 Data Model)
public struct User {
    public let userID: String
    public var username: String
    public var email: String
    public var languagePreference: String // "en" or "es"
    
    // Additional properties (e.g., allergens, nutrient targets) can be added here.
    
    public init(userID: String, username: String, email: String, languagePreference: String = "en") {
        self.userID = userID
        self.username = username
        self.email = email
        self.languagePreference = languagePreference
    }
}
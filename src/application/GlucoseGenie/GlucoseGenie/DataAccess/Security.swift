import Foundation
import CryptoKit

/// Provides cryptographic functions for password handling.
public class Security {
    /// Returns a SHA256 hash of the given password.
    public static func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verifies that the given password matches the stored hash.
    public static func verifyPassword(_ password: String, hash: String) -> Bool {
        return hashPassword(password) == hash
    }
}
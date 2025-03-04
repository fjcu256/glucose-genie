import Foundation

/// Represents a stored account record.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Section 5.1 Data Storage)
public struct Account {
    public let userID: String
    public let username: String
    public let email: String
    public let passwordHash: String
}

/// Manages access to user account data.
/// In production, this class should interface with Amazon RDS (or your chosen database).
public class AccountDatabase {
    public static let shared = AccountDatabase()
    
    // Replace this dictionary with real database calls.
    private var accounts: [String: Account] = [:] // keyed by username
    
    private init() {
        // TODO: Remove dummy initialization once integrated with a real database.
        let dummyHash = Security.hashPassword("password")
        let dummyAccount = Account(userID: UUID().uuidString,
                                   username: "test",
                                   email: "test@example.com",
                                   passwordHash: dummyHash)
        accounts["test"] = dummyAccount
    }
    
    public func getAccount(username: String) -> Account? {
        // TODO: Implement retrieval from Amazon RDS.
        return accounts[username]
    }
    
    public func addAccount(_ account: Account) {
        // TODO: Implement insertion into Amazon RDS.
        accounts[account.username] = account
    }
    
    public func updateAccount(_ account: Account) {
        // TODO: Implement update in Amazon RDS.
        accounts[account.username] = account
    }
}
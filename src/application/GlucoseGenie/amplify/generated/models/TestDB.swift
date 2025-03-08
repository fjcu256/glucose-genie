// swiftlint:disable all
import Amplify
import Foundation

public struct TestDB: Model {
  public let id: String
  public var owner: String?
  public var description: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      owner: String? = nil,
      description: String? = nil) {
    self.init(id: id,
      owner: owner,
      description: description,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      owner: String? = nil,
      description: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.owner = owner
      self.description = description
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
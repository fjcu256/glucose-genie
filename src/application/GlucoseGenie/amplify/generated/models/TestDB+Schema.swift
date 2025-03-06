// swiftlint:disable all
import Amplify
import Foundation

extension TestDB {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case owner
    case description
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let testDB = TestDB.keys
    
    model.authRules = [
      rule(allow: .private, operations: [.create, .read, .update, .delete])
    ]
    
    model.listPluralName = "TestDBS"
    model.syncPluralName = "TestDBS"
    
    model.attributes(
      .primaryKey(fields: [testDB.id])
    )
    
    model.fields(
      .field(testDB.id, is: .required, ofType: .string),
      .field(testDB.owner, is: .optional, ofType: .string),
      .field(testDB.description, is: .optional, ofType: .string),
      .field(testDB.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(testDB.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension TestDB: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
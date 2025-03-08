// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "61997102db07f35908b26d2eb0a7fec1"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: TestDB.self)
  }
}
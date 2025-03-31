import Foundation

/// Processes map data to retrieve and format grocery store information.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Section 2.3 – method: queryMapAPI)
public class MapLogic {
    public static let shared = MapLogic()
    private let mapAPI = MapAPI()
    
    private init() {}
    
    /// Queries for nearby grocery stores.
    public func queryGroceryStores(searchQueries: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        mapAPI.queryMapAPI(searchQueries: searchQueries, completion: completion)
    }
}
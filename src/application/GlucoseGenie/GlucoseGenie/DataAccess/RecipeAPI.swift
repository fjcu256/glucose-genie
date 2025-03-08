import Foundation

/// Interfaces with an external recipe API (e.g., Edamam).
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Section 5.2 Data Model – methods: queryRecipes, fetchRecipe)
public class RecipeAPI {
    
    /// Queries the external recipe API using the given search queries.
    /// - Parameter searchQueries: An array of search strings.
    /// - Parameter completion: Returns an array of Recipe objects or an error.
    public func queryRecipes(searchQueries: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        // TODO: Integrate with Edamam (or Spoonacular) API.
        // Build the URL request with search parameters, perform the network call, parse the response.
        fatalError("queryRecipes(searchQueries:completion:) not implemented.")
    }
    
    /// Fetches detailed recipe information for a given recipeID.
    public func fetchRecipe(recipeID: String, completion: @escaping (Result<Recipe, Error>) -> Void) {
        // TODO: Integrate with the external recipe API to fetch detailed recipe data.
        fatalError("fetchRecipe(recipeID:completion:) not implemented.")
    }
}
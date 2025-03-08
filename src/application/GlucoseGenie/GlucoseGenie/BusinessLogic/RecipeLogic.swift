import Foundation

/// Processes recipe-related data and prepares it for presentation.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Section 2.3 – methods: queryRecipes, fetchRecipe, fetchSavedRecipes, addToSavedRecipes, deleteFromSavedRecipes)
public class RecipeLogic {
    public static let shared = RecipeLogic()
    private let recipeAPI = RecipeAPI()
    
    private init() {}
    
    /// Queries recipes from the external API.
    public func queryRecipes(searchQueries: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        recipeAPI.queryRecipes(searchQueries: searchQueries, completion: completion)
    }
    
    /// Fetches detailed information for a specific recipe.
    public func fetchRecipe(recipeID: String, completion: @escaping (Result<Recipe, Error>) -> Void) {
        recipeAPI.fetchRecipe(recipeID: recipeID, completion: completion)
    }
    
    /// Retrieves recipes saved locally.
    public func fetchSavedRecipes(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        // Replace with actual error handling if needed.
        let recipes = LocalData.shared.fetchSavedRecipes()
        completion(.success(recipes))
    }
    
    /// Saves a recipe to the local storage.
    public func addToSavedRecipes(recipe: Recipe, completion: @escaping (Result<Void, Error>) -> Void) {
        LocalData.shared.saveRecipe(recipe)
        completion(.success(()))
    }
    
    /// Deletes a recipe from the local storage.
    public func deleteFromSavedRecipes(recipe: Recipe, completion: @escaping (Result<Void, Error>) -> Void) {
        LocalData.shared.deleteRecipe(recipe)
        completion(.success(()))
    }
}
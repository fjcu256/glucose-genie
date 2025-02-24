import Foundation

/// Handles local data persistence (e.g., meal plans, saved recipes).
/// In production, this might use Core Data, SQLite, or other persistence frameworks.
public class LocalData {
    public static let shared = LocalData()
    
    // In-memory storage as a placeholder.
    private var mealPlans: [MealPlan] = []
    private var savedRecipes: [Recipe] = []
    
    private init() {}
    
    // MARK: - Meal Plans
    public func saveMealPlan(_ mealPlan: MealPlan) {
        // TODO: Replace with persistence logic.
        if let index = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: mealPlan.date) }) {
            mealPlans[index] = mealPlan
        } else {
            mealPlans.append(mealPlan)
        }
    }
    
    public func fetchWeeklyMealPlans() -> [MealPlan] {
        // TODO: Retrieve from persistent storage.
        return mealPlans
    }
    
    // MARK: - Saved Recipes
    public func saveRecipe(_ recipe: Recipe) {
        // TODO: Replace with persistent storage logic.
        savedRecipes.append(recipe)
    }
    
    public func deleteRecipe(_ recipe: Recipe) {
        // TODO: Remove recipe from persistent storage.
        savedRecipes.removeAll { $0.recipeID == recipe.recipeID }
    }
    
    public func fetchSavedRecipes() -> [Recipe] {
        // TODO: Retrieve saved recipes from persistent storage.
        return savedRecipes
    }
}
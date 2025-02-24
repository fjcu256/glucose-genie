import Foundation

/// Aggregates ingredients from meal plans to generate a grocery list.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Section 5.2 – method: fetchGroceryList)
public class GroceryListService {
    /// Generates a grocery list based on the user's weekly meal plans.
    public func fetchGroceryList(mealPlans: [MealPlan], completion: @escaping (Result<[GroceryItem], Error>) -> Void) {
        var ingredientDict: [String: (quantity: Double, unit: String)] = [:]
        
        for mealPlan in mealPlans {
            for recipe in mealPlan.recipes {
                for ingredient in recipe.ingredients {
                    // Aggregate ingredients (you may wish to parse quantities if provided)
                    if let existing = ingredientDict[ingredient] {
                        ingredientDict[ingredient] = (existing.quantity + 1, existing.unit)
                    } else {
                        ingredientDict[ingredient] = (1, "unit")
                    }
                }
            }
        }
        
        let groceryList = ingredientDict.map { (name, value) in
            GroceryItem(name: name, quantity: value.quantity, unit: value.unit, estimatedPrice: nil)
        }
        completion(.success(groceryList))
    }
}
//
//  RecipeParser.swift
//  GlucoseGenie
//

import Foundation

struct RecipeParser {

    /// Parses a Spoonacular /recipes/complexSearch response (with
    /// addRecipeNutrition=true & addRecipeInformation=true) into the
    /// app's internal Recipe model.
    static func parseRecipes(from data: Data) -> (recipes: [Recipe], nextPageUrl: URL?) {

        guard !data.isEmpty else {
            print("RecipeParser: empty response data")
            return ([], nil)
        }

        do {
            let decoded = try JSONDecoder().decode(SpoonacularSearchResponse.self, from: data)
            let recipes = decoded.results.map { mapToRecipe($0) }
            // Spoonacular uses offset-based pagination, not next-page URLs
            return (recipes, nil)
        } catch {
            print("RecipeParser: JSON decoding failed — \(error)")
            return ([], nil)
        }
    }

    // MARK: - Private mapping

    private static func mapToRecipe(_ src: SpoonacularRecipe) -> Recipe {

        // Map extendedIngredients → [Ingredient]
        let ingredients: [Ingredient] = (src.extendedIngredients ?? []).map { ing in
            Ingredient(
                text:     ing.original ?? ing.name,
                quantity: ing.amount   ?? 0,
                units:    ing.unit     ?? ""
            )
        }

        // Map nutrition nutrients → [Nutrient]
        let nutrients: [Nutrient] = (src.nutrition?.nutrients ?? []).map { n in
            Nutrient(name: n.name, quantity: n.amount, unit: n.unit)
        }

        // Map Spoonacular diets → [DietType]
        let diets: [DietType] = (src.diets ?? []).compactMap { spoonacularDietToApp($0) }

        // Map dishTypes → [MealType]
        let mealTypes: [MealType] = (src.dishTypes ?? []).compactMap { dishTypeToMealType($0) }

        return Recipe(
            id:             src.id,
            name:           src.title,
            image:          src.image ?? "",
            url:            src.sourceUrl ?? "https://spoonacular.com/recipes/\(src.title.lowercased().replacingOccurrences(of: " ", with: "-"))-\(src.id)",
            ingredients:    ingredients,
            totalTime:      src.readyInMinutes.map { Double($0) },
            servings:       src.servings,
            totalNutrients: nutrients,
            diets:          diets,
            mealtypes:      mealTypes,
            healthLabels:   [],   // Spoonacular doesn't expose these in search; extend if needed
            tags:           src.dishTypes ?? []
        )
    }

    // MARK: - Diet mapping

    private static func spoonacularDietToApp(_ diet: String) -> DietType? {
        switch diet.lowercased() {
        case "gluten free":                     return nil  // HealthLabel, not DietType
        case "ketogenic", "low carb":           return .lowCarb
        case "vegetarian", "lacto vegetarian",
             "ovo vegetarian":                  return nil  // HealthLabel
        case "vegan":                           return nil  // HealthLabel
        case "low fodmap":                      return nil
        case "whole30":                         return nil
        case "paleolithic", "primal":           return .highProtein
        default:                                return nil
        }
    }

    // MARK: - Dish type → MealType

    private static func dishTypeToMealType(_ dishType: String) -> MealType? {
        switch dishType.lowercased() {
        case "breakfast", "morning meal", "brunch": return .breakfast
        case "lunch", "main course", "main dish":   return .lunch
        case "dinner":                               return .dinner
        case "snack", "appetizer", "fingerfood":    return .snack
        default:                                     return nil
        }
    }
}

//
//  RecipeParser.swift
//  GlucoseGenie
//

import Foundation

struct RecipeParser {

    static func parseRecipes(from data: Data) -> (recipes: [Recipe], nextPageUrl: URL?) {
        guard !data.isEmpty else {
            print("RecipeParser: empty response data")
            return ([], nil)
        }
        do {
            let decoded = try JSONDecoder().decode(SpoonacularSearchResponse.self, from: data)
            let recipes = decoded.results.map { mapToRecipe($0) }
            return (recipes, nil)
        } catch {
            print("RecipeParser: JSON decoding failed — \(error)")
            return ([], nil)
        }
    }

    // MARK: - Translation

    // Translates recipe names and ingredient text only.
    // Nutrient names are kept in English internally so lookup logic in Recipe.swift stays intact.
    static func translateRecipes(_ recipes: [Recipe], to language: String) async -> [Recipe] {
        guard language != "en", !recipes.isEmpty else { return recipes }

        let names = recipes.map { $0.name }
        let allIngredientTexts = recipes.flatMap { $0.ingredients.map { $0.text } }
        let allStrings = names + allIngredientTexts

        let translated = await TranslationService.translate(allStrings, to: language)

        guard translated.count == allStrings.count else {
            print("RecipeParser: translation count mismatch, returning originals")
            return recipes
        }

        let translatedNames = Array(translated.prefix(recipes.count))
        var offset = recipes.count

        return recipes.enumerated().map { i, recipe in
            let ingCount = recipe.ingredients.count
            let translatedIngredients: [Ingredient] = recipe.ingredients.enumerated().map { j, ing in
                Ingredient(
                    text:     translated[offset + j],
                    quantity: ing.quantity,
                    units:    ing.units
                )
            }
            offset += ingCount

            return Recipe(
                id:             recipe.id,
                name:           translatedNames[i],
                image:          recipe.image,
                url:            recipe.url,
                ingredients:    translatedIngredients,
                totalTime:      recipe.totalTime,
                servings:       recipe.servings,
                totalNutrients: recipe.totalNutrients, // kept in English intentionally
                diets:          recipe.diets,
                mealtypes:      recipe.mealtypes,
                healthLabels:   recipe.healthLabels,
                tags:           recipe.tags
            )
        }
    }

    // MARK: - Private mapping

    private static func mapToRecipe(_ src: SpoonacularRecipe) -> Recipe {
        let ingredients: [Ingredient] = (src.extendedIngredients ?? []).map { ing in
            Ingredient(
                text:     ing.original ?? ing.name,
                quantity: ing.amount   ?? 0,
                units:    ing.unit     ?? ""
            )
        }
        let nutrients: [Nutrient] = (src.nutrition?.nutrients ?? []).map { n in
            Nutrient(name: n.name, quantity: n.amount, unit: n.unit)
        }
        let diets: [DietType] = (src.diets ?? []).compactMap { spoonacularDietToApp($0) }
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
            healthLabels:   [],
            tags:           src.dishTypes ?? []
        )
    }

    // MARK: - Diet mapping

    private static func spoonacularDietToApp(_ diet: String) -> DietType? {
        switch diet.lowercased() {
        case "gluten free":                    return nil
        case "ketogenic", "low carb":          return .lowCarb
        case "vegetarian", "lacto vegetarian",
             "ovo vegetarian":                 return nil
        case "vegan":                          return nil
        case "low fodmap":                     return nil
        case "whole30":                        return nil
        case "paleolithic", "primal":          return .highProtein
        default:                               return nil
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

//
//  RecipeParser.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 4/3/25.
//

import Foundation

struct RecipeParser {
    
    static func parseRecipes(from data: Data) -> (recipes: [Recipe], nextPageUrl: URL?) {
        do {
            guard !data.isEmpty else {
                print("Empty response data")
                return ([], nil)
            }
            let decodedResponse = try JSONDecoder().decode(RecipeAPIResponse.self, from: data)
            
            let nextUrl = URL(string: decodedResponse.links.next?.href ?? "")
            let recipes: [Recipe] = decodedResponse.hits.map {hit in
                let edamam = hit.recipe
                return Recipe(
                    name: edamam.label,
                    image: edamam.image,
                    url: edamam.url,
                    ingredients: edamam.ingredients.map { Ingredient(text: $0.text, quantity: $0.quantity, units: $0.measure ?? "") },
                    totalTime: edamam.totalTime,
                    servings: edamam.yield.map { Int($0) },
                    totalNutrients: parseTotalNutrients( from: edamam.totalNutrients),
                    diets: edamam.dietLabels?.compactMap {DietType(rawValue: normalizeDietLabel($0)) } ?? [],
                    mealtypes: edamam.mealType?.compactMap {MealType(rawValue: normalizeMealType($0)) } ?? [],
                    healthLabels: edamam.healthLabels?.compactMap {HealthLabel(rawValue: normalizeHealthLabel($0)) } ?? [],
                    tags: edamam.tags ?? []
                )
            }
            return (recipes, nextUrl)
        } catch {
            print("JSON Parsing into Recipes Failed: \(error)")
            return ([], nil)
        }
    }
    
    // Extracts needed parameters for each nutrient.
    // Creates a Nutrient and stores it in a dictionary.
    // Returns dictionary of Nutrients.
    private static func parseTotalNutrients(from dict: [String: NutrientAPI]?) -> [Nutrient] {
        guard let dict = dict else {return []}
        
        return dict.map {
            (key, value) in Nutrient(name: value.label, quantity: value.quantity, unit: value.unit)
        }
    }
    
    private static func normalizeDietLabel(_ rawLabel: String) -> String {
        // ex. "Low-Carb" -> "lowCarb"
        return rawLabel.replacingOccurrences(of: "-", with: "").lowercased()
    }
    
    private static func normalizeMealType(_ rawMeal: String) -> String {
        let meal = rawMeal.lowercased()
        if meal.contains("lunch") {
            return "lunch"
        } else if meal.contains("dinner"){
            return "dinner"
        } else if meal.contains("breakfast"){
            return "breakfast"
        } else if meal.contains("snack") {
            return "snack"
        }
        return meal
    }
    
    private static func normalizeHealthLabel(_ rawLabel: String) -> String {
        return rawLabel
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }
    
}

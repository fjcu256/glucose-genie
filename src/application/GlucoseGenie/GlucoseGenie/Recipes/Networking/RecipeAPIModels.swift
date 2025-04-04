//
//  RecipeAPIModels.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 4/3/25.
//

import Foundation

struct RecipeAPIResponse: Codable {
    let hits: [Hit]
}

struct Hit: Codable {
    let recipe: EdamamRecipe
}

struct EdamamRecipe: Codable {
    let label: String
    let image: String
    let ingredientLines: [String]?
    let ingredients: [IngredientAPI]
    let healthLabels: [String]?
    let mealType: [String]?
    let dietLabels: [String]?
    let cuisineType: [String]?
    let totalNutrients: [String: NutrientAPI]?
}

// Ingredient defined by Edamam API
struct IngredientAPI: Codable {
    let text: String
    let quantity: Double
    let measure: String?
}

// Nutrients defined by Edamam API
struct NutrientAPI: Codable {
    let label: String
    let quantity: Double
    let unit: String
}

//
//  RecipeAPIModels.swift
//  GlucoseGenie
//

import Foundation

// MARK: - Spoonacular Search Response

struct SpoonacularSearchResponse: Codable {
    let results: [SpoonacularRecipe]
    let totalResults: Int?
}

// MARK: - Spoonacular Recipe (raw API shape)

struct SpoonacularRecipe: Codable {
    let id: Int
    let title: String
    let image: String?
    let readyInMinutes: Int?
    let servings: Int?
    let summary: String?
    let instructions: String?
    let extendedIngredients: [SpoonacularIngredient]?
    let nutrition: SpoonacularNutrition?
    let diets: [String]?
    let dishTypes: [String]?
    let healthScore: Double?
    let sourceUrl: String?
}

// MARK: - Spoonacular Ingredient (raw API shape)

struct SpoonacularIngredient: Codable {
    let id: Int?
    let name: String
    let original: String?
    let amount: Double?
    let unit: String?
}

// MARK: - Spoonacular Nutrition

struct SpoonacularNutrition: Codable {
    let nutrients: [SpoonacularNutrient]?
}

struct SpoonacularNutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
}

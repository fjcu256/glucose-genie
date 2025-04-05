//
//  RecipeAPIModels.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 4/3/25.
//

import Foundation

struct RecipeAPIResponse: Codable {
    let hits: [Hit]
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case hits
        case links = "_links"
    }
}

struct Hit: Codable {
    let recipe: EdamamRecipe
}

struct Links: Codable {
    let next: Link?
}

struct Link: Codable {
    let href: String
    let title: String?
}

// Keys to extract from Edamam API
struct EdamamRecipe: Codable {
    let label: String
    let image: String
    let url: String
    let ingredientLines: [String]?
    let ingredients: [IngredientAPI]
    let healthLabels: [String]?
    let mealType: [String]?
    let dietLabels: [String]?
    let cuisineType: [String]?
    let totalNutrients: [String: NutrientAPI]?
    let tags: [String]?
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

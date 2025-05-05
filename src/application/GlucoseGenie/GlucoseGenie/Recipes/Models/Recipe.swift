//
//  Recipe.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 4/3/25.
//

import Foundation

struct Recipe: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let image: String
    let url: String
    let ingredients: [Ingredient]
    let totalTime:     Double?
    let servings:      Int?
    let totalNutrients: [Nutrient]
    let diets: [DietType]
    let mealtypes: [MealType]
    let healthLabels: [HealthLabel]
    let tags: [String]
    
    /*
     Getters. All of the getters return nil if a value cannot be found.
     Returning a nil will not crash the application */
    
    var imageUrl: URL? {
        URL(string: image)
    }
    
    var calories: Int? {
        if let calorieNutrient = totalNutrients.first(where: {
            $0.name.lowercased().contains("energy") || $0.name.lowercased().contains("calories")
        }) {
            return Int(calorieNutrient.quantity)
        }
        return nil
    }
    
    var carbs: Int? {
        if let carbNutrient = totalNutrients.first(where: {
            $0.name.localizedCaseInsensitiveContains("carb")
        }) {
            return Int(carbNutrient.quantity)
        }
        return nil
    }
    
    var sugar: Int? {
        if let sugarNutrient = totalNutrients.first(where: {
            $0.name.lowercased().contains("sugar")
        }) {
            return Int(sugarNutrient.quantity)
        }
        return nil
    }
    
    // Displays
    var mealTypesDisplay: String {
        mealtypes.map { $0.displayName }.joined(separator: ", ")
    }
    
    var dietTypesDisplay: String {
        diets.map { $0.displayName }.joined(separator: ", ")
    }
    
    var healthLabelsDisplay: String {
        healthLabels.map { $0.displayName }.joined(separator: ", ")
    }
    
    var tagsDisplay: String {
        tags.joined(separator: ", ")
    }
    
}

struct Ingredient: Identifiable, Equatable, Codable {
    let id = UUID()
    let text: String
    let quantity: Double
    let units: String
}

struct Nutrients: Codable {
    let calories: Nutrient
    let fat: Nutrient
    let carbs: Nutrient
    let fiber: Nutrient
    let sugar: Nutrient
    let protein: Nutrient
    let cholesterol: Nutrient
    let sodium: Nutrient
    let calcium: Nutrient
    let magnesium: Nutrient
    let potassium: Nutrient
    let iron: Nutrient
    let zinc: Nutrient
    let phosphorus: Nutrient
    let vitA: Nutrient
    let vitC: Nutrient
    let thiamin: Nutrient
    let riboflavin: Nutrient
    let niacin: Nutrient
    let vitB6: Nutrient
    let vitB12: Nutrient
    let vitD: Nutrient
    let vitE: Nutrient
    
    enum CodingKeys: String, CodingKey {
        case calories = "ENERC_KCAL"
        case fat = "FAT"
        case carbs = "CHOCDF"
        case fiber = "FIBTG"
        case sugar = "SUGAR"
        case protein = "PROCNT"
        case cholesterol = "CHOLE"
        case sodium = "NA"
        case calcium = "CA"
        case magnesium = "MG"
        case potassium = "K"
        case iron = "FE"
        case zinc = "ZN"
        case phosphorus = "P"
        case vitA = "VITA_RAE"
        case vitC = "VITC"
        case thiamin = "THIA"
        case riboflavin = "RIBF"
        case niacin = "NIA"
        case vitB6 = "VITB6A"
        case vitB12 = "VITB12"
        case vitD = "VITD"
        case vitE = "TOCPHA"
    }
}

struct Nutrient: Codable, Equatable {
    let name: String
    let quantity: Double
    let unit: String
}

enum DietType: String, Codable, CaseIterable, Equatable, Identifiable {
    case balanced
    case highFiber
    case highProtein
    case lowCarb
    case lowFat
    case lowSodium
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .balanced:
            return "Balanced"
        case .highFiber:
            return "High-Fiber"
        case .highProtein:
            return "High-Protein"
        case .lowCarb:
            return "Low-Carb"
        case .lowFat:
            return "Low-Fat"
        case .lowSodium:
            return "Low-Sodium"
        }
    }
}


enum MealType: String, Codable, CaseIterable, Equatable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snack:
            return "Snack"
        }
    }
}

enum HealthLabel: String, Codable, CaseIterable, Equatable, Identifiable {
    case dairyFree
    case glutenFree
    case kidneyFriendly
    case kosher
    case lowPotassium
    case lowSugar
    case peanutFree
    case pescatarian
    case porkFree
    case soyFree
    case treeNutFree
    case vegan
    case vegetarian
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .dairyFree:
            return "Dairy Free"
        case .glutenFree:
            return "Gluten Free"
        case .kidneyFriendly:
            return "Kidney Friendly"
        case .kosher:
            return "Kosher"
        case .lowPotassium:
            return "Low Potassium"
        case .lowSugar:
            return "Low Sugar"
        case .peanutFree:
            return "Peanut Free"
        case .pescatarian:
            return "Pescatarian"
        case .porkFree:
            return "Pork Free"
        case .soyFree:
            return "Soy Free"
        case .treeNutFree:
            return "Tree Nut Free"
        case .vegan:
            return "Vegan"
        case .vegetarian:
            return "Vegetarian"
        }
    }
}

import Foundation

/// Represents a diabetes-friendly recipe.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Sections 2.4.2 & 2.4.3, Data Model)
public struct Recipe {
    public let recipeID: String
    public var title: String
    public var imageURL: URL?
    public var ingredients: [String]
    public var totalCarbs: Double
    public var totalProtein: Double
    public var totalFat: Double
    public var instructions: String?
    public var cuisineType: String?
    
    public init(recipeID: String, title: String, imageURL: URL? = nil, ingredients: [String],
                totalCarbs: Double, totalProtein: Double, totalFat: Double,
                instructions: String? = nil, cuisineType: String? = nil) {
        self.recipeID = recipeID
        self.title = title
        self.imageURL = imageURL
        self.ingredients = ingredients
        self.totalCarbs = totalCarbs
        self.totalProtein = totalProtein
        self.totalFat = totalFat
        self.instructions = instructions
        self.cuisineType = cuisineType
    }
}
import Foundation

/// Represents a user's meal plan for a specific day.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Sections 2.4.4 & 5.2, Data Model)
public struct MealPlan {
    public var date: Date
    public var recipes: [Recipe]
    public var totalCarbsForDay: Double
    public var totalProteinForDay: Double
    public var totalFatForDay: Double
    
    public init(date: Date, recipes: [Recipe] = [],
                totalCarbsForDay: Double = 0.0, totalProteinForDay: Double = 0.0, totalFatForDay: Double = 0.0) {
        self.date = date
        self.recipes = recipes
        self.totalCarbsForDay = totalCarbsForDay
        self.totalProteinForDay = totalProteinForDay
        self.totalFatForDay = totalFatForDay
    }
}
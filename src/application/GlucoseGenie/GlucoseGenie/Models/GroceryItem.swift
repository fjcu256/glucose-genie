import Foundation

/// Represents an item in the user's grocery list.
/// (Referenced in: SoftwareDesignDoc-v1.pdf, Sections 2.4.5 & 5.2, Data Model)
public struct GroceryItem {
    public var name: String
    public var quantity: Double
    public var unit: String
    public var estimatedPrice: Double?
    
    public init(name: String, quantity: Double, unit: String = "unit", estimatedPrice: Double? = nil) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.estimatedPrice = estimatedPrice
    }
}
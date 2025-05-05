//
//  GroceryListView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

// Hard-coded ingredients
let testRecipe = Recipe(
    name: "Recipe Name",
    image: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/shutterstock_425424460.webp?h=e2d4e250&itok=ptCQ_FGY",
    url: "https://example.com/recipe",
    ingredients: [
        Ingredient(text: "1 egg", quantity: 1, units: "unit"),
        Ingredient(text: "100g flour", quantity: 100, units: "g"),
        Ingredient(text: "2cups milk", quantity: 2, units: "cups"),
        Ingredient(text: "1.5tbsp olive oil", quantity: 1.5, units: "tbsp"),
        Ingredient(text: "200g chicken breast", quantity: 200, units: "g"),
        Ingredient(text: "3cloves garlic", quantity: 3, units: "cloves"),
        Ingredient(text: "1tsp salt", quantity: 1, units: "tsp"),
        Ingredient(text: "0.5cup chopped onions", quantity: 0.5, units: "cup"),
        Ingredient(text: "250ml vegetable broth", quantity: 250, units: "ml"),
        Ingredient(text: "1slice whole wheat bread", quantity: 1, units: "slice"),
        Ingredient(text: "100g spinach", quantity: 100, units: "g"),
        Ingredient(text: "2tbsp soy sauce", quantity: 2, units: "tbsp")
    ],
    totalTime: nil,
    servings: nil,
    totalNutrients: [
        Nutrient(name: "Energy", quantity: 250, unit: "kcal"),
        Nutrient(name: "Carbohydrates", quantity: 30, unit: "g"),
        Nutrient(name: "Sugars", quantity: 5, unit: "g")
    ],
    diets: [.balanced, .lowFat],
    mealtypes: [.breakfast],
    healthLabels: [.glutenFree, .vegetarian],
    tags: ["dairy", "vegatable"]
)

struct GroceryItem: Identifiable {
    let id = UUID()
    let quantity: String
    let name: String
    var isChecked: Bool = false
}

func parseIngredients(_ ingredients: [Ingredient]) -> [GroceryItem] {
    ingredients.map { ingredient in
        let parts = ingredient.text.split(separator: " ", maxSplits: 1).map(String.init)
        let quantity = parts.first ?? ""
        let name = parts.count > 1 ? parts[1] : ""
        return GroceryItem(quantity: quantity, name: name.capitalized)
    }
}


struct GroceryListView: View {
    @State private var groceryItems: [GroceryItem] = parseIngredients(testRecipe.ingredients)
    @State private var syncConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Based on your weekly meal plan, you will need:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($groceryItems) { $item in
                            HStack {
                                Button(action: {
                                    item.isChecked.toggle()
                                }) {
                                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                        .foregroundColor(item.isChecked ? .green : .gray)
                                        .font(.title3)
                                }

                                Text(item.quantity)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(width: 80, alignment: .center)
                                    .strikethrough(item.isChecked, color: .gray)
                                    .foregroundColor(item.isChecked ? .gray : .primary)

                                Text(item.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .strikethrough(item.isChecked, color: .gray)
                                    .foregroundColor(item.isChecked ? .gray : .primary)

                                Spacer()
                                
                                Button(action: {
                                    if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
                                        groceryItems.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        syncConfirmation = true
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityLabel("Sync with Meal Plan")
                }
            }
            .alert("Sync Grocery List?", isPresented: $syncConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sync") {
                    groceryItems = parseIngredients(testRecipe.ingredients)
                }
            } message: {
                Text("This will sync your grocery list with your current meal plan. Any changes will be lost.")
            }
        }
    }
}

#Preview {
    GroceryListView()
}

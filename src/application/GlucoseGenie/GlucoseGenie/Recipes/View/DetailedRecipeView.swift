//
//  DetailedRecipeView.swift
//  GlucoseGenie
//
//  Created by Thomas Capro on 5/6/25.
//

import SwiftUI

struct DetailedRecipeView: View {
    let recipe: Recipe

    @EnvironmentObject private var store: RecipeStore
    @State private var showingPlanSheet = false

    // The nutrients to display
    private let nutrientKeys = [
        "Sugar", "Fat", "Cholesterol",
        "Protein", "Sodium", "Calcium",
        "Magnesium", "Potassium"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Recipe Image
                if let url = recipe.imageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Text("🍽️")
                                .font(.largeTitle)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Title
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()

                // Calories & Carbs
                HStack {
                    if let cal = recipe.calories {
                        Text("Calories: \(cal) kcal")
                    }
                    if let carb = recipe.carbs {
                        Text("Carbs: \(carb)g")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                // Total Time & Servings
                HStack {
                    if let time = recipe.totalTime {
                        Text("⏱ \(Int(time)) min")
                    }
                    if let serves = recipe.servings {
                        Text("🍽 Serves \(serves)")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

                // Ingredients
                Text("Ingredients")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(recipe.ingredients) { ing in
                        Text("• \(ing.text)")
                    }
                }
                .padding(.leading, 8)

                Divider()

                // Nutrition Facts
                Text("Nutrition Facts")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(nutrientKeys, id: \.self) { key in
                        if let nut = recipe.totalNutrients.first(
                            where: { $0.name.localizedCaseInsensitiveContains(key) }
                        ) {
                            let qty = Int(nut.quantity)
                            Text("\(key): \(qty) \(nut.unit)")
                        }
                    }
                }
                .padding(.leading, 8)

                Divider()

                // View Full Recipe
                if let recipeURL = URL(string: recipe.url) {
                    SwiftUI.Link(destination: recipeURL) {
                        Text("View Full Recipe")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Save / Unsave Button
                Button {
                    store.toggleSave(recipe)
                } label: {
                    Label(
                        store.saved.contains(recipe) ? "Unsave Recipe" : "Save Recipe",
                        systemImage: store.saved.contains(recipe)
                            ? "bookmark.fill" : "bookmark"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                // Add to Meal Plan Button
                Button("Add to Meal Plan") {
                    showingPlanSheet = true
                }
                .buttonStyle(.bordered)
                .sheet(isPresented: $showingPlanSheet) {
                    AddToMealPlanView(recipe: recipe)
                        .environmentObject(store)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct DetailedRecipeView_Previews: PreviewProvider {
    static var sampleRecipe: Recipe {
        Recipe(
            name:           "Sample",
            image:          "",
            url:            "",
            ingredients:    [ Ingredient(text: "Example", quantity: 1, units: "") ],
            totalTime:      30,
            servings:       4,
            totalNutrients: [
                Nutrient(name: "Sugar",       quantity: 5,  unit: "g"),
                Nutrient(name: "Fat",         quantity: 12, unit: "g"),
                Nutrient(name: "Cholesterol", quantity: 30, unit: "mg"),
                Nutrient(name: "Protein",     quantity: 8,  unit: "g"),
                Nutrient(name: "Sodium",      quantity: 200,unit: "mg"),
                Nutrient(name: "Calcium",     quantity: 100,unit: "mg"),
                Nutrient(name: "Magnesium",   quantity: 50, unit: "mg"),
                Nutrient(name: "Potassium",   quantity: 250,unit: "mg"),
            ],
            diets:           [],
            mealtypes:       [],
            healthLabels:    [],
            tags:            []
        )
    }

    static var previews: some View {
        NavigationStack {
            DetailedRecipeView(recipe: sampleRecipe)
                .environmentObject(RecipeStore())
        }
    }
}
#endif

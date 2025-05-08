//
//  DetailedRecipeView.swift
//  GlucoseGenie
//
//  Created by Thomas Capro on 5/6/25.
//

// Recipes/View/DetailedRecipeView.swift

import SwiftUI

struct DetailedRecipeView: View {
    let recipe: Recipe
    
    @EnvironmentObject private var store: RecipeStore
    @State private var showingPlanSheet = false

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
                
                // 🌟 Save / Unsave Button
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
                
                // 🌟 Add to Meal Plan Button
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
    // Sample data
    static var sampleRecipe: Recipe {
        Recipe(
            name: "Sample",
            image: "",
            url: "",
            ingredients: [ Ingredient(text: "Example", quantity: 1, units: "") ],
            totalTime: 30,
            servings: 4,
            totalNutrients: [],
            diets: [],
            mealtypes: [],
            healthLabels: [],
            tags: []
        )
    }

    static var previews: some View {
        NavigationStack {
            DetailedRecipeView(recipe: sampleRecipe)
                .environmentObject( RecipeStore() )
        }
    }
}
#endif

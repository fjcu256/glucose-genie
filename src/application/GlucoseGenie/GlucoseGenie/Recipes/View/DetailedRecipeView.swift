//
//  DetailedRecipeView.swift
//  GlucoseGenie
//
//  Created by Thomas Capro on 5/6/25.
//

import SwiftUI

struct DetailedRecipeView: View {
    let recipe: Recipe

    // pulls in the shared store and auth from the environment
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var authenticationService: AuthenticationService
    @State private var showingPlanSheet = false

    // which nutrients to list under “Nutrition Facts”
    private let nutrientKeys = [
        ("Sugar", String(localized: "Sugar")),
        ("Fat", String(localized: "Fat")),
        ("Cholesterol", String(localized: "Cholesterol")),
        ("Protein", String(localized: "Protein")),
        ("Sodium", String(localized: "Sodium")),
        ("Calcium", String(localized: "Calcium")),
        ("Magnesium", String(localized: "Magnesium")),
        ("Potassium", String(localized: "Potassium"))
    ]
    let caloriesString = String(localized: "Calories")
    let carbsString = String(localized: "Carbs")
    let servingsString = String(localized: "servings")

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
                        Text("\(caloriesString): \(cal) kcal")
                    }
                    if let carb = recipe.carbs {
                        Text("\(carbsString): \(carb) g")
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
                        Text("🍽 \(serves) \(servingsString)")
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
                    // Calories & Carbs again
                    if let cal = recipe.calories {
                        Text("\(caloriesString): \(cal) kcal")
                    }
                    if let carb = recipe.carbs {
                        Text("\(carbsString): \(carb)g")
                    }
                    // Other selected nutrients
                    ForEach(nutrientKeys, id:\.0) { key in
                        if let nut = recipe.totalNutrients.first(
                            where: { $0.name.localizedCaseInsensitiveContains(key.0) }
                        ) {
                            let qty = Int(nut.quantity)
                            Text("\(key.1): \(qty) \(nut.unit)")
                        }
                    }
                }
                .padding(.leading, 8)

                Divider()

                // View Full Recipe
                if let recipeURL = URL(string: recipe.url) {
                    // Official two-arg initializer
                    SwiftUI.Link("View Full Recipe", destination: recipeURL)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                // Save / Unsave
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
                .tint(.orangeMain)

                // Add to Meal Plan
                Button("Add to Meal Plan") {
                    showingPlanSheet = true
                }
                .buttonStyle(.bordered)
                .sheet(isPresented: $showingPlanSheet) {
                    // Only the store needs to be passed explicitly;
                    // auth and store both already live in the environment:
                    AddToMealPlanView(recipe: recipe)
                        .environmentObject(store)
                }

                Spacer()
            }
            .padding()
            .background(Color.eggWhite)
            Spacer(minLength: 30)
            Image("EdamamBadge")
                .resizable()
                .scaledToFit()
                .frame(height: 30)
                .padding(.bottom, 20)
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.eggWhite)
        .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
struct DetailedRecipeView_Previews: PreviewProvider {
    static var sampleRecipe: Recipe {
        Recipe(
            name: "Sample",
            image: "",
            url: "",
            ingredients: [Ingredient(text: "Example", quantity: 1, units: "")],
            totalTime: 30,
            servings: 4,
            totalNutrients: [
                Nutrient(name: "Calories", quantity: 5, unit: "kcal"),
                Nutrient(name: "Carbs",    quantity: 5, unit: "g"),
                Nutrient(name: "Sugar",    quantity: 5, unit: "g"),
                Nutrient(name: "Fat",      quantity: 12, unit: "g"),
                Nutrient(name: "Cholesterol", quantity: 30, unit: "mg"),
                Nutrient(name: "Protein",  quantity: 8, unit: "g"),
                Nutrient(name: "Sodium",   quantity: 200, unit: "mg"),
                Nutrient(name: "Calcium",  quantity: 100, unit: "mg"),
                Nutrient(name: "Magnesium",quantity: 50, unit: "mg"),
                Nutrient(name: "Potassium",quantity: 250, unit: "mg"),
            ],
            diets: [], mealtypes: [], healthLabels: [], tags: []
        )
    }

    static var previews: some View {
        NavigationStack {
            DetailedRecipeView(recipe: sampleRecipe)
                .environmentObject(RecipeStore())
                .environmentObject(AuthenticationService())
        }
    }
}
#endif

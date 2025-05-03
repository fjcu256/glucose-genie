//
//  WeeklyMealPlanView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

// Test recipe
let testRecipe = Recipe(
    name: "Recipe Name",
    image: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/shutterstock_425424460.webp?h=e2d4e250&itok=ptCQ_FGY",
    url: "https://example.com/recipe",
    ingredients: [
        Ingredient(text: "1 egg", quantity: 1, units: "unit"),
        Ingredient(text: "100g flour", quantity: 100, units: "g")
    ],
    totalNutrients: [
        Nutrient(name: "Energy", quantity: 250, unit: "kcal"),
        Nutrient(name: "Carbohydrates", quantity: 30, unit: "g"),
        Nutrient(name: "Sugars", quantity: 5, unit: "g")
    ],
    diets: [.balanced, .lowFat],
    mealtypes: [.breakfast],
    healthLabels: [.glutenFree, .vegetarian]
)

class MealPlan: ObservableObject {
    @Published var mealsByDay: [Date: [String: Recipe]] = [:]
    
    func addMeal(recipe: Recipe, for date: Date, mealType: String) {
        var dayMeals = mealsByDay[date] ?? [:]
        dayMeals[mealType] = recipe
        mealsByDay[date] = dayMeals
        
        // Log add update
        print("Added \(recipe.name) to \(mealType) on \(date)")
    }
    
    func removeMeal(for date: Date, mealType: String) {
        var dayMeals = mealsByDay[date] ?? [:]
        dayMeals.removeValue(forKey: mealType)
        mealsByDay[date] = dayMeals
        
        // Log remove update
        print("Removed meal from \(mealType) on \(date)")
    }
    
    func getMeal(for date: Date, mealType: String) -> Recipe? {
        return mealsByDay[date]?[mealType]
    }
}

struct WeeklyMealPlanView: View {
    let calendar = Calendar.current

    // Compute and store the current week's dates
    var weekDays: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - calendar.firstWeekday), to: today)!

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    @StateObject private var mealPlan = MealPlan()
        
    // Debug
    @State private var lastSelectedRecipe: Recipe?

    var body: some View {
        NavigationView {
            ScrollView {
                // Debug view to confirm recipe selection is working
                if let recipe = lastSelectedRecipe {
                    Text("Last selected: \(recipe.name)")
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // LazyVStack so that full width is used
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(weekDays, id: \.self) { date in
                        Section(header:
                            HStack {
                                Text(sectionHeader(for: date))
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(calendar.isDateInToday(date) ? .blue : .primary)
                                if calendar.isDateInToday(date) {
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        ) {
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 25) {
                                    // Breakfast slots
                                    MealSectionWithPlan(
                                        title: "Breakfast",
                                        date: date,
                                        mealPlan: mealPlan,
                                        onRecipeSelected: { recipe in
                                            lastSelectedRecipe = recipe
                                        }
                                    )
                                    .id(mealPlan.getMeal(for: date, mealType: "Breakfast")?.id)
                                    
                                    // Lunch slots
                                    MealSectionWithPlan(
                                        title: "Lunch",
                                        date: date,
                                        mealPlan: mealPlan,
                                        onRecipeSelected: { recipe in
                                            lastSelectedRecipe = recipe
                                        }
                                    )
                                    .id(mealPlan.getMeal(for: date, mealType: "Lunch")?.id)
                                    
                                    // Dinner slots
                                    MealSectionWithPlan(
                                        title: "Dinner",
                                        date: date,
                                        mealPlan: mealPlan,
                                        onRecipeSelected: { recipe in
                                            lastSelectedRecipe = recipe
                                        }
                                    )
                                    .id(mealPlan.getMeal(for: date, mealType: "Dinner")?.id)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Weekly Meal Planner")
        }
    }

    // Format date into weekday, month day string
    func sectionHeader(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

struct MealSectionWithPlan: View {
    let title: String
    let date: Date
    @ObservedObject var mealPlan: MealPlan
    let onRecipeSelected: (Recipe) -> Void
    
    @State private var isSelecting = false
    
    var selectedRecipe: Recipe? {
        mealPlan.getMeal(for: date, mealType: title)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))

                if let recipe = selectedRecipe {
                    VStack {
                        AsyncImage(url: URL(string: recipe.image)) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } placeholder: {
                            ProgressView()
                        }
                        Text(recipe.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(8)
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Add Meal")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 180)
            .onTapGesture {
                isSelecting = true
            }
            .contextMenu {
                if selectedRecipe != nil {
                    Button(role: .destructive) {
                        mealPlan.removeMeal(for: date, mealType: title)
                    } label: {
                        Label("Remove Meal", systemImage: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $isSelecting) {
            RecipeUIView(onRecipeSelected: { recipe in
                mealPlan.addMeal(recipe: recipe, for: date, mealType: title)
                onRecipeSelected(recipe)
                self.isSelecting = false
                print("Recipe selected in MealSection: \(recipe.name)")
            })
        }
        .frame(width: 180, alignment: .leading)
        .padding()
        .cornerRadius(10)
    }
}

#Preview {
    WeeklyMealPlanView()
}

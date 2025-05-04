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
    @Published var mealsByDay: [Date: [String: Recipe]] = [:] {
        didSet {
            saveMealPlan()
        }
    }

    init() {
        loadMealPlan()
    }

    private let storageKey = "mealPlanData"

    private func saveMealPlan() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(mealsByDay) {
            UserDefaults.standard.set(data, forKey: storageKey)
            //print("Meal Plan Saved")
        }
    }

    private func loadMealPlan() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? decoder.decode([Date: [String: Recipe]].self, from: data) {
            self.mealsByDay = decoded
            //print("Meal Plan Loaded")
        }
    }
    
    func addMeal(recipe: Recipe, for date: Date, mealType: String) {
        let normalizedDate = normalizeDate(date)
        
        // Create a new dictionary if needed, otherwise update existing
        var dayMeals = mealsByDay[normalizedDate] ?? [:]
        dayMeals[mealType] = recipe
        mealsByDay[normalizedDate] = dayMeals
        
        // Log add update
        print("Added \(recipe.name) to \(mealType) on \(normalizedDate)")
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    func removeMeal(for date: Date, mealType: String) {
        let normalizedDate = normalizeDate(date)
        
        guard var dayMeals = mealsByDay[normalizedDate] else { return }
        dayMeals.removeValue(forKey: mealType)
        
        // If no meals left for this day, remove the whole day entry
        if dayMeals.isEmpty {
            mealsByDay.removeValue(forKey: normalizedDate)
        } else {
            mealsByDay[normalizedDate] = dayMeals
        }
        
        // Log remove update
        print("Removed meal from \(mealType) on \(normalizedDate)")
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    func getMeal(for date: Date, mealType: String) -> Recipe? {
        let normalizedDate = normalizeDate(date)
        return mealsByDay[normalizedDate]?[mealType]
    }
    
    func clearMeals() {
        mealsByDay.removeAll()
        print("Cleared Meal Planner")
    }
    
    // Normalize date by removing timestamps
    private func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
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
    @State private var clearConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
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
                                        mealPlan: mealPlan
                                    )
                                    
                                    // Lunch slots
                                    MealSectionWithPlan(
                                        title: "Lunch",
                                        date: date,
                                        mealPlan: mealPlan
                                    )
                                    
                                    // Dinner slots
                                    MealSectionWithPlan(
                                        title: "Dinner",
                                        date: date,
                                        mealPlan: mealPlan
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Weekly Meal Planner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        clearConfirmation = true
                    }) {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Clear Meal Plan")
                }
            }
            .alert("Clear Meal Planner?", isPresented: $clearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    mealPlan.clearMeals()
                }
            } message: {
                Text("This will remove all the recipes in your meal plan. Saved recipes will not be affected.")
            }
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
    let onRecipeSelected: (Recipe) -> Void = { _ in }
    
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
                            .lineLimit(nil) // To show full name
                            .fixedSize(horizontal: false, vertical: true) // To show full name
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
                if selectedRecipe == nil {
                    isSelecting = true
                }
                // TODO: Else open recipe detail UI view
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

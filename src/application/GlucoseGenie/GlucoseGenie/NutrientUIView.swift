//
//  NutrientUIView.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 3/8/25.
//

import SwiftUI

struct NutrientUIView: View {
    @EnvironmentObject private var store: RecipeStore

    private let caloriesString = String(localized: "Calories")
    private let carbsString    = String(localized: "Carbs")
    private let fiberString    = String(localized: "Fiber")
    private let sugarString    = String(localized: "Sugar")
    private let proteinString  = String(localized: "Protein")
    private let mealString     = String(localized: "meal")
    private let mealsString    = String(localized: "meals")
    private let noMealsString  = String(localized: "No meals planned.")

    private let daysOrder: [DayOfWeek] = [
        .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday
    ]

    private struct MacroTotals {
        var calories: Double = 0
        var carbs:    Double = 0
        var fiber:    Double = 0
        var sugar:    Double = 0
        var protein:  Double = 0
    }

    // Edamam totals are for the whole recipe yield, so divide by servings
    // to approximate what one meal-plan slot actually contributes.
    private func perServing(_ recipe: Recipe, matching keyword: String) -> Double {
        guard let nutrient = recipe.totalNutrients.first(where: {
            $0.name.localizedCaseInsensitiveContains(keyword)
        }) else { return 0 }
        let servings = max(Double(recipe.servings ?? 1), 1)
        return nutrient.quantity / servings
    }

    private func add(_ recipe: Recipe, to totals: inout MacroTotals) {
        let energy = perServing(recipe, matching: "energ")
        totals.calories += energy > 0 ? energy : perServing(recipe, matching: "calorie")
        totals.carbs    += perServing(recipe, matching: "carb")
        totals.fiber    += perServing(recipe, matching: "fiber")
        totals.sugar    += perServing(recipe, matching: "sugar")
        totals.protein  += perServing(recipe, matching: "protein")
    }

    private var weekTotals: MacroTotals {
        var totals = MacroTotals()
        for entry in store.plan { add(entry.recipe, to: &totals) }
        return totals
    }

    private func totals(for day: DayOfWeek) -> MacroTotals {
        var totals = MacroTotals()
        for entry in store.plan where entry.day == day {
            add(entry.recipe, to: &totals)
        }
        return totals
    }

    var body: some View {
        ZStack {
            Color.eggWhite.ignoresSafeArea()

            if store.plan.isEmpty {
                VStack(spacing: 12) {
                    Text("Your meal plan is empty.")
                        .font(.headline)
                    Text("Add recipes to your weekly meal plan to see your macros.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .foregroundColor(Color.darkBrown)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        weeklySummary

                        Text("By Day")
                            .font(.title2).bold()
                            .foregroundColor(Color.darkBrown)
                            .padding(.horizontal)

                        ForEach(daysOrder) { day in
                            dayCard(day)
                        }

                        Spacer(minLength: 30)
                        Image("EdamamBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 20)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Nutrient Tracker 📊")
        .navigationBarTitleDisplayMode(.large)
    }

    private var weeklySummary: some View {
        let totals = weekTotals
        return VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.title2).bold()
            macroRow(caloriesString, value: totals.calories, unit: "kcal")
            macroRow(carbsString,    value: totals.carbs,    unit: "g")
            macroRow(fiberString,    value: totals.fiber,    unit: "g")
            macroRow(sugarString,    value: totals.sugar,    unit: "g")
            macroRow(proteinString,  value: totals.protein,  unit: "g")
        }
        .foregroundColor(Color.darkBrown)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.darkBeige))
        .padding(.horizontal)
    }

    private func dayCard(_ day: DayOfWeek) -> some View {
        let dayTotals  = totals(for: day)
        let entryCount = store.plan.filter { $0.day == day }.count
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(day.displayName).font(.headline)
                Spacer()
                Text("\(entryCount) \(entryCount == 1 ? mealString : mealsString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if entryCount == 0 {
                Text(noMealsString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                macroRow(caloriesString, value: dayTotals.calories, unit: "kcal")
                macroRow(carbsString,    value: dayTotals.carbs,    unit: "g")
                macroRow(fiberString,    value: dayTotals.fiber,    unit: "g")
                macroRow(sugarString,    value: dayTotals.sugar,    unit: "g")
                macroRow(proteinString,  value: dayTotals.protein,  unit: "g")
            }
        }
        .foregroundColor(Color.darkBrown)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .padding(.horizontal)
    }

    private func macroRow(_ name: String, value: Double, unit: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(value, specifier: "%.1f") \(unit)")
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        NutrientUIView()
            .environmentObject(RecipeStore())
    }
}

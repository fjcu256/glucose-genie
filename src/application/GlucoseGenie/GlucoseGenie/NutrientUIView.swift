//
//  NutrientUIView.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 3/8/25.
//

import SwiftUI

// MARK: - Weekly Macro Goals

struct WeeklyMacroGoals: Codable, Equatable {
    var calories: Double?
    var carbs:    Double?
    var fiber:    Double?
    var sugar:    Double?
    var protein:  Double?
    var fat:      Double?

    static let empty = WeeklyMacroGoals()
}

final class MacroGoalsStore: ObservableObject {
    @Published var goals: WeeklyMacroGoals = .empty

    private let storageKey = "weekly_macro_goals"

    init() { load() }

    func save() {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(WeeklyMacroGoals.self, from: data) else {
            return
        }
        goals = decoded
    }
}

// MARK: - Main View

struct NutrientUIView: View {
    @EnvironmentObject private var store: RecipeStore
    @StateObject private var goalsStore = MacroGoalsStore()
    @State private var showingGoalsEditor = false

    private let caloriesString  = String(localized: "Calories")
    private let carbsString     = String(localized: "Carbs")
    private let fiberString     = String(localized: "Fiber")
    private let sugarString     = String(localized: "Sugar")
    private let proteinString   = String(localized: "Protein")
    private let fatString       = String(localized: "Fat")
    private let mealString      = String(localized: "meal")
    private let mealsString     = String(localized: "meals")
    private let noMealsString   = String(localized: "No meals planned.")
    private let setGoalsString  = String(localized: "Set Goals")
    private let editGoalsString = String(localized: "Edit Goals")
    private let goalsMetString  = String(localized: "Goals met:")

    private let daysOrder: [DayOfWeek] = [
        .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday
    ]

    private struct MacroTotals {
        var calories: Double = 0
        var carbs:    Double = 0
        var fiber:    Double = 0
        var sugar:    Double = 0
        var protein:  Double = 0
        var fat:      Double = 0
    }

    private enum GoalDirection { case atMost, atLeast }

    private struct MacroLine {
        let label: String
        let actual: Double
        let goal: Double?
        let unit: String
        let direction: GoalDirection

        // nil when no goal is set
        var achieved: Bool? {
            guard let goal else { return nil }
            switch direction {
            case .atMost:  return actual <= goal
            case .atLeast: return actual >= goal
            }
        }
    }

    // Mirror the Nutrition Facts panel in DetailedRecipeView so the
    // tracker reads the same numbers users see on each recipe. The
    // Spoonacular endpoint already returns per-serving values, so a
    // meal-plan slot contributes one recipe's nutrition as-is — no
    // divide-by-servings here.
    private func quantity(_ recipe: Recipe, matching keyword: String) -> Double {
        recipe.totalNutrients.first(where: {
            $0.name.localizedCaseInsensitiveContains(keyword)
        })?.quantity ?? 0
    }

    private func add(_ recipe: Recipe, to totals: inout MacroTotals) {
        let energy = quantity(recipe, matching: "energy")
        totals.calories += energy > 0 ? energy : quantity(recipe, matching: "calorie")
        totals.carbs    += quantity(recipe, matching: "carb")
        totals.fiber    += quantity(recipe, matching: "fiber")
        totals.sugar    += quantity(recipe, matching: "sugar")
        totals.protein  += quantity(recipe, matching: "protein")
        totals.fat      += quantity(recipe, matching: "fat")
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

    private func macroLines(for totals: MacroTotals) -> [MacroLine] {
        let g = goalsStore.goals
        return [
            .init(label: caloriesString, actual: totals.calories, goal: g.calories, unit: "kcal", direction: .atMost),
            .init(label: carbsString,    actual: totals.carbs,    goal: g.carbs,    unit: "g",    direction: .atMost),
            .init(label: fiberString,    actual: totals.fiber,    goal: g.fiber,    unit: "g",    direction: .atLeast),
            .init(label: sugarString,    actual: totals.sugar,    goal: g.sugar,    unit: "g",    direction: .atMost),
            .init(label: proteinString,  actual: totals.protein,  goal: g.protein,  unit: "g",    direction: .atLeast),
            .init(label: fatString,      actual: totals.fat,      goal: g.fat,      unit: "g",    direction: .atMost)
        ]
    }

    var body: some View {
        ZStack {
            Color.eggWhite.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    weeklySummary

                    if !store.plan.isEmpty {
                        Text("By Day")
                            .font(.title2).bold()
                            .foregroundColor(Color.darkBrown)
                            .padding(.horizontal)

                        ForEach(daysOrder) { day in
                            dayCard(day)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Nutrient Tracker 📊")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingGoalsEditor) {
            EditMacroGoalsView(goalsStore: goalsStore)
        }
    }

    // MARK: - Weekly summary with goal status

    private var weeklySummary: some View {
        let totals = weekTotals
        let lines = macroLines(for: totals)
        let goalsSetCount = lines.filter { $0.goal != nil }.count
        let goalsAchievedCount = lines.compactMap { $0.achieved }.filter { $0 }.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("This Week")
                    .font(.title2).bold()
                Spacer()
                Button {
                    showingGoalsEditor = true
                } label: {
                    Label(
                        goalsSetCount == 0 ? setGoalsString : editGoalsString,
                        systemImage: "target"
                    )
                    .font(.subheadline)
                }
            }

            if goalsSetCount > 0 {
                Text("\(goalsMetString) \(goalsAchievedCount) / \(goalsSetCount)")
                    .font(.subheadline.bold())
            }

            ForEach(lines, id: \.label) { line in
                weeklyMacroRow(line)
            }

            if store.plan.isEmpty {
                Text("Add recipes to your weekly meal plan to see your macros.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .foregroundColor(Color.darkBrown)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.darkBeige))
        .padding(.horizontal)
    }

    private func weeklyMacroRow(_ line: MacroLine) -> some View {
        HStack {
            Text(line.label)
            Spacer()
            if let goal = line.goal {
                Text("\(line.actual, specifier: "%.1f") / \(goal, specifier: "%.0f") \(line.unit)")
                    .fontWeight(.medium)
                Image(systemName: line.achieved == true
                      ? "checkmark.circle.fill"
                      : "xmark.circle.fill")
                    .foregroundColor(line.achieved == true ? .green : .red)
            } else {
                Text("\(line.actual, specifier: "%.1f") \(line.unit)")
                    .fontWeight(.medium)
            }
        }
    }

    // MARK: - Per-day card (unchanged)

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
                macroRow(fatString,      value: dayTotals.fat,      unit: "g")
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

// MARK: - Edit goals sheet

struct EditMacroGoalsView: View {
    @ObservedObject var goalsStore: MacroGoalsStore
    @Environment(\.dismiss) private var dismiss

    @State private var calories: String
    @State private var carbs:    String
    @State private var fiber:    String
    @State private var sugar:    String
    @State private var protein:  String
    @State private var fat:      String

    init(goalsStore: MacroGoalsStore) {
        self.goalsStore = goalsStore
        let g = goalsStore.goals
        _calories = State(initialValue: Self.formatted(g.calories))
        _carbs    = State(initialValue: Self.formatted(g.carbs))
        _fiber    = State(initialValue: Self.formatted(g.fiber))
        _sugar    = State(initialValue: Self.formatted(g.sugar))
        _protein  = State(initialValue: Self.formatted(g.protein))
        _fat      = State(initialValue: Self.formatted(g.fat))
    }

    private static func formatted(_ value: Double?) -> String {
        guard let value else { return "" }
        return String(format: "%g", value)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Set your weekly macro goals. Leave a field blank to skip it.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Section(header: Text("Stay Under")) {
                    goalRow(label: "Calories", direction: "≤", unit: "kcal", value: $calories)
                    goalRow(label: "Carbs",    direction: "≤", unit: "g",    value: $carbs)
                    goalRow(label: "Sugar",    direction: "≤", unit: "g",    value: $sugar)
                    goalRow(label: "Fat",      direction: "≤", unit: "g",    value: $fat)
                }
                Section(header: Text("Aim For At Least")) {
                    goalRow(label: "Fiber",   direction: "≥", unit: "g", value: $fiber)
                    goalRow(label: "Protein", direction: "≥", unit: "g", value: $protein)
                }
            }
            .navigationTitle("Weekly Goals")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        commit()
                        dismiss()
                    }
                }
            }
        }
    }

    private func goalRow(
        label: LocalizedStringKey,
        direction: String,
        unit: String,
        value: Binding<String>
    ) -> some View {
        HStack {
            Text(label)
            Text(direction).foregroundColor(.secondary)
            Spacer()
            TextField("—", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(unit).foregroundColor(.secondary)
        }
    }

    private func commit() {
        goalsStore.goals = WeeklyMacroGoals(
            calories: Double(calories),
            carbs:    Double(carbs),
            fiber:    Double(fiber),
            sugar:    Double(sugar),
            protein:  Double(protein),
            fat:      Double(fat)
        )
        goalsStore.save()
    }
}

#Preview {
    NavigationStack {
        NutrientUIView()
            .environmentObject(RecipeStore())
    }
}

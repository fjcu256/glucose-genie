//
//  AddToMealPlanView.swift
//  GlucoseGenie
//
//  Created by Thomas Capro on 5/8/25.
//

import SwiftUI

struct AddToMealPlanView: View {
    let recipe: Recipe
    // Optional pre-selected day when presenting this view
    let initialDay: DayOfWeek?

    @EnvironmentObject private var store: RecipeStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDay: DayOfWeek
    @State private var selectedSlot: MealSlot = .breakfast

    // Initialize with an optional pre-selected day
    init(recipe: Recipe, initialDay: DayOfWeek? = nil) {
        self.recipe = recipe
        self.initialDay = initialDay
        // If a day was passed in, start the picker there
        _selectedDay = State(initialValue: initialDay ?? .monday)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Day", selection: $selectedDay) {
                    ForEach(DayOfWeek.allCases) { day in
                        Text(day.displayName).tag(day)
                    }
                }

                Picker("Meal", selection: $selectedSlot) {
                    ForEach(MealSlot.allCases) { slot in
                        Text(slot.displayName).tag(slot)
                    }
                }
            }
            .navigationTitle("Add to Meal Plan")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addToPlan(
                            recipe: recipe,
                            day: selectedDay,
                            slot: selectedSlot
                        )
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct AddToMealPlanView_Previews: PreviewProvider {
    static var sampleRecipe: Recipe {
        // reuse your existing preview sample
        DetailedRecipeView_Previews.sampleRecipe
    }

    static var previews: some View {
        AddToMealPlanView(recipe: sampleRecipe, initialDay: .wednesday)
            .environmentObject(RecipeStore())
    }
}
#endif

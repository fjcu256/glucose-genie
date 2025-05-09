//
//  AddToMealPlanView.swift
//  GlucoseGenie
//
//  Created by Thomas Capro on 5/8/25.
//

import SwiftUI

struct AddToMealPlanView: View {
    let recipe: Recipe
    @EnvironmentObject private var store: RecipeStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDay: DayOfWeek = .monday
    @State private var selectedSlot: MealSlot = .breakfast

    var body: some View {
        NavigationStack {
            Form {
                Picker("Day",   selection: $selectedDay) {
                  ForEach(DayOfWeek.allCases) { day in
                    Text(day.displayName).tag(day)
                  }
                }
                Picker("Meal",  selection: $selectedSlot) {
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
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}

#if DEBUG
struct AddToMealPlanView_Previews: PreviewProvider {
  static var previews: some View {
    AddToMealPlanView(recipe: DetailedRecipeView_Previews.sampleRecipe)
      .environmentObject( RecipeStore() )
  }
}
#endif

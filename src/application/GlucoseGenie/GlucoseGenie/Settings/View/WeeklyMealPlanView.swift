//
//  WeeklyMealPlanView.swift
//  GlucoseGenie
//
//  Created by Capro,Thomas on 5/8/25
//

import SwiftUI

struct WeeklyMealPlanView: View {
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        List {
            ForEach(DayOfWeek.allCases) { day in
                Section(day.displayName) {
                    let entries = store.plan.filter { $0.day == day }
                    if entries.isEmpty {
                        Text("No recipes added").foregroundStyle(.secondary)
                    } else {
                        ForEach(entries) { entry in
                            HStack {
                                Text(entry.slot.displayName)
                                Spacer()
                                NavigationLink(entry.recipe.name) {
                                    DetailedRecipeView(recipe: entry.recipe)
                                      .environmentObject(store)
                                }
                            }
                        }
                        .onDelete { offsets in
                            offsets.map { entries[$0] }
                                .forEach(store.removeFromPlan)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Weekly Meal Plan")
    }
}

#if DEBUG
struct WeeklyMealPlanView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WeeklyMealPlanView()
        .environmentObject( RecipeStore() )
    }
  }
}
#endif

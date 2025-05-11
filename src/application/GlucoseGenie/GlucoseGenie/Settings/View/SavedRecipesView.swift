//
//  SavedRecipesView.swift
//  GlucoseGenie
//
//  Created by Capro,Thomas 5/8/25
//

import SwiftUI

struct SavedRecipesView: View {
    @EnvironmentObject private var store: RecipeStore

    // Holds the recipe the user tapped “plan” on
    @State private var planRecipe: Recipe?

    var body: some View {
        List {
            if store.saved.isEmpty {
                // Empty state
                Text("You have no saved recipes.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.saved) { recipe in
                    HStack {
                        // Tap name to go to detail
                        NavigationLink(recipe.name) {
                            DetailedRecipeView(recipe: recipe)
                                .environmentObject(store)
                        }
                        Spacer()
                        // “+” button to plan this recipe
                        Button {
                            planRecipe = recipe
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .accessibilityLabel("Add \(recipe.name) to meal plan")
                    }
                    .swipeActions {
                        Button {
                            planRecipe = recipe
                        } label: {
                            Label("Plan", systemImage: "calendar.badge.plus")
                        }
                        .tint(.blue)
                    }
                }
                .onDelete { offsets in
                    store.saved.remove(atOffsets: offsets)
                }
            }
        }
        .navigationTitle("Saved Recipes")
        // sheet(item:) only fires if planRecipe is non-nil
        .sheet(item: $planRecipe) { recipeToPlan in
            NavigationStack {
                AddToMealPlanView(recipe: recipeToPlan)
                    .environmentObject(store)
            }
        }
    }
}

#if DEBUG
struct SavedRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SavedRecipesView()
                .environmentObject(RecipeStore())
        }
    }
}
#endif

//  SavedRecipesView.swift
//  GlucoseGenie
//
//  Created by Capro,Thomas on 5/8/25
//

import SwiftUI

struct SavedRecipesView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var authenticationService: AuthenticationService

    // Which saved recipe the user tapped “plan” on
    @State private var planRecipe: Recipe?
    let addString = String(localized: "Add")
    let toMealPlanString = String(localized: "to meal plan")

    var body: some View {
        List {
            if store.saved.isEmpty {
                // Empty state
                Text("You have no saved recipes.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ForEach(store.saved) { recipe in
                    HStack {
                        // Name → detail
                        NavigationLink(recipe.name) {
                            DetailedRecipeView(recipe: recipe)
                                .environmentObject(store)
                                .environmentObject(authenticationService)
                        }
                        Spacer()
                        // Calendar button → plan sheet
                        Button {
                            planRecipe = recipe
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                                .imageScale(.large)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .accessibilityLabel("\(addString) \(recipe.name) \(toMealPlanString)")
                    }
                    .swipeActions {
                        Button {
                            planRecipe = recipe
                        } label: {
                            Label("Plan", systemImage: "calendar.badge.plus")
                        }
                        .tint(.orangeMain)
                    }
                    .listRowBackground(Color.white)
                }
                .onDelete { offsets in
                    store.saved.remove(atOffsets: offsets)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.eggWhite)
        .navigationTitle("Saved Recipes")
        .navigationBarTitleDisplayMode(.large)
        // Present the standard day+slot picker
        .sheet(item: $planRecipe) { recipeToPlan in
            NavigationStack {
                AddToMealPlanView(recipe: recipeToPlan)
                    .environmentObject(store)
            }
        }
        Spacer(minLength: 30)
        Image("EdamamBadge")
            .resizable()
            .scaledToFit()
            .frame(height: 30)
            .padding(.bottom, 20)
    }
}

#if DEBUG
struct SavedRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SavedRecipesView()
                .environmentObject(RecipeStore())
                .environmentObject(AuthenticationService())
        }
    }
}
#endif

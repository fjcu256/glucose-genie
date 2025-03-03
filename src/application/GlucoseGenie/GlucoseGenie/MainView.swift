//
//  MainView.swift
//  GlucoseGenie
//
//  Created by Francisco Cruz-Urbanc on 2/23/25.

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    @State private var showMenu = false
    
    var body: some View {
        NavigationStack {
            VStack {                
                NavigationLink(destination: SettingsUIView()) {
                    Image(systemName: "gearshape.fill")
                }
                NavigationLink(destination: RecipeView()) {
                    Text("Recipes")
                }
                NavigationLink(destination: SavedRecipesView()) {
                    Text("Saved Recipes")
                }
                NavigationLink(destination: WeeklyMealPlanView()) {
                    Text("Weekly Meal Plan")
                }
                NavigationLink(destination: GroceryListView()) {
                    Text("Grocery List")
                }
                NavigationLink(destination: GroceryStoreView()) {
                    Text("Find Grocery Store")
                }
            }
        }
    }
}

#Preview {
    MainView()
}

//
//  WeeklyMealPlanView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

struct WeeklyMealPlanView: View {
    var body: some View {
        // Text("Weekly Meal Plan View")
        // Weekly meal plan page should have a section that
        // shows nutrient totals from recipes.
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Test")
                }
                .padding()
            }
            .navigationTitle("Weekly Meal Planner")
            .toolbar {
                Button(action: {
                    // Action for adding or editing meals
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
}

#Preview {
    WeeklyMealPlanView()
}

//
//  WeeklyMealPlanView.swift
//  GlucoseGenie
//
//  Created by Capro,Thomas on 5/8/25
//

import SwiftUI

struct WeeklyMealPlanView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var authenticationService: AuthenticationService
    private let calendar = Calendar.current

    // Which day the user tapped “+” on, to show the picker sheet
    @State private var dayToAdd: DayOfWeek? = nil

    // Compute the current week’s dates (Sunday…Saturday by default)
    private var weekDays: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - calendar.firstWeekday),
            to: today
        )!
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(DayOfWeek.allCases) { day in
                    Section(header: headerView(for: day)) {
                        let entries = store.plan.filter { $0.day == day }

                        if entries.isEmpty {
                            Text("No recipes added")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(entries) { entry in
                                HStack {
                                    Text(entry.slot.displayName)
                                    Spacer()
                                    NavigationLink(entry.recipe.name) {
                                        DetailedRecipeView(recipe: entry.recipe)
                                            .environmentObject(store)
                                            .environmentObject(authenticationService)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.removeFromPlan(entry)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete { offsets in
                                let toDelete = offsets.map { entries[$0] }
                                toDelete.forEach(store.removeFromPlan)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Weekly Meal Plan")
            // Present the “choose saved recipe” sheet when dayToAdd is set
            .sheet(item: $dayToAdd) { day in
                    NavigationStack {
                        Group {
                            if store.saved.isEmpty {
                                // When there are no saved recipes
                                VStack(spacing: 16) {
                                    Text("No saved recipes to add")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Save some recipes first, then come back to add them here.")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            } else {
                                // Show the list of saved recipes
                                List(store.saved) { recipe in
                                    NavigationLink(recipe.name) {
                                        AddToMealPlanView(recipe: recipe, initialDay: day)
                                            .environmentObject(store)
                                            .environmentObject(authenticationService)
                                    }
                                }
                            }
                        }
                        .navigationTitle("Add to \(day.displayName.prefix(3))")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { dayToAdd = nil }
                            }
                        }
                    }
                    .environmentObject(store)
                    .environmentObject(authenticationService)
                }
        }
    }

    // Builds the section header with day name and a "+" button
    @ViewBuilder
    private func headerView(for day: DayOfWeek) -> some View {
        HStack {
            Text(day.displayName)
                .font(.title2)
                .bold()
                .foregroundColor(
                    calendar.isDateInToday(
                        calendar.date(from: calendar.dateComponents([.year, .month, .day], from: Date()))!
                    ) ? .blue : .primary
                )
            Spacer()
            Button {
                dayToAdd = day
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title2)
            }
            .accessibilityLabel("Add recipe to \(day.displayName)")
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
struct WeeklyMealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeeklyMealPlanView()
                .environmentObject(RecipeStore())
                .environmentObject(AuthenticationService())
        }
    }
}
#endif

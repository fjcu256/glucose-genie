//
//  WeeklyMealPlanView.swift
//  GlucoseGenie
//
//  Created by Capro,Thomas on 5/8/25
//

import SwiftUI

struct WeeklyMealPlanView: View {
    @EnvironmentObject private var store: RecipeStore
    let calendar = Calendar.current

    // For presenting the “choose saved recipe” sheet
    @State private var dayToAdd: DayOfWeek? = nil

    // Compute the current week’s dates
    var weekDays: [Date] {
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
                    // Section for each day, with a + button in header
                    Section(
                        header:
                            HStack {
                                Text(day.displayName)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(
                                        calendar.isDateInToday(
                                            calendar.date(from: calendar.dateComponents([.year, .month, .day], from: Date()))!
                                        )
                                        ? .blue
                                        : .primary
                                    )
                                Spacer()
                                // Add button for this day
                                Button {
                                    dayToAdd = day
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.title2)
                                }
                                .accessibilityLabel("Add recipe to \(day.displayName)")
                            }
                            .padding(.vertical, 4)
                    ) {
                        // List all entries for this day
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
            // Sheet to pick from saved recipes
            .sheet(item: $dayToAdd) { day in
                NavigationStack {
                    List(store.saved) { recipe in
                        NavigationLink(recipe.name) {
                            // Reuse your existing AddToMealPlanView:
                            AddToMealPlanView(recipe: recipe)
                                .environmentObject(store)
                                // Pre-select the day for convenience
                                .onAppear {
                                    // If you want to prefill the day picker,
                                    // you could add an initializer or @State default in AddToMealPlanView
                                }
                        }
                    }
                    .navigationTitle("Add To \(day.displayName)")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { dayToAdd = nil }
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct WeeklyMealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyMealPlanView()
            .environmentObject(RecipeStore())
    }
}
#endif

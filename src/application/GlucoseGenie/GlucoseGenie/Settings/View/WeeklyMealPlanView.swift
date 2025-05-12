// WeeklyMealPlanView.swift
// GlucoseGenie
//
// Created by Capro,Thomas on 5/8/25
//

import SwiftUI

private enum ActiveSheet: Identifiable {
    case chooseDay(day: DayOfWeek)
    case chooseRecipe(day: DayOfWeek, slot: MealSlot)

    var id: String {
        switch self {
        case .chooseDay(let d):           return "day-\(d.rawValue)"
        case .chooseRecipe(let d, let s): return "recipe-\(d.rawValue)-\(s.rawValue)"
        }
    }
}

struct WeeklyMealPlanView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var authService: AuthenticationService

    @State private var activeSheet: ActiveSheet?
    @State private var clearConfirmation = false

    private let calendar = Calendar.current
    private let slots: [MealSlot] = [.breakfast, .lunch, .dinner]
    private let addRecipeToString = String(localized: "Add recipe to")

    // Always start week on Sunday
    private let daysOrder: [DayOfWeek] = [
        .sunday, .monday, .tuesday,
        .wednesday, .thursday, .friday, .saturday
    ]

    // Formatter for "May 11" style
    private static let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM d"
        return f
    }()

    // Compute the dates for this week, starting Sunday
    private var weekDays: [Date] {
        let today       = Date()
        let weekday     = calendar.component(.weekday, from: today) // 1 = Sunday
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: today
        )!
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(Array(zip(daysOrder, weekDays)), id: \.0) { day, date in
                        VStack(alignment: .leading, spacing: 8) {
                            // Day header with date and sun icon
                            HStack(spacing: 4) {
                                Text(day.displayName)
                                    .font(.title2).bold()
                                    .foregroundColor(
                                        calendar.isDateInToday(date)
                                            ? .blue
                                            : .primary
                                    )
                                Text("· \(Self.monthDayFormatter.string(from: date))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                if calendar.isDateInToday(date) {
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(.orange)
                                }
                                Spacer()
                                Button {
                                    activeSheet = .chooseDay(day: day)
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.title2)
                                }
                                .accessibilityLabel("\(addRecipeToString) \(day.displayName)")
                            }
                            .padding(.horizontal)

                            // Horizontal carousel of meal slots
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(slots, id: \.self) { slot in
                                        MealTile(day: day, slot: slot, activeSheet: $activeSheet)
                                            .environmentObject(store)
                                            .environmentObject(authService)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Weekly Meal Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        clearConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Clear all meals")
                }
            }
            .confirmationDialog(
                "Clear all meals in your plan?",
                isPresented: $clearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    store.plan.removeAll()
                }
                Button("Cancel", role: .cancel) { }
            }
            // unified sheet for both flows
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .chooseDay(let day):
                    // show full search UI, then move to choose slot
                    RecipeUIView(onRecipeSelected: { recipe, _ in
                        activeSheet = .chooseRecipe(day: day, slot: .breakfast)
                    })
                    .environmentObject(store)
                    .environmentObject(authService)

                case .chooseRecipe(let day, let slot):
                    // show full search UI, tap adds directly
                    RecipeUIView(onRecipeSelected: { recipe, _ in
                        store.addToPlan(recipe: recipe, day: day, slot: slot)
                        activeSheet = nil
                    })
                    .environmentObject(store)
                    .environmentObject(authService)
                }
            }
        }
    }
}

private struct MealTile: View {
    let day: DayOfWeek
    let slot: MealSlot
    @Binding var activeSheet: ActiveSheet?

    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var authService: AuthenticationService

    private var entry: MealPlanEntry? {
        store.plan.first { $0.day == day && $0.slot == slot }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(slot.displayName).font(.headline)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 150, height: 150)

                if let entry = entry {
                    NavigationLink {
                        DetailedRecipeView(recipe: entry.recipe)
                            .environmentObject(store)
                            .environmentObject(authService)
                    } label: {
                        TileContent(recipe: entry.recipe)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            store.removeFromPlan(entry)
                        } label: {
                            Label("Remove Meal", systemImage: "trash")
                        }
                    }
                } else {
                    Button {
                        activeSheet = .chooseRecipe(day: day, slot: slot)
                    } label: {
                        VStack {
                            Image(systemName: "plus.circle")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            Text("Add")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}

private struct TileContent: View {
    let recipe: Recipe

    var body: some View {
        VStack(spacing: 4) {
            if let url = recipe.imageUrl {
                AsyncImage(url: url) { phase in
                    phase.image?
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Text("🍽️")
                    .font(.largeTitle)
            }
            Text(recipe.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 150)
    }
}

#if DEBUG
struct WeeklyMealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyMealPlanView()
            .environmentObject(RecipeStore())
            .environmentObject(AuthenticationService())
    }
}
#endif

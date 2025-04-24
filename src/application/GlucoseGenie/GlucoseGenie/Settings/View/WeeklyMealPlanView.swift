//
//  WeeklyMealPlanView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

let testRecipe: Recipe = Recipe(name: "Recipe Name", imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/shutterstock_425424460.webp?h=e2d4e250&itok=ptCQ_FGY", calories: 5, carbs: 5)

struct WeeklyMealPlanView: View {
    let calendar = Calendar.current

    // Compute and store the current week's dates
    var weekDays: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - calendar.firstWeekday), to: today)!

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                // LazyVStack so that full width is used
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(weekDays, id: \.self) { date in
                        Section(header:
                            HStack {
                                Text(sectionHeader(for: date))
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(calendar.isDateInToday(date) ? .blue : .primary)
                                if calendar.isDateInToday(date) {
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        ) {
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 25) {
                                    MealSection(title: "Breakfast")
                                    MealSection(title: "Lunch")
                                    MealSection(title: "Dinner")
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Weekly Meal Planner")
        }
    }

    // Format date into weekday, month day string
    func sectionHeader(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

struct MealSection: View {
    let title: String
    @State private var mealAdded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))

                if mealAdded {
                    VStack {
                        AsyncImage(url: URL(string: testRecipe.imageUrl)) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } placeholder: {
                            ProgressView()
                        }
                        Text(testRecipe.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Add Meal")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 180)
            .onTapGesture {
                if !mealAdded {
                    mealAdded = true
                }
            }
            .contextMenu {
                if mealAdded {
                    Button(role: .destructive) {
                        mealAdded = false
                    } label: {
                        Label("Remove Meal", systemImage: "trash")
                    }
                }
            }
        }
        .frame(width: 180, alignment: .leading)
        .padding()
        .cornerRadius(10)
    }
}


#Preview {
    WeeklyMealPlanView()
}

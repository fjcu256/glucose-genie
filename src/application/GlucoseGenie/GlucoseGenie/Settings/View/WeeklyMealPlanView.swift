//
//  WeeklyMealPlanView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

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
                                //Spacer()
                                Button(action: {
                                    // None
                                }) {
                                    Image(systemName: "square.and.pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        ) {
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 30) {
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

            VStack {
                if mealAdded {
                    Text("Meal Info Here")
                } else {
                    Button(action: {
                        mealAdded = true
                    }) {
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
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .frame(width: 100, alignment: .leading) // Fixed width
        .padding()
        .cornerRadius(10)
    }
}

#Preview {
    WeeklyMealPlanView()
}

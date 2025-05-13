//
//  RecipeStore.swift
//  GlucoseGenie
//
//  Created by Thomas Capro on 5/8/25.
//

import Foundation
import Combine

//–– The days & meal-slots the user can choose when adding a recipe
enum DayOfWeek: String, CaseIterable, Codable, Identifiable {
  case monday, tuesday, wednesday, thursday, friday, saturday, sunday
  var id: String { rawValue }
  var displayName: String { return NSLocalizedString(rawValue.capitalized, comment: "") }
}

enum MealSlot: String, CaseIterable, Codable, Identifiable {
  case breakfast, lunch, dinner
  var id: String { rawValue }
    var displayName: String { return NSLocalizedString(rawValue.capitalized, comment: "") }
}

//–– One entry in the weekly meal plan
struct MealPlanEntry: Identifiable, Codable {
  let id: UUID
  let day: DayOfWeek
  let slot: MealSlot
  let recipe: Recipe
}

final class RecipeStore: ObservableObject {
  @Published var saved: [Recipe] = []
  @Published var plan: [MealPlanEntry] = []

  private let savedKey = "saved_recipes"
  private let planKey  = "weekly_plan"

  init() { load() }

  func toggleSave(_ r: Recipe) {
    if let idx = saved.firstIndex(of: r) {
      saved.remove(at: idx)
    } else {
      saved.append(r)
    }
    save()
  }

  func addToPlan(recipe: Recipe, day: DayOfWeek, slot: MealSlot) {
    let entry = MealPlanEntry(id: UUID(), day: day, slot: slot, recipe: recipe)
    plan.append(entry)
    save()
  }

  func removeFromPlan(_ entry: MealPlanEntry) {
    plan.removeAll { $0.id == entry.id }
    save()
  }
    
  func clearPlan() {
    plan.removeAll()
    save()
  }

  private func load() {
    let decoder = JSONDecoder()
    if let data = UserDefaults.standard.data(forKey: savedKey),
       let arr  = try? decoder.decode([Recipe].self, from: data) {
      saved = arr
    }
    if let data = UserDefaults.standard.data(forKey: planKey),
       let arr  = try? decoder.decode([MealPlanEntry].self, from: data) {
      plan = arr
    }
  }

  private func save() {
    let encoder = JSONEncoder()
    if let d = try? encoder.encode(saved) {
      UserDefaults.standard.set(d, forKey: savedKey)
    }
    if let d = try? encoder.encode(plan) {
      UserDefaults.standard.set(d, forKey: planKey)
    }
  }
}

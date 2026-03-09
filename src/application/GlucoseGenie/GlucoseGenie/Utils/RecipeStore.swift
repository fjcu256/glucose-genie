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

  // Cached recipes — persists across tab navigation, cleared on language change
  @Published var cachedRecipes: [Recipe] = []
  @Published var cachedLanguage: String = ""

  // Current language selection
  @Published var language: String = (Bundle.main.preferredLocalizations.first ?? "en").components(separatedBy: "-").first ?? "en"

  private let savedKey      = "saved_recipes"
  private let planKey       = "weekly_plan"
  private let cachedKey     = "cached_recipes"
  private let cachedLangKey = "cached_language"
  private let lastResetDate = "last_reset_date"

  init() { load() }

  // Returns true if cached recipes are valid for the current language
  var hasFreshCache: Bool {
    !cachedRecipes.isEmpty && cachedLanguage == language
  }

  func setCachedRecipes(_ recipes: [Recipe], language: String) {
    cachedRecipes = recipes
    cachedLanguage = language
    saveCachedRecipes()
  }

  func clearCache() {
    cachedRecipes = []
    cachedLanguage = ""
    UserDefaults.standard.removeObject(forKey: cachedKey)
    UserDefaults.standard.removeObject(forKey: cachedLangKey)
  }

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

  func resetIfNewWeek() {
    let calendar = Calendar.current
    let today = Date()
    let startOfThisWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

    if let lastResetData = UserDefaults.standard.object(forKey: lastResetDate) as? Date {
      if !calendar.isDate(lastResetData, equalTo: today, toGranularity: .weekOfYear) {
        clearPlan()
        UserDefaults.standard.set(startOfThisWeek, forKey: lastResetDate)
      }
    } else {
      UserDefaults.standard.set(startOfThisWeek, forKey: lastResetDate)
    }
  }

  // MARK: - Persistence

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
    // Load cached recipes
    if let data = UserDefaults.standard.data(forKey: cachedKey),
       let arr  = try? decoder.decode([Recipe].self, from: data) {
      cachedRecipes = arr
    }
    cachedLanguage = UserDefaults.standard.string(forKey: cachedLangKey) ?? ""
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

  private func saveCachedRecipes() {
    let encoder = JSONEncoder()
    if let d = try? encoder.encode(cachedRecipes) {
      UserDefaults.standard.set(d, forKey: cachedKey)
    }
    UserDefaults.standard.set(cachedLanguage, forKey: cachedLangKey)
  }
}

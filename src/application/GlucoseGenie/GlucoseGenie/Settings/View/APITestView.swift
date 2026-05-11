//
//  APITestView.swift
//  GlucoseGenie
//

import SwiftUI

struct APITestView: View {
    @State private var message = "Tap to test Spoonacular API"
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .padding()
                .multilineTextAlignment(.center)
                .foregroundColor(message.contains("✅") ? .green :
                                 message.contains("❌") ? .red : .primary)

            Button {
                Task { await testAPI() }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Test Spoonacular API")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)

            List(recipes) { recipe in
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name).font(.headline)
                    if let cal = recipe.calories {
                        Text("\(cal) kcal").font(.subheadline).foregroundColor(.gray)
                    }
                    Text("\(recipe.ingredients.count) ingredients")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle("API Test")
    }

    func testAPI() async {
        isLoading = true
        message = "Fetching..."

        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!
        components.queryItems = [
            .init(name: "apiKey",               value: Secrets.spoonacularKey),
            .init(name: "addRecipeInformation", value: "true"),
            .init(name: "addRecipeNutrition",   value: "true"),
            .init(name: "fillIngredients",      value: "true"),
            .init(name: "maxCalories",          value: "800"),
            .init(name: "maxCarbs",             value: "50"),
            .init(name: "maxSugar",             value: "15"),
            .init(name: "number",               value: "5")
        ]

        guard let url = components.url else {
            message = "❌ Invalid URL"
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            let (parsed, _) = RecipeParser.parseRecipes(from: data)

            await MainActor.run {
                if parsed.isEmpty {
                    // Show raw response to help diagnose
                    let raw = String(data: data, encoding: .utf8) ?? "unreadable"
                    message = "❌ HTTP \(statusCode) — parsed 0 recipes\n\n\(raw.prefix(300))"
                } else {
                    message = "✅ HTTP \(statusCode) — got \(parsed.count) recipes"
                    recipes = parsed
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                message = "❌ Network error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

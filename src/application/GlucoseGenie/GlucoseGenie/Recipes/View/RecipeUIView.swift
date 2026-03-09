//
//  RecipeUIView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/10/25.
//

import SwiftUI

struct RecipeUIView: View {
    var onRecipeSelected: ((Recipe, URL?) -> Void)? = nil

    init(onRecipeSelected: ((Recipe, URL?) -> Void)? = nil) {
        self.onRecipeSelected = onRecipeSelected
    }

    @EnvironmentObject private var store: RecipeStore
    @State private var allRecipes: [Recipe] = []
    @State private var searchQuery: String = ""
    @State private var isLoading: Bool = true
    @State private var uiErrorMessage: String?
    @State private var nextPageUrl: URL?
    @State private var isLoadingMore = false

    let mealTypeFilters: [MealType] = MealType.allCases
    let healthFilters: [HealthLabel] = HealthLabel.allCases
    @State private var selectedMealTypes: Set<MealType> = []
    @State private var selectedHealthLabels: Set<HealthLabel> = []
    let caloriesString = String(localized: "Calories")
    let carbsString = String(localized: "Carbs")
    let filtersString = String(localized: "Filters")

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Color.eggWhite
                }.ignoresSafeArea()

                ScrollView {
                    VStack {
                        filterSection
                        recipeGrid
                        loadMoreButton
                        Spacer(minLength: 30)
                    }
                }
                .navigationTitle("Recipes 🔎")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    if store.hasFreshCache {
                        // Use cached recipes — no API call needed
                        allRecipes = store.cachedRecipes
                        isLoading = false
                    } else {
                        Task { await fetchAndTranslateRecipes() }
                    }
                }
                .onChange(of: store.language) {
                    // Language changed — clear cache and re-fetch
                    store.clearCache()
                    allRecipes = []
                    Task { await fetchAndTranslateRecipes() }
                }
            }
        }
    }

    // MARK: - Fetch + Translate

    private func fetchAndTranslateRecipes() async {
        await MainActor.run { isLoading = true }

        guard !Secrets.spoonacularKey.isEmpty else {
            await MainActor.run {
                isLoading = false
                uiErrorMessage = String(localized: "Unable to get recipes. Credentials are missing. Please contact support.")
            }
            return
        }

        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!
        components.queryItems = [
            .init(name: "apiKey",               value: Secrets.spoonacularKey),
            .init(name: "addRecipeInformation", value: "true"),
            .init(name: "addRecipeNutrition",   value: "true"),
            .init(name: "fillIngredients",      value: "true"),
            .init(name: "maxCalories",          value: "800"),
            .init(name: "maxCarbs",             value: "50"),
            .init(name: "maxSugar",             value: "15"),
            .init(name: "number",               value: "10"),
            .init(name: "offset",               value: "0")
        ]

        guard let url = components.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let (parsed, _) = RecipeParser.parseRecipes(from: data)
            let final = await RecipeParser.translateRecipes(parsed, to: store.language)

            await MainActor.run {
                allRecipes = final
                store.setCachedRecipes(final, language: store.language)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                uiErrorMessage = String(localized: "Something went wrong while getting recipes.")
            }
        }
    }

    private func loadMoreRecipes() {
        nextPageUrl = nil
    }

    // MARK: - Filter Section

    @ViewBuilder private var filterSection: some View {
        VStack(spacing: 12) {
            TextField("Search recipes...", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Menu {
                Section("Meal Types") {
                    ForEach(mealTypeFilters, id: \.self) { filter in
                        Button {
                            toggleMealTypeFilter(filter)
                        } label: {
                            HStack {
                                Text(filter.displayName)
                                Spacer()
                                if selectedMealTypes.contains(filter) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                Section("Diets") {
                    ForEach(healthFilters, id: \.self) { filter in
                        Button {
                            toggleHealthFilter(filter)
                        } label: {
                            HStack {
                                Text(filter.displayName)
                                Spacer()
                                if selectedHealthLabels.contains(filter) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                Divider()
                Button("Clear All Filters") {
                    selectedMealTypes.removeAll()
                    selectedHealthLabels.removeAll()
                }
            } label: {
                HStack {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                    Text("\(filtersString) (\(selectedMealTypes.count + selectedHealthLabels.count))")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orangeMain)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
            }

            if let error = uiErrorMessage {
                Text(error)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - Recipe Grid

    @ViewBuilder private var recipeGrid: some View {
        if isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(filteredRecipes) { recipe in
                    if let selectAction = onRecipeSelected {
                        Button {
                            selectAction(recipe, recipe.imageUrl)
                        } label: {
                            recipeCard(recipe)
                        }
                    } else {
                        NavigationLink {
                            DetailedRecipeView(recipe: recipe)
                        } label: {
                            recipeCard(recipe)
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Load More

    @ViewBuilder private var loadMoreButton: some View {
        if nextPageUrl != nil {
            Button {
                loadMoreRecipes()
            } label: {
                if isLoadingMore {
                    ProgressView().padding()
                } else {
                    Text("Load More Recipes")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orangeMain)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Recipe Card

    private func recipeCard(_ recipe: Recipe) -> some View {
        VStack {
            if let imageUrl = recipe.imageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 150)
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        Text("🍽️")
                            .font(.system(size: 60))
                            .frame(width: 150, height: 150)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("🍽️")
                    .font(.system(size: 60))
                    .frame(width: 150, height: 150)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.darkBrown)

                HStack {
                    if let cal = recipe.calories {
                        Text("\(caloriesString): \(cal) kcal")
                    }
                    if let carb = recipe.carbs {
                        Text("\(carbsString): \(carb)g")
                    }
                }
                .font(.subheadline)
                .foregroundColor(Color.darkBrown)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color.darkBeige))
    }

    // MARK: - Filtering

    private var filteredRecipes: [Recipe] {
        let trimmed = searchQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        var results = allRecipes

        if !selectedMealTypes.isEmpty {
            results = results.filter {
                !Set($0.mealtypes).isDisjoint(with: selectedMealTypes)
            }
        }
        if !selectedHealthLabels.isEmpty {
            results = results.filter {
                !Set($0.healthLabels).isDisjoint(with: selectedHealthLabels)
            }
        }
        guard !trimmed.isEmpty else { return results }
        return results.filter { recipe in
            recipe.name.lowercased().contains(trimmed) ||
            recipe.ingredients.contains { $0.text.lowercased().contains(trimmed) } ||
            recipe.healthLabelsDisplay.lowercased().contains(trimmed) ||
            recipe.tags.contains { $0.lowercased().contains(trimmed) }
        }
    }

    // MARK: - Helpers

    private func toggleMealTypeFilter(_ filter: MealType) {
        if selectedMealTypes.contains(filter) {
            selectedMealTypes.remove(filter)
        } else {
            selectedMealTypes.insert(filter)
        }
    }

    private func toggleHealthFilter(_ filter: HealthLabel) {
        if selectedHealthLabels.contains(filter) {
            selectedHealthLabels.remove(filter)
        } else {
            selectedHealthLabels.insert(filter)
        }
    }
}

struct RecipeUIView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecipeUIView()
        }
        .environmentObject(RecipeStore())
    }
}

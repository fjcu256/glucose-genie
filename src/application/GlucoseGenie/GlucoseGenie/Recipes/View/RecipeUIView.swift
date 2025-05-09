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
    // All fetched recipes
    @State public var allRecipes: [Recipe] = []
    // Search text
    @State private var searchQuery: String = ""
    // Which recipes the user has "liked"
    @State private var likedRecipes: [Recipe] = []
    // Loading / error state
    @State private var isLoading: Bool = true
    @State private var uiErrorMessage: String?
    // Language header for API calls
    @State private var lang: String = "en"
    // Pagination
    @State private var nextPageUrl: URL?
    @State private var isLoadingMore = false

    // Available filter options
    let mealTypeFilters: [MealType] = MealType.allCases
    let healthFilters: [HealthLabel] = HealthLabel.allCases
    @State private var selectedMealTypes: Set<MealType> = []
    @State private var selectedHealthLabels: Set<HealthLabel> = []

    var body: some View {
        NavigationView {
            ScrollView {
                // Search bar + filter controls
                filterSection

                // Grid of recipe cards
                recipeGrid

                // "Load More" button if there is a next page
                loadMoreButton
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if allRecipes.isEmpty {
                    fetchInitialRecipes()
                }
            }
        }
    }


    // The search field and filter menu
    @ViewBuilder
    private var filterSection: some View {
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
                Section("Health Labels") {
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
                    Text("Filters (\(selectedMealTypes.count + selectedHealthLabels.count))")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
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

    // The grid of fetched recipes
    @ViewBuilder
    private var recipeGrid: some View {
        if isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink {
                        DetailedRecipeView(recipe: recipe)
                            .environmentObject(RecipeStore())
                    } label: {
                        recipeCard(recipe)
                    }
                }
            }
            .padding()
        }
    }

    // Button to load more recipes if available
    @ViewBuilder
    private var loadMoreButton: some View {
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
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
        }
    }

    // A single recipe "card" showing image, name, calories/carbs, and like button
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

                HStack {
                    if let cal = recipe.calories {
                        Text("Calories: \(cal) kcal")
                    }
                    if let carb = recipe.carbs {
                        Text("Carbs: \(carb)g")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Button {
                    toggleLike(recipe)
                } label: {
                    Image(systemName: likedRecipes.contains(recipe) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6)))
    }


    // Returns the recipes array filtered by search text and selected filters
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

    // Toggle whether a meal type filter is active
    private func toggleMealTypeFilter(_ filter: MealType) {
        if selectedMealTypes.contains(filter) {
            selectedMealTypes.remove(filter)
        } else {
            selectedMealTypes.insert(filter)
        }
    }

    // Toggle whether a health label filter is active
    private func toggleHealthFilter(_ filter: HealthLabel) {
        if selectedHealthLabels.contains(filter) {
            selectedHealthLabels.remove(filter)
        } else {
            selectedHealthLabels.insert(filter)
        }
    }

    // Add or remove a recipe from `likedRecipes`
    private func toggleLike(_ recipe: Recipe) {
        if likedRecipes.contains(recipe) {
            likedRecipes.removeAll { $0 == recipe }
        } else {
            likedRecipes.append(recipe)
        }
    }

    // Fetches the first one or more pages of recipes from Edamam
    private func fetchInitialRecipes() {
        let baseUrl = "https://api.edamam.com/api/recipes/v2"
        guard !Secrets.appId.isEmpty, !Secrets.appKey.isEmpty else {
            DispatchQueue.main.async {
                isLoading = false
                uiErrorMessage = "Credentials missing. Please contact support."
            }
            return
        }

        var query = URLComponents(string: baseUrl)!
        query.queryItems = [
            .init(name: "type", value: "public"),
            .init(name: "app_id", value: Secrets.appId),
            .init(name: "app_key", value: Secrets.appKey),
            .init(name: "health", value: "alcohol-free"),
            .init(name: "glycemicIndex", value: "0.0-69.0"),
            .init(name: "calories", value: "0-800"),
            .init(name: "nutrients[CHOCDF]", value: "0-50.0"),
            .init(name: "nutrients[SUGAR]", value: "0-15.0")
        ]

        isLoading = true
        var combined: [Recipe] = []
        var pagesFetched = 0
        let maxPages = 3

        func fetchPage(from url: URL) {
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.addValue("application/json", forHTTPHeaderField: "accept")
            req.addValue(lang, forHTTPHeaderField: "Accept-Language")

            URLSession.shared.dataTask(with: req) { data, _, error in
                if error != nil || data == nil {
                    DispatchQueue.main.async {
                        isLoading = false
                        uiErrorMessage = "Failed to load recipes."
                    }
                    return
                }
                let (parsed, nextUrl) = RecipeParser.parseRecipes(from: data!)
                combined.append(contentsOf: parsed)
                pagesFetched += 1

                if let nxt = nextUrl, pagesFetched < maxPages {
                    fetchPage(from: nxt)
                    nextPageUrl = nxt
                } else {
                    DispatchQueue.main.async {
                        allRecipes = combined
                        isLoading = false
                    }
                }
            }
            .resume()
        }

        if let initial = query.url {
            fetchPage(from: initial)
        }
    }

    // Loads the next page of recipes if there is one
    private func loadMoreRecipes() {
        guard let url = nextPageUrl, !isLoadingMore else { return }
        isLoadingMore = true

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.addValue("application/json", forHTTPHeaderField: "accept")
        req.addValue(lang, forHTTPHeaderField: "Accept-Language")

        URLSession.shared.dataTask(with: req) { data, _, _ in
            defer { DispatchQueue.main.async { isLoadingMore = false } }
            guard let data else { return }
            let (parsed, nextUrl) = RecipeParser.parseRecipes(from: data)
            let unique = parsed.filter { !allRecipes.contains($0) }
            DispatchQueue.main.async {
                allRecipes.append(contentsOf: unique)
                self.nextPageUrl = nextUrl
            }
        }
        .resume()
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

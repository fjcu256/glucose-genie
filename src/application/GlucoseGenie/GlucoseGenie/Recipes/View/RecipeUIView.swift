//
//  RecipeUIView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/10/25.
//

import SwiftUI

struct RecipeUIView: View {
    @State public var allRecipes: [Recipe] = []
    @State private var searchQuery: String = ""
    @State private var likedRecipes: [Recipe] = []
    @State private var isLoading: Bool = true
    @State private var uiErrorMessage: String?
    
    // Language for API calls
    @State private var lang: String = "en"
    
    // Pagination state
    @State private var nextPageUrl: URL?
    @State private var isLoadingMore = false
        
    // Available filters
    let mealTypeFilters: [MealType] = MealType.allCases
    let healthFilters: [HealthLabel] = HealthLabel.allCases
    @State private var selectedMealTypes: Set<MealType> = []
    @State private var selectedHealthLabels: Set<HealthLabel> = []
    
    // Placeholder for missing images
    private var placeHolderEmoji: some View {
        Text("🍽️")
            .font(.system(size: 60))
            .frame(width: 150, height: 150)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // Apply search text and filters to the full recipe list
    var filteredRecipes: [Recipe] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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
    
    var body: some View {
        ScrollView {
            // Search Bar & Filters
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
            
            // Recipe Grid
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredRecipes) { recipe in
                        NavigationLink(destination: DetailedRecipeView(recipe: recipe)
                            .environmentObject(RecipeStore())) {
                                VStack {
                                    // Image or placeholder
                                    if let imageUrl = recipe.imageUrl {
                                        AsyncImage(url: imageUrl) { phase in
                                            if let img = phase.image {
                                                img.resizable()
                                                    .scaledToFit()
                                                    .frame(width: 150, height: 150)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            } else if phase.error != nil {
                                                placeHolderEmoji
                                            } else {
                                                ProgressView()
                                                    .frame(width: 150, height: 150)
                                            }
                                        }
                                    } else {
                                        placeHolderEmoji
                                    }
                                    
                                    // Name, calories, carbs, like button
                                    VStack(spacing: 4) {
                                        Text(recipe.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
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
                                        .multilineTextAlignment(.center)
                                        
                                        Button {
                                            toggleLike(recipe)
                                        } label: {
                                            Image(systemName: likedRecipes.contains(recipe) ? "heart.fill" : "heart")
                                                .foregroundColor(.red)
                                                .padding(.top, 4)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 4)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6)))
                            }
                    }
                }
                .padding()
                
                // Load More Recipes
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
        }
        .navigationTitle("Recipes")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if allRecipes.isEmpty {
                fetchInitialRecipes()
            }
        }
    }
    
    // Filter methods
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
    
    // Like / save methods
    private func toggleLike(_ recipe: Recipe) {
        if likedRecipes.contains(recipe) {
            likedRecipes.removeAll { $0 == recipe }
        } else {
            likedRecipes.append(recipe)
        }
    }
    
    // Networking
    private func fetchInitialRecipes() {
        let baseUrl = "https://api.edamam.com/api/recipes/v2"
        guard !Secrets.appId.isEmpty, !Secrets.appKey.isEmpty else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.uiErrorMessage = "Credentials missing. Please contact support."
            }
            return
        }
        
        var query = URLComponents(string: baseUrl)!
        query.queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: Secrets.appId),
            URLQueryItem(name: "app_key", value: Secrets.appKey),
            URLQueryItem(name: "health", value: "alcohol-free"),
            URLQueryItem(name: "glycemicIndex", value: "0.0-69.0"),
            URLQueryItem(name: "calories", value: "0-800"),
            URLQueryItem(name: "nutrients[CHOCDF]", value: "0-50.0"),
            URLQueryItem(name: "nutrients[SUGAR]", value: "0-15.0")
        ]
        
        self.isLoading = true
        var combined: [Recipe] = []
        var pagesFetched = 0
        let maxPages = 3
        
        func fetchPage(from url: URL) {
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.addValue("application/json", forHTTPHeaderField: "accept")
            req.addValue(lang, forHTTPHeaderField: "Accept-Language")
            
            URLSession.shared.dataTask(with: req) { data, response, error in
                if error != nil || data == nil {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.uiErrorMessage = "Failed to load recipes."
                    }
                    return
                }
                
                let (parsed, nextUrl) = RecipeParser.parseRecipes(from: data!)
                combined.append(contentsOf: parsed)
                pagesFetched += 1
                
                if let next = nextUrl, pagesFetched < maxPages {
                    fetchPage(from: next)
                    self.nextPageUrl = next
                } else {
                    DispatchQueue.main.async {
                        self.allRecipes = combined
                        self.isLoading = false
                    }
                }
            }.resume()
        }
        
        if let url = query.url {
            fetchPage(from: url)
        }
    }
    
    private func loadMoreRecipes() {
        guard let url = nextPageUrl, !isLoadingMore else { return }
        isLoadingMore = true
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.addValue("application/json", forHTTPHeaderField: "accept")
        req.addValue(lang, forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: req) { data, _, _ in
            defer { DispatchQueue.main.async { isLoadingMore = false } }
            guard let data = data else { return }
            let (parsed, nextUrl) = RecipeParser.parseRecipes(from: data)
            let unique = parsed.filter { new in
                !allRecipes.contains(where: { $0.id == new.id })
            }
            DispatchQueue.main.async {
                self.allRecipes.append(contentsOf: unique)
                self.nextPageUrl = nextUrl
            }
        }.resume()
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

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
    @State private var selectedFilters: Set<String> = []
    @State private var likedRecipes: [Recipe] = []
    @State private var isLoading: Bool = true
    @State private var uiErrorMessage: String?
    
    // Set language to English
    @State private var lang: String = "en"
    
    // For "Load More" button
    @State private var nextPageUrl: URL?
    @State private var isLoadingMore = false
        
    // Filter values
    let mealTypeFilters: [MealType] = MealType.allCases
    let healthFilters: [HealthLabel] = HealthLabel.allCases
    @State private var selectedMealTypes: Set<MealType> = []
    @State private var selectedHealthLabels: Set<HealthLabel> = []
    
    // Placeholder for missing image
    private var placeHolderEmoji: some View {
        Text("🍽️")
            .font(.system(size: 60))
            .frame(width: 150, height: 150)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // Filtered recipes based on search & filters
    var filteredRecipes: [Recipe] {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
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
        
        guard !trimmedQuery.isEmpty else { return results }
        
        return results.filter { recipe in
            recipe.name.lowercased().contains(trimmedQuery) ||
            recipe.ingredients.contains { $0.text.lowercased().contains(trimmedQuery) } ||
            recipe.healthLabelsDisplay.lowercased().contains(trimmedQuery) ||
            recipe.tags.contains { $0.lowercased().contains(trimmedQuery) }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                // MARK: Search & Filters
                VStack(spacing: 12) {
                    TextField("Search recipes...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        //.onSubmit {
                          //  print("Submitted search for \(searchQuery)") // Debugging
                        //}
                    
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
                        // Button that unchecks all filters when clicked.
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
                
                // MARK: Recipe Grid
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: DetailedRecipeView(recipe: recipe)) {
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
                    
                    // Load More button
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
            .onAppear {
                if allRecipes.isEmpty {
                    fetchInitialRecipes()
                }
            }
        }
    }
    
    // MARK: – Filter Methods
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
    
    // MARK: – Like Methods
    private func toggleLike(_ recipe: Recipe) {
        if likedRecipes.contains(recipe) {
            likedRecipes.removeAll { $0 == recipe }
        } else {
            likedRecipes.append(recipe)
            saveToProfile(recipe)
        }
    }

    func saveToProfile(_ recipe: Recipe) {
        // TODO - Add logic to save the recipe/recipeID/recipe URL to the user's favorited recipes.
        // API call to save to DB.
        print("Saved Recipe: \(recipe.name)") // logging
    }
    
    // MARK: – Networking
    private func fetchInitialRecipes() {
        let baseUrl = "https://api.edamam.com/api/recipes/v2"
        if Secrets.appId.isEmpty || Secrets.appKey.isEmpty {
            DispatchQueue.main.async {
                self.isLoading = false
                self.uiErrorMessage = "Credentials missing. Please contact support."
            }
            return
        }
        
        // Build initial query.
        var query = URLComponents(string: baseUrl)!
        query.queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: Secrets.appId),
            URLQueryItem(name: "app_key", value: Secrets.appKey),
            URLQueryItem(name: "health", value: "alcohol-free"),
            // Diabetes Friendly Nutrient Filters
            URLQueryItem(name: "glycemicIndex", value: "0.0-69.0"),
            URLQueryItem(name: "calories", value: "0-800"),
            URLQueryItem(name: "nutrients[CHOCDF]", value: "0-50.0"),
            URLQueryItem(name: "nutrients[SUGAR]", value: "0-15.0")
        ]
        
        self.isLoading = true
        var combinedRecipes: [Recipe] = []
        var pagesFetched = 0
        let maxPages = 3
        
        // Function to sent request with given Url.
        func fetchPage(from url: URL) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "accept")
            request.addValue(lang, forHTTPHeaderField: "Accept-Language")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.uiErrorMessage = "Network error: \(error.localizedDescription)"
                    }
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.uiErrorMessage = "Invalid response."
                    }
                    return
                }
                print("Status Code: \(httpResponse.statusCode)")
                let (parsed, nextUrl) = RecipeParser.parseRecipes(from: data)
                combinedRecipes.append(contentsOf: parsed)
                pagesFetched += 1
                // DEBUGGING/Logging
                //if let json = String(data: data, encoding: .utf8) {
                 //   print("JSON Response: \(json)") }
                
                if let nextUrl = nextUrl, pagesFetched < maxPages {
                    fetchPage(from: nextUrl)
                    self.nextPageUrl = nextUrl
                } else {
                    DispatchQueue.main.async {
                        self.allRecipes = combinedRecipes
                        self.isLoading = false
                    }
                }
                
            }.resume()
        }
        
        // Iteratively fetch pages.
        if let initialUrl = query.url {
            fetchPage(from: initialUrl)
        }
    }
    
    private func loadMoreRecipes() {
        guard let url = nextPageUrl, !isLoadingMore else { return }
        isLoadingMore = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(lang, forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
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
        NavigationStack {            // so your nav links work
            RecipeUIView()
                .environmentObject( RecipeStore() )
        }
    }
}

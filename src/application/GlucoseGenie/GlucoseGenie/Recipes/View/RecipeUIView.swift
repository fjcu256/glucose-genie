//
//  RecipeUIView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/10/25.
//

import SwiftUI

struct RecipeUIView: View {
    @State public  var allRecipes: [Recipe] = []
    @State private var searchQuery: String = ""
    @State private var selectedFilters: Set<String> = []
    @State private var likedRecipes: [Recipe] = []
    @State private var isLoading: Bool = true
    @State private var uiErrorMessage: String?
    
    // Set language to english
    @State private var lang: String = "en"
    
    // For "Load More" button.
    @State private var nextPageUrl: URL?
    @State private var isLoadingMore = false
        
    // Filter values.
    let mealTypeFilters: [MealType] = MealType.allCases
    let healthFilters: [HealthLabel] = HealthLabel.allCases
    @State private var selectedMealTypes: Set<MealType> = []
    @State private var selectedHealthLabels: Set<HealthLabel> = []
    
    // Filter recipes based on search and filtering options.
    var filteredRecipes: [Recipe] {
        // Query from search bar.
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        var results = allRecipes
        
        if !selectedMealTypes.isEmpty {
            results = results.filter { recipe in
                !Set(recipe.mealtypes).isDisjoint(with: selectedMealTypes)
            }
        }
        
        if !selectedHealthLabels.isEmpty {
            results = results.filter { recipe in
                !Set(recipe.healthLabels).isDisjoint(with:  selectedHealthLabels)
            }
        }
        
        if trimmedQuery.isEmpty {
            return results
        }
        
        results = results.filter { recipe in
            recipe.name.lowercased().contains(trimmedQuery) ||
            recipe.ingredients.contains(where: { $0.text.lowercased().contains(trimmedQuery) }) ||
            recipe.healthLabelsDisplay.lowercased().contains(trimmedQuery) ||
            recipe.tags.contains(where: { $0.lowercased().contains(trimmedQuery) })
        }
        print("Done filtering recipes")
        return results
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Search Bar & Filter Button stacked at the top of the screen.
                VStack(spacing: 12) {
                    // Search Bar
                    TextField("Search recipes...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        //.onSubmit {
                          //  print("Submitted search for \(searchQuery)") // Debugging
                        //}
                    
                    // Filter Menu
                    Menu {
                        Section("Meal Types"){
                            ForEach(mealTypeFilters, id: \.self) {filter in
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
                        .frame(maxWidth: .infinity) // This spreads the button across the screen.
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                    }
                    
                    if let error = uiErrorMessage{
                        Text(error)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // Scrollable Grid Layout of Recipes.
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredRecipes) { recipe in
                            VStack {
                                // Show Image or place holder.
                                if let imageUrl = recipe.imageUrl {
                                    AsyncImage(url: imageUrl) { phase in
                                        if let image = phase.image {
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(width: 150, height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        } else if phase.error != nil {
                                            placeHolderEmoji
                                        } else {
                                            ProgressView().frame(width: 150, height: 150)
                                        }
                                    }
                                } else {
                                    placeHolderEmoji
                                }
                                
                                VStack(spacing: 4) {
                                    Text(recipe.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                    
                                    // Show the calorie and carb info if available.
                                    HStack {
                                        if let calories = recipe.calories {
                                            Text("Calories: \(calories) kcal")
                                        }
                                        if let carbs = recipe.carbs {
                                            Text("Carbs: \(carbs)g")
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    Button(action: { toggleLike(recipe)}) {
                                        Image(systemName: likedRecipes.contains(recipe) ? "heart.fill" : "heart")
                                            .foregroundColor(.red)
                                            .padding(.top, 4)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        }
                    }.padding()
                    // Load More button
                    if let _ = nextPageUrl {
                        Button(action: {
                            loadMoreRecipes()
                        }) {
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
                    } // End of Button
                }
            }.navigationTitle("Recipes")
        }
        .onAppear {
            if allRecipes.isEmpty{
                fetchInitialRecipes()
            }
        }
    }
    
    // Methods for Filtering buttons.
    func toggleMealTypeFilter(_ filter: MealType) {
        if selectedMealTypes.contains(filter) {
            selectedMealTypes.remove(filter)
        } else {
            selectedMealTypes.insert(filter)
        }
    }
    
    func toggleHealthFilter(_ filter: HealthLabel) {
        if selectedHealthLabels.contains(filter) {
            selectedHealthLabels.remove(filter)
        } else {
            selectedHealthLabels.insert(filter)
        }
    }
    
    func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    
    // Methods for Saving recipes.
    func toggleLike(_ recipe: Recipe) {
        if likedRecipes.contains(recipe) {
            likedRecipes.removeAll {$0 == recipe}
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
    
    
    // Method to get all recipes at initial page opening.
    func fetchInitialRecipes() {
        let baseUrl = "https://api.edamam.com/api/recipes/v2"
        
        // Check if both API credentials are supplied. Returns if not.
        if Secrets.appId.isEmpty || Secrets.appKey.isEmpty{
            print("Needed API credentials are missing")
            DispatchQueue.main.async {
                self.isLoading = false
                self.uiErrorMessage = "Unable to get recipes. Credentials are missing. Please contact support."
            }
            return
        }
        
        // Build initial query.
        var query = URLComponents(string: baseUrl)!
        query.queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: Secrets.appId),
            URLQueryItem(name: "app_key", value: Secrets.appKey),
            URLQueryItem(name: "glycemicIndex", value: "0.0-69.0"),
        ]
        
        self.isLoading = true
        var combinedRecipes: [Recipe] = []
        var pagesFetched = 0
        let maxPages = 3 // To limit the number of pages loaded at once.
        
        // Function to sent request with given Url.
        func fetchPage(from url: URL) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "accept")
            request.addValue(lang, forHTTPHeaderField: "Accept-Language")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.uiErrorMessage = "Network error."
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No valid response")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.uiErrorMessage = "Something went wrong while getting recipes."
                    }
                    return
                }
                
                print("Status Code: \(httpResponse.statusCode)") // Debugging
                guard let data = data else {
                    print("No data received")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.uiErrorMessage = "No recipes found."
                    }
                    return
                }
                
                let (parsedRecipes, nextUrl) = RecipeParser.parseRecipes(from: data)
                
                combinedRecipes.append(contentsOf: parsedRecipes)
                print("Total recipes fetched: \(combinedRecipes.count)")
                pagesFetched += 1
                // DEBUGGING/Logging
                //if let json = String(data: data, encoding: .utf8) {
                 //   print("JSON Response: \(json)") }
                
                if let nextUrl = nextUrl, pagesFetched < maxPages  {
                    fetchPage(from: nextUrl)
                    nextPageUrl = nextUrl
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
    
    func loadMoreRecipes() {
        guard let url = nextPageUrl, !isLoadingMore else { return }
        isLoadingMore = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(lang, forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    isLoadingMore = false
                }
            }
            
            guard let data = data else { return }
            let (parsedRecipes, newNextUrl) = RecipeParser.parseRecipes(from: data)
            
            // Filter out duplicates. 
            let uniqueRecipes = parsedRecipes.filter { newRecipe in
                !allRecipes.contains(where: {$0.id == newRecipe.id} )
            }
            
            DispatchQueue.main.async {
                allRecipes.append(contentsOf: uniqueRecipes)
                nextPageUrl = newNextUrl
            }
        }.resume()
    }
    
    private var placeHolderEmoji: some View {
        Text("🍽️")
            .font(.system(size: 60))
            .frame(width: 150, height: 150)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RecipeUIView()
}

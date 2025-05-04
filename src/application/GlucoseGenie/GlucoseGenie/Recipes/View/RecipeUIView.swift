//
//  RecipeUIView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/10/25.
//

import SwiftUI

struct RecipeUIView: View {
    @State private var allRecipes: [Recipe] = []
    @State private var searchQuery: String = ""
    @State private var selectedFilters: Set<String> = []
    @State private var likedRecipes: [Recipe] = []
    @State private var isLoading: Bool = true
    @State private var uiErrorMessage: String?
    
    var onRecipeSelected: ((Recipe) -> Void)? = nil
        
    // TODO Filter and Search Recipes
    let filters: [String] = ["vegetarian", "low-carb", "breakfast", "lunch", "dinner", "snack"]
    //var filteredRecipes: [Recipe] {    }
    
    var filteredRecipes: [Recipe] {
        var result = allRecipes
        
        // Search
        // TODO Implement search results through API search.
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
        
        // Filters
        // TODO Implement filtering through API for mealtype, diet type, etc.
        /*if !selectedFilters.isEmpty {
            result = result.filter { recipe in
                selectedFilters.allSatisfy { filter in
                    switch filter {
                    case "vegetarian":
                        return recipe.name.localizedCaseInsensitiveContains("spinach") || recipe.name.localizedCaseInsensitiveContains("carrot")
                    case "low carb":
                        return recipe.carbs < 10
                    default:
                        return true
                    }
                }
                
            }
        }*/
        return result
    }
    
    func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
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
                    
                    // Filter Menu
                    Menu {
                        // Display Different Filters in menu dropdown.
                        ForEach(filters, id: \.self) { filter in
                            Button {
                                toggleFilter(filter)
                            } label: {
                                HStack {
                                    Text(filter.capitalized)
                                    Spacer()
                                    if selectedFilters.contains(filter) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        Divider()
                        Button("Clear Filters") {
                            selectedFilters.removeAll()
                        }
                        
                    } label: {
                        HStack {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                            Text(selectedFilters.isEmpty ? "Filter" : "Filter: \(selectedFilters.joined(separator: ", ").capitalized)")
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
                        ForEach(allRecipes) { recipe in
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
                            .onTapGesture {
                                // TODO: will probably need to modify this line to work with other flows besides weekly meal planner
                                onRecipeSelected?(recipe)
                            }
                        }
                    }.padding()
                }
            }.navigationTitle("Recipes")
        }
        .onAppear {
            if allRecipes.isEmpty{
                fetchInitialRecipes()
            }
        }
        
    }
    
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
        
        var query = URLComponents(string: baseUrl)!
        query.queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: Secrets.appId),
            URLQueryItem(name: "app_key", value: Secrets.appKey),
            URLQueryItem(name: "glycemicIndex", value: "0.0-69.0")
        ]
        
        // Language choosing logic.
        let lang = "en"
        
        // Setup GET Request in desired language.
        var request = URLRequest(url: query.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(lang, forHTTPHeaderField: "Accept-Language")
        
        isLoading = true
        
        // Response
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
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
            
            print("Status Code: \(httpResponse.statusCode)")
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.uiErrorMessage = "No recipes recipes received."
                }
                return
            }
            
            let parsedRecipes = RecipeParser.parseRecipes(from: data)
            
            // DEBUGGING/Logging
            if let json = String(data: data, encoding: .utf8) {
                print("JSON Response: \(json)")
            }
            
            DispatchQueue.main.async {
                self.allRecipes = parsedRecipes
                self.isLoading = false
                self.uiErrorMessage = nil
                
                if parsedRecipes.isEmpty {
                    print("No recipes found")
                    self.uiErrorMessage = "No recipes found. Try another search."
                }
            }
        }
        task.resume()
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

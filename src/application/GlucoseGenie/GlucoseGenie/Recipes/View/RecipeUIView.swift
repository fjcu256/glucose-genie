//
//  RecipeUIView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/10/25.
//

import SwiftUI

/*struct Recipe: Identifiable, Equatable, Codable {
    let id = UUID()
    let name: String
    let imageUrl: String
    let calories: Int
    let carbs: Int
    
}*/
struct RecipeUIView: View {
    @State private var allRecipes: [Recipe] = []
    @State private var searchQuery: String = ""
    @State private var selectedFilters: Set<String> = []
    @State private var isLoading: Bool = true
    
    let filters: [String] = ["vegetarian", "low-carb", "breakfast", "lunch", "dinner", "snack"]
    
    // TODO
    //var filteredRecipes: [Recipe] {    }
    
    
    @State private var likedRecipes: [Recipe] = []
    
    // FIXME Hard Coded Recipe info and URLs
    /*let recipes: [Recipe] = [
        Recipe(name: "Grilled Veggie Wrap",
               imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/shutterstock_425424460.webp?h=e2d4e250&itok=ptCQ_FGY",
               calories: 110,
               carbs: 11),
        Recipe(name: "Roasted Cauliflower",
               imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/2050-diabetic-roasted-Cauliflower_DaVita_040821.webp?h=13c67c56&itok=-y2MYyC4",
              calories: 40,
               carbs: 4),
        Recipe(name: "Ginger Carrot Soup",
               imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/Carrot%20Ginger%20Soup%20Diabetic.webp?h=9ed651ec&itok=pw_mK-BQ",
              calories: 90,
               carbs: 10),
        Recipe(name: "Spinach Yogurt Dip",
               imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/521-diabetic-spinach-yogurt-dip_96297700_083018.webp?h=6853934b&itok=jtgGjBZx",
              calories: 15,
               carbs: 1),
        Recipe(name: "Zucchini Egg Boats",
               imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/recipe_hero_banner_720w_2x/public/2019-diabetic-breakfast-zucchini-egg-boat_diabetes-cookbook_081618_1021x779.webp?h=48784f2c&itok=clFreezC",
              calories: 160,
               carbs: 8),
    ]*/
    
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
            // TODO - Add logic to save the recipe to the user's favorited recipes.
            // API call to save to DB.
            print("Saved Recipe: \(recipe.name)")
        }
    
    
    func fetchInitialRecipes() {
        let baseUrl = "https://api.edamam.com/api/recipes/v2"
        
        var query = URLComponents(string: baseUrl)!
        query.queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: Secrets.appId),
            URLQueryItem(name: "app_key", value: Secrets.appKey),
            URLQueryItem(name: "glycemicIndex", value: "0.0-69.0")
        ]
        
        // Setup GET Request in English.
        var request = URLRequest(url: query.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("en", forHTTPHeaderField: "Accept-Language")
        
        // Response
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid response")
                return
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            guard let data = data else {
                print("No data received")
                return
            }
            let parsedRecipes = RecipeParser.parseRecipes(from: data)
            
            // DEBUGGING
            if let json = String(data: data, encoding: .utf8) {
                print("JSON Response: \(json)")
            }
            
            DispatchQueue.main.async {
                self.allRecipes = parsedRecipes
                self.isLoading = false
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

//
//  RecipeUIView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/10/25.
//

import SwiftUI

struct RecipeUIView: View {
    // When non-nil, tapping a recipe calls this instead of pushing the detail view.
    var onRecipeSelected: ((Recipe, URL?) -> Void)? = nil

    // Allow you to inject a callback, default is nil
    init(onRecipeSelected: ((Recipe, URL?) -> Void)? = nil) {
        self.onRecipeSelected = onRecipeSelected
    }

    @State private var allRecipes: [Recipe] = []
    @State private var searchQuery: String = ""
    @State private var likedRecipes: [Recipe] = []
    @State private var isLoading: Bool = true
    @State private var uiErrorMessage: String?
    @State private var lang: String = Bundle.main.preferredLocalizations.first ?? "en"
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
                
                // Set background to two colors
                VStack(spacing: 0) {
                    Color.eggWhite
                }.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        filterSection
                        recipeGrid
                        loadMoreButton
                        
                        Spacer(minLength: 30)
                        
                        Image("EdamamBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Recipes 🔎")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    if allRecipes.isEmpty {
                        // FIXME if statement purely for the demo
                        if lang == "es" {
                            print("Spanish demo data fetching...")
                            fetchDemoRecipesSpanish()
                        } else {
                            fetchInitialRecipes()
                        }
                    }
                }
            }
        }
    }
        
    // Search + Filters
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

            // Error message to display to user if something unexpected happens or if no recipes were found.
            if let error = uiErrorMessage {
                Text(error)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    // Recipe Grid
    @ViewBuilder private var recipeGrid: some View {
        if isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(filteredRecipes) { recipe in
                    // If onRecipeSelected is set, use a Button to pick the recipe
                    if let selectAction = onRecipeSelected {
                        Button {
                            selectAction(recipe, recipe.imageUrl)
                        } label: {
                            recipeCard(recipe)
                        }
                    } else {
                        // Otherwise navigate to detail
                        NavigationLink {
                            DetailedRecipeView(recipe: recipe)
                                // inherits the store from the environment
                        } label: {
                            recipeCard(recipe)
                        }
                    }
                }
            }
            .padding()
        }
    }

    // Load More
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

    // Recipe Card
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

                // FIXME - Removed Heart saving from each recipe. Not functional.
                /*Button {
                    toggleLike(recipe)
                } label: {
                    Image(systemName: likedRecipes.contains(recipe) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
                .padding(.top, 4)*/
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color.darkBeige))
    }

    // Filtering logic
    private var filteredRecipes: [Recipe] {
        // Search Query from User search bar.
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

    // Helpers
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

    private func toggleLike(_ recipe: Recipe) {
        if likedRecipes.contains(recipe) {
            likedRecipes.removeAll { $0 == recipe }
        } else {
            likedRecipes.append(recipe)
        }
    }

    private func fetchInitialRecipes() {
        let baseUrl = "https://api.spoonacular.com/recipes/complexSearch"
        guard !Secrets.spoonacularKey.isEmpty else {
            DispatchQueue.main.async {
                isLoading = false
                uiErrorMessage = String(localized: "Unable to get recipes. Credentials are missing. Please contact support.")
            }
            return
        }

        var query = URLComponents(string: baseUrl)!
        query.queryItems = [
            .init(name: "apiKey",                   value: Secrets.spoonacularKey),
            .init(name: "addRecipeInformation",      value: "true"),
            .init(name: "addRecipeNutrition",        value: "true"),
            .init(name: "maxCalories",               value: "800"),
            .init(name: "maxCarbs",                  value: "50"),
            .init(name: "maxSugar",                  value: "15"),
            .init(name: "number",                    value: "20"),
            .init(name: "offset",                    value: "0")
        ]

        isLoading = true

        guard let url = query.url else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.addValue("application/json", forHTTPHeaderField: "accept")

        URLSession.shared.dataTask(with: req) { data, _, error in
            if error != nil || data == nil {
                DispatchQueue.main.async {
                    isLoading = false
                    uiErrorMessage = String(localized: "Something went wrong while getting recipes.")
                }
                return
            }
            let (parsed, _) = RecipeParser.parseRecipes(from: data!)
            DispatchQueue.main.async {
                allRecipes = parsed
                isLoading = false
            }
        }
        .resume()
    }

    private func loadMoreRecipes() {
        // Spoonacular uses offset-based pagination; nextPageUrl is repurposed as a sentinel.
        // For now, load-more is a no-op since we load 20 results upfront.
        // To implement: track current offset and increment by 20 each call.
        nextPageUrl = nil
    }
    
    // FIXME this function is purely for demo purposes
    private func fetchDemoRecipesSpanish() {
        allRecipes = [
            Recipe(
                name: "Brochetas de Camarones",
                image: "https://s3.amazonaws.com/static.realcaliforniamilk.com/media/recipes_2/grilled-shrimp-skewers-with-herb-butter.jpg",
                url: "https://www.mayoclinic.org/es/healthy-lifestyle/recipes/shrimp-kebabs/rcp-20197749",
                ingredients: [
                    Ingredient(
                        text: "2 brochetas de madera de 8 pulgadas (20cm) cada una",
                        quantity: 2,
                        units: "brochetas"
                    ),
                    Ingredient(
                        text: "1 limón, exprimido",
                        quantity: 1,
                        units: "limón"
                    ),
                    Ingredient(
                        text: "1 cucharada de aceite de oliva",
                        quantity: 1,
                        units: "cucharada"
                    ),
                    Ingredient(
                        text: "2 cucharaditas de ajo picado fino",
                        quantity: 2,
                        units: "cucharaditas"
                    ),
                    Ingredient(
                        text: "1 cucharadita de estragón fresco picado fino",
                        quantity: 1,
                        units: "cucharadita"
                    ),
                    Ingredient(
                        text: "1 cucharadita de romero fresco picado fino",
                        quantity: 1,
                        units: "cucharadita"
                    ),
                    Ingredient(
                        text: "1/2 cucharadita de sal kósher",
                        quantity: 0.5,
                        units: "cucharadita"
                    ),
                    Ingredient(
                        text: "1/4 de cucharadita de pimienta negra molida",
                        quantity: 0.25,
                        units: "cucharadita"
                    ),
                    Ingredient(
                        text: "12 piezas de camarones, pelados y desvenados (tamaño 21/25)",
                        quantity: 12,
                        units: "piezas"
                    )
                ],
                totalTime: Optional(30.0),
                servings: Optional(2),
                totalNutrients: [
                    Nutrient(name: "Calories", quantity: 210, unit: "kcal"),
                    Nutrient(name: "Carbs",    quantity: 0, unit: "g"),
                    Nutrient(name: "Sugar",    quantity: 0, unit: "g"),
                    Nutrient(name: "Fat",      quantity: 2, unit: "g"),
                    Nutrient(name: "Cholesterol", quantity: 360, unit: "mg"),
                    Nutrient(name: "Protein",  quantity: 48, unit: "g"),
                    Nutrient(name: "Sodium",   quantity: 370, unit: "mg"),
                ],
                diets: [
                    DietType.highProtein, DietType.lowCarb, DietType.lowFat
                ],
                mealtypes: [
                    MealType.dinner
                ],
                healthLabels: [
                    HealthLabel.dairyFree, HealthLabel.glutenFree, HealthLabel.lowSugar, HealthLabel.porkFree
                ],
                tags: [
                    "low calorie", "sides", "low fat", "dinner"
                ]
            ),
            Recipe(
                name: "Salmón Asado al Estilo Mediterráneo",
                image: "https://www.mayoclinic.org/-/media/kcms/gbs/patient-consumer/images/2013/08/26/11/02/nu00509_im00262_billboard.png",
                url: "https://www.mayoclinic.org/es/healthy-lifestyle/recipes/mediterraneanstyle-grilled-salmon/rcp-20049781",
                ingredients: [
                    Ingredient(
                        text: "4 cucharadas de albahaca fresca picada",
                        quantity: 4,
                        units: "cucharadas"
                    ),
                    Ingredient(
                        text: "1 cucharada de perejil fresco picado",
                        quantity: 1,
                        units: "cucharada"
                    ),
                    Ingredient(
                        text: "1 cucharada de ajo picado",
                        quantity: 1,
                        units: "cucharada"
                    ),
                    Ingredient(
                        text: "2 cucharadas de jugo de limón",
                        quantity: 2,
                        units: "cucharadas"
                    ),
                    Ingredient(
                        text: "4 filetes de salmón de 5 onzas (140 g) cada uno",
                        quantity: 4,
                        units: "filetes"
                    ),
                    Ingredient(
                        text: "Pimienta negra machacada, a gusto",
                        quantity: 0,
                        units: ""
                    ),
                    Ingredient(
                        text: "4 aceitunas verdes, picadas",
                        quantity: 4,
                        units: "aceitunas"
                    ),
                    Ingredient(
                        text: "4 rojas finas de limón",
                        quantity: 4,
                        units: "rojas finas"
                    )
                ],
                totalTime: Optional(35.0),
                servings: Optional(4),
                totalNutrients: [
                    Nutrient(name: "Calories", quantity: 856, unit: "kcal"),
                    Nutrient(name: "Carbs",    quantity: 12, unit: "g"),
                    Nutrient(name: "Sugar",    quantity: 2, unit: "g"),
                    Nutrient(name: "Fat",      quantity: 40, unit: "g"),
                    Nutrient(name: "Cholesterol", quantity: 312, unit: "mg"),
                    Nutrient(name: "Protein",  quantity: 112, unit: "g"),
                    Nutrient(name: "Sodium",   quantity: 572, unit: "mg"),
                ],
                diets: [
                    DietType.highProtein, DietType.lowCarb
                ],
                mealtypes: [
                    MealType.dinner
                ],
                healthLabels: [
                    HealthLabel.dairyFree, HealthLabel.glutenFree, HealthLabel.lowSugar, HealthLabel.porkFree, HealthLabel.pescatarian
                ],
                tags: [
                    "low fat", "low sugar"
                ]
            ),
            Recipe(
                name: "Ensalada de Lechuga y Manzana",
                image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMXIzqx6tnKt7291F_TK6X_vbwjHr6XammKA&s",
                url: "https://www.mayoclinic.org/es/healthy-lifestyle/recipes/apple-lettuce-salad/rcp-20049999",
                ingredients: [
                    Ingredient(
                        text: "1/4 de taza de jugo de manzana sin endulzar",
                        quantity: 0.25,
                        units: "taza"
                    ),
                    Ingredient(
                        text: "2 cucharadas de jugo de limón amarillo",
                        quantity: 2,
                        units: "cucharadas"
                    ),
                    Ingredient(
                        text: "1 cucharada de aceite de canola",
                        quantity: 1,
                        units: "cucharada"
                    ),
                    Ingredient(
                        text: "1/2 cucharaditas de azúcar moreno",
                        quantity: 0.5,
                        units: "cucharaditas"
                    ),
                    Ingredient(
                        text: "1/2 cucharadita de mostaza de Dijon",
                        quantity: 0.5,
                        units: "cucharadita"
                    ),
                    Ingredient(
                        text: "1/4 de cucharadita de especias para tarta de manzana",
                        quantity: 0.25,
                        units: "cucharadita"
                    ),
                    Ingredient(
                        text: "1 manzana roja mediana, picada",
                        quantity: 1,
                        units: "manzana"
                    ),
                    Ingredient(
                        text: "8 tazas de hortalizas de hoja verde mezcladas",
                        quantity: 8,
                        units: "tazas"
                    )
                ],
                totalTime: Optional(10.0),
                servings: Optional(4),
                totalNutrients: [
                    Nutrient(name: "Calories", quantity: 496, unit: "kcal"),
                    Nutrient(name: "Carbs",    quantity: 80, unit: "g"),
                    Nutrient(name: "Sugar",    quantity: 56, unit: "g"),
                    Nutrient(name: "Fat",      quantity: 16, unit: "g"),
                    Nutrient(name: "Cholesterol", quantity: 0, unit: "mg"),
                    Nutrient(name: "Protein",  quantity: 8, unit: "g"),
                    Nutrient(name: "Sodium",   quantity: 176, unit: "mg"),
                ],
                diets: [
                    DietType.lowFat, DietType.highFiber
                ],
                mealtypes: [
                    MealType.lunch, MealType.dinner, MealType.snack
                ],
                healthLabels: [
                    HealthLabel.dairyFree, HealthLabel.glutenFree, HealthLabel.lowSugar, HealthLabel.porkFree, HealthLabel.vegetarian
                ],
                tags: [
                    "low fat", "low sugar", "vegetarian"
                ]
            ),
            Recipe(
                name: "Agua Fresca de Sandía y Arándanos Rojos",
                image: "https://www.mayoclinic.org/-/media/kcms/gbs/patient-consumer/images/2013/08/26/10/12/nu00356_im01144_billboard.png",
                url: "https://www.mayoclinic.org/es/healthy-lifestyle/recipes/watermeloncranberry-agua-fresca/rcp-20049628",
                ingredients: [
                    Ingredient(
                        text: "2 1/2 libras (1,15 kg) de sandía sin semillas, sin cáscara y cortada en cubos (aproximadamente 7 tazas)",
                        quantity: 7,
                        units: "tazas"
                    ),
                    Ingredient(
                        text: "1 taza de jugo de arándanos rojos con fructosa (a veces llamado néctar de arándanos rojos)",
                        quantity: 1,
                        units: "taza"
                    ),
                    Ingredient(
                        text: "1/4 de taza de jugo de lima fresco",
                        quantity: 0.25,
                        units: "taza"
                    ),
                    Ingredient(
                        text: "1 lima cortada en 6 rodajas",
                        quantity: 1,
                        units: "lima"
                    )
                ],
                totalTime: Optional(15.0),
                servings: Optional(6),
                totalNutrients: [
                    Nutrient(name: "Calories", quantity: 504, unit: "kcal"),
                    Nutrient(name: "Carbs",    quantity: 120, unit: "g"),
                    Nutrient(name: "Sugar",    quantity: 64, unit: "g"),
                    Nutrient(name: "Fat",      quantity: 0, unit: "g"),
                    Nutrient(name: "Cholesterol", quantity: 0, unit: "mg"),
                    Nutrient(name: "Protein",  quantity: 4, unit: "g"),
                    Nutrient(name: "Sodium",   quantity: 36, unit: "mg"),
                ],
                diets: [
                    DietType.lowFat, DietType.highFiber, DietType.lowCarb
                ],
                mealtypes: [
                    MealType.breakfast, MealType.lunch, MealType.snack
                ],
                healthLabels: [
                    HealthLabel.dairyFree, HealthLabel.glutenFree, HealthLabel.porkFree, HealthLabel.vegetarian, HealthLabel.kidneyFriendly
                ],
                tags: [
                    "low fat", "vegetarian", "low carb"
                ]
            )
        ]
        isLoading = false
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

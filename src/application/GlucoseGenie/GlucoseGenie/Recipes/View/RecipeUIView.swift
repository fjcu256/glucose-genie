//
//  RecipeUIView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/10/25.
//

import SwiftUI

struct Recipe: Identifiable, Equatable, Codable {
    let id = UUID()
    let name: String
    let imageUrl: String
    let calories: Int
    let carbs: Int
    let ingredients: [String]
    let instructions: [String]
    let totalTime: String
    let servings: Int
}
struct RecipeUIView: View {
    @State private var likedRecipes: [Recipe] = []
    
    let recipes: [Recipe] = [
        Recipe(
            name: "Grilled Veggie Wrap",
            imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/shutterstock_425424460.webp?h=e2d4e250&itok=ptCQ_FGY",
            calories: 110,
            carbs: 11,
            ingredients: [
                "olive oil - 1 tbsp",
                "balsamic vinegar - 2 tbsp",
                "black pepper - 1/4 tsp",
                "medium zucchini (sliced lengthwise into 8 slices) - 1",
                "medium yellow squash (sliced lengthwise into 8 slices) - 1",
                "red bell pepper (sliced into 4 slices) - 1",
                "large whole wheat tortillas (about 10 inch diameter) - 4",
                "hummus - 1/2 cup",
                "fresh basil leaves - 8"
            ],
            instructions: [
                "Preheat an indoor or outdoor grill.",
                "In a large bowl, whisk together olive oil, balsamic vinegar and ground black pepper.",
                "Add sliced zucchini, squash and bell pepper to marinade and let sit for 5 minutes.",
                "Grill the vegetables about 2-3 minutes on both sides.",
                "Lay out the tortilla and spread with 2 Tbsp. hummus, then add two fresh basil leaves and top with 2 slices of zucchini, 2 slices of yellow squash and 1 slice bell pepper.",
                "Fold in the two sides of the tortilla and roll like a burrito. Serve immediately or refrigerate."
            ],
            totalTime: "15 min",
            servings: 4
        ),
        Recipe(
            name: "Roasted Cauliflower",
            imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/2050-diabetic-roasted-Cauliflower_DaVita_040821.webp?h=13c67c56&itok=-y2MYyC4",
            calories: 40,
            carbs: 4,
            ingredients: [
                "nonstick cooking spray - 1",
                "large cauliflower head (cut into small florets) - 1",
                "olive oil - 2 tbsp",
                "black pepper - 1/4 tsp",
                "salt - 1/4 tsp"
            ],
            instructions: [
                "Preheat the oven to 425°F. Spray a baking sheet with cooking spray.",
                "In a small bowl, mix together the cauliflower, olive oil, black pepper and salt. Pour the mixture onto the baking sheet.",
                "Bake for 15-20 minutes until the cauliflower tips are slightly brown and tender."
            ],
            totalTime: "30 min",
            servings: 6
        ),
        Recipe(
            name: "Spiced Ginger Carrot Soup",
            imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/Carrot%20Ginger%20Soup%20Diabetic.webp?h=9ed651ec&itok=pw_mK-BQ",
            calories: 90,
            carbs: 10,
            ingredients: [
                "carrots (peeled and chopped) - 1 lbs",
                "onion (chopped) - 1 whole",
                "garlic (minced) - 2 cloves",
                "olive oil - 2 tbsp",
                "fresh ginger (grated) - 2 tbsp",
                "ground coriander - 1 tsp",
                "ground turmeric - 1/4 tsp",
                "salt - 1/4 tsp",
                "low sodium vegetable broth - 4 cups",
                "lite coconut milk (unsweetened) - 1 cup",
                "fresh cilantro (for garnish) - 1"
            ],
            instructions: [
                "In a large pot, heat the olive oil over medium heat. Add the chopped onion and sauté until translucent, 4–5 minutes.",
                "Add the minced garlic and freshly grated ginger. Sauté for about 1–2 minutes until fragrant. Stir in the coriander and turmeric. Cook for another minute.",
                "Add the chopped carrots and sauté for a few minutes, coating them with the spices.",
                "Pour in the vegetable broth and bring to a gentle simmer. Cover and let the carrots cook until tender.",
                "Once the carrots are cooked, use an immersion blender to purée the soup until smooth. Alternatively, blend in a blender then return to the pot.",
                "Stir in the coconut milk and season with salt and pepper.",
                "Let the soup simmer for a few more minutes and serve hot, garnished with chopped fresh cilantro."
            ],
            totalTime: "35 min",
            servings: 8
        ),
        Recipe(
            name: "Spinach Yogurt Dip",
            imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/375_375_2x/public/521-diabetic-spinach-yogurt-dip_96297700_083018.webp?h=6853934b&itok=jtgGjBZx",
            calories: 15,
            carbs: 1,
            ingredients: [
                "cottage cheese (low-fat, 1% milk fat) - 1 cup",
                "Plain Nonfat Greek yogurt - 1 cup",
                "frozen spinach (thawed, squeezed dry, chopped) - 1 cup",
                "ranch-flavored salad dressing powder mix - 1 tbsp"
            ],
            instructions: [
                "In a food processor or blender, puree the cottage cheese and transfer to a medium bowl.",
                "Add the yogurt, spinach and ranch dressing powder and whisk together.",
                "Refrigerate for at least 30 minutes up to overnight.",
                "Serve with assorted vegetables for dipping."
            ],
            totalTime: "10 min",
            servings: 24
        ),
        Recipe(
            name: "Zucchini Egg Boats",
            imageUrl: "https://diabetesfoodhub.org/sites/foodhub/files/styles/recipe_hero_banner_720w_2x/public/2019-diabetic-breakfast-zucchini-egg-boat_diabetes-cookbook_081618_1021x779.webp?h=48784f2c&itok=clFreezC",
            calories: 160,
            carbs: 8,
            ingredients: [
                "nonstick cooking spray - 1",
                "zucchini - 2",
                "sliced mushrooms - 8 oz",
                "small onion (diced) - 1",
                "chicken breakfast sausage links (fully cooked) - 4 oz",
                "eggs - 4",
                "water - 2 tbsp",
                "hot sauce - 1 tsp",
                "salt - 1/4 tsp",
                "black pepper - 1/4 tsp"
            ],
            instructions: [
                "Preheat oven to 400°F. Coat a baking sheet with cooking spray.",
                "Slice zucchini in half lengthwise, scoop out the seeds to form boats, and place on the baking sheet.",
                "Roast the zucchini for 25 minutes.",
                "Meanwhile, in a nonstick sauté pan over medium-high heat, add cooking spray, mushrooms, onion, and sausage. Sauté for 7 minutes until tender.",
                "In a medium bowl, whisk together eggs, water, hot sauce, salt, and pepper.",
                "Pour the egg mixture into the pan with sautéed veggies and sausage, stirring gently over medium-low heat for about 4 minutes.",
                "Remove the zucchini from the oven and top each half with a scant cup of the egg mixture."
            ],
            totalTime: "50 min",
            servings: 4
        )
    ]
    
    
    var body: some View {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(recipes) { recipe in
                            NavigationLink(destination: DetailedRecipeView(recipe: recipe)) {
                                VStack {
                                    AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text(recipe.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Calories: \(recipe.calories)  |  Carbs: \(recipe.carbs)g")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                        
                                        Button(action: { toggleLike(recipe) }) {
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
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Recipes")
            }
        }
        
        func toggleLike(_ recipe: Recipe) {
            if likedRecipes.contains(recipe) {
                likedRecipes.removeAll { $0 == recipe }
            } else {
                likedRecipes.append(recipe)
                saveToProfile(recipe)
            }
        }
        
        func saveToProfile(_ recipe: Recipe) {
            // TODO: Add logic to save the recipe to the user's profile.
            print("Saved Recipe: \(recipe.name)")
        }
    }

    #Preview {
        RecipeUIView()
    }

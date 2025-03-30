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
}
struct RecipeUIView: View {
    @State private var likedRecipes: [Recipe] = []
    
    // FIXME Hard Coded Recipe info and URLs
    let recipes: [Recipe] = [
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
    ]
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(recipes) { recipe in
                        VStack {
                            AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                                image.resizable()
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
                                
                                Text("Calories: \(recipe.calories)  Carbs: \(recipe.carbs)g")
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
            }.navigationTitle("Recipes")
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
}

#Preview {
    RecipeUIView()
}

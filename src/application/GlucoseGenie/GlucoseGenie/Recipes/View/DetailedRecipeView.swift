//
//  DetailedRecipeView.swift
//  GlucoseGenie
//
//  Created by Capro,Thomas on 4/14/25.
//

import SwiftUI

struct DetailedRecipeView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Recipe Image
                AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // MARK: - Recipe Title and Info
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 4)
                
                Text("Calories: \(recipe.calories)  |  Carbs: \(recipe.carbs)g")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Total Time: \(recipe.totalTime)  |  Servings: \(recipe.servings)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // MARK: - Ingredients Section
                Text("Ingredients")
                    .font(.title2)
                    .bold()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                    }
                }
                .padding(.leading, 8)
                
                Divider()
                
                // MARK: - Instructions Section
                Text("Instructions")
                    .font(.title2)
                    .bold()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

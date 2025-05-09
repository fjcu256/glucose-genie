//
//  SavedRecipesView.swift
//  GlucoseGenie
//
//  Created by Capro,Thomas 5/8/25
//

import SwiftUI

struct SavedRecipesView: View {
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        List {
            ForEach(store.saved) { recipe in
                NavigationLink(recipe.name) {
                    DetailedRecipeView(recipe: recipe)
                      .environmentObject(store)
                }
            }
            .onDelete { offsets in
                store.saved.remove(atOffsets: offsets)
            }
        }
        .navigationTitle("Saved Recipes")
    }
}

#if DEBUG
struct SavedRecipesView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SavedRecipesView()
        .environmentObject( RecipeStore() )
    }
  }
}
#endif

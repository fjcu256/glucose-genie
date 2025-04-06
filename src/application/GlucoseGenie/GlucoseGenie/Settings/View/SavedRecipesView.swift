//
//  SavedRecipesView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

struct SavedRecipesView: View {
    var body: some View {
        Text("Saved Recipes")
        Spacer(minLength: 30)
        Image("EdamamBadge")
            .resizable()
            .scaledToFit()
            .frame(height: 30)
            .padding(.bottom, 20)
    }
}

#Preview {
    SavedRecipesView()
}

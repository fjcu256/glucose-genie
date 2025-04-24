//
//  GroceryListView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

// Change based on API format
struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: String
}

struct GroceryListView: View {
    // Temp
    let groceryItems: [GroceryItem] = [
        GroceryItem(name: "Chicken Breast", quantity: "2 lbs"),
        GroceryItem(name: "Broccoli", quantity: "3 heads"),
        GroceryItem(name: "Brown Rice", quantity: "1 bag"),
        GroceryItem(name: "Eggs", quantity: "1 dozen"),
        GroceryItem(name: "Olive Oil", quantity: "500ml")
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Based on your weekly meal plan, you will need:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(groceryItems) { item in
                            HStack {
                                Text(item.quantity)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .leading)

                                Text(item.name)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Grocery List")
        }
    }
}

#Preview {
    GroceryListView()
}


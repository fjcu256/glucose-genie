//
//  GroceryListView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

class GroceryList: ObservableObject {
    @Published var items: [GroceryItem] = [] {
        didSet {
            saveItems()
        }
    }

    private let storageKey = "grocery_list"

    init() {
        loadItems()
    }

    private func saveItems() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
            // print("Grocery list saved")
        }
    }

    private func loadItems() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? decoder.decode([GroceryItem].self, from: data) {
            self.items = decoded
            // print("Grocery list loaded")
        }
    }
    
    func removeItem(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            objectWillChange.send()
        }
    }
    
    func syncWithMealPlan(from plan: [MealPlanEntry]) {
        items = plan.flatMap { entry in
            entry.recipe.ingredients.map { ingredient in
                GroceryItem(
                    recipeName: entry.recipe.name,
                    ingredientName: ingredient.text
                )
            }
        }
    }
}

struct GroceryItem: Identifiable, Codable {
    let id = UUID()
    let recipeName: String
    let ingredientName: String
    var isChecked: Bool = false
}

struct GroceryListView: View {
    @EnvironmentObject private var store: RecipeStore
    @StateObject private var groceryList = GroceryList()
    @State private var syncConfirmation = false
    
    // Group grocery items by recipe name
    private var groupedGroceryList: [String: [Binding<GroceryItem>]] {
        Dictionary(grouping: $groceryList.items) { $item in
            item.recipeName
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if groceryList.items.isEmpty {
                    ZStack {
                        Color.eggWhite.ignoresSafeArea()
                        Text("Your grocery list is empty.")
                            .font(.headline)
                            .padding(.top, -80)
                        Spacer()
                        
                        Text("Add recipes to your weekly meal plan and click the sync button.")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                } else {
                    List {
                        ForEach(groupedGroceryList.keys.sorted(), id: \.self) { recipeName in
                            Section(header: Text(recipeName)
                                        .font(.headline)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)) {
                                ForEach(groupedGroceryList[recipeName]!, id: \.id) { $item in
                                    HStack {
                                        Button(action: {
                                            item.isChecked.toggle()
                                        }) {
                                            Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                                .foregroundColor(item.isChecked ? .green : .gray)
                                                .font(.title3)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())

                                        Text(item.ingredientName.capitalized)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .strikethrough(item.isChecked, color: .gray)
                                            .foregroundColor(item.isChecked ? .gray : .primary)

                                        Spacer()

                                        Button(action: {
                                            groceryList.removeItem(item)
                                        }) {
                                            Image(systemName: "xmark.circle")
                                                .foregroundColor(.red)
                                                .font(.title3)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.eggWhite)
                    Spacer(minLength: 30)
                    Image("EdamamBadge")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle("Grocery List 🗒️")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        syncConfirmation = true
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityLabel("Sync with Meal Plan")
                }
            }
            .alert("Sync Grocery List?", isPresented: $syncConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sync") {
                    groceryList.syncWithMealPlan(from: store.plan)
                }
            } message: {
                Text("This will sync your grocery list with your current meal plan. Any changes will be lost.")
            }
        }
    }
}

#Preview {
    GroceryListView()
}

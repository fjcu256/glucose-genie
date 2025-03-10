//
//  MainView.swift
//  GlucoseGenie
//
//  Created by Francisco Cruz-Urbanc on 2/23/25.

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .bottom) {
                    
                    VStack(spacing: 20) {
                        Spacer()
                        Spacer()
                        Spacer()
                        NavigationLink(destination: RecipeView()) {
                            Text("Recipes").styledButton()
                        }
                        NavigationLink(destination: SavedRecipesView()) {
                            Text("Saved Recipes").styledButton()
                        }
                        NavigationLink(destination: WeeklyMealPlanView()) {
                            Text("Weekly Meal Plan").styledButton()
                        }
                        NavigationLink(destination: GroceryListView()) {
                            Text("Grocery List").styledButton()
                        }
                        NavigationLink(destination: GroceryStoreView()) {
                            Text("Find Grocery Store").styledButton()
                        }
                        NavigationLink(destination:
                                        NutrientUIView()) {
                            Text("Track Nutrients").styledButton()
                        }
                        Spacer()
                    }.padding()
                    
                    VStack {
                        HStack(spacing: -16) {
                          Spacer()
                            NavigationLink(destination: APITestView()) {
                                Image(systemName: "heart.fill")
                                    .font(.largeTitle)
                                    .padding()
                            }
                            NavigationLink(destination: SettingsUIView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.largeTitle)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
                
            }
            
        }
    }
    
}

struct NutrientInputField: View {
    var title: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField("Enter \(title.lowercased())", text: $value)
                .padding(.bottom)
                .frame(width: 200.0)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
        }
    }
}

#Preview {
    MainView()
}

extension View {
    func styledButton(color: Color = .orange) -> some View {
        self
            .font(.title)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding()
            .background(color)
            .foregroundColor(.black)
            .cornerRadius(15)
            .padding(.horizontal)
    }
}

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
            ZStack(alignment: .bottom) {
                
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    NavigationLink(destination: SavedRecipesView()) {
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
                    Spacer()
                }.padding()
                
                VStack {
                    HStack {
                      Spacer()
                        NavigationLink(destination: SettingsUIView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.largeTitle)
                                .padding()
                        }
                        NavigationLink(destination: APITestView()) {
                            Image(systemName: "heart.fill")
                                .font(.largeTitle)
                                .padding()
                        }
                    }.padding()
                    Spacer()
                }
            }
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

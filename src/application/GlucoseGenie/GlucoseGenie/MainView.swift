//
//  MainView.swift
//  GlucoseGenie
//
//  Created by Francisco Cruz-Urbanc on 2/23/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Set Background Color
                Color.orangeMain.ignoresSafeArea()
                ScrollView {
                    ZStack(alignment: .bottom) {
                        
                        VStack(spacing: 20) {
                            // Add Logo to top.
                            Image("GlucoseGenieBanner")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width, height:100)
                                .offset(y:  -12) // Show only the middle section of square banner
                                .clipped()

                            NavigationLink(destination: RecipeUIView()) {
                                Text("Recipes 🔎").styledButton()
                            }
                            NavigationLink(destination: SavedRecipesView()) {
                                Text("Saved Recipes ❤️").styledButton()
                            }
                            NavigationLink(destination: WeeklyMealPlanView()) {
                                Text("Weekly Meal Plan 📆").styledButton()
                            }
                            NavigationLink(destination: GroceryListView()) {
                                Text("Grocery List 🗒️").styledButton()
                            }
                            NavigationLink(destination: GroceryStoreView()) {
                                Text("Find Grocery Store 📍").styledButton()
                            }
                            NavigationLink(destination: NutrientUIView()) {
                                Text("Track Nutrients 📊").styledButton()
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        VStack {
                            HStack(spacing: -16) {
                                Spacer()
                                /** Remove  test heart button for Demo */
                                /*NavigationLink(destination: APITestView()) {
                                    Image(systemName: "heart.fill")
                                        .font(.largeTitle)
                                        .padding()
                                }*/
                                NavigationLink(destination: SettingsUIView()) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(Color.darkBrown)
                                        .padding()
                                        .padding(.top, -20)
                                        .padding(.horizontal, 10)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
            }
        }
    }
}

struct NutrientInputField: View {
    var title: String
    @Binding var value: String
    let enterString = String(localized: "Enter")
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField("\(enterString) \(title.lowercased())", text: $value)
                .padding(.bottom)
                .frame(width: 200.0)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainView()
                .environmentObject(AuthenticationService())
                .environmentObject(RecipeStore())
        }
    }
}

extension View {
    func styledButton(color: Color = Color.eggWhite) -> some View {
        self
            .font(.title)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding()
            .background(color)
            .foregroundColor(Color.darkBrown)
            .cornerRadius(15)
            .padding(.horizontal)
    }
}

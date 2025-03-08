//
//  MainView.swift
//  GlucoseGenie
//
//  Created by Francisco Cruz-Urbanc on 2/23/25.

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    
    @StateObject var nutrientsViewModel = NutrientViewModel()
    @State private var carbs: String = ""
    @State private var fiber: String = ""
    @State private var protein: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("This is the main view :)")
                NavigationLink(destination: SettingsUIView()) {
                    Image(systemName: "gearshape.fill")
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
                    }.padding()
                    Spacer()
                }
                
                Text("Nutrient Tracker")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                VStack(spacing: 10) {
                    NutrientInputField(title: "Carbohydrates (g)", value: $carbs)
                    NutrientInputField(title: "Fiber (g)", value: $fiber)
                    NutrientInputField(title: "Protein (g)", value: $protein)
                    
                    Button(action: addEntry) {
                        Text("Add Entry")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.top)
                }
                .padding()
                
                List(nutrientsViewModel.logs.sorted(by: { $0.date > $1.date})) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.date, style: .date)
                                .font(.headline)
                            Text("Carbs: \(log.totalCarbohydrates, specifier: "%.1f")g")
                            Text("Fiber: \(log.totalFiber, specifier: "%.1f")g")
                            Text("Protein: \(log.totalProtein, specifier: "%.1f")g")
                            
                        }
                    }
                }
                    
            }
            .onAppear {
                nutrientsViewModel.loadLogs()
            }
        }
    }
    
    private func addEntry() {
        guard let carbsValue = Double(carbs), 
                let fiberValue = Double(fiber),
                let proteinValue = Double(protein) else {
            print("Invalid input: Carbs = \(carbs), Fiber = \(fiber), Protein = \(protein)")
            return
        }
        nutrientsViewModel.addLog(carbs: carbsValue, fiber: fiberValue, protein: proteinValue)
        carbs = ""
        fiber = ""
        protein = ""
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

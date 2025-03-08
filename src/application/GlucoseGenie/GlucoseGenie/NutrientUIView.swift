//
//  NutrientUIView.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 3/8/25.
//

import SwiftUI

struct NutrientUIView: View {
    @StateObject var nutrientsViewModel = NutrientViewModel()
    @State private var carbs: String = ""
    @State private var fiber: String = ""
    @State private var protein: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
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
                .background(Color.orange)
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

#Preview {
    NutrientUIView()
}

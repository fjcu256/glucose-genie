//
//  NutrientViewModel.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 3/3/25.
//

import SwiftUI

class NutrientViewModel: ObservableObject {
    @Published var logs: [NutrientLog] = []
    
    init() {
        loadLogs()
    }
    
    func addLog(carbs: Double, fiber: Double, protein: Double) {
        let today = Date()
        
        if let index = logs.firstIndex(where: {$0.isSameDay(as: today)}) {
            //Update today's logs
            logs[index].totalCarbohydrates += carbs
            logs[index].totalFiber += fiber
            logs[index].totalProtein += protein
        } else {
            let newLog = NutrientLog(
                date: today,
                totalCarbohydrates: carbs,
                totalFiber: fiber,
                totalProtein: protein
            )
            logs.append(newLog)
        }
        
        saveLogs()
    }
    
    func saveLogs() {
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: "NutrientLogs")
        }
    }
    
    func loadLogs() {
        if let savedData = UserDefaults.standard.data(forKey: "NutrientLogs"),
           let decodedLogs = try? JSONDecoder().decode([NutrientLog].self, from: savedData) {
            logs = decodedLogs
        }
    }
}

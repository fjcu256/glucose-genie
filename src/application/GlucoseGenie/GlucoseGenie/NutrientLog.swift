//
//  NutrientLog.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 3/3/25.
//

import Foundation

struct NutrientLog: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var totalCarbohydrates: Double
    var totalFiber: Double
    var totalProtein: Double
    
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self.date, inSameDayAs: otherDate)
    }
}

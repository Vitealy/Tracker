//
//  Statistics.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 21.09.2026.
//

import Foundation

struct Statistics {
    let bestPeriod: Int       // «Лучший период»
    let idealDays: Int        // «Идеальные дни»
    let completedTrackers: Int // «Трекеров завершено»
    let averageValue: Int     // «Среднее значение»
    
    var isEmpty: Bool {
        bestPeriod == 0 && idealDays == 0 && completedTrackers == 0 && averageValue == 0
    }
    
    static let empty = Statistics(bestPeriod: 0, idealDays: 0, completedTrackers: 0, averageValue: 0)
}

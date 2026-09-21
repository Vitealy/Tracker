//
//  Tracker.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 08.08.2026.
//

import UIKit

// MARK: - Tracker

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [Weekday]? 
    let categoryKey: String? 
}

// MARK: - Weekday

enum Weekday: String, CaseIterable {
    case monday = "Пн"
    case tuesday = "Вт"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Сб"
    case sunday = "Вс"
}

extension Weekday {
    
    var localizationKey: String {
        switch self {
        case .monday: return "weekday.monday"
        case .tuesday: return "weekday.tuesday"
        case .wednesday: return "weekday.wednesday"
        case .thursday: return "weekday.thursday"
        case .friday: return "weekday.friday"
        case .saturday: return "weekday.saturday"
        case .sunday: return "weekday.sunday"
        }
    }
    
    var shortLocalizationKey: String {
        switch self {
        case .monday: return "weekday.monday.short"
        case .tuesday: return "weekday.tuesday.short"
        case .wednesday: return "weekday.wednesday.short"
        case .thursday: return "weekday.thursday.short"
        case .friday: return "weekday.friday.short"
        case .saturday: return "weekday.saturday.short"
        case .sunday: return "weekday.sunday.short"
        }
    }
    
    var fullName: String {
        return NSLocalizedString(localizationKey, comment: "Полное название дня недели")
    }
    
    var shortName: String {
        return NSLocalizedString(shortLocalizationKey, comment: "Короткое название дня недели")
    }
    
    static func from(date: Date) -> Weekday? {
        let calendar = Calendar.current
        
        switch calendar.component(.weekday, from: date) {
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        case 6: return .saturday
        case 7: return .sunday
        default: return nil
        }
    }
}

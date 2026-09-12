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
    let schedule: [Weekday]? // nil для нерегулярного события
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
// Расширение для Weekday (полное название на русском)
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
    
    /// Ключ локализации для короткого названия дня
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
}

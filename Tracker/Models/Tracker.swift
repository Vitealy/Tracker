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
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

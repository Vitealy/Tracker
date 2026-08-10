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

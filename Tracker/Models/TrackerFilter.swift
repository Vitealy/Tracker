//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 20.09.2026.
//

import Foundation

enum TrackerFilter: String, CaseIterable {
    case all            // Все трекеры
    case today          // Трекеры на сегодня
    case completed      // Завершённые
    case uncompleted    // Незавершённые
    
    var title: String {
        switch self {
        case .all:         return NSLocalizedString("filter.all", comment: "")
        case .today:       return NSLocalizedString("filter.today", comment: "")
        case .completed:   return NSLocalizedString("filter.completed", comment: "")
        case .uncompleted: return NSLocalizedString("filter.uncompleted", comment: "")
        }
    }
    
    var isActive: Bool {
        switch self {
        case .all, .today: return false
        case .completed, .uncompleted: return true
        }
    }
    
    var showsCheckmark: Bool {
        return isActive
    }
}

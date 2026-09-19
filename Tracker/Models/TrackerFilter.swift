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
    
    /// Текст, который показывается в списке фильтров.
    var title: String {
        switch self {
        case .all:         return NSLocalizedString("filter.all", comment: "")
        case .today:       return NSLocalizedString("filter.today", comment: "")
        case .completed:   return NSLocalizedString("filter.completed", comment: "")
        case .uncompleted: return NSLocalizedString("filter.uncompleted", comment: "")
        }
    }
    
    /// Активный ли это фильтр — используется для подсветки кнопки.
    /// .all и .today — это сброс фильтрации, они не считаются активными.
    var isActive: Bool {
        switch self {
        case .all, .today: return false
        case .completed, .uncompleted: return true
        }
    }
    
    /// Нужно ли показывать синюю галочку в списке фильтров.
    /// .all и .today — не показываем.
    var showsCheckmark: Bool {
        return isActive
    }
}

//
//  CategoryLocalization.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 12.09.2026.
//

import Foundation

enum CategoryLocalization {
    
    private static let defaultCategoryPrefix = "category.default."
    
    static func displayTitle(for title: String) -> String {
        guard title.hasPrefix(defaultCategoryPrefix) else {
            return title // пользовательская категория – оставляем как есть
        }
        return NSLocalizedString(title, comment: "Название категории по умолчанию")
    }
}

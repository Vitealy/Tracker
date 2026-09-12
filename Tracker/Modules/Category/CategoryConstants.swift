//
//  CategoryConstants.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 06.09.2026.
//

import Foundation

enum CategoryConstants {
    static let defaultCategoryKeys = [
        "category.default.important",
        "category.default.joyful",
        "category.default.wellbeing",
        "category.default.habits",
        "category.default.mindfulness",
        "category.default.sport"
    ]
    
    /// Соответствие «старый локализованный текст → ключ локализации».
    /// Используется для одноразовой миграции в Core Data.
    static let legacyTitleToKeyMap: [String: String] = [
        // Русские значения
        "Важное": "category.default.important",
        "Радостные мелочи": "category.default.joyful",
        "Самочувствие": "category.default.wellbeing",
        "Привычки": "category.default.habits",
        "Внимательность": "category.default.mindfulness",
        "Спорт": "category.default.sport",
        // Английские значения (на случай, если пользователь уже запускал с английским)
        "Important": "category.default.important",
        "Little Joys": "category.default.joyful",
        "Wellbeing": "category.default.wellbeing",
        "Habits": "category.default.habits",
        "Mindfulness": "category.default.mindfulness",
        "Sport": "category.default.sport"
    ]
}

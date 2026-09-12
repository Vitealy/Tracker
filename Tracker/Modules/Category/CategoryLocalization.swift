//
//  CategoryLocalization.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 12.09.2026.
//

import Foundation

/// Помощник для локализации названий категорий.
///
/// Логика:
/// - Если название категории — это ключ локализации (начинается с `category.default.`),
///   возвращаем локализованную строку через `NSLocalizedString`.
/// - Иначе (пользовательская категория) возвращаем строку как есть.
enum CategoryLocalization {
    
    /// Префикс ключей локализации для дефолтных категорий.
    private static let defaultCategoryPrefix = "category.default."
    
    /// Возвращает локализованное название категории для отображения в UI.
    static func displayTitle(for title: String) -> String {
        guard title.hasPrefix(defaultCategoryPrefix) else {
            return title // пользовательская категория – оставляем как есть
        }
        return NSLocalizedString(title, comment: "Название категории по умолчанию")
    }
}

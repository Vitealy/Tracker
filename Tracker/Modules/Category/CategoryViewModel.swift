//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.09.2026.
//

import Foundation

final class CategoryViewModel {
    
    // MARK: - Dependencies
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Output
    var onCategoriesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - State
    private(set) var categories: [String] = []
    private(set) var selectedCategory: String?
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        loadCategories()
    }
    
    // MARK: - Public Methods
    
    func loadCategories() {
        let fetched = categoryStore.fetchAllCategories()
        if fetched.isEmpty {
            // Добавляем категории по умолчанию
            do {
                for title in CategoryConstants.defaultCategories {
                    _ = try categoryStore.getOrCreateCategory(with: title)
                }
            } catch {
                onError?("Не удалось добавить категории по умолчанию")
            }
        }
        categories = categoryStore.fetchAllCategories().map { $0.title }
        onCategoriesUpdated?()
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func category(at index: Int) -> String {
        return categories[index]
    }
    
    func isSelected(at index: Int) -> Bool {
        return categories[index] == selectedCategory
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        onCategoriesUpdated?()
    }
    
    func addCategory(_ name: String) {
        do {
            let category = TrackerCategory(title: name, trackers: [])
            _ = try categoryStore.getOrCreateCategory(with: category.title)
            loadCategories() // перезагружаем список
        } catch {
            onError?("Не удалось добавить категорию")
        }
    }
    
    func editCategory(at index: Int, newName: String) {
        let oldName = categories[index]
        do {
            try categoryStore.updateCategory(oldTitle: oldName, newTitle: newName)
            loadCategories()
        } catch {
            onError?("Не удалось обновить категорию")
        }
    }
    
    func deleteCategory(at index: Int) {
        let title = categories[index]
        do {
            try categoryStore.deleteCategory(with: title)
            loadCategories()
        } catch {
            onError?("Не удалось удалить категорию")
        }
    }
}

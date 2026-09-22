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
    
    // MARK: - Private
    private let defaultsSeededKey = "categories.defaultsSeeded"
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        loadCategories()
    }
    
    // MARK: - Public Methods
    
    func loadCategories() {
        seedDefaultCategoriesIfNeeded()
        
        let fetched = categoryStore.fetchAllCategories()
        categories = fetched.map { $0.title }
        onCategoriesUpdated?()
    }
    
    private func seedDefaultCategoriesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: defaultsSeededKey) else { return }
        
        for key in CategoryConstants.defaultCategoryKeys {
            _ = try? categoryStore.getOrCreateCategory(with: key)
        }
        UserDefaults.standard.set(true, forKey: defaultsSeededKey)
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
            onError?(NSLocalizedString("category.error.add", comment: "Ошибка добавления категории"))
        }
    }
    
    func editCategory(at index: Int, newName: String) {
        let oldName = categories[index]
        do {
            try categoryStore.updateCategory(oldTitle: oldName, newTitle: newName)
            loadCategories()
        } catch {
            onError?(NSLocalizedString("category.error.update", comment: "Ошибка обновления категории"))
        }
    }
    
    func deleteCategory(at index: Int) {
        let title = categories[index]
        do {
            try categoryStore.deleteCategory(with: title)
            loadCategories()
        } catch {
            onError?(NSLocalizedString("category.error.delete", comment: "Ошибка удаления категории"))
        }
    }
}

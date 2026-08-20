//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 20.08.2026.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Получение или создание категории по названию
    
    func getOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try? context.fetch(request).first {
            return existing
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = title
            try context.save()
            return newCategory
        }
    }
    
    // MARK: - Получение всех категорий с трекерами (для отображения на главном экране)
    
    func fetchAllCategories() -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        guard let results = try? context.fetch(request) else { return [] }
        
        return results.compactMap { (categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? in
            guard let title = categoryCoreData.title else { return nil }
            
            // Извлекаем трекеры через связь (To Many)
            let trackersSet = categoryCoreData.trackers as? Set<TrackerCoreData> ?? []
            let trackers = trackersSet.compactMap { trackerCoreData -> Tracker? in
                guard let id = trackerCoreData.id,
                      let name = trackerCoreData.name,
                      let color = trackerCoreData.color,
                      let emoji = trackerCoreData.emoji else { return nil }
                
                let schedule: [Weekday]? = trackerCoreData.schedule?
                    .split(separator: ",")
                    .compactMap { Weekday(rawValue: String($0)) }
                
                return Tracker(
                    id: id,
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: schedule
                )
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    // MARK: - Удаление категории (вместе с трекерами, если настроено каскадное удаление)
    
    func deleteCategory(with title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        guard let object = try? context.fetch(request).first else { return }
        context.delete(object)
        try context.save()
    }
}

//
//  TrackerStore.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 20.08.2026.
//

import UIKit
import CoreData

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    // Инициализатор с внедрением контекста (Dependency Injection)
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Сохранение нового трекера
    
    func addTracker(_ tracker: Tracker, in category: TrackerCategory) throws {
        // 1. Находим категорию в Core Data по названию (или создаём, если нет)
        let categoryStore = TrackerCategoryStore(context: context)
        let categoryCoreData = try categoryStore.getOrCreateCategory(with: category.title)
        
        // 2. Создаём новый объект TrackerCoreData
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule?.map { $0.rawValue }.joined(separator: ",") // сохраняем как строку "Пн,Вт,Ср"
        trackerCoreData.category = categoryCoreData
        
        // 3. Сохраняем контекст
        try context.save()
    }
    
    // MARK: - Получение всех трекеров
    
    func fetchAllTrackers() -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        // Можно отсортировать по имени или id
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { trackerCoreData in
            return tracker(from: trackerCoreData)
        }
    }
    
    // MARK: - Получение трекеров для конкретной категории
    
    func fetchTrackers(for categoryTitle: String) -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "category.title == %@", categoryTitle)
        request.predicate = predicate
        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { trackerCoreData in
            return tracker(from: trackerCoreData)
        }
    }
    
    // MARK: - Обновление трекера (например, при изменении названия или расписания)
    
    func updateTracker(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        guard let existing = try? context.fetch(request).first else {
            // Если трекер не найден, можно создать новый или кинуть ошибку
            return
        }
        existing.name = tracker.name
        existing.color = tracker.color
        existing.emoji = tracker.emoji
        existing.schedule = tracker.schedule?.map { $0.rawValue }.joined(separator: ",")
        try context.save()
    }
    
    // MARK: - Удаление трекера
    
    func deleteTracker(by id: UUID) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let object = try? context.fetch(request).first else { return }
        context.delete(object)
        try context.save()
    }
    
    // MARK: - Конвертация Core Data → структура Tracker
    
    private func tracker(from coreData: TrackerCoreData) -> Tracker? {
        guard let id = coreData.id,
              let name = coreData.name,
              let color = coreData.color,
              let emoji = coreData.emoji else { return nil }
        
        let schedule: [Weekday]? = coreData.schedule?
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
}

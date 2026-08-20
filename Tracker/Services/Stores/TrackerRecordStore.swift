//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 20.08.2026.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Добавление записи о выполнении
    
    func addRecord(for trackerId: UUID, date: Date) throws {
        // Проверяем, есть ли уже запись на эту дату для этого трекера
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
        if let existing = try? context.fetch(request).first {
            // Если запись уже существует, ничего не делаем (или обновляем, но это не нужно)
            return
        }
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        try context.save()
    }
    
    // MARK: - Удаление записи о выполнении
    
    func removeRecord(for trackerId: UUID, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
        guard let object = try? context.fetch(request).first else { return }
        context.delete(object)
        try context.save()
    }
    
    // MARK: - Получение всех записей для конкретного трекера
    
    func fetchRecords(for trackerId: UUID) -> [Date] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { $0.date }
    }
    
    // MARK: - Получение всех записей для конкретной даты (для быстрой проверки отметок)
    
    func fetchRecordIds(for date: Date) -> Set<UUID> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as CVarArg, endOfDay as CVarArg)
        guard let results = try? context.fetch(request) else { return [] }
        return Set(results.compactMap { $0.trackerId })
    }
    
    // MARK: - Проверка, выполнен ли трекер в определённую дату
    
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        guard let count = try? context.count(for: request) else { return false }
        return count > 0
    }
}

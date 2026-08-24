//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 23.08.2026.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Singleton
    
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Persistent Container
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("❌ Не удалось загрузить хранилище Core Data: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Context
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Saving
    
    /// Сохраняет изменения в контексте, если они есть.
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("❌ Не удалось сохранить контекст Core Data: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker
import CoreData

@MainActor
final class TrackersViewControllerSnapshotTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        cleanInMemoryContext()
    }
    
    // MARK: - Tests
    
    func testTrackersViewController_empty_light() {
        let vc = makeTrackersViewController()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testTrackersViewController_empty_dark() {
        let vc = makeTrackersViewController()
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
        )
    }
    
//    func testTrackersViewController_withData_light() {
//        seedTestData()
//        let vc = makeTrackersViewController()
//        assertSnapshot(
//            of: vc,
//            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
//        )
//    }
//    
//    func testTrackersViewController_withData_dark() {
//        seedTestData()
//        let vc = makeTrackersViewController()
//        assertSnapshot(
//            of: vc,
//            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
//        )
//    }
    
    // MARK: - Helpers
    
    private func makeTrackersViewController() -> UIViewController {
        let context = CoreDataManager.shared.context
        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)
        
        let vc = TrackersViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
        
        return UINavigationController(rootViewController: vc)
    }
    
    private func seedTestData() {
        let context = CoreDataManager.shared.context
        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        
        do {
            let categoryKey = "category.default.important"
            _ = try categoryStore.getOrCreateCategory(with: categoryKey)
            
            let tracker = Tracker(
                id: UUID(),
                name: "Пить воду",
                color: "Color_1",
                emoji: "💧",
                schedule: Weekday.allCases,
                categoryKey: categoryKey
            )
            let category = TrackerCategory(title: categoryKey, trackers: [tracker])
            try trackerStore.addTracker(tracker, in: category)
        } catch {
            XCTFail("Не удалось заполнить тестовые данные: \(error)")
        }
    }
    
    /// Удаляет все объекты из контекста — работает для in-memory store.
    private func cleanInMemoryContext() {
        let context = CoreDataManager.shared.context
        let entities = ["TrackerRecordCoreData", "TrackerCoreData", "TrackerCategoryCoreData"]
        
        for entityName in entities {
            let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
            if let objects = try? context.fetch(fetch) {
                for object in objects {
                    context.delete(object)
                }
            }
        }
        try? context.save()
    }
}

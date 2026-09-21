//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit
import CoreData

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        migrateCategoriesIfNeeded()
        cleanupOrphanRecordsIfNeeded(context: CoreDataManager.shared.context) 
        setupTabs()
        setupTabBarDivider()
    }
    
    private func migrateCategoriesIfNeeded() {
        let context = CoreDataManager.shared.context
        let categoryStore = TrackerCategoryStore(context: context)
        do {
            try categoryStore.migrateDefaultCategoriesToKeys()
        } catch {
            print("❌ Ошибка миграции категорий: \(error)")
        }
    }
    
    /// Удаляет записи о выполнении, у которых tracker == nil (сироты).
    /// Идемпотентно: если сирот нет — ничего не делает.
    func cleanupOrphanRecordsIfNeeded(context: NSManagedObjectContext) {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker == nil")
        guard let orphans = try? context.fetch(request), !orphans.isEmpty else { return }
        orphans.forEach { context.delete($0) }
        do {
            try context.save()
            print("🧹 Удалено осиротевших записей: \(orphans.count)")
        } catch {
            print("❌ Ошибка очистки записей: \(error)")
        }
    }
    
    private func setupTabs() {
        let context = CoreDataManager.shared.context
        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)

        let trackersVC = TrackersViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
        
        let statisticsService = StatisticsService(
            recordStore: recordStore,
            trackerStore: trackerStore
        )
        
        // Создаём вью-контроллеры для каждой вкладки
        let statisticsVC = StatisticsViewController(statisticsService: statisticsService)
        
        // Оборачиваем их в навигационные контроллеры
        let trackersNav = makeNavigationController(root: trackersVC)
        let statisticsNav = makeNavigationController(root: statisticsVC)
        
        // Настраиваем иконки для вкладок (пока используем системные)
        trackersNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar.trackers", comment: "Название вкладки Трекеры"),
            image: UIImage(resource: .trackers),
            tag: 0
        )
        statisticsNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar.statistics", comment: "Название вкладки Статистика"),
            image: UIImage(resource: .statistics),
            tag: 1
        )
        
        viewControllers = [trackersNav, statisticsNav]
    }
    
    private func makeNavigationController(root: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.compactAppearance = appearance
        return nav
    }
    
    private func setupTabBarDivider() {
        // Убираем стандартную тень (чтобы не было дублирования)
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        // Создаём линию
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            lineView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

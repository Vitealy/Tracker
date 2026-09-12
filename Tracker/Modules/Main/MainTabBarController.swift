//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        migrateCategoriesIfNeeded()
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
    
    private func setupTabs() {
        let context = CoreDataManager.shared.context
        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)

        let trackersVC = TrackersViewController(trackerStore: trackerStore, categoryStore: categoryStore, recordStore: recordStore)
        // Создаём вью-контроллеры для каждой вкладки
        let statisticsVC = StatisticsViewController()
        
        // Оборачиваем их в навигационные контроллеры
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        
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
        
        // Добавляем контроллеры в TabBar
        viewControllers = [trackersNav, statisticsNav]
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

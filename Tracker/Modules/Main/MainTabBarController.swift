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
        setupTabs()
    }
    
    private func setupTabs() {
        // Создаём вью-контроллеры для каждой вкладки
        let trackersVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        // Оборачиваем их в навигационные контроллеры
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        
        // Настраиваем иконки для вкладок (пока используем системные)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackers),
            tag: 0
        )
        statisticsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statistics),
            tag: 1
        )
        
        // Добавляем контроллеры в TabBar
        viewControllers = [trackersNav, statisticsNav]
    }
}

//
//  AppDelegate.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Инициализация AppMetrica
        if let configuration = AppMetricaConfiguration(apiKey: "ab9e04fc-1698-45b3-9ebc-83490774f490") {
            configuration.areLogsEnabled = true // включаем логи библиотеки (полезно при отладке)
            AppMetrica.activate(with: configuration)
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // MARK: - Core Data Saving
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Сохраняем контекст при уходе в фон
        CoreDataManager.shared.saveContext()
    }
}

//
//  AppDelegate.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit
import AppMetricaCore
import os

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Читаем API-ключ из Info.plist (значение подставляется из Config.xcconfig)
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "AppMetricaAPIKey") as? String,
           !apiKey.isEmpty,
           let configuration = AppMetricaConfiguration(apiKey: apiKey) {
            configuration.areLogsEnabled = true
            AppMetrica.activate(with: configuration)
            AppLogger.analytics.info("AppMetrica activated successfully")
        } else {
            AppLogger.analytics.error("AppMetrica API key not found in Info.plist")
            assertionFailure("AppMetrica API key not found in Info.plist")
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
        CoreDataManager.shared.saveContext()
    }
}

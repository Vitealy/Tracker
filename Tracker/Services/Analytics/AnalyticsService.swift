//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 21.09.2026.
//

import Foundation
import AppMetricaCore
import os

// MARK: - AnalyticsService

final class AnalyticsService {
    
    // MARK: - Singleton
    
    static let shared = AnalyticsService()
    private init() {}
    
    // MARK: - Константы событий
    
    enum Event: String {
        case open  = "open"
        case close = "close"
        case click = "click"
    }
    
    enum Screen: String {
        case main = "Main"
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track    = "track"
        case filter   = "filter"
        case edit     = "edit"
        case delete   = "delete"
    }
    
    // MARK: - Публичный метод
    
    func log(event: Event, screen: Screen, item: Item? = nil) {
        // Формируем словарь параметров
        var params: [String: String] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        
        // item отправляется только для событий click
        if let item = item {
            params["item"] = item.rawValue
        }
        
        // Дублируем в лог для отладки на тестах
        print("📊 Analytics: event=\(event.rawValue), screen=\(screen.rawValue), item=\(item?.rawValue ?? "-")")
        AppLogger.analytics.info("event=\(event.rawValue, privacy: .public), screen=\(screen.rawValue, privacy: .public), item=\(item?.rawValue ?? "-", privacy: .public)")
        
        // Отправляем событие в AppMetrica
        AppMetrica.reportEvent(name: "ui_event", parameters: params) { error in
            print("❌ Analytics error: \(error.localizedDescription)")
            AppLogger.analytics.error("Analytics error: \(error.localizedDescription)")
        }
    }
}

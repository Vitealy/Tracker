//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 21.09.2026.
//

import Foundation
import AppMetricaCore

// MARK: - AnalyticsService

/// Сервис для отправки событий в AppMetrica.
/// Инкапсулирует строковые константы и упрощает вызовы.
final class AnalyticsService {
    
    // MARK: - Singleton
    
    static let shared = AnalyticsService()
    private init() {}
    
    // MARK: - Константы событий
    
    /// Типы событий.
    enum Event: String {
        case open  = "open"
        case close = "close"
        case click = "click"
    }
    
    /// Экраны, на которых происходят события.
    enum Screen: String {
        case main = "Main"
    }
    
    /// Элементы, по которым был совершен тап.
    enum Item: String {
        case addTrack = "add_track"
        case track    = "track"
        case filter   = "filter"
        case edit     = "edit"
        case delete   = "delete"
    }
    
    // MARK: - Публичный метод
    
    /// Отправляет событие в AppMetrica.
    /// - Parameters:
    ///   - event: Тип события (open, close, click).
    ///   - screen: Название экрана.
    ///   - item: Элемент (только для click).
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
        
        // Отправляем событие в AppMetrica
        AppMetrica.reportEvent(name: "ui_event", parameters: params) { error in
            print("❌ Analytics error: \(error.localizedDescription)")
        }
    }
}

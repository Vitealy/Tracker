//
//  AppLogger.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 22.09.2026.
//

import Foundation
import os

/// Единая точка логирования по приложению.
///
/// Использует `os.Logger` из системного фреймворка `os`:
/// - нет внешних зависимостей;
/// - поддерживает уровни (debug/info/notice/error/fault);
/// - логи видны в Console.app и Xcode с фильтром по subsystem.
enum AppLogger {
    
    /// Подсистема — обычно bundle identifier приложения.
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Tracker"
    
    /// Логгер для общих сообщений приложения.
    static let general = Logger(subsystem: subsystem, category: "general")
    
    /// Логгер для Core Data.
    static let coreData = Logger(subsystem: subsystem, category: "coreData")
    
    /// Логгер для аналитики.
    static let analytics = Logger(subsystem: subsystem, category: "analytics")
}

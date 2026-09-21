//
//  StatisticsService.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 21.09.2026.
//

import Foundation

final class StatisticsService {
    
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    private let calendar: Calendar
    
    init(recordStore: TrackerRecordStore,
         trackerStore: TrackerStore,
         calendar: Calendar = .current) {
        self.recordStore = recordStore
        self.trackerStore = trackerStore
        self.calendar = calendar
    }
    
    // MARK: - Публичный метод
    
    func calculate() -> Statistics {
        // 1. Забираем все записи и группируем их по дню
        let records = recordStore.fetchAllRecords()
        guard !records.isEmpty else { return .empty }
        
        let recordsByDay = groupRecordsByDay(records)
        
        // 2. Считаем показатели
        let completedTrackers = records.count
        let bestPeriod = calculateBestPeriod(from: recordsByDay.keys)
        let idealDays = calculateIdealDays(recordsByDay: recordsByDay)
        let averageValue = completedTrackers / max(recordsByDay.count, 1)
        
        return Statistics(
            bestPeriod: bestPeriod,
            idealDays: idealDays,
            completedTrackers: completedTrackers,
            averageValue: averageValue
        )
    }
    
    // MARK: - Группировка по дням
    
    private func groupRecordsByDay(_ records: [(trackerId: UUID, date: Date)]) -> [Date: Set<UUID>] {
        var result: [Date: Set<UUID>] = [:]
        for record in records {
            let day = calendar.startOfDay(for: record.date)
            result[day, default: []].insert(record.trackerId)
        }
        return result
    }
    
    // MARK: - Лучший период
    
    private func calculateBestPeriod(from days: Dictionary<Date, Set<UUID>>.Keys) -> Int {
        guard !days.isEmpty else { return 0 }
        
        let sortedDays = days.sorted()
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDays.count {
            let prev = sortedDays[i - 1]
            let curr = sortedDays[i]
            let diff = calendar.dateComponents([.day], from: prev, to: curr).day ?? 0
            
            if diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        return maxStreak
    }
    
    // MARK: - Идеальные дни
    
    /// Дни, в которые выполнены ВСЕ запланированные на этот день недели трекеры.
    private func calculateIdealDays(recordsByDay: [Date: Set<UUID>]) -> Int {
        let allTrackers = trackerStore.fetchAllTrackers()
        
        // Трекеры с расписанием (нерегулярные не учитываются)
        let scheduledTrackers = allTrackers.filter { $0.schedule != nil }
        guard !scheduledTrackers.isEmpty else { return 0 }
        
        var idealDaysCount = 0
        
        for (day, completedIds) in recordsByDay {
            guard let weekday = Weekday.from(date: day) else { continue }
            
            // Все трекеры, запланированные на этот день недели
            let trackersForDay = scheduledTrackers.filter { tracker in
                tracker.schedule?.contains(weekday) ?? false
            }
            
            guard !trackersForDay.isEmpty else { continue }
            
            // Все ли они выполнены?
            let allCompleted = trackersForDay.allSatisfy { completedIds.contains($0.id) }
            if allCompleted { idealDaysCount += 1 }
        }
        
        return idealDaysCount
    }
}

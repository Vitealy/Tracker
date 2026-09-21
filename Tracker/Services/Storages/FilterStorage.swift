//
//  FilterStorage.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 20.09.2026.
//

import Foundation

final class FilterStorage {
    private let key = "trackers.selectedFilter"
    
    var current: TrackerFilter {
        get {
            guard let raw = UserDefaults.standard.string(forKey: key),
                  let filter = TrackerFilter(rawValue: raw) else {
                return .all
            }
            return filter
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}

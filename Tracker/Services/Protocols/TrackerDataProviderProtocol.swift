//
//  TrackerDataProviderProtocol.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 23.08.2026.
//

import Foundation

/// Протокол для предоставления данных о трекерах, скрывающий реализацию хранения.
protocol TrackerDataProviderProtocol: AnyObject {
    var delegate: TrackerDataProviderDelegate? { get set }
    
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func titleForSection(at index: Int) -> String
    func performFetch()
    func refresh()
}

/// Делегат для оповещения об изменениях данных (аналог NSFetchedResultsControllerDelegate)
protocol TrackerDataProviderDelegate: AnyObject {
    func didChangeContent(_ provider: TrackerDataProviderProtocol)
}

//
//  TrackerDataProvider.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 23.08.2026.
//

import CoreData
import UIKit

/// Реализация провайдера данных на основе NSFetchedResultsController.
final class TrackerDataProvider: NSObject, TrackerDataProviderProtocol {
    weak var delegate: TrackerDataProviderDelegate?
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    private let trackerStore: TrackerStore
    
    init(date: Date, trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
        self.fetchedResultsController = trackerStore.fetchedResultsController(for: date)
        super.init()
        self.fetchedResultsController.delegate = self
        try? self.fetchedResultsController.performFetch()
    }
    
    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let sections = fetchedResultsController.sections,
              section < sections.count else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let sections = fetchedResultsController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            return nil
        }
        let coreData = fetchedResultsController.object(at: indexPath)
        return trackerStore.convertToTracker(from: coreData)
    }
    
    func titleForSection(at index: Int) -> String {
        guard let sections = fetchedResultsController.sections,
              index < sections.count else { return "" }
        return sections[index].name ?? ""
    }
    
    func performFetch() {
        try? fetchedResultsController.performFetch()
    }
    
    func refresh() {
        trackerStore.refreshContext()
        try? fetchedResultsController.performFetch()
        delegate?.didChangeContent(self)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeContent(self)
    }
}

//
//  TrackerDataProvider.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 23.08.2026.
//

import CoreData
import UIKit

final class TrackerDataProvider: NSObject, TrackerDataProviderProtocol {
    weak var delegate: TrackerDataProviderDelegate?
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    private let trackerStore: TrackerStore
    private let date: Date
    private var filter: TrackerFilter = .all
    private var currentQuery: String = ""
    
    private var sectionData: [(title: String, trackers: [TrackerCoreData])] = []
    
    init(date: Date, trackerStore: TrackerStore, filter: TrackerFilter = .all) {
        self.trackerStore = trackerStore
        self.date = date
        self.filter = filter
        self.fetchedResultsController = trackerStore.fetchedResultsController(for: date, filter: filter)
        super.init()
        self.fetchedResultsController.delegate = self
        try? self.fetchedResultsController.performFetch()
        computeSections()
    }
    
    // MARK: - Секции
    
    private func computeSections() {
        guard let objects = fetchedResultsController.fetchedObjects else {
            sectionData = []
            return
        }
        
        var pinned: [TrackerCoreData] = []
        var byCategory: [String: [TrackerCoreData]] = [:]
        
        for tracker in objects {
            if tracker.isPinned {
                pinned.append(tracker)
            } else if let title = tracker.category?.title {
                byCategory[title, default: []].append(tracker)
            }
        }
        
        var result: [(title: String, trackers: [TrackerCoreData])] = []
        if !pinned.isEmpty {
            let pinnedTitle = NSLocalizedString("category.pinned", comment: "Название раздела закреплённых")
            result.append((title: pinnedTitle, trackers: pinned))
        }
        for (categoryKey, trackers) in byCategory.sorted(by: { $0.key < $1.key }) {
            let displayTitle = CategoryLocalization.displayTitle(for: categoryKey) 
            result.append((title: displayTitle, trackers: trackers))
        }
        sectionData = result
    }
    
    // MARK: - TrackerDataProviderProtocol
    
    func numberOfSections() -> Int {
        return sectionData.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard section < sectionData.count else { return 0 }
        return sectionData[section].trackers.count
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard indexPath.section < sectionData.count else { return nil }
        let trackers = sectionData[indexPath.section].trackers
        guard indexPath.row < trackers.count else { return nil }
        return trackerStore.convertToTracker(from: trackers[indexPath.row])
    }
    
    func titleForSection(at index: Int) -> String {
        guard index < sectionData.count else { return "" }
        return sectionData[index].title
    }
    
    func trackerId(at indexPath: IndexPath) -> UUID? {
        guard indexPath.section < sectionData.count else { return nil }
        let trackers = sectionData[indexPath.section].trackers
        guard indexPath.row < trackers.count else { return nil }
        return trackers[indexPath.row].id
    }
    
    func isPinned(at indexPath: IndexPath) -> Bool {
        guard indexPath.section < sectionData.count else { return false }
        let trackers = sectionData[indexPath.section].trackers
        guard indexPath.row < trackers.count else { return false }
        return trackers[indexPath.row].isPinned
    }
    
    func performFetch() {
        try? fetchedResultsController.performFetch()
        computeSections()
    }
    
    func refresh() {
        trackerStore.refreshContext()
        try? fetchedResultsController.performFetch()
        computeSections()
        delegate?.didChangeContent(self)
    }
    
    func updateSearchQuery(_ query: String) {
        currentQuery = query
        fetchedResultsController.delegate = nil
        fetchedResultsController = trackerStore.fetchedResultsController(for: date, searchQuery: query)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        computeSections()
        delegate?.didChangeContent(self)
    }
    
    func updateFilter(_ filter: TrackerFilter) {
        self.filter = filter
        fetchedResultsController.delegate = nil
        fetchedResultsController = trackerStore.fetchedResultsController(for: date, searchQuery: currentQuery, filter: filter)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        computeSections()
        delegate?.didChangeContent(self)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        computeSections()
        delegate?.didChangeContent(self)
    }
}

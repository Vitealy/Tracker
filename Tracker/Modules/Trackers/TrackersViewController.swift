//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit

protocol TrackersViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory categoryTitle: String)
}

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        return picker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        return collectionView
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .star1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.placeholder", comment: "Заглушка при отсутствии трекеров")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypGray)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Data Properties
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private var dataProvider: TrackerDataProviderProtocol?
    private var currentDate: Date = Date()
    
    // MARK: - Init
    
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()
        updateDataProvider(for: currentDate)
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.title = NSLocalizedString("trackers.title", comment: "Заголовок экрана трекеров")
        
        let addButton = UIBarButtonItem(
            image: UIImage(resource: .addTracker).withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        navigationItem.leftBarButtonItem = addButton
        
        let calendar = Calendar.current
        let currentDate = Date()
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.date = currentDate
        
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header"
        )
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupPlaceholder() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        placeholderImageView.isHidden = true
        placeholderLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Data Management
    
    private func updateDataProvider(for date: Date) {
        dataProvider = TrackerDataProvider(date: date, trackerStore: trackerStore)
        dataProvider?.delegate = self
        dataProvider?.performFetch()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = dataProvider?.numberOfItems(in: 0) == 0 && dataProvider?.numberOfSections() == 0
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func didTapAddButton() {
        let typeVC = TrackerTypeViewController()
        typeVC.delegate = self
        present(typeVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateDataProvider(for: currentDate)
    }
    
    // MARK: - Logic: Toggle completion
    
    private func toggleTrackerCompletion(for trackerId: UUID) {
        let calendar = Calendar.current
        if calendar.isDateInToday(currentDate) || currentDate < Date() {
            do {
                if recordStore.isTrackerCompleted(trackerId: trackerId, date: currentDate) {
                    try recordStore.removeRecord(for: trackerId, date: currentDate)
                } else {
                    try recordStore.addRecord(for: trackerId, date: currentDate)
                }
                collectionView.reloadData()
            } catch {
                print("Ошибка изменения отметки: \(error)")
            }
        } else {
            print("Нельзя отметить трекер на будущую дату")
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider?.numberOfSections() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfItems(in: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        guard let tracker = dataProvider?.tracker(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        let daysCount = recordStore.fetchRecords(for: tracker.id).count
        let isCompleted = recordStore.isTrackerCompleted(trackerId: tracker.id, date: currentDate)
        let isFuture = currentDate > Date()
        
        cell.delegate = self
        cell.configure(
            with: tracker,
            daysCount: daysCount,
            isCompleted: isCompleted,
            isFutureDate: isFuture
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let reuseIdentifier = "Header"
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        
        let categoryKey = dataProvider?.titleForSection(at: indexPath.section) ?? ""
        let displayTitle = CategoryLocalization.displayTitle(for: categoryKey)
        
        view.subviews.forEach { $0.removeFromSuperview() }
        let label = UILabel()
        label.text = displayTitle
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let availableWidth = collectionView.bounds.width - spacing
        let width = availableWidth / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didTapCompleteButton(in cell: TrackerCell, for trackerId: UUID) {
        toggleTrackerCompletion(for: trackerId)
    }
}

// MARK: - TrackersViewControllerDelegate

extension TrackersViewController: TrackersViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, inCategory categoryTitle: String) {
        do {
            let category = TrackerCategory(title: categoryTitle, trackers: [tracker])
            try trackerStore.addTracker(tracker, in: category)
            // DataProvider автоматически обновится через делегата
        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
    }
}

// MARK: - TrackerTypeViewControllerDelegate

extension TrackersViewController: TrackerTypeViewControllerDelegate {
    func didSelectTrackerType(_ type: TrackerType) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let newTrackerVC = NewTrackerViewController(
                trackerType: type,
                categoryStore: self.categoryStore 
            )
            newTrackerVC.delegate = self
            let navController = UINavigationController(rootViewController: newTrackerVC)
            self.present(navController, animated: true)
        }
    }
}

// MARK: - TrackerDataProviderDelegate

extension TrackersViewController: TrackerDataProviderDelegate {
    func didChangeContent(_ provider: TrackerDataProviderProtocol) {
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

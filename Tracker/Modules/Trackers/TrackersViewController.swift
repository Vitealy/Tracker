//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit
import CoreData

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
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypGray)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Data Properties
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    private var currentDate: Date = Date() // текущая выбранная дата
    
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()
        updateFetchedResultsController(for: currentDate)
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        // Настраиваем внешний вид заголовка
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        // Обычный заголовок (будет виден при скролле)
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        // Крупный заголовок (Large Title)
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        // Применяем для стандартного и компактного (для скролла) состояний
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // Включаем Large Title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Заголовок
        navigationItem.title = "Трекеры"
        
        // Кнопка "+" слева
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
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
        
        // Регистрируем ячейку
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        
        // Регистрируем хедер
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
        
        // Констрейнты
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func updateFetchedResultsController(for date: Date) {
        trackerStore.refreshContext() 
        fetchedResultsController = trackerStore.fetchedResultsController(for: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEE"
        let weekdayString = dateFormatter.string(from: date).lowercased()
        let weekdayShort: String = {
            switch weekdayString {
            case "понедельник": return "Пн"
            case "вторник": return "Вт"
            case "среда": return "Ср"
            case "четверг": return "Чт"
            case "пятница": return "Пт"
            case "суббота": return "Сб"
            case "воскресенье": return "Вс"
            default: return ""
            }
        }()
        print("📅 Текущий день: \(weekdayShort)")
        let allTrackers = trackerStore.fetchAllTrackers()
        print("🔍 Всего трекеров в базе: \(allTrackers.count)")
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
            collectionView.reloadData()
            updatePlaceholderVisibility()
        } catch {
            print("Ошибка выполнения запроса: \(error)")
        }
        print("🔍 Обновление FRC для даты: \(date)")
        let objects = fetchedResultsController?.fetchedObjects?.count ?? 0
        print("🔍 Найдено объектов: \(objects)")
    }
    
    private func convertToTracker(from coreData: TrackerCoreData) -> Tracker {
        let id = coreData.id ?? UUID()
        let name = coreData.name ?? ""
        let color = coreData.color ?? "Color_1"
        let emoji = coreData.emoji ?? "🙂"
        let schedule: [Weekday]? = coreData.schedule?
            .split(separator: ",")
            .compactMap { Weekday(rawValue: String($0)) }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    // MARK: - Data Management
    
    private func updatePlaceholderVisibility() {
        let isEmpty = fetchedResultsController?.fetchedObjects?.isEmpty ?? true
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
        updateFetchedResultsController(for: currentDate)
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
            } catch {
                print("Ошибка изменения отметки: \(error)")
            }
        } else {
            print("Нельзя отметить трекер на будущую дату")
        }
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        guard let trackerCoreData = fetchedResultsController?.object(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        let tracker = convertToTracker(from: trackerCoreData) // вспомогательный метод
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
    
    // Заголовки секций (категории)
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
        
        let sectionInfo = fetchedResultsController?.sections?[indexPath.section]
        let categoryTitle = sectionInfo?.name ?? ""
        
        view.subviews.forEach { $0.removeFromSuperview() }
        let label = UILabel()
        label.text = categoryTitle
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
        return CGSize(width: width, height: 148) // высота по дизайну (примерно)
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
    
    // Для хедера (категорий) – пока не используем, но можно добавить позднее.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30) // высота заголовка категории
    }
    
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didTapCompleteButton(in cell: TrackerCell, for trackerId: UUID) {
        toggleTrackerCompletion(for: trackerId)
    }
}

extension TrackersViewController: TrackersViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, inCategory categoryTitle: String) {
        do {
            let category = TrackerCategory(title: categoryTitle, trackers: [tracker])
            try trackerStore.addTracker(tracker, in: category)
            print("✅ didCreateTracker вызван для трекера: \(tracker.name)")
            updateFetchedResultsController(for: currentDate)
        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
    }
}

extension TrackersViewController: TrackerTypeViewControllerDelegate {
    func didSelectTrackerType(_ type: TrackerType) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let newTrackerVC = NewTrackerViewController(trackerType: type)
            newTrackerVC.delegate = self
            let navController = UINavigationController(rootViewController: newTrackerVC)
            self.present(navController, animated: true)
        }
    }
}

extension TrackersViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatePlaceholderVisibility()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                collectionView.insertItems(at: [newIndexPath])
            }
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
            }
        case .update:
            if let indexPath = indexPath {
                collectionView.reloadItems(at: [indexPath])
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                collectionView.moveItem(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            collectionView.insertSections(indexSet)
        case .delete:
            collectionView.deleteSections(indexSet)
        default:
            break
        }
    }
}

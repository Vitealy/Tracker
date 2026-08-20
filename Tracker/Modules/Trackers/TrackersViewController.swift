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
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
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
    
    private var categories: [TrackerCategory] = []
    private var completedTrackerIdsForCurrentDate: Set<UUID> = []
    private var currentDate: Date = Date() // текущая выбранная дата
    
    
    // Отфильтрованные категории для отображения
    private var filteredCategories: [TrackerCategory] = [] {
        didSet {
            updatePlaceholderVisibility()
            collectionView.reloadData()
        }
    }
    
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
        // Обновляем трекеры для текущей даты
        updateFilteredCategories(for: currentDate)
        loadData()
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        categories = categoryStore.fetchAllCategories()
        // completedTrackers пока не загружаем, будем получать по дате
        updateFilteredCategories(for: currentDate)
    }
    
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
            .foregroundColor: UIColor(named: "YP Black") ?? .black
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
    
    private func updateCompletedTrackerIdsForCurrentDate() {
        completedTrackerIdsForCurrentDate = recordStore.fetchRecordIds(for: currentDate)
    }
    
    // MARK: - Data Management
    
    private func updateFilteredCategories(for date: Date) {
        let calendar = Calendar.current
        _ = calendar.component(.weekday, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEE"
        let weekdayName = dateFormatter.string(from: date).lowercased()
        
        let weekdayEnum: Weekday? = {
            switch weekdayName {
            case "понедельник": return .monday
            case "вторник": return .tuesday
            case "среда": return .wednesday
            case "четверг": return .thursday
            case "пятница": return .friday
            case "суббота": return .saturday
            case "воскресенье": return .sunday
            default: return nil
            }
        }()
        
        guard let weekdayEnum = weekdayEnum else {
            filteredCategories = []
            return
        }
        
        // Фильтруем категории и трекеры
        let newCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                if let schedule = tracker.schedule {
                    // Если есть расписание, проверяем, содержит ли оно нужный день
                    return schedule.contains(weekdayEnum)
                } else {
                    // Нерегулярное событие (без расписания) показываем всегда
                    return true
                }
            }
            if filteredTrackers.isEmpty {
                return nil
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        filteredCategories = newCategories
        
        updateCompletedTrackerIdsForCurrentDate()
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = filteredCategories.isEmpty
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
        updateFilteredCategories(for: currentDate)
    }
    
    // MARK: - Logic: Toggle completion
    
    private func toggleTrackerCompletion(for trackerId: UUID) {

        let calendar = Calendar.current
        if calendar.isDateInToday(currentDate) || currentDate < Date() {
            do {
                if recordStore.isTrackerCompleted(trackerId: trackerId, date: currentDate) {
                    // Если уже выполнено – снимаем отметку
                    try recordStore.removeRecord(for: trackerId, date: currentDate)
                } else {
                    // Отмечаем как выполненное
                    try recordStore.addRecord(for: trackerId, date: currentDate)
                }
                // Обновляем UI
                updateFilteredCategories(for: currentDate)
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
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = recordStore.fetchRecords(for: tracker.id).count
        
        // Проверяем, отмечен ли трекер на текущую дату
        let calendar = Calendar.current
        let isCompleted = completedTrackerIdsForCurrentDate.contains(tracker.id)
        
        // Будущая ли дата?
        _ = calendar.isDateInTomorrow(currentDate) // проще: если дата больше сегодняшней
        // Более точная проверка: если currentDate > текущая дата (начало дня)
        let today = Date()
        let isFuture = currentDate > today
        
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
        
        // Проверяем, что это хедер
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let reuseIdentifier = "Header"
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        
        // Настраиваем внешний вид хедера
        let category = filteredCategories[indexPath.section]
        view.backgroundColor = .clear
        
        // Добавляем UILabel с названием категории
        let label = UILabel()
        label.text = category.title
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "YP Black") ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Удаляем старые subviews, если они есть
        view.subviews.forEach { $0.removeFromSuperview() }
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
            // Добавляем трекер в Core Data
            // Сначала найдём или создадим категорию
            let category = TrackerCategory(title: categoryTitle, trackers: [tracker])
            try trackerStore.addTracker(tracker, in: category)
            // Перезагружаем данные
            loadData()
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

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
        picker.datePickerMode = .date                  // Только дата, без времени
        picker.preferredDatePickerStyle = .compact    // Компактный стиль (в навбаре)
        picker.backgroundColor = .clear
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
        imageView.image = UIImage(named: "Star_1")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YP Gray") ?? .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Data Properties
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIdsForCurrentDate: Set<UUID> = []
    private var currentDate: Date = Date() // текущая выбранная дата
    
    // Отфильтрованные категории для отображения
    private var filteredCategories: [TrackerCategory] = [] {
        didSet {
            updatePlaceholderVisibility()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()
        //        addTestData()
        // Обновляем трекеры для текущей даты
        updateFilteredCategories(for: currentDate)
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
        let calendar = Calendar.current
        completedTrackerIdsForCurrentDate = Set(
            completedTrackers
                .filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
                .map { $0.trackerId }
        )
    }
    
    // MARK: - Data Management
    
    private func addTestData() {
        // Создаём несколько тестовых трекеров
        let tracker1 = Tracker(
            id: UUID(),
            name: "Пить воду",
            color: "YP Blue",
            emoji: "💧",
            schedule: [.monday, .wednesday, .friday]
        )
        
        let tracker2 = Tracker(
            id: UUID(),
            name: "Читать книгу",
            color: "YP Red",
            emoji: "📚",
            schedule: Weekday.allCases // все дни
        )
        
        let tracker3 = Tracker(
            id: UUID(),
            name: "Нерегулярное событие",
            color: "YP Green",
            emoji: "🎉",
            schedule: nil // нерегулярное
        )
        
        let category1 = TrackerCategory(title: "Здоровье", trackers: [tracker1])
        let category2 = TrackerCategory(title: "Развитие", trackers: [tracker2, tracker3])
        
        categories = [category1, category2]
    }
    
    private func updateFilteredCategories(for date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
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
        // Проверяем, можно ли отметить (не будущая дата)
        let calendar = Calendar.current
        if calendar.isDateInToday(currentDate) || currentDate < Date() {
            // Если сегодня или прошлая дата, можно менять
            if let index = completedTrackers.firstIndex(where: { $0.trackerId == trackerId && calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                // Удаляем запись (снимаем отметку)
                completedTrackers.remove(at: index)
            } else {
                // Добавляем запись
                let record = TrackerRecord(trackerId: trackerId, date: currentDate)
                completedTrackers.append(record)
            }
            updateCompletedTrackerIdsForCurrentDate()
            collectionView.reloadData()
        } else {
            // Будущая дата – нельзя отметить
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
        let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        // Проверяем, отмечен ли трекер на текущую дату
        let calendar = Calendar.current
        let isCompleted = completedTrackerIdsForCurrentDate.contains(tracker.id)
        
        // Будущая ли дата?
        let isFutureDate = calendar.isDateInTomorrow(currentDate) // проще: если дата больше сегодняшней
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
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            // Создаём обновлённую категорию
            let updatedCategory = TrackerCategory(
                title: categories[index].title,
                trackers: categories[index].trackers + [tracker]
            )
            // Создаём новый массив категорий
            var updatedCategories = categories
            updatedCategories[index] = updatedCategory
            categories = updatedCategories
        } else {
            // Создаём новую категорию
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        updateFilteredCategories(for: currentDate)
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

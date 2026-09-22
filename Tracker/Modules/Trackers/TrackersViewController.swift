//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit
import os

protocol TrackersViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory categoryTitle: String)
}

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    
    /// Строка поиска — размещается вручную, а не в навбаре.
    private let searchTextField: UISearchTextField = {
        let field = UISearchTextField()
        field.placeholder = NSLocalizedString("search.placeholder", comment: "Плейсхолдер поиска")
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
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
    
    // MARK: - Placeholders
    
    /// Первая заглушка — когда трекеров вообще нет (стартовое состояние)
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .star1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.placeholder", comment: "Заглушка при отсутствии трекеров")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypGray)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Вторая заглушка — когда поиск не дал результатов
    private let notFoundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .nothing)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let notFoundLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.notFound", comment: "Заглушка при отсутствии результатов поиска")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Data Properties
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private var dataProvider: TrackerDataProviderProtocol?
    private var currentDate: Date = Date()
    private var currentSearchQuery: String = ""
    private let filterStorage = FilterStorage()
    private var currentFilter: TrackerFilter = .all

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filter.button.title", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return button
    }()
    
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
        currentFilter = filterStorage.current
        view.backgroundColor = UIColor(resource: .ypBackground)
        setupNavigationBar()
        setupSearchTextField()
        setupCollectionView()
        setupPlaceholders()
        setupFilterButton()
        updateDataProvider(for: currentDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.log(event: .open, screen: .main)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.shared.log(event: .close, screen: .main)
    }
    
    // MARK: - Setup
    
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
        addButton.tintColor = .clear
        navigationItem.leftBarButtonItem = addButton
        
        // DatePicker
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
    
    /// Размещаем UISearchTextField вручную ниже навбара.
    private func setupSearchTextField() {
        view.addSubview(searchTextField)
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
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
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    /// Настраиваем обе заглушки — они центрируются одинаково.
    private func setupPlaceholders() {
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        view.addSubview(notFoundImageView)
        view.addSubview(notFoundLabel)
        
        emptyImageView.isHidden = true
        emptyLabel.isHidden = true
        notFoundImageView.isHidden = true
        notFoundLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            // Заглушка "Пусто"
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Заглушка "Ничего не найдено"
            notFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            notFoundImageView.widthAnchor.constraint(equalToConstant: 80),
            notFoundImageView.heightAnchor.constraint(equalToConstant: 80),
            
            notFoundLabel.topAnchor.constraint(equalTo: notFoundImageView.bottomAnchor, constant: 8),
            notFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
        
        // Оверскролл — чтобы ячейки прокручивались выше кнопки
        collectionView.contentInset.bottom = 100
        collectionView.verticalScrollIndicatorInsets.bottom = 100
        collectionView.alwaysBounceVertical = true
        
        updateFilterButtonAppearance()
    }

    private func updateFilterButtonAppearance() {
        if currentFilter.isActive {
            filterButton.backgroundColor = UIColor(resource: .ypRed)
        } else {
            filterButton.backgroundColor = .systemBlue
        }
    }
    
    // MARK: - Data Management
    
    private func updateDataProvider(for date: Date) {
        dataProvider = TrackerDataProvider(
                date: date,
                trackerStore: trackerStore,
                filter: currentFilter
            )
        dataProvider?.delegate = self
        dataProvider?.performFetch()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    /// Показывает нужную заглушку в зависимости от контекста:
    /// - Пусто и нет поиска → "Что будем отслеживать?"
    /// - Пусто и есть поиск → "Ничего не найдено"
    /// - Есть данные → скрыть всё
    private func updatePlaceholderVisibility() {
        let isEmpty = (dataProvider?.numberOfSections() ?? 0) == 0
        
        let hasSearchQuery = !currentSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Первая заглушка — только когда нет поискового запроса
        let showEmptyPlaceholder = isEmpty && !hasSearchQuery
        // Вторая заглушка — только когда есть поисковый запрос и результат пуст
        let showNotFoundPlaceholder = isEmpty && hasSearchQuery
        
        emptyImageView.isHidden = !showEmptyPlaceholder
        emptyLabel.isHidden = !showEmptyPlaceholder
        
        notFoundImageView.isHidden = !showNotFoundPlaceholder
        notFoundLabel.isHidden = !showNotFoundPlaceholder
        
        collectionView.isHidden = isEmpty
        
        // Скрываем кнопку «Фильтры», если на выбранный день нет трекеров вообще
        filterButton.isHidden = isEmpty && !currentFilter.isActive && !hasSearchQuery
    }
    
    // MARK: - Actions
    
    @objc private func didTapAddButton() {
        
        AnalyticsService.shared.log(event: .click, screen: .main, item: .addTrack)
        
        let typeVC = TrackerTypeViewController()
        typeVC.delegate = self
        present(typeVC, animated: true)
    }
    
    /// Обрабатываем изменение текста в поиске.
    @objc private func searchTextChanged(_ sender: UISearchTextField) {
        currentSearchQuery = sender.text ?? ""
        dataProvider?.updateSearchQuery(currentSearchQuery)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        // Сбрасываем поиск
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        currentSearchQuery = ""
        updateDataProvider(for: currentDate)
    }
    
    @objc private func didTapFilterButton() {
        
        AnalyticsService.shared.log(event: .click, screen: .main, item: .filter)
        
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.onFilterSelected = { [weak self] filter in
            self?.applyFilter(filter)
        }
        let nav = UINavigationController(rootViewController: filtersVC)
        present(nav, animated: true)
    }

    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        filterStorage.current = filter
        
        // Если .today — переключаем дату на сегодня
        if filter == .today {
            currentDate = Date()
            datePicker.date = currentDate
        }
        
        updateFilterButtonAppearance()
        
        // Пересоздаём провайдер с новым фильтром
        if let provider = dataProvider as? TrackerDataProvider {
            provider.updateFilter(filter)
        }
        
        updatePlaceholderVisibility()
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
                AppLogger.general.error("Ошибка изменения отметки: \(error.localizedDescription)")
            }
        } else {
            print("Нельзя отметить трекер на будущую дату")
            AppLogger.general.error("Нельзя отметить трекер на будущую дату")
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
        
//        let categoryKey = dataProvider?.titleForSection(at: indexPath.section) ?? ""
//        let displayTitle = CategoryLocalization.displayTitle(for: categoryKey)
        let displayTitle = dataProvider?.titleForSection(at: indexPath.section) ?? ""
        
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
        
        AnalyticsService.shared.log(event: .click, screen: .main, item: .track)
        
        toggleTrackerCompletion(for: trackerId)
    }
}

// MARK: - TrackersViewControllerDelegate

extension TrackersViewController: TrackersViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, inCategory categoryTitle: String) {
        do {
            let category = TrackerCategory(title: categoryTitle, trackers: [tracker])
            try trackerStore.addTracker(tracker, in: category)
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
                categoryStore: self.categoryStore,
                trackerStore: self.trackerStore
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

// MARK: - UICollectionViewDelegate (Context Menu)

extension TrackersViewController {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let trackerId = dataProvider?.trackerId(at: indexPath) else { return nil }
        let isPinned = dataProvider?.isPinned(at: indexPath) ?? false
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            
            // Пункт 1 — Закрепить/Открепить
            let pinTitle = isPinned
                ? NSLocalizedString("tracker.unpin", comment: "Открепить трекер")
                : NSLocalizedString("tracker.pin", comment: "Закрепить трекер")
            
            let pinImage = UIImage(systemName: isPinned ? "pin.slash" : "pin")
            let pinAction = UIAction(title: pinTitle, image: pinImage) { _ in
                self?.togglePin(for: trackerId)
            }
            
            // Пункт 2 — Редактировать
            let editAction = UIAction(
                title: NSLocalizedString("tracker.edit", comment: "Редактировать трекер"),
                image: UIImage(systemName: "pencil")
            ) { _ in
                AnalyticsService.shared.log(event: .click, screen: .main, item: .edit)
                self?.editTracker(withId: trackerId)
            }
            
            // Пункт 3 — Удалить (красный цвет)
            let deleteAction = UIAction(
                title: NSLocalizedString("tracker.delete", comment: "Удалить трекер"),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                AnalyticsService.shared.log(event: .click, screen: .main, item: .delete)
                self?.deleteTracker(withId: trackerId)
            }
            
            return UIMenu(children: [pinAction, editAction, deleteAction])
        }
    }
}

// MARK: - Actions

extension TrackersViewController {
    
    private func togglePin(for trackerId: UUID) {
        do {
            try trackerStore.togglePin(for: trackerId)
            dataProvider?.refresh() // пересобирает секции
        } catch {
            print("Ошибка закрепления: \(error)")
        }
    }
    
    private func editTracker(withId id: UUID) {
        guard let tracker = trackerStore.fetchTracker(by: id) else { return }
        
        let newTrackerVC = NewTrackerViewController(
            trackerType: tracker.schedule == nil ? .irregular : .habit,
            categoryStore: categoryStore,
            trackerStore: trackerStore,
            trackerToEdit: tracker
        )
        newTrackerVC.delegate = self
        let nav = UINavigationController(rootViewController: newTrackerVC)
        present(nav, animated: true)
    }
    
    private func deleteTracker(withId id: UUID) {
        let deleteVC = DeleteConfirmationViewController()
        
        deleteVC.messageText = NSLocalizedString("tracker.delete.message", comment: "Сообщение подтверждения удаления трекера")
        deleteVC.onConfirm = { [weak self] in
            guard let self = self else { return }
            do {
                try self.trackerStore.deleteTracker(withId: id)
                self.dataProvider?.refresh()
            } catch {
                print("Ошибка удаления: \(error)")
            }
        }
        deleteVC.modalPresentationStyle = .overFullScreen
        deleteVC.modalTransitionStyle = .crossDissolve
        present(deleteVC, animated: true)
    }
}

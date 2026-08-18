//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 09.08.2026.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    // MARK: - Data
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let colors: [String] = [
        "Color_1", "Color_2", "Color_3", "Color_4", "Color_5", "Color_6",
        "Color_7", "Color_8", "Color_9", "Color_10", "Color_11", "Color_12",
        "Color_13", "Color_14", "Color_15", "Color_16", "Color_17", "Color_18"
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    // MARK: - Блок "Категория + Расписание"
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "Важное"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scheduleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private let scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "Ежедневно"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Emoji
    private let emojiTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        return collectionView
    }()
    
    // MARK: - Color
    private let colorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        return collectionView
    }()
    
    // MARK: - Кнопки (фиксированы внизу)
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let trackerType: TrackerType
    private var selectedCategory: String = "Важное"
    private var selectedDays: [Weekday] = Weekday.allCases
    weak var delegate: TrackersViewControllerDelegate?
    
    // MARK: - Init
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
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
        
        navigationItem.title = trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.label
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        setupLayout()
        setupCollections()
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeights()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Все элементы добавляем в contentView
        contentView.addSubview(textField)
        contentView.addSubview(containerView)
        containerView.addSubview(categoryView)
        categoryView.addSubview(categoryLabel)
        categoryView.addSubview(categoryDetailLabel)
        categoryView.addSubview(categoryArrowImageView)
        
        if trackerType == .habit {
            containerView.addSubview(separatorView)
            containerView.addSubview(scheduleView)
            scheduleView.addSubview(scheduleLabel)
            scheduleView.addSubview(scheduleDetailLabel)
            scheduleView.addSubview(scheduleArrowImageView)
        }
        
        contentView.addSubview(emojiTitleLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(colorCollectionView)
        
        // Кнопки добавляем в основное view (не в scrollView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        view.addSubview(buttonStackView)
        
        // Отключаем автоматическую трансляцию
        [scrollView, contentView, textField, containerView, categoryView, categoryLabel, categoryDetailLabel, categoryArrowImageView,
         separatorView, scheduleView, scheduleLabel, scheduleDetailLabel, scheduleArrowImageView,
         emojiTitleLabel, emojiCollectionView, colorTitleLabel, colorCollectionView,
         buttonStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        buttonStackView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Констрейнты scrollView (занимает место от верха до кнопок)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16)
        ])
        
        // Констрейнты contentView (внутри scrollView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        // Констрейнты элементов внутри contentView (все привязаны к contentView)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 50),
            
            containerView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? 150 : 75),
            
            categoryView.topAnchor.constraint(equalTo: containerView.topAnchor),
            categoryView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            categoryView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            categoryView.heightAnchor.constraint(equalToConstant: 75),
            
            categoryLabel.topAnchor.constraint(equalTo: categoryView.topAnchor, constant: 11),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryView.leadingAnchor, constant: 16),
            
            categoryDetailLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 2),
            categoryDetailLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            categoryDetailLabel.trailingAnchor.constraint(lessThanOrEqualTo: categoryArrowImageView.leadingAnchor, constant: -8),
            
            categoryArrowImageView.trailingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: -16),
            categoryArrowImageView.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor),
            categoryArrowImageView.widthAnchor.constraint(equalToConstant: 20),
            categoryArrowImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Emoji
            emojiTitleLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 0), // будет обновлено
            
            // Color
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 0), // будет обновлено
            
            // Важно: задаём нижний отступ для contentView, чтобы он имел корректную высоту
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        // Констрейнты кнопок (фиксированы внизу)
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34)
        ])
        
        // Констрейнты для расписания (только привычка)
        if trackerType == .habit {
            NSLayoutConstraint.activate([
                separatorView.topAnchor.constraint(equalTo: categoryView.bottomAnchor),
                separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                separatorView.heightAnchor.constraint(equalToConstant: 1),
                
                scheduleView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
                scheduleView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                scheduleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                scheduleView.heightAnchor.constraint(equalToConstant: 74),
                scheduleView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                
                scheduleLabel.topAnchor.constraint(equalTo: scheduleView.topAnchor, constant: 11),
                scheduleLabel.leadingAnchor.constraint(equalTo: scheduleView.leadingAnchor, constant: 16),
                
                scheduleDetailLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 2),
                scheduleDetailLabel.leadingAnchor.constraint(equalTo: scheduleLabel.leadingAnchor),
                scheduleDetailLabel.trailingAnchor.constraint(lessThanOrEqualTo: scheduleArrowImageView.leadingAnchor, constant: -8),
                
                scheduleArrowImageView.trailingAnchor.constraint(equalTo: scheduleView.trailingAnchor, constant: -16),
                scheduleArrowImageView.centerYAnchor.constraint(equalTo: scheduleView.centerYAnchor),
                scheduleArrowImageView.widthAnchor.constraint(equalToConstant: 20),
                scheduleArrowImageView.heightAnchor.constraint(equalToConstant: 20),
            ])
        }
    }
    
    private func setupCollections() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }
    
    private func updateCollectionViewHeights() {
        let spacing: CGFloat = 5
        let rows: CGFloat = 3
        let columns: CGFloat = 6
        
        let totalHorizontalInsets: CGFloat = 16 * 2
        let collectionViewWidth = view.bounds.width - totalHorizontalInsets
        let totalSpacing = (columns - 1) * spacing
        let availableWidth = collectionViewWidth - totalSpacing
        let itemWidth = floor(availableWidth / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        for collectionView in [emojiCollectionView, colorCollectionView] {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.itemSize = itemSize
                layout.minimumInteritemSpacing = spacing
                layout.minimumLineSpacing = spacing
                layout.invalidateLayout()
            }
        }
        
        let height = (itemSize.height + spacing) * rows - spacing
        
        // Удаляем старые констрейнты высоты и создаём новые
        emojiCollectionView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        colorCollectionView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        emojiCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    // MARK: - Actions
    @objc private func textFieldChanged() {
        let text = textField.text ?? ""
        let isFormValid = !text.isEmpty && selectedEmoji != nil && selectedColor != nil
        createButton.isEnabled = isFormValid
        createButton.backgroundColor = isFormValid ? .systemBlue : .systemGray
    }
    
    @objc private func categoryTapped() {
        print("Категория нажата")
    }
    
    @objc private func scheduleTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = textField.text, !name.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: trackerType == .habit ? selectedDays : nil
        )
        delegate?.didCreateTracker(tracker, inCategory: selectedCategory)
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate
extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(days: [Weekday]) {
        selectedDays = days
        if days.count == 7 {
            scheduleDetailLabel.text = "Каждый день"
        } else {
            let dayNames = days.map { $0.shortName }.joined(separator: ", ")
            scheduleDetailLabel.text = dayNames
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let colorName = colors[indexPath.item]
            cell.configure(with: colorName, isSelected: colorName == selectedColor)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            colorCollectionView.reloadData()
        }
        textFieldChanged()
    }
}

// MARK: - EmojiCell
final class EmojiCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        label.text = emoji
        contentView.backgroundColor = isSelected ? .systemGray5 : .clear
    }
}

// MARK: - ColorCell
final class ColorCell: UICollectionViewCell {
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(with colorName: String, isSelected: Bool) {
        let color = UIColor(named: colorName) ?? .systemBlue
        colorView.backgroundColor = color
        
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
    }
}

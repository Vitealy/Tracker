//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 09.08.2026.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    // MARK: - UI Elements
    
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
    
    // Категория (верхняя часть)
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
    
    // Разделитель 
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Расписание (нижняя часть)
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
    
    // MARK: - Кнопки в UIStackView
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Настройка заголовка
        navigationItem.title = trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        
        // Настройка внешнего вида навбара
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear // убираем линию под навбаром
        
        // Шрифт и цвет заголовка
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.label
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        setupLayout()
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(textField)
        view.addSubview(containerView)
        
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
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        view.addSubview(buttonStackView)
        
        // Отключаем автоматическую трансляцию для всех элементов, кроме тех, что уже в стеке
        [textField, containerView, categoryView, categoryLabel, categoryDetailLabel, categoryArrowImageView,
         separatorView, scheduleView, scheduleLabel, scheduleDetailLabel, scheduleArrowImageView,
         buttonStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        buttonStackView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        NSLayoutConstraint.activate([
            // Поле ввода
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 50),
            
            // Контейнер (категория + расписание)
            containerView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? 150 : 75),
            
            // Категория
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
            
            // Разделитель
            separatorView.topAnchor.constraint(equalTo: categoryView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // Расписание
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
        
        // Стек кнопок
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
        ])
    }
    
    // MARK: - Actions
    @objc private func textFieldChanged() {
        let text = textField.text ?? ""
        createButton.isEnabled = !text.isEmpty
        createButton.backgroundColor = !text.isEmpty ? .systemBlue : .systemGray
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
        guard let name = textField.text, !name.isEmpty else { return }
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: "YP Blue",
            emoji: "😎",
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

extension Weekday {
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

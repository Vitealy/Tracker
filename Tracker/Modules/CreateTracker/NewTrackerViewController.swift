//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 09.08.2026.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка" // будет меняться
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private lazy var categoryCell: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = "Категория"
        cell.detailTextLabel?.text = "Важное" // пока статично
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .systemGray6
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        return cell
    }()
    
    private lazy var scheduleCell: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = "Расписание"
        cell.detailTextLabel?.text = "Ежедневно" // позже будет обновляться
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .systemGray6
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        return cell
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
    
    weak var delegate: TrackersViewControllerDelegate? // для добавления трекера
    
    // MARK: - Init
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = trackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Добавляем жест для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(categoryCell)
        if trackerType == .habit {
            view.addSubview(scheduleCell)
        }
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        categoryCell.translatesAutoresizingMaskIntoConstraints = false
        if trackerType == .habit {
            scheduleCell.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Констрейнты
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 50),
            
            // Категория
            categoryCell.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            categoryCell.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryCell.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryCell.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        if trackerType == .habit {
            NSLayoutConstraint.activate([
                scheduleCell.topAnchor.constraint(equalTo: categoryCell.bottomAnchor, constant: 0),
                scheduleCell.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                scheduleCell.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                scheduleCell.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
        
        let bottomButtonsTopAnchor = trackerType == .habit ? scheduleCell.bottomAnchor : categoryCell.bottomAnchor
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: bottomButtonsTopAnchor, constant: 24),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        // Добавляем обработчики для ячеек
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryCell.addGestureRecognizer(categoryTap)
        
        if trackerType == .habit {
            let scheduleTap = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
            scheduleCell.addGestureRecognizer(scheduleTap)
        }
    }
    
    // MARK: - Actions
    @objc private func textFieldChanged() {
        let text = textField.text ?? ""
        createButton.isEnabled = !text.isEmpty
        createButton.backgroundColor = !text.isEmpty ? .systemBlue : .systemGray
    }
    
    @objc private func categoryTapped() {
        // Пока ничего не делаем
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
        
        // Создаём трекер
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: "YP Blue", // временно используем дефолтный цвет
            emoji: "😎",      // временно используем дефолтный эмодзи
            schedule: trackerType == .habit ? selectedDays : nil
        )
        
        // Передаём в делегат
        delegate?.didCreateTracker(tracker, inCategory: selectedCategory)
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate
extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(days: [Weekday]) {
        selectedDays = days
        // Обновляем отображение в ячейке
        if days.count == 7 {
            scheduleCell.detailTextLabel?.text = "Каждый день"
        } else {
            let dayNames = days.map { $0.shortName }.joined(separator: ", ")
            scheduleCell.detailTextLabel?.text = dayNames
        }
    }
}

// Добавим shortName для Weekday
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

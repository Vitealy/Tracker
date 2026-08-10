//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 09.08.2026.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(days: [Weekday])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP Black") ?? .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedDays: [Weekday] = Weekday.allCases
    private let days = Weekday.allCases
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Расписание"
        setupLayout()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            // Таблица с днями недели
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(days.count * 44)),
            
            // Кнопка "Готово" внизу экрана
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        delegate?.didSelectSchedule(days: selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let day = days[indexPath.row]
        cell.textLabel?.text = day.fullName 
        
        let switchView = UISwitch()
        switchView.isOn = selectedDays.contains(day)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        let day = days[sender.tag]
        if sender.isOn {
            if !selectedDays.contains(day) {
                selectedDays.append(day)
            }
        } else {
            selectedDays.removeAll { $0 == day }
        }
    }
}

// Расширение для Weekday, чтобы получить полное название на русском
extension Weekday {
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

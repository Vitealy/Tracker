//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private let statisticsService: StatisticsService
    
    // MARK: - State
    
    private var statistics: Statistics = .empty
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            StatisticsCell.self,
            forCellReuseIdentifier: StatisticsCell.reuseIdentifier
        )
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .cryingFaceEmoji)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.placeholder", comment: "Заглушка статистики")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(statisticsService: StatisticsService) {
        self.statisticsService = statisticsService
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBackground)
        setupNavigationBar()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadStatistics()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("statistics.title", comment: "Заголовок статистики")
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        tableView.addSubview(emptyImageView)
        tableView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyImageView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -20),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tableView.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: tableView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Data
    
    private func reloadStatistics() {
        statistics = statisticsService.calculate()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = statistics.isEmpty
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
    }
}

// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Если статистики нет — строк нет (иначе под заглушкой висели бы 4 нулевые карточки).
        return statistics.isEmpty ? 0 : 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsCell else {
            return UITableViewCell()
        }
        
        let config: (value: Int, title: String)
        switch indexPath.row {
        case 0:
            config = (statistics.bestPeriod, NSLocalizedString("statistics.bestPeriod", comment: ""))
        case 1:
            config = (statistics.idealDays, NSLocalizedString("statistics.idealDays", comment: ""))
        case 2:
            config = (statistics.completedTrackers, NSLocalizedString("statistics.completed", comment: ""))
        case 3:
            config = (statistics.averageValue, NSLocalizedString("statistics.average", comment: ""))
        default:
            config = (0, "")
        }
        
        cell.configure(value: config.value, title: config.title)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension StatisticsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
}

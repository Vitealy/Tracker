//
//  TrackerCell.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 09.08.2026.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapCompleteButton(in cell: TrackerCell, for trackerId: UUID)
}

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    // Верхняя часть (цветная)
    private let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Нижняя часть (светлая)
    private let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack // или системный
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    private var isCompletedToday: Bool = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Configuration
    func configure(
        with tracker: Tracker,
        daysCount: Int,
        isCompleted: Bool,
        isFutureDate: Bool
    ) {
        trackerId = tracker.id
        isCompletedToday = isCompleted
        
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysLabel.text = pluralizeDays(daysCount)
        
        // Цвет верхней части ячейки
        if let color = UIColor(named: tracker.color) {
            topView.backgroundColor = color
        } else {
            topView.backgroundColor = .systemBlue
        }
        
        // Кнопка
        let imageName = isCompleted ? "Button_Done" : "Button_Plus"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        completeButton.setImage(image, for: .normal)
        completeButton.isEnabled = !isFutureDate // если будущая дата, кнопка неактивна
        completeButton.alpha = isFutureDate ? 0.5 : 1.0
    }
    
    // MARK: - Actions
    @objc private func completeButtonTapped() {
        guard let trackerId = trackerId else { return }
        delegate?.didTapCompleteButton(in: self, for: trackerId)
    }
    
    // MARK: - Private Helpers
    private func pluralizeDays(_ count: Int) -> String {
        return "\(count) \(getDaysWord(for: count))"
    }
    
    private func getDaysWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "дней"
        }
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    // MARK: - Layout
    private func setupLayout() {
        contentView.layer.cornerRadius = 0
        contentView.clipsToBounds = false
        
        // Добавляем верхнюю и нижнюю части
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)
        
        // Добавляем элементы в верхнюю часть
        topView.addSubview(emojiLabel)
        topView.addSubview(nameLabel)
        
        // Добавляем элементы в нижнюю часть
        bottomView.addSubview(daysLabel)
        bottomView.addSubview(completeButton)
        
        // Отключаем автоматическую трансляцию
        [topView, bottomView, emojiLabel, nameLabel, daysLabel, completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Применяем скругление ко ВСЕМ углам topView
        topView.layer.cornerRadius = 16
        topView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        topView.clipsToBounds = true
        
        // Применяем скругление ко ВСЕМ углам bottomView
        bottomView.layer.cornerRadius = 16
        bottomView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        bottomView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            // topView – занимает верхнюю часть
            topView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            // bottomView – занимает нижнюю часть
            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // emojiLabel – в верхней части
            emojiLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // nameLabel – в верхней части, прижат к нижнему краю topView
            nameLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -12),
            
            // daysLabel – в нижней части, слева
            daysLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            daysLabel.trailingAnchor.constraint(lessThanOrEqualTo: completeButton.leadingAnchor, constant: -8),
            
            // completeButton – в нижней части, справа
            completeButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}

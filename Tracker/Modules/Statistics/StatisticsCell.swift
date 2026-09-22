//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 21.09.2026.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    
    static let reuseIdentifier = "StatisticsCell"
    
    // MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypBackground)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Слой с градиентом — рисует рамку вокруг карточки.
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        return layer
    }()
    
    /// Маска для градиента — оставляет видимой только рамку.
    private let shapeMask: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        return shape
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }

    private func updateGradientFrame() {

        guard containerView.bounds.width > 0, containerView.bounds.height > 0 else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.frame = containerView.bounds
        
        let inset: CGFloat = 1
        let path = UIBezierPath(
            roundedRect: containerView.bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: containerView.layer.cornerRadius
        )
        shapeMask.path = path.cgPath
        
        CATransaction.commit()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        
        // Градиент + маска для рамки
        containerView.layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeMask
        
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title

        containerView.layoutIfNeeded()
        updateGradientFrame()
    }
}

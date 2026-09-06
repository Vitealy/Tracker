//
//  DeleteConfirmationViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 04.09.2026.
//

import UIKit

final class DeleteConfirmationViewController: UIViewController {
    
    var onConfirm: (() -> Void)?
    
    // MARK: - UI Elements
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Верхний блок (текст + кнопка "Удалить")
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topBlurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Эта категория точно не нужна?"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(resource: .ypGray)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(UIColor(resource: .ypRed2), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    // Нижний блок (кнопка "Отменить")
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypWhite)
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(resource: .ypBlue2), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(topContainerView)
        view.addSubview(bottomContainerView)
        
        topContainerView.addSubview(topBlurEffectView)
        topContainerView.addSubview(messageLabel)
        topContainerView.addSubview(topSeparatorView)
        topContainerView.addSubview(deleteButton)
        
        bottomContainerView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            // Затемнённый фон
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Верхний блок (текст + "Удалить")
            topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topContainerView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: -8),
            topContainerView.heightAnchor.constraint(equalToConstant: 103),
            
            // Blur-фон верхнего блока
            topBlurEffectView.topAnchor.constraint(equalTo: topContainerView.topAnchor),
            topBlurEffectView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
            topBlurEffectView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
            topBlurEffectView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            
            // Текст
            messageLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -16),
            messageLabel.heightAnchor.constraint(equalToConstant: 18),
            
            // Разделитель
            topSeparatorView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            topSeparatorView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Кнопка "Удалить"
            deleteButton.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            
            // Нижний блок ("Отменить")
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 61),
            
            // Кнопка "Отменить"
            cancelButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor)
        ])
        
        // Закрытие по тапу на фон
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func deleteTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
}

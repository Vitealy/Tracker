//
//  ContextMenuViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 04.09.2026.
//

import UIKit

final class ContextMenuViewController: UIViewController {
    
    // MARK: - Properties
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let blurEffectView: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
            let view = UIVisualEffectView(effect: blurEffect)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать", for: .normal)
        button.setTitleColor(UIColor(resource: .ypBlack), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(UIColor(resource: .ypRed2), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(blurEffectView)
        containerView.addSubview(editButton)
        containerView.addSubview(separatorView)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 230),
            
            blurEffectView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            editButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            editButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 44),
            
            separatorView.topAnchor.constraint(equalTo: editButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            deleteButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        // Закрытие по тапу на фон
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func editTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onEdit?()
        }
    }
    
    @objc private func deleteTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDelete?()
        }
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
}

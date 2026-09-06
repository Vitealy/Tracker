//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.09.2026.
//

import UIKit

enum NewCategoryMode {
    case add
    case edit(index: Int, currentName: String)
}

final class NewCategoryViewController: UIViewController {
    
    // MARK: - UI Elements
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
        field.backgroundColor = UIColor(resource: .grayLight)
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.tintColor = UIColor(resource: .ypBlack)
        field.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let mode: NewCategoryMode
    private let viewModel: CategoryViewModel
    
    // MARK: - Init
    init(mode: NewCategoryMode, viewModel: CategoryViewModel) {
        self.mode = mode
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Заполнить текст при редактировании
        if case .edit(_, let currentName) = mode {
            textField.text = currentName
            textField.becomeFirstResponder()
        }
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateDoneButtonState()
    }
    
    private func setupNavigationBar() {
        let title: String
        switch mode {
        case .add:
            title = "Новая категория"
        case .edit:
            title = "Редактирование категории"
        }
        navigationItem.title = title
    }
    
    private func updateDoneButtonState() {
        let isEnabled = !(textField.text?.isEmpty ?? true)
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        updateDoneButtonState()
    }
    
    @objc private func doneButtonTapped() {
        guard let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
        
        switch mode {
        case .add:
            viewModel.addCategory(name)
        case .edit(let index, _):
            viewModel.editCategory(at: index, newName: name)
        }
        dismiss(animated: true)
    }
    
}

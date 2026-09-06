//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.09.2026.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .separator
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor(resource: .grayLight)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        return tableView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: CategoryViewModel
    
    // MARK: - Init
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        setupUI()
        setupBindings()
        setupLongPressGesture()
        viewModel.loadCategories()
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Категория"
        
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 450),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onError = { [weak self] message in
            self?.showAlert(message: message)
        }
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let newCategoryVC = NewCategoryViewController(mode: .add, viewModel: viewModel)
        let nav = UINavigationController(rootViewController: newCategoryVC)
        present(nav, animated: true)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location), gesture.state == .began else { return }
        showActionSheet(for: indexPath.row)
    }
    
    private func showActionSheet(for index: Int) {
        let contextMenu = ContextMenuViewController()
        contextMenu.onEdit = { [weak self] in
            self?.editCategory(at: index)
        }
        contextMenu.onDelete = { [weak self] in
            self?.showDeleteConfirmation(at: index)
        }
        present(contextMenu, animated: true)
    }
    
    private func editCategory(at index: Int) {
        let currentName = viewModel.category(at: index)
        let editVC = NewCategoryViewController(mode: .edit(index: index, currentName: currentName), viewModel: viewModel)
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
    
    private func showDeleteConfirmation(at index: Int) {
        let deleteVC = DeleteConfirmationViewController()
        deleteVC.onConfirm = { [weak self] in
            self?.viewModel.deleteCategory(at: index)
        }
        deleteVC.modalPresentationStyle = .overFullScreen
        deleteVC.modalTransitionStyle = .crossDissolve
        present(deleteVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let title = viewModel.category(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        cell.configure(with: title, isSelected: isSelected)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.category(at: indexPath.row)
        viewModel.selectCategory(at: indexPath.row)
        onCategorySelected?(category)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfCategories() - 1 {
            // Скрываем разделитель для последней ячейки
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        } else {
            // Стандартные отступы для остальных ячеек
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

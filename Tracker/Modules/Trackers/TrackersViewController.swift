//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 03.08.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupPlaceholder()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        // Настраиваем внешний вид заголовка
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        // Обычный заголовок (будет виден при скролле)
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        // Крупный заголовок (Large Title)
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(named: "Black") ?? .black
        ]
        
        // Применяем для стандартного и компактного (для скролла) состояний
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // Включаем Large Title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Заголовок
        navigationItem.title = "Трекеры"
        
        // Кнопка "+" слева
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
        navigationItem.leftBarButtonItem = addButton
    }
    
    private func setupPlaceholder() {
        // Звезда
        let starImageView = UIImageView()
        starImageView.image = UIImage(named: "Star_1")
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starImageView)
        
        // Текст
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Gray") ?? .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            // Центрируем звезду по X и Y (немного смещаем вверх, чтобы текст был ниже)
            starImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20), // смещение вверх, чтобы текст поместился
            
            // Размер звезды
            starImageView.widthAnchor.constraint(equalToConstant: 80),
            starImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Текст под звездой
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8),
        ])
    }
    
    @objc private func didTapAddButton() {
        print("Кнопка + нажата") // позже здесь будет открытие экрана создания трекера
    }
}

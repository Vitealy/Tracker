//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 02.09.2026.
//

import UIKit

final class OnboardingContentViewController: UIViewController {
    
    // MARK: - Properties
    private let image: UIImage
    private let titleText: String
    private let buttonTitle = "Вот это технологии!"
    
    var onButtonTap: (() -> Void)?
    
    // MARK: - UI Elements
    private let imageView = UIImageView()
    private let label = UILabel()
    private let button = UIButton(type: .system)
    
    // MARK: - Init
    init(image: UIImage, titleText: String) {
        self.image = image
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // 📌 Настройка текста с переносом на 2 строки
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        
        let attributedText = NSAttributedString(
            string: titleText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor(resource: .ypBlack),
                .paragraphStyle: paragraphStyle
            ]
        )
        label.attributedText = attributedText
        
        view.addSubview(label)
        
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Картинка на весь экран
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Текст
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalToConstant: 343),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            
            // Кнопка
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 668),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func buttonTapped() {
        onButtonTap?()
    }
}

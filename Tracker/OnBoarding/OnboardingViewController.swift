//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Vitaly Kashavkin on 02.09.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Properties
    private var pages: [UIViewController] = []
    private let pageControl = UIPageControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        // Создаём две страницы
        let firstPage = OnboardingContentViewController(
            image: UIImage(resource: .onboarding1),
            titleText: NSLocalizedString("onboarding.page1.title", comment: "Заголовок первой страницы онбординга")
        )
        let secondPage = OnboardingContentViewController(
            image: UIImage(resource: .onboarding2),
            titleText: NSLocalizedString("onboarding.page2.title", comment: "Заголовок второй страницы онбординга")
        )
        
        // Замыкание для завершения онбординга
        firstPage.onButtonTap = { [weak self] in
            self?.finishOnboarding()
        }
        secondPage.onButtonTap = { [weak self] in
            self?.finishOnboarding()
        }
        
        pages = [firstPage, secondPage]
        
        // Показываем первую страницу
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        setupPageControl()
    }
    
    // MARK: - Setup
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(resource: .ypBlack)
        pageControl.pageIndicatorTintColor = UIColor(resource: .ypBlack).withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 638)
        ])
    }
    
    // MARK: - Actions
    private func finishOnboarding() {
        // Сохраняем флаг первого запуска и переключаем на главный экран
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        sceneDelegate.switchToMainScreen()
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}

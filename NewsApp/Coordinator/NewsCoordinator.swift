//
//  NewsCoordinator.swift
//  NewsApp
//
//  Created by Octo Siswardhono on 13/11/24.
//

import UIKit

protocol NewsCoordinatorProtocol {
    func showNewsDetail(for news: NewsElement)
}

class NewsCoordinator: NewsCoordinatorProtocol {

    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = NewsViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showNewsDetail(for news: NewsElement) {
        let detailViewModel = NewsDetailViewModel(news: news)
        let detailViewController = NewsDetailViewController(viewModel: detailViewModel)
        navigationController.pushViewController(detailViewController, animated: true)
        
    }
}

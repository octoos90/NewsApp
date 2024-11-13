//
//  NewsDetailViewModel.swift
//  NewsApp
//
//  Created by Octo Siswardhono on 13/11/24.
//

import Foundation
import UIKit

class NewsDetailViewModel {
    let news: NewsElement
    private let apiService: NewsAPIServiceProtocol
    private var imageCache: [String: UIImage] = [:]
    init(news: NewsElement, apiService: NewsAPIServiceProtocol = NewsAPIService.shared) {
        self.news = news
        self.apiService = apiService
    }

    
    func fetchImage(for news: NewsElement, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache[news.title] {
            completion(cachedImage)
            return
        }
        
        apiService.downloadImage(from: news.image) { [weak self] result in
            switch result {
            case .success(let image):
                self?.imageCache[news.title] = image
                completion(image)
            case .failure(let error):
                print("Failed to download image for \(news.title): \(error)")
                completion(nil)
            }
        }
    }
}

//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Octo Siswardhono on 13/11/24.
//

import Foundation
import UIKit

class NewsViewModel {
    private let apiService: NewsAPIServiceProtocol
    private var imageCache: [String: UIImage] = [:]
    var newsData: [NewsElement] = [NewsElement]() {
        didSet {
            bind()
        }
    }
    var bind: (() -> ()) = {}
    var isLoading: ((Bool) -> ())?
    var onError: ((String) -> ())?
    
    init(apiService: NewsAPIServiceProtocol = NewsAPIService.shared) {
        self.apiService = apiService
    }
    
    func startFetchNews() {
        fetchNews()
    }
    
    func cachedImage(for news: NewsElement) -> UIImage? {
        return imageCache[news.title]
    }
    
    func fetchImage(for news: NewsElement, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache[news.title] {
            completion(cachedImage)
            return
        }
        
        apiService.downloadImage(from: news.thumbnail) { [weak self] result in
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

private extension NewsViewModel {
    func fetchNews() {
        isLoading?(true)
        apiService.fetchNewsList(from: .posts) { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let newsList):
                print("JSONN:")
                dump(newsList)
                self.newsData = newsList
            case .failure(let error):
                print(error.localizedDescription)
                self.onError?(error.localizedDescription)
            }
            self.isLoading?(false)
        }
    }
}

//
//  NewsAPIService.swift
//  NewsApp
//
//  Created by Octo Siswardhono on 13/11/24.
//


import Foundation
import UIKit

extension URLSession {
    
    func dataTask(with url: URL, result: @escaping(Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { data, response, error in
            if let error {
                result(.failure(error))
                return
            }
            guard let response, let data else {
                result(.failure(NSError(domain: "Error", code: -1)))
                return
            }
            result(.success((response,data)))
        }
    }
}

protocol NewsAPIServiceProtocol {
    func fetchNewsList(from endPoint: NewsAPIService.Endpoint, result: @escaping(Result<[NewsElement], NewsAPIService.APIError>) -> Void)
    func downloadImage(from urlString: String, completion: @escaping (Result<UIImage, NewsAPIService.APIError>) -> Void)
}


class NewsAPIService: NewsAPIServiceProtocol {

    public static let shared = NewsAPIService()
    
    private init() {}
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://jsonplaceholder.org/")!
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    private let imageCache = NSCache<NSString, UIImage>()
    
    public enum APIError: Error {
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case decodeError
    }
    
    enum Endpoint: String, CustomStringConvertible, CaseIterable {
        var description: String {
            switch self {
            case .posts:
                return "posts"
            }
        }
        
        case posts
    }
    
    func downloadImage(from urlString: String, completion: @escaping (Result<UIImage, APIError>) -> Void) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(.success(cachedImage))
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSession.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Image download error: \(error.localizedDescription)")
                completion(.failure(.apiError))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.noData))
                return
            }
            
            self.imageCache.setObject(image, forKey: urlString as NSString) // Cache the image
            completion(.success(image))
        }.resume()
    }
    
    
    private func fetchRequest<T: Decodable>(url: URL, completion: @escaping(Result<[T], APIError>) -> Void) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSession.dataTask(with: url) { result in
            switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                do {
                    let object = try self.jsonDecoder.decode([T].self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(.decodeError))
                }
            case .failure(_):
                completion(.failure(.apiError))
            }
        }.resume()
    }
    
    func fetchNewsList(from endPoint: Endpoint, result: @escaping(Result<[NewsElement], APIError>) -> Void) {
        fetchRequest(url: baseURL.appendingPathComponent(endPoint.rawValue), completion: result)
    }
}

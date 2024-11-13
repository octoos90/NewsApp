//
//  NewsModel.swift
//  NewsApp
//
//  Created by Octo Siswardhono on 13/11/24.
//


import Foundation

// MARK: - NewsElement
struct NewsElement: Codable {
    let id: Int
    let slug: String
    let url: String
    let title, content: String
    let image, thumbnail: String
    let status: Status
    let category: Category
    let publishedAt, updatedAt: String
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case id, slug, url, title, content, image, thumbnail, status, category, publishedAt, updatedAt
        case userID = "userId"
    }
}

enum Category: String, Codable {
    case elementum = "elementum"
    case ipsum = "ipsum"
    case jsonplaceholder = "jsonplaceholder"
    case lorem = "lorem"
    case rutrum = "rutrum"
}

enum Status: String, Codable {
    case published = "published"
}

typealias News = [NewsElement]

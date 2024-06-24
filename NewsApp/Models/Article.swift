//
//  Article.swift
//  NewsApp
//
//  Created by Aziza Gilash on 05.03.2024.
//

import Foundation

struct Article: Codable {
    struct Source: Codable {
        let name: String
    }
    
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}

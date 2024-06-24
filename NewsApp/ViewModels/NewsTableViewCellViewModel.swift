//
//  NewsTableViewCellViewModel.swift
//  NewsApp
//
//  Created by Aziza Gilash on 05.03.2024.
//

import Foundation

final class NewsTableViewCellViewModel: Identifiable {
    
    enum CellType {
        case news
        case favorites
    }
    
    let id: String
    let title: String
    let subtitle: String?
    let cellType: CellType
    let imageURL: URL?
    var imageData: Data?
    let pageURL: String?
    
    init(
        title: String,
        subtitle: String?,
        cellType: CellType,
        imageURL: URL?,
        imageData: Data? = nil,
        pageURL: String?
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.subtitle = subtitle
        self.cellType = cellType
        self.imageURL = imageURL
        self.imageData = imageData
        self.pageURL = pageURL
    }
}

//
//  FavoritesEmptyView.swift
//  NewsApp
//
//  Created by Aziza Gilash on 06.03.2024.
//

import UIKit

final class FavoritesEmptyView: UIView {
    
    // MARK: - UI
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "favorites")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "There are no favorites 🫃🏻"
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 22)
        return label
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        stackView.addArrangedSubviews(imageView, label)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(150)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

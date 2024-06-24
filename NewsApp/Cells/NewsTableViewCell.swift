//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Aziza Gilash on 03.03.2024.
//

import UIKit
import SnapKit

protocol NewsTableViewCellDelegate: AnyObject {
    
    func actionButtonTapped(_ cell: UITableViewCell)
}

final class NewsTableViewCell: UITableViewCell {
    
    static let identifier = "NewTableViewCell"
    
    weak var delegate: NewsTableViewCellDelegate?
    
    // MARK: - UI
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .trailing
        return stackView
    }()
    
    private lazy var textsAndImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var textsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.numberOfLines = 2
        label.font = .preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var favoritesButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        textsStackView.addArrangedSubviews(titleLabel, subtitleLabel)
        textsAndImageStackView.addArrangedSubviews(textsStackView, newsImageView)
        stackView.addArrangedSubviews(textsAndImageStackView, favoritesButton)
        
        textsAndImageStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        newsImageView.snp.makeConstraints { make in
            make.size.equalTo(90)
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    @objc
    private func favoriteButtonTapped() {
        delegate?.actionButtonTapped(self)
    }
    
    // MARK: - Override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        newsImageView.image = nil
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: NewsTableViewCellViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        switch viewModel.cellType {
        case .news:
            favoritesButton.setTitle("Add to Favorites", for: .normal)
            favoritesButton.setTitleColor(.accentColor, for: .normal)
        case .favorites:
            favoritesButton.setTitle("Remove from Favorites", for: .normal)
            favoritesButton.setTitleColor(.systemRed, for: .normal)
        }
        
        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)
        } else if let url = viewModel.imageURL {
            // fetch
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}

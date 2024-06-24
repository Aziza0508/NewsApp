//
//  FavoritesViewController.swift
//  NewsApp
//
//  Created by Aziza Gilash on 05.03.2024.
//

import UIKit
import SafariServices

final class FavoritesViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return tableView
    }()
    
    private lazy var favoritesEmptyView = FavoritesEmptyView()
    
    private var cellViewModels = [NewsTableViewCellViewModel]()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupObserver()
        setupBackgroundView()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        navigationItem.title = "Favorites ⭐️"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeArticle),
            name: .articles,
            object: nil
        )
    }
    
    private func setupBackgroundView() {
        view.addSubview(favoritesEmptyView)
        favoritesEmptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc
    private func observeArticle(_ notification: Notification) {
        guard let article = notification.userInfo?["article"] as? Article else { return }
        let viewModel = NewsTableViewCellViewModel(
            title: article.title,
            subtitle: article.description,
            cellType: .favorites,
            imageURL: URL(string: article.urlToImage ?? ""),
            pageURL: article.url
        )
        guard !cellViewModels.contains(where: { $0.title == viewModel.title }) else {
            return
        }
        cellViewModels.insert(viewModel, at: 0)
        reloadTableView()
    }
    
    private func reloadTableView() {
        let range = NSMakeRange(0, tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        tableView.reloadSections(sections as IndexSet, with: .automatic)
        favoritesEmptyView.isHidden = !cellViewModels.isEmpty
        tableView.isHidden = cellViewModels.isEmpty
    }
}

// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = cellViewModels[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath
        ) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = cellViewModels[indexPath.row]
        guard let url = URL(string: viewModel.pageURL ?? "") else {
            return
        }
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .accentColor
        present(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        let addToFavorite = UIContextualAction(style: .destructive, title: "Remove from Favorites") { [weak self] _, _, completion in
            self?.actionButtonTapped(cell)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [addToFavorite])
    }
}

// MARK: - NewsTableViewCellDelegate

extension FavoritesViewController: NewsTableViewCellDelegate {
    
    func actionButtonTapped(_ cell: UITableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        cellViewModels.remove(at: index)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        reloadTableView()
    }
}

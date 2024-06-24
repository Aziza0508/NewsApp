//
//  MainViewController.swift
//  NewsApp
//
//  Created by Aziza Gilash on 03.03.2024.
//

import UIKit
import SafariServices

final class MainViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return tableView
    }()
    
    private lazy var searchViewController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        controller.searchBar.placeholder = "Search for a topic"
        return controller
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSMutableAttributedString(string: "Refreshing 🍆💦")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = .accentColor
        refreshControl.layoutIfNeeded()
        return refreshControl
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.color = .accentColor
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    private var timer: Timer?
    private var cellViewModels = [NewsTableViewCellViewModel]()
    private var articles = [Article]()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchController()
        setupRefreshControl()
        setupActivityIndicatorView()
        setupTimer()
        
        showActivityIndicatorView()
        // Для наглядности
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchInitialInfo(isSourceRefreshControl: false)
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private
    
    private func setupUI() {
        navigationItem.title = "News ☔️"
    }
    
    private func setupTableView() {
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupSearchController() {
        navigationItem.searchController = searchViewController
    }
    
    private func setupRefreshControl() {
        tableView.refreshControl = refreshControl
    }
    
    private func setupActivityIndicatorView() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            print("Fetching a data every 60 secs. Current date: \(Date())")
            self.fetchInitialInfo(isSourceRefreshControl: false)
        }
    }
    
    private func reloadTableView(isSourceRefreshControl: Bool) {
        let range = NSMakeRange(0, tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        tableView.reloadSections(sections as IndexSet, with: .automatic)
        refreshControl.endRefreshing()
        hideActivityIndicatorView()
        if isSourceRefreshControl {
            //            let generator = UINotificationFeedbackGenerator()
            //            generator.notificationOccurred(.success)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
    
    @objc
    private func refresh() {
        // Для наглядности
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.searchViewController.searchBar.text = ""
            self.fetchInitialInfo(isSourceRefreshControl: true)
        }
    }
    
    // MARK: - Activity Indicator
    
    private func showActivityIndicatorView() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    private func hideActivityIndicatorView() {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    
    // MARK: - Network
    
    private func fetchInitialInfo(isSourceRefreshControl: Bool) {
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.cellViewModels = articles.compactMap {
                    return NewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description,
                        cellType: .news,
                        imageURL: URL(string: $0.urlToImage ?? ""),
                        pageURL: $0.url
                    )
                }
                
                DispatchQueue.main.async {
                    self?.reloadTableView(isSourceRefreshControl: isSourceRefreshControl)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
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

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else {
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
        let addToFavorite = UIContextualAction(style: .normal, title: "Add to Favorites") { [weak self] _, _, completion in
            self?.actionButtonTapped(cell)
            completion(true)
        }
        addToFavorite.backgroundColor = .accentColor
        let configuration = UISwipeActionsConfiguration(actions: [addToFavorite])
        return configuration
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchInitialInfo(isSourceRefreshControl: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.isEmpty else { return }
        fetchInitialInfo(isSourceRefreshControl: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        
        APICaller.shared.search(with: text) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.cellViewModels = articles.compactMap {
                    return NewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description,
                        cellType: .news,
                        imageURL: URL(string: $0.urlToImage ?? ""), 
                        pageURL: $0.url
                    )
                }
                
                DispatchQueue.main.async {
                    self?.reloadTableView(isSourceRefreshControl: false)
                    self?.searchViewController.dismiss(animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - NewsTableViewCellDelegate

extension MainViewController: NewsTableViewCellDelegate {
    
    func actionButtonTapped(_ cell: UITableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        let article = articles[index]
        NotificationCenter.default.post(name: .articles, object: nil, userInfo: ["article": article])
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

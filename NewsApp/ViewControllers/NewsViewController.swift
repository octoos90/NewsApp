//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Octo Siswardhono on 13/11/24.
//

import UIKit

class NewsViewController: UIViewController {
    var coordinator: NewsCoordinatorProtocol?
    private var viewModel: NewsViewModel!
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    override func viewDidLoad() {
        view.backgroundColor = .white
        setupActivityIndicator()
        setupTableView()
        viewModel = NewsViewModel()
        viewModel.isLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.toggleLoading(isLoading)
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
        
        viewModel.bind = { [weak self] in
            DispatchQueue.main.async {
                self?.updateTableView()
            }
        }
        
        viewModel.startFetchNews()
    }
}

private extension NewsViewController {
    
    func setupActivityIndicator() {
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        // Center the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsTableViewCell")

        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)

        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateTableView() {
        tableView.reloadData()
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func toggleLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            tableView.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            tableView.isHidden = false
        }
    }
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        let newsData = viewModel.newsData[indexPath.row]
        cell.configureText(with: newsData)
        
        if let cachedImage = viewModel.cachedImage(for: newsData) {
            cell.configureImage(with: cachedImage)
        } else {
            viewModel.fetchImage(for: newsData) { image in
                DispatchQueue.main.async {
                    if let visibleCell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell {
                        visibleCell.configureImage(with: image)
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // Adjust the height as needed
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newsData = viewModel.newsData[indexPath.row]
        coordinator?.showNewsDetail(for: newsData)
        
    }
}

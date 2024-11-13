//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Octo Siswardhono on 13/11/24.
//

import UIKit

class NewsDetailViewController: UIViewController {
    private var viewModel: NewsDetailViewModel
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // UI Elements
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Headline"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let bodyTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    init(viewModel: NewsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupScrollView()
        setupLayout()
        bindViewModel()
    }
    
    private func bindViewModel() {
        // Bind data from the viewModel to the UI
        dateLabel.text = viewModel.news.publishedAt
        bodyTextLabel.text = viewModel.news.content
    
        viewModel.fetchImage(for: viewModel.news) { image in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    private func setupNavigationBar() {
        title = "Title"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    // Setup Layout
    private func setupLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(headlineLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bodyTextLabel)
        
        // Disable Autoresizing Mask
        [imageView, headlineLabel, dateLabel, bodyTextLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            headlineLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            bodyTextLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            bodyTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bodyTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}

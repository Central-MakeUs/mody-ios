//
//  FeedViewController.swift
//  Feed
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import FeedInterface

public final class FeedViewController: UIViewController {
    private weak var router: FeedRouter?

    public init(router: FeedRouter) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureLayout()
    }
}

private extension FeedViewController {
    func configureLayout() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Hello, FeedViewController~"
        label.textAlignment = .center

        let button = UIButton(type: .system)
        button.setTitle("Temp 으로 가기", for: .normal)
        button.addTarget(self, action: #selector(tempButtonTapped), for: .touchUpInside)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc
    func tempButtonTapped() {
        router?.route(from: .temp)
    }
}

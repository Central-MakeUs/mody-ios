//
//  FeedRecordSkeletonCell.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import UIKit
import DesignSystem
import SnapKit

final class FeedRecordSkeletonCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedRecordSkeletonCell"

    private let profileSkeletonView = UISkeletonView(width: 32, height: 32)
    private let nameSkeletonView = UISkeletonView(width: 92, height: 22)
    private let chipSkeletonView = UISkeletonView(width: 69, height: 28)
    private let cardSkeletonView = UISkeletonView(width: 1, height: 200)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            stopAnimating()
        } else {
            startAnimating()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        startAnimating()
    }
}

private extension FeedRecordSkeletonCell {
    func setupUI() {
        contentView.backgroundColor = .systemWhite
        [profileSkeletonView, nameSkeletonView, chipSkeletonView, cardSkeletonView].forEach {
            $0.layer.cornerRadius = 4
        }
        profileSkeletonView.layer.cornerRadius = 16
        cardSkeletonView.layer.cornerRadius = 16
    }

    func setupLayout() {
        contentView.addSubview(profileSkeletonView)
        contentView.addSubview(nameSkeletonView)
        contentView.addSubview(chipSkeletonView)
        contentView.addSubview(cardSkeletonView)

        profileSkeletonView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(32)
        }

        nameSkeletonView.snp.makeConstraints {
            $0.leading.equalTo(profileSkeletonView.snp.trailing).offset(8)
            $0.centerY.equalTo(profileSkeletonView)
        }

        chipSkeletonView.snp.makeConstraints {
            $0.leading.equalTo(nameSkeletonView.snp.trailing).offset(8)
            $0.centerY.equalTo(profileSkeletonView)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        cardSkeletonView.snp.makeConstraints {
            $0.top.equalTo(profileSkeletonView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(200)
        }
    }

    func startAnimating() {
        [profileSkeletonView, nameSkeletonView, chipSkeletonView, cardSkeletonView].forEach {
            $0.startAnimating()
        }
    }

    func stopAnimating() {
        [profileSkeletonView, nameSkeletonView, chipSkeletonView, cardSkeletonView].forEach {
            $0.stopAnimating()
        }
    }
}

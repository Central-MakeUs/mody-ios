//
//  FeedViewController+CollectionView.swift
//  Feed
//
//  Created by 김동준 on 7/22/26.
//

import UIKit

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        feedListViewState.isInitialLoading ? 3 : feedListViewState.records.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if feedListViewState.isInitialLoading {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeedRecordSkeletonCell.reuseIdentifier,
                for: indexPath
            )
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedRecordCardCell.reuseIdentifier,
            for: indexPath
        ) as? FeedRecordCardCell else {
            return UICollectionViewCell()
        }

        let viewState = feedListViewState.records[indexPath.item]
        cell.onMenuSelect = { [weak self] menu in
            self?.reactor?.action.onNext(
                .didTapRecordMenu(
                    menu,
                    recordId: viewState.recordId
                )
            )
        }
        cell.configure(
            viewState,
            imageLoader: imageLoader
        )
        return cell
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: FeedLoadingFooterView.reuseIdentifier,
            for: indexPath
        )
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == UICollectionView.elementKindSectionFooter,
              feedListViewState.hasNextPage else {
            return
        }

        reactor?.action.onNext(.didReachFeedListBottom)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: collectionView.bounds.width - 48,
            height: FeedRecordCardCell.contentHeight
        )
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard feedListViewState.hasNextPage else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 64)
    }
}

//
//  ChallengeBuilder.swift
//  Challenge
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import ChallengeInterface
import ComposableArchitecture
import CoreModyImageInterface
import SwiftUI

public struct ChallengeBuilder: ChallengeBuildable {
    private let makeChallengeFeature: (ChallengeRouter, ChallengeOutputHandler) -> ChallengeFeature
    private let makeChallengeChangeFeature: (ChallengeChangeRouter, ChallengeOutputHandler) -> ChallengeChangeFeature
    private let makeChallengeWeeklyDetailFeature: (ChallengeWeeklyDetailRouter) -> ChallengeWeeklyDetailFeature
    private let imageLoader: RemoteImageLoading

    public init(
        makeChallengeFeature: @escaping (ChallengeRouter, ChallengeOutputHandler) -> ChallengeFeature,
        makeChallengeChangeFeature: @escaping (ChallengeChangeRouter, ChallengeOutputHandler) -> ChallengeChangeFeature,
        makeChallengeWeeklyDetailFeature: @escaping (ChallengeWeeklyDetailRouter) -> ChallengeWeeklyDetailFeature,
        imageLoader: RemoteImageLoading
    ) {
        self.makeChallengeFeature = makeChallengeFeature
        self.makeChallengeChangeFeature = makeChallengeChangeFeature
        self.makeChallengeWeeklyDetailFeature = makeChallengeWeeklyDetailFeature
        self.imageLoader = imageLoader
    }

    @MainActor
    public func makeChallengeViewController(
        router: ChallengeRouter,
        outputHandler: ChallengeOutputHandler
    ) -> UIViewController {
        let store: StoreOf<ChallengeFeature> = .init(initialState: .init()) {
            makeChallengeFeature(router, outputHandler)
        }

        return ChallengeHostingController(
            store: store,
            imageLoader: imageLoader
        )
    }

    @MainActor
    public func makeChallengeChangeViewController(
        groupId: Int,
        router: ChallengeChangeRouter,
        outputHandler: ChallengeOutputHandler
    ) -> UIViewController {
        let store: StoreOf<ChallengeChangeFeature> = .init(
            initialState: .init(groupId: groupId)
        ) {
            makeChallengeChangeFeature(router, outputHandler)
        }

        return UIHostingController(rootView: ChallengeChangeView(store: store))
    }

    @MainActor
    public func makeChallengeWeeklyDetailViewController(
        groupId: Int,
        challengeId: Int,
        groupChallengeId: Int,
        router: ChallengeWeeklyDetailRouter
    ) -> UIViewController {
        let store: StoreOf<ChallengeWeeklyDetailFeature> = .init(
            initialState: .init(
                groupId: groupId,
                challengeId: challengeId,
                groupChallengeId: groupChallengeId
            )
        ) {
            makeChallengeWeeklyDetailFeature(router)
        }

        return UIHostingController(
            rootView: ChallengeWeeklyDetailView(store: store)
        )
    }
}

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
    private let makeChallengeChangeFeature: (ChallengeChangeRouter) -> ChallengeChangeFeature
    private let imageLoader: RemoteImageLoading

    public init(
        makeChallengeFeature: @escaping (ChallengeRouter, ChallengeOutputHandler) -> ChallengeFeature,
        makeChallengeChangeFeature: @escaping (ChallengeChangeRouter) -> ChallengeChangeFeature,
        imageLoader: RemoteImageLoading
    ) {
        self.makeChallengeFeature = makeChallengeFeature
        self.makeChallengeChangeFeature = makeChallengeChangeFeature
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
        router: ChallengeChangeRouter
    ) -> UIViewController {
        let store: StoreOf<ChallengeChangeFeature> = .init(
            initialState: .init(groupId: groupId)
        ) {
            makeChallengeChangeFeature(router)
        }

        return UIHostingController(rootView: ChallengeChangeView(store: store))
    }
}

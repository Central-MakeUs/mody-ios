//
//  FeedBuilder.swift
//  Feed
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import CoreCameraInterface
import FeedInterface

public struct FeedBuilder: FeedBuildable {
    private let makeFeedReactor: (FeedRouter) -> FeedReactor
    private let makeFeedRecordReactor: (FeedRecordRouter, FeedRecordType, FeedRecordOutputHandler) -> FeedRecordReactor
    private let cameraCaptureBuilder: CameraCaptureBuildable
    
    public init(
        makeFeedReactor: @escaping (FeedRouter) -> FeedReactor,
        makeFeedRecordReactor: @escaping (FeedRecordRouter, FeedRecordType, FeedRecordOutputHandler) -> FeedRecordReactor,
        cameraCaptureBuilder: CameraCaptureBuildable
    ) {
        self.makeFeedReactor = makeFeedReactor
        self.makeFeedRecordReactor = makeFeedRecordReactor
        self.cameraCaptureBuilder = cameraCaptureBuilder
    }

    @MainActor
    public func makeFeedViewController(router: FeedRouter) -> UIViewController {
        return FeedViewController(reactor: makeFeedReactor(router))
    }

    @MainActor
    public func makeFeedRecordViewController(
        router: FeedRecordRouter,
        recordType: FeedRecordType,
        outputHandler: FeedRecordOutputHandler
    ) -> UIViewController {
        return FeedRecordViewController(
            reactor: makeFeedRecordReactor(router, recordType, outputHandler),
            cameraCaptureBuilder: cameraCaptureBuilder
        )
    }
}

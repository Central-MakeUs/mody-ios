//
//  FeedBuilder.swift
//  Feed
//
//  Created by 김동준 on 6/30/26
//

import CoreModyImageInterface
import UIKit
import CoreCameraInterface
import FeedInterface

public struct FeedBuilder: FeedBuildable {
    private let makeFeedReactor: (FeedRouter, FeedOutputHandler) -> FeedReactor
    private let makeFeedRecordReactor: (FeedRecordRouter, FeedRecordType, FeedRecordOutputHandler) -> FeedRecordReactor
    private let cameraCaptureBuilder: CameraCaptureBuildable
    private let imageLoader: RemoteImageLoading
    
    public init(
        makeFeedReactor: @escaping (FeedRouter, FeedOutputHandler) -> FeedReactor,
        makeFeedRecordReactor: @escaping (FeedRecordRouter, FeedRecordType, FeedRecordOutputHandler) -> FeedRecordReactor,
        cameraCaptureBuilder: CameraCaptureBuildable,
        imageLoader: RemoteImageLoading
    ) {
        self.makeFeedReactor = makeFeedReactor
        self.makeFeedRecordReactor = makeFeedRecordReactor
        self.cameraCaptureBuilder = cameraCaptureBuilder
        self.imageLoader = imageLoader
    }

    @MainActor
    public func makeFeedViewController(
        router: FeedRouter,
        outputHandler: FeedOutputHandler
    ) -> UIViewController {
        return FeedViewController(
            reactor: makeFeedReactor(router, outputHandler),
            imageLoader: imageLoader
        )
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

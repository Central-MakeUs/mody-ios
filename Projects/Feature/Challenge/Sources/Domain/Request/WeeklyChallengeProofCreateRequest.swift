//
//  WeeklyChallengeProofCreateRequest.swift
//  Challenge
//
//  Created by 김동준 on 8/14/26.
//

public struct WeeklyChallengeProofCreateRequest: Equatable {
    public let imageKey: String
    public let imageCropRegion: WeeklyChallengeProofImageCropRegionRequest

    public init(
        imageKey: String,
        imageCropRegion: WeeklyChallengeProofImageCropRegionRequest
    ) {
        self.imageKey = imageKey
        self.imageCropRegion = imageCropRegion
    }
}

public struct WeeklyChallengeProofImageCropRegionRequest: Equatable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

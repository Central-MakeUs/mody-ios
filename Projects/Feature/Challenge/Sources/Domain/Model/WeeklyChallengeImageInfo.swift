//
//  WeeklyChallengeImageInfo.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

public struct WeeklyChallengeImageInfo: Equatable {
    public let proofId: Int
    public let imageUrl: String
    public let imageCropRegion: WeeklyChallengeImageCropRegion?
    public let memberId: Int
    public let nickname: String
    public let profileImageUrl: String?

    public init(
        proofId: Int,
        imageUrl: String,
        imageCropRegion: WeeklyChallengeImageCropRegion?,
        memberId: Int,
        nickname: String,
        profileImageUrl: String?
    ) {
        self.proofId = proofId
        self.imageUrl = imageUrl
        self.imageCropRegion = imageCropRegion
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
    }
}

public struct WeeklyChallengeImageCropRegion: Equatable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

//
//  WeeklyChallengeShareResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/15/26.
//

struct WeeklyChallengeShareResponse: Decodable, Equatable {
    private let imageUrl: String?
    private let imageCropRegion: WeeklyChallengeShareImageCropRegionResponse?
    private let rows: Int?
    private let columns: Int?

    func toDomain() -> WeeklyChallengeShare {
        WeeklyChallengeShare(imageUrl: imageUrl ?? "")
    }
}

private struct WeeklyChallengeShareImageCropRegionResponse: Decodable, Equatable {
    private let x: Double?
    private let y: Double?
    private let width: Double?
    private let height: Double?
}

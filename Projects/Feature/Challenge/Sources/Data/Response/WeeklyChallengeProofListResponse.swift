//
//  WeeklyChallengeProofListResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

struct WeeklyChallengeProofListResponse: Decodable, Equatable {
    private let proofs: [WeeklyChallengeProofResponse]?

    func toDomain() -> [WeeklyChallengeImageInfo] {
        (proofs ?? []).map { $0.toDomain() }
    }
}

private struct WeeklyChallengeProofResponse: Decodable, Equatable {
    private let proofId: Int?
    private let imageUrl: String?
    private let imageCropRegion: WeeklyChallengeImageCropRegionResponse?
    private let memberId: Int?
    private let nickname: String?
    private let profileImageUrl: String?

    func toDomain() -> WeeklyChallengeImageInfo {
        WeeklyChallengeImageInfo(
            proofId: proofId ?? -1,
            imageUrl: imageUrl ?? "",
            imageCropRegion: imageCropRegion?.toDomain(),
            memberId: memberId ?? -1,
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl
        )
    }
}

private struct WeeklyChallengeImageCropRegionResponse: Decodable, Equatable {
    private let x: Double?
    private let y: Double?
    private let width: Double?
    private let height: Double?

    func toDomain() -> WeeklyChallengeImageCropRegion? {
        guard let x, let y, let width, let height else { return nil }

        return WeeklyChallengeImageCropRegion(
            x: x,
            y: y,
            width: width,
            height: height
        )
    }
}

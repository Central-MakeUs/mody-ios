//
//  FeedPresignedUrlResponse.swift
//  Feed
//
//  Created by 김동준 on 7/22/26.
//

struct FeedPresignedUrlResponse: Decodable, Equatable {
    let presignedUrl: String?
    let imageKey: String?
    let expiresInSeconds: Int?
}

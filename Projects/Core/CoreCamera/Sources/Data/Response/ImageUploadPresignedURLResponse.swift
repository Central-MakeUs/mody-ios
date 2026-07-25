//
//  ImageUploadPresignedURLResponse.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

struct ImageUploadPresignedURLResponse: Decodable, Equatable {
    let presignedUrl: String?
    let imageKey: String?
    let expiresInSeconds: Int?
}

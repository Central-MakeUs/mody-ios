//
//  PresignedImageUpload.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

import Foundation

public struct PresignedImageUpload: Equatable {
    public let url: URL
    public let imageKey: String

    public init(url: URL, imageKey: String) {
        self.url = url
        self.imageKey = imageKey
    }
}

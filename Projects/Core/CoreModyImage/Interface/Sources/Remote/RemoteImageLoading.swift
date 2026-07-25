//
//  RemoteImageLoading.swift
//  CoreModyImageInterface
//
//  Created by 김동준 on 7/25/26.
//

import UIKit

public protocol RemoteImageLoading: AnyObject, Sendable {
    func cachedImage(for request: RemoteImageRequest) -> UIImage?
    func loadImage(with request: RemoteImageRequest) async throws -> UIImage
}

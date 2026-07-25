//
//  ImageUploadEndpoint.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

import CoreCameraInterface
import CoreNetworkInterface

enum ImageUploadEndpoint {
    static func postPresignedURL(
        domain: ImageUploadDomain,
        fileName: String
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/uploads/presigned-url",
            method: .POST,
            queryParameters: [
                "domain": domain.rawValue,
                "fileName": fileName
            ]
        )
    }
}

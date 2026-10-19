//  CameraItemProviderSpy.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import Foundation

final class CameraItemProviderSpy: NSItemProvider, @unchecked Sendable {
    private let identifiers: [String]
    private(set) var requestedTypes: [String] = []
    private var completion: ((URL?, Error?) -> Void)?
    let progress = Progress(totalUnitCount: 1)

    init(identifiers: [String] = ["public.jpeg"]) {
        self.identifiers = identifiers
        super.init()
    }

    override var registeredTypeIdentifiers: [String] { identifiers }

    override func loadFileRepresentation(
        forTypeIdentifier typeIdentifier: String, completionHandler: @escaping (URL?, Error?) -> Void
    ) -> Progress {
        requestedTypes.append(typeIdentifier)
        completion = completionHandler
        return progress
    }

    func complete(url: URL?, error: Error? = nil) {
        completion?(url, error)
        completion = nil
    }
}

//
//  ImageDataLoaderSpy.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import Foundation
import Nuke

final class ImageDataLoaderSpy: DataLoading, @unchecked Sendable {
    private let result: Result<Data, Error>?
    private let onStart: @Sendable () -> Void
    private let onCancel: @Sendable () -> Void
    private let lock = NSLock()
    private var recordedURLs: [URL] = []
    var requestedURLs: [URL] { lock.withLock { recordedURLs } }

    init(
        result: Result<Data, Error>?,
        onStart: @escaping @Sendable () -> Void = {},
        onCancel: @escaping @Sendable () -> Void = {}
    ) {
        self.result = result
        self.onStart = onStart
        self.onCancel = onCancel
    }

    func loadData(
        with request: URLRequest,
        didReceiveData: @escaping @Sendable (Data, URLResponse) -> Void,
        completion: @escaping @Sendable (Error?) -> Void
    ) -> any Cancellable {
        let url = request.url!
        lock.withLock { recordedURLs.append(url) }
        onStart()
        if let result {
            switch result {
            case .success(let data):
                didReceiveData(data, URLResponse(url: url, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil))
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
        return ImageDataTaskSpy(onCancel: onCancel)
    }
}

private struct ImageDataTaskSpy: Cancellable {
    private let onCancel: @Sendable () -> Void

    init(onCancel: @escaping @Sendable () -> Void) { self.onCancel = onCancel }

    func cancel() { onCancel() }
}

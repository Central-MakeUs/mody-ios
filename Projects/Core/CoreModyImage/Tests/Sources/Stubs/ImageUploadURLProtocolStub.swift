//
//  ImageUploadURLProtocolStub.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import Foundation

/// 주입한 ephemeral Session에서 테스트 전용 host의 요청만 가로챕니다.
final class ImageUploadURLProtocolStub: URLProtocol, @unchecked Sendable {
    static let host = "coremodyimage-upload.invalid"
    private static let lock = NSLock()
    private static var recordedRequests: [URLRequest] = []
    static var requests: [URLRequest] { lock.withLock { recordedRequests } }
    static func reset() { lock.withLock { recordedRequests.removeAll() } }

    override class func canInit(with request: URLRequest) -> Bool { request.url?.host == host }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lock.withLock { Self.recordedRequests.append(request) }
        let url = request.url!
        if url.pathComponents.contains("error"), let code = Int(url.lastPathComponent) {
            client?.urlProtocol(self, didFailWithError: URLError(URLError.Code(rawValue: code)))
            return
        }
        let status = Int(url.lastPathComponent) ?? 204
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

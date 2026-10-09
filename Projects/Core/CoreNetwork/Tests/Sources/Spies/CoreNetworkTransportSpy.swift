//  CoreNetworkTransportSpy.swift
//  CoreNetworkTests
//
//  Created by 김동준 on 10/9/26.
//

import Alamofire
import Foundation

final class CoreNetworkTransportSpy {
    let baseURL = URL(string: "https://\(UUID().uuidString).test")!
    let session: Session
    private let lock = NSLock()
    private var recordedRequests: [URLRequest] = []

    var requests: [URLRequest] {
        lock.lock()
        defer { lock.unlock() }
        return recordedRequests
    }

    init(handler: @escaping (URLRequest, Int) throws -> (Int, Data)) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CoreNetworkURLProtocolStub.self]
        session = Session(configuration: configuration)
        CoreNetworkURLProtocolStub.register(host: baseURL.host!) { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            lock.lock()
            recordedRequests.append(request)
            let count = recordedRequests.count
            lock.unlock()
            return try handler(request, count)
        }
    }

    convenience init(status: Int = 200, json: String = "{}") {
        self.init { _, _ in (status, Data(json.utf8)) }
    }

    deinit { CoreNetworkURLProtocolStub.unregister(host: baseURL.host!) }

    static func body(of request: URLRequest) -> Data {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return Data() }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count <= 0 { break }
            data.append(contentsOf: buffer.prefix(count))
        }
        return data
    }
}

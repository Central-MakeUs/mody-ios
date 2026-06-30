//
//  CoreNetworkRequest.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation
import CoreNetworkInterface

struct CoreNetworkRequest: URLRequestConvertible {
    let baseURL: URL
    let endpoint: CoreNetworkEndpoint
    let defaultHeaders: [String: String]

    init(
        baseURL: URL,
        endpoint: CoreNetworkEndpoint,
        defaultHeaders: [String: String]
    ) {
        self.baseURL = baseURL
        self.endpoint = endpoint
        self.defaultHeaders = defaultHeaders
    }

    func asURLRequest() throws -> URLRequest {
        let request = try URLRequest(
            url: makeURL(),
            method: HTTPMethod(rawValue: endpoint.method.rawValue),
            headers: makeHeaders()
        )

        guard !endpoint.bodyParameters.isEmpty else {
            return request
        }

        return try JSONEncoding.default.encode(
            request,
            with: endpoint.bodyParameters
        )
    }
}

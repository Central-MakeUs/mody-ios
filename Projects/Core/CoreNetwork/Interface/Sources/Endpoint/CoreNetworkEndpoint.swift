//
//  CoreNetworkEndpoint.swift
//  CoreNetworkInterface
//
//  Created by 김동준 on 6/30/26
//

public struct CoreNetworkEndpoint: Equatable, Sendable {
    public let path: String
    public let method: HttpMethod
    public let headers: [String: String]
    public let queryParameters: [String: String]
    public let bodyParameters: [String: String]
    public let requiresAuthorization: Bool

    public init(
        path: String,
        method: HttpMethod = .GET,
        headers: [String: String] = [:],
        queryParameters: [String: String] = [:],
        bodyParameters: [String: String] = [:],
        requiresAuthorization: Bool = true
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
        self.requiresAuthorization = requiresAuthorization
    }
}

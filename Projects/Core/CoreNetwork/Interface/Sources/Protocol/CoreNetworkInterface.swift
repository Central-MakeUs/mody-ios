//
//  CoreNetworkInterface.swift
//  CoreNetworkInterface
//
//  Created by 김동준 on 6/30/26
//

public protocol CoreNetworkProtocol {
    func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response
}

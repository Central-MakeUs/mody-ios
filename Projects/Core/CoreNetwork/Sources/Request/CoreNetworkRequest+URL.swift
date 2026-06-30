//
//  CoreNetworkRequest+URL.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Foundation

extension CoreNetworkRequest {
    func makeURL() throws -> URL {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw CoreNetworkClientError.invalidURL
        }
        
        if !endpoint.queryParameters.isEmpty {
            components.queryItems = endpoint.queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = components.url else { throw CoreNetworkClientError.invalidURL }
        
        return url
    }
}

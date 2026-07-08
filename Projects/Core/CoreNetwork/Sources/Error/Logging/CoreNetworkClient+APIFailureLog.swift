//
//  CoreNetworkClient+APIFailureLog.swift
//  CoreNetwork
//
//  Created by 김동준 on 7/3/26
//

import CommonDomain
import CoreNetworkInterface
import Foundation

extension CoreNetworkClient {
    func apiFailureLog(
        endpoint: CoreNetworkEndpoint,
        coreNetworkClientError: CoreNetworkClientError,
        networkError: NetworkError
    ) -> String {
        """
        Request:
          method: \(endpoint.method.rawValue)
          path: \(endpoint.path)
          requiresAuthorization: \(endpoint.requiresAuthorization)
          headers:
        \(indented(jsonString(headers(endpoint: endpoint)), depth: 2))
          queryParameters:
        \(indented(jsonString(endpoint.queryParameters), depth: 2))
          bodyParameters:
        \(indented(jsonString(endpoint.bodyParameters), depth: 2))
        Result:
          coreNetworkClientError: \(coreNetworkClientError)
          networkError: \(networkError)
        """
    }
}

private extension CoreNetworkClient {
    func headers(endpoint: CoreNetworkEndpoint) -> [String: String] {
        var headers = defaultHeaders
        endpoint.headers.forEach {
            headers[$0.key] = $0.value
        }

        if headers["Accept-Charset"] == nil {
            headers["Accept-Charset"] = "UTF-8"
        }

        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }

        return headers
    }

    func jsonString(_ body: Encodable?) -> String {
        guard
            let body,
            let encodedData = try? JSONEncoder().encode(body),
            let jsonObject = try? JSONSerialization.jsonObject(with: encodedData),
            JSONSerialization.isValidJSONObject(jsonObject),
            let data = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }

        return jsonString
    }

    func indented(_ text: String, depth: Int) -> String {
        let prefix = String(repeating: "  ", count: depth)

        return text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(prefix)\($0)" }
            .joined(separator: "\n")
    }
}

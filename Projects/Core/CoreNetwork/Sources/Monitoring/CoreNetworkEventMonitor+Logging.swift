//
//  CoreNetworkEventMonitor+Logging.swift
//  CoreNetwork
//
//  Created by 김동준 on 7/2/26
//

import Alamofire
import Foundation

extension CoreNetworkEventMonitor {
    func logRequest(_ request: URLRequest) {
        print(
            """
            
            ┌────────────────────────────────────────
            │ [CoreNetwork] Request
            ├────────────────────────────────────────
            │ Method: \(request.httpMethod ?? "-")
            │ URL: \(maskedURL(request.url))
            │ Headers:
            \(indented(prettyHeaders(request.allHTTPHeaderFields), prefix: "│   "))
            │ Body:
            \(indented(prettyJSON(request.httpBody), prefix: "│   "))
            └────────────────────────────────────────
            """
        )
    }

    func logResponse<Value>(_ response: DataResponse<Value, AFError>) {
        print(
            """
            
            ┌────────────────────────────────────────
            │ [CoreNetwork] Response
            ├────────────────────────────────────────
            │ URL: \(maskedURL(response.request?.url))
            │ Status: \(response.response?.statusCode ?? -1)
            │ Body:
            \(indented(prettyJSON(response.data), prefix: "│   "))
            └────────────────────────────────────────
            """
        )
    }
}

private extension CoreNetworkEventMonitor {
    func maskedURL(_ url: URL?) -> String {
        guard
            let url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return "-"
        }

        components.queryItems = components.queryItems?.map {
            guard shouldMask(key: $0.name) else { return $0 }
            return URLQueryItem(name: $0.name, value: "***")
        }

        return components.url?.absoluteString ?? url.absoluteString
    }

    func maskedHeaders(_ headers: [String: String]?) -> [String: String] {
        guard var headers else { return [:] }

        if headers["Authorization"] != nil {
            headers["Authorization"] = "Bearer ***"
        }

        return headers
    }

    func prettyHeaders(_ headers: [String: String]?) -> String {
        let headers = maskedHeaders(headers)
        guard !headers.isEmpty else { return "-" }

        return headers
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }

    func prettyJSON(_ data: Data?) -> String {
        guard let data, !data.isEmpty else { return "-" }

        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let maskedObject = maskedJSONValue(object),
            JSONSerialization.isValidJSONObject(maskedObject),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: maskedObject,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8) ?? "-"
        }

        return prettyString
    }

    func maskedJSONValue(_ value: Any, key: String? = nil) -> Any? {
        if let key, shouldMask(key: key) {
            return "***"
        }

        if let object = value as? [String: Any] {
            return object.reduce(into: [String: Any]()) { result, element in
                result[element.key] = maskedJSONValue(element.value, key: element.key)
            }
        }

        if let array = value as? [Any] {
            return array.compactMap { maskedJSONValue($0) }
        }

        return value
    }

    func shouldMask(key: String) -> Bool {
        let lowercasedKey = key.lowercased()
        return lowercasedKey.contains("token")
            || lowercasedKey.contains("authorization")
    }

    func indented(_ text: String, prefix: String) -> String {
        text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(prefix)\($0)" }
            .joined(separator: "\n")
    }
}

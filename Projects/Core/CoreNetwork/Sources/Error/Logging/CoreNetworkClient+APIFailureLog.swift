//
//  CoreNetworkClient+APIFailureLog.swift
//  CoreNetwork
//
//  Created by 김동준 on 7/3/26
//

import CommonDomain
import CoreAnalyticsInterface
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

    func apiFailureEvent(
        endpoint: CoreNetworkEndpoint,
        networkError: NetworkError
    ) -> AmplitudeLogEvent {
        var properties: [String: Any] = [
            "http_method": endpoint.method.rawValue,
            "endpoint": analyticsEndpoint(endpoint.path),
        ]
        
        properties["network_error"] = String(describing: networkError)
        properties["query_parameters"] = compactJSONString(endpoint.queryParameters.keys.sorted())
        properties["request_body"] = compactJSONString(
            jsonKeyPaths(jsonObject(endpoint.bodyParameters))
        )

        return AmplitudeLogEvent(
            name: "api_error",
            properties: properties
        )
    }
}

private extension CoreNetworkClient {
    func headers(endpoint: CoreNetworkEndpoint) -> [String: String] {
        var headers = defaultHeaders
        endpoint.headers.forEach {
            headers[$0.key] = $0.value
        }

        return headers
    }

    func jsonString(_ body: Encodable?) -> String {
        let jsonObject = maskedJSONValue(jsonObject(body))

        guard
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

    func jsonObject(_ body: Encodable?) -> Any {
        guard
            let body,
            let encodedData = try? JSONEncoder().encode(body),
            let jsonObject = try? JSONSerialization.jsonObject(with: encodedData)
        else {
            return [String: Any]()
        }

        return jsonObject
    }

    func compactJSONString(_ value: Any) -> String {
        let maskedValue = maskedJSONValue(value)

        guard
            JSONSerialization.isValidJSONObject(maskedValue),
            let data = try? JSONSerialization.data(
                withJSONObject: maskedValue,
                options: [.sortedKeys]
            ),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }

        return jsonString
    }

    func analyticsEndpoint(_ path: String) -> String {
        return path
            .split(separator: "/", omittingEmptySubsequences: false)
            .map { component in
                isIdentifierPathComponent(String(component)) ? ":id" : String(component)
            }
            .joined(separator: "/")
    }

    func isIdentifierPathComponent(_ component: String) -> Bool {
        !component.isEmpty && (
            component.allSatisfy(\.isNumber)
                || UUID(uuidString: component) != nil
        )
    }

    func jsonKeyPaths(_ value: Any, prefix: String? = nil) -> [String] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix.map { "\($0).\(key)" } ?? key
                guard let child = object[key] else { return [path] }

                let nestedPaths = jsonKeyPaths(child, prefix: path)

                return nestedPaths.isEmpty ? [path] : nestedPaths
            }
        }

        if let array = value as? [Any] {
            guard let prefix else { return [] }

            let arrayPath = "\(prefix)[]"
            let nestedPaths = array.flatMap { jsonKeyPaths($0, prefix: arrayPath) }

            return nestedPaths.isEmpty ? [arrayPath] : Array(Set(nestedPaths)).sorted()
        }

        return prefix.map { [$0] } ?? []
    }

    func maskedJSONValue(_ value: Any, key: String? = nil) -> Any {
        if let key, shouldMask(key: key) {
            return "***"
        }

        if let object = value as? [String: Any] {
            return object.reduce(into: [String: Any]()) { result, element in
                result[element.key] = maskedJSONValue(element.value, key: element.key)
            }
        }

        if let array = value as? [Any] {
            return array.map { maskedJSONValue($0) }
        }

        return value
    }

    func shouldMask(key: String) -> Bool {
        let normalizedKey = key
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }

        return Self.sensitiveKeyFragments.contains {
            normalizedKey.contains($0)
        }
    }

    func indented(_ text: String, depth: Int) -> String {
        let prefix = String(repeating: "  ", count: depth)

        return text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(prefix)\($0)" }
            .joined(separator: "\n")
    }

    static var sensitiveKeyFragments: [String] {
        [
            "token", "authorization", "password", "secret", "credential", "cookie", "apikey",
            "memberid", "userid", "deviceid", "sessionid", "identifier", "idfv", "idfa", "fcm",
            "email", "phone", "name", "nickname", "birth", "gender", "sex", "age", "address",
            "account", "profile", "resident", "passport", "code", "pin",
            "weight", "height", "step", "health", "medical", "disease", "symptom",
            "blood", "heart", "sleep", "calorie", "exercise", "workout", "meal", "food", "menu",
            "latitude", "longitude", "location",
            "photo", "image", "video", "file", "url",
            "message", "memo", "content", "description", "proof", "date", "time"
        ]
    }
}

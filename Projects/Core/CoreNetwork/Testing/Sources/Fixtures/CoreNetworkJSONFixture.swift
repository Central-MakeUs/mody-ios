//  CoreNetworkJSONFixture.swift
//  CoreNetworkTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface
import Foundation

public enum CoreNetworkJSONFixture {
    public static func response(result: Any = NSNull()) throws -> Data {
        try JSONSerialization.data(withJSONObject: ["isSuccess": true, "result": result])
    }

    public static func body(of endpoint: CoreNetworkEndpoint) throws -> [String: Any] {
        guard let body = endpoint.bodyParameters else { return [:] }
        let data = try JSONEncoder().encode(body)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotDecodeContentData)
        }
        return object
    }
}

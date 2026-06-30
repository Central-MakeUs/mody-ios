//
//  CoreNetworkEventMonitor.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation

final class CoreNetworkEventMonitor: EventMonitor {
    let queue = DispatchQueue(label: "CoreNetworkEventMonitor")

    func requestDidResume(_ request: Request) {
        guard let urlRequest = request.request else { return }

        print(
            """
            [CoreNetwork] Request
            - method: \(urlRequest.httpMethod ?? "-")
            - url: \(urlRequest.url?.absoluteString ?? "-")
            - headers: \(maskedHeaders(urlRequest.allHTTPHeaderFields))
            """
        )
    }

    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        print(
            """
            [CoreNetwork] Response
            - url: \(response.request?.url?.absoluteString ?? "-")
            - statusCode: \(response.response?.statusCode ?? -1)
            - result: \(response.result)
            """
        )
    }
}

private extension CoreNetworkEventMonitor {
    func maskedHeaders(_ headers: [String: String]?) -> [String: String] {
        guard var headers else { return [:] }

        if headers["Authorization"] != nil {
            headers["Authorization"] = "Bearer ***"
        }

        return headers
    }
}

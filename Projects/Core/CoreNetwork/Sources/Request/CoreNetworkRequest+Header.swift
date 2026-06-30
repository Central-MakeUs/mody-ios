//
//  CoreNetworkRequest+Header.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation

extension CoreNetworkRequest {
    func makeHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders()

        defaultHeaders.forEach {
            headers.update(name: $0.key, value: $0.value)
        }

        endpoint.headers.forEach {
            headers.update(name: $0.key, value: $0.value)
        }

        if headers["Accept-Charset"] == nil {
            headers.update(name: "Accept-Charset", value: "UTF-8")
        }

        if headers["Content-Type"] == nil {
            headers.update(name: "Content-Type", value: "application/json; charset=utf-8")
        }

        return headers
    }
}

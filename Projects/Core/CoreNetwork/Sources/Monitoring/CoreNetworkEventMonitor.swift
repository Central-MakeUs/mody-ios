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

    func request(_ request: Request, didResumeTask task: URLSessionTask) {
        guard let urlRequest = task.currentRequest else { return }

        logRequest(urlRequest, bodyFallback: request.request?.httpBody)
    }

    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        logResponse(response)
    }
}

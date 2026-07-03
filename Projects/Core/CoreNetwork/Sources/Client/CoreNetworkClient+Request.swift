//
//  CoreNetworkClient+Request.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation
import CoreNetworkInterface

extension CoreNetworkClient {
    func call<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        try await execute(endpoint: endpoint) {
            let response = await session
                .request(
                    CoreNetworkRequest(
                        baseURL: baseURL,
                        endpoint: endpoint,
                        defaultHeaders: defaultHeaders
                    ),
                    interceptor: endpoint.requiresAuthorization ? requestInterceptor : nil
                )
                .validate(statusCode: 200..<300)
                .serializingDecodable(
                    Response.self,
                    decoder: decoder,
                    emptyResponseCodes: [200]
                )
                .response

            switch response.result {
            case .success(let value):
                return value
            case .failure(let error):
                throw decodeServerError(from: response) ?? error.asCoreNetworkError()
            }
        }
    }
}

private extension CoreNetworkClient {
    func decodeServerError<Response>(
        from response: DataResponse<Response, AFError>
    ) -> CoreNetworkClientError? {
        guard
            let data = response.data,
            let statusCode = response.response?.statusCode,
            let errorResponse = try? decoder.decode(
                CoreNetworkResponse<CoreNetworkEmptyResponse>.self,
                from: data
            )
        else { return nil }

        return .serverError(
            statusCode: statusCode,
            code: errorResponse.code,
            message: errorResponse.message
        )
    }
}

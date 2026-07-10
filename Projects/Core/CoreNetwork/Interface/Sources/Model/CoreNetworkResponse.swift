//
//  CoreNetworkResponse.swift
//  CoreNetworkInterface
//
//  Created by 김동준 on 6/30/26
//

public struct CoreNetworkResponse<Result: Decodable>: Decodable {
    public let isSuccess: Bool?
    public let code: String?
    public let message: String?
    public let result: Result?

    public init(
        isSuccess: Bool? = nil,
        code: String? = nil,
        message: String? = nil,
        result: Result? = nil
    ) {
        self.isSuccess = isSuccess
        self.code = code
        self.message = message
        self.result = result
    }
}

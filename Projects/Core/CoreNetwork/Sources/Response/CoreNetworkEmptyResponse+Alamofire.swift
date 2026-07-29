//
//  CoreNetworkEmptyResponse+Alamofire.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import CoreNetworkInterface

extension CoreNetworkEmptyResponse: @retroactive EmptyResponse {
    public static func emptyValue() -> CoreNetworkEmptyResponse {
        CoreNetworkEmptyResponse()
    }
}

//
//  CoreNetworkBaseURLProvider.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Foundation

enum CoreNetworkBaseURLProvider {
    static var current: URL {
        guard
            let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
            !baseURLString.isEmpty,
            let baseURL = URL(string: baseURLString)
        else {
            fatalError("CoreNetworkBaseURL is missing or invalid in Info.plist.")
        }

        return baseURL
    }
}

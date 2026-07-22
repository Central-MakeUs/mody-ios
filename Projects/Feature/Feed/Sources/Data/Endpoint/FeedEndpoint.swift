//
//  FeedEndpoint.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import CoreNetworkInterface

enum FeedEndpoint {
    static func postPresignedUrl(
        domain: String,
        fileName: String
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/uploads/presigned-url",
            method: .POST,
            queryParameters: [
                "domain": domain,
                "fileName": fileName
            ]
        )
    }

    static func postRecord(_ body: FeedRecordCreateBody) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/records",
            method: .POST,
            bodyParameters: body
        )
    }

    static func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) -> CoreNetworkEndpoint {
        var queryParameters = [
            "date": date,
            "size": String(size)
        ]

        if let cursor {
            queryParameters["cursor"] = String(cursor)
        }

        return CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/records",
            method: .GET,
            queryParameters: queryParameters
        )
    }
}

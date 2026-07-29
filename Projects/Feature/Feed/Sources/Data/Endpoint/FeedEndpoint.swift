//
//  FeedEndpoint.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import CoreNetworkInterface

enum FeedEndpoint {
    static func getActivityCalendar(
        groupId: Int,
        baseDate: String
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/activities/calendar",
            queryParameters: ["baseDate": baseDate]
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

    static func postRecord(_ body: FeedRecordCreateBody) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/records",
            method: .POST,
            bodyParameters: body
        )
    }

    static func postRecordReport(
        groupId: Int,
        recordId: Int
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/records/\(recordId)/report",
            method: .POST
        )
    }
}

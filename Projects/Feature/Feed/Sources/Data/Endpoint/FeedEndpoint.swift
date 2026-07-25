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
}

//
//  NotificationUnReadExistsResponse.swift
//  CoreNotification
//
//  Created by 김동준 on 7/23/26.
//

struct NotificationUnReadExistsResponse: Decodable {
    let hasUnread: Bool?
}

extension NotificationUnReadExistsResponse {
    func toDomain() -> Bool {
        hasUnread ?? false
    }
}

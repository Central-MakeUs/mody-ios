//
//  AmplitudeLogEvent.swift
//  CoreAnalyticsInterface
//
//  Created by 김동준 on 8/17/26.
//

public struct AmplitudeLogEvent {
    public let name: String
    public let properties: [String: Any]

    public init(
        name: String,
        properties: [String: Any] = [:]
    ) {
        self.name = name
        self.properties = properties
    }
}

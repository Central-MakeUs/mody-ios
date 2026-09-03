//
//  FeedAnalyticsEvent.swift
//  Feed
//
//  Created by 김동준 on 9/3/26.
//

import CoreAnalyticsInterface
import FeedInterface

enum FeedAnalyticsEvent {
    static func recordPhotoSourceSelected(
        recordType: FeedRecordType,
        source: String
    ) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "record_photo_source_selected",
            properties: [
                "record_type": recordType.analyticsValue,
                "source": source
            ]
        )
    }

    static func recordCreated(recordType: FeedRecordType) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "record_created",
            properties: ["record_type": recordType.analyticsValue]
        )
    }

    static func calendarNavigated(direction: String) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "feed_calendar_navigated",
            properties: ["direction": direction]
        )
    }

    static func calendarDateSelected(date: String) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "feed_calendar_date_selected",
            properties: ["date": date]
        )
    }
}

private extension FeedRecordType {
    var analyticsValue: String {
        switch self {
        case .meal: "meal"
        case .exercise: "exercise"
        }
    }
}

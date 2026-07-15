//
//  FeedRecordType.swift
//  FeedInterface
//
//  Created by 김동준 on 7/12/26.
//

public enum FeedRecordType: Equatable {
    case exercise
    case meal

    public var title: String {
        switch self {
        case .exercise:
            "운동 기록"
        case .meal:
            "식사 기록"
        }
    }
}

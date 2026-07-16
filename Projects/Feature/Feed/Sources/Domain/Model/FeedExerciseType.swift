//
//  FeedExerciseType.swift
//  Feed
//
//  Created by 김동준 on 7/15/26.
//

public enum FeedExerciseType: CaseIterable, Equatable {
    case fitness
    case running
    case pilates
    case swimming
    case yoga
    case custom

    public var name: String {
        switch self {
        case .fitness:
            "헬스"
        case .running:
            "러닝"
        case .pilates:
            "필라테스"
        case .swimming:
            "수영"
        case .yoga:
            "요가"
        case .custom:
            "직접 입력"
        }
    }
}

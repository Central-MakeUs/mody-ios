//
//  MealScheduleRequest.swift
//  CommonDomain
//
//  Created by 김동준 on 7/19/26.
//

public struct MealScheduleRequest: Equatable, Codable {
    public let mealType: MealType
    public let time: String?
    public let skipped: Bool

    public init(
        mealType: MealType,
        time: String?,
        skipped: Bool
    ) {
        self.mealType = mealType
        self.time = time
        self.skipped = skipped
    }

    enum CodingKeys: String, CodingKey {
        case mealType
        case time
        case skipped
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(mealType, forKey: .mealType)
        try container.encode(skipped, forKey: .skipped)

        if let time {
            try container.encode(time, forKey: .time)
        } else {
            try container.encodeNil(forKey: .time)
        }
    }
}

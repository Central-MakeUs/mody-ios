//
//  FeedDateFixture.swift
//  FeedTesting
//
//  Created by 김동준 on 10/5/26.
//

import Foundation

public enum FeedDateFixture {
    public static func today() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

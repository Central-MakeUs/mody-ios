//
//  String+Formatting.swift
//  Util
//
//  Created by 김동준 on 7/10/26
//

import Foundation

public extension String {
    static func toHourMinString(
        hour: Int,
        minute: Int
    ) -> String {
        String(format: "%02d:%02d", hour, minute)
    }
}

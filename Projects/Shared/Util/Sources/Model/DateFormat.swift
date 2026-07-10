//
//  DateFormat.swift
//  Util
//
//  Created by 김동준 on 7/10/26
//

public enum DateFormat: Equatable {
    case yyyyMMdd
    case mmdd
    case custom(String)

    public var value: String {
        switch self {
        case .yyyyMMdd:
            return "yyyy-MM-dd"
        case .mmdd:
            return "MM-dd"
        case .custom(let format):
            return format
        }
    }
}

//
//  ModyLogLevel.swift
//  ModyLogger
//
//  Created by 김동준 on 7/2/26
//

import OSLog

public enum ModyLogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case error = "ERROR"

    var title: String {
        switch self {
        case .debug:
            return "🟡 [Debug]"
        case .info:
            return "🟠 [Info]"
        case .error:
            return "🔴 [Error]"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .error:
            return .error
        }
    }

    var isEnabledInRelease: Bool {
        switch self {
        case .debug, .info:
            return false
        case .error:
            return true
        }
    }
}

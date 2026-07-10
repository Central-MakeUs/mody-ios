//
//  ModyLogger.swift
//  ModyLogger
//
//  Created by 김동준 on 7/2/26
//

import Foundation
import OSLog

public struct ModyLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.mody.logger"

    private init() {}

    public static func debug(
        _ message: String
    ) {
        guard shouldLog(.debug) else { return }
        log(message, level: .debug, privacy: .public, metadata: nil)
    }

    public static func info(
        _ message: String,
        file: String = #fileID,
        line: Int = #line
    ) {
        guard shouldLog(.info) else { return }
        log(
            message,
            level: .info,
            privacy: .public,
            metadata: simpleMetadata(file: file, line: line)
        )
    }

    public static func error(
        _ message: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        guard shouldLog(.error) else { return }
        log(
            message,
            level: .error,
            privacy: .private,
            metadata: detailedMetadata(level: .error, file: file, function: function, line: line)
        )
    }
}

private extension ModyLogger {
    static func shouldLog(_ level: ModyLogLevel) -> Bool {
#if DEBUG
        return true
#else
        return level.isEnabledInRelease
#endif
    }

    static func log(
        _ message: String,
        level: ModyLogLevel,
        privacy: ModyLogPrivacy,
        metadata: String?
    ) {
        let logger = Logger(subsystem: subsystem, category: level.rawValue)

        switch (metadata, privacy) {
        case (.some(let metadata), .public):
            logger.log(level: level.osLogType, "\(metadata, privacy: .public)\n\(message, privacy: .public)")
        case (.some(let metadata), .private):
            logger.log(level: level.osLogType, "\(metadata, privacy: .public)\n\(message, privacy: .private)")
        case (.none, .public):
            let output = """
            \(level.title)
            \(message)
            """

            logger.log(level: level.osLogType, "\(output, privacy: .public)")
        case (.none, .private):
            let output = """
            \(level.title)
            \(message)
            """

            logger.log(level: level.osLogType, "\(output, privacy: .private)")
        }
    }

    static func simpleMetadata(file: String, line: Int) -> String {
        """
        \(ModyLogLevel.info.title)
        [\(fileName(from: file)):\(line)]
        """
    }

    static func detailedMetadata(
        level: ModyLogLevel,
        file: String,
        function: String,
        line: Int
    ) -> String {
        """
        \(level.title)
        file: \(fileName(from: file))
        function: \(function)
        line: \(line)
        """
    }

    static func fileName(from file: String) -> String {
        (file as NSString).lastPathComponent
    }
}

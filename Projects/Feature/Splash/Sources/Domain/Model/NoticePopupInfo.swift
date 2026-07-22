//
//  NoticePopupInfo.swift
//  Splash
//

public struct NoticePopupInfo: Decodable, Equatable {
    public let title: String?
    public let contents: String?
    public let skipPossible: Bool?

    public init(
        title: String? = nil,
        contents: String? = nil,
        skipPossible: Bool? = nil
    ) {
        self.title = title
        self.contents = contents
        self.skipPossible = skipPossible
    }

    public var isEmpty: Bool {
        title == nil && contents == nil && skipPossible == nil
    }
}

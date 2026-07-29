//
//  FeedImageURLResolver.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import Foundation

enum FeedImageURLResolver {
    static func resolve(_ urlString: String?) -> URL? {
        guard let urlString else { return nil }

        let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else { return nil }

        guard let url = URL(string: trimmedURLString),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              let host = url.host,
              !host.isEmpty else {
            return nil
        }

        return url
    }
}

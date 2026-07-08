//
//  CoreKakaoShareService.swift
//  CoreKakao
//
//  Created by 김동준 on 7/7/26
//

import CoreKakaoInterface
import KakaoSDKShare
import KakaoSDKTemplate
import UIKit

public final class CoreKakaoShareService: CoreKakaoShareInterface {
    public init() {}

    @MainActor
    public func shareCodeToKakao(code: String) async throws {
        guard let template = makeTemplate(code: code) else { return }

        let sharingURL = try await makeSharingURL(from: template)
        await UIApplication.shared.open(sharingURL)
    }
}

private enum CoreKakaoShareError: Error {
    case failedToMakeSharingURL
    case missingSharingResult
}

private extension CoreKakaoShareService {
    var inviteImageURL: URL {
        URL(string: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fst.depositphotos.com%2F1000604%2F2576%2Fi%2F450%2Fdepositphotos_25763201-stock-photo-lonely-tree.jpg&type=sc960_832")!
    }

    var groupCodeWebURL: URL? {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              !baseURLString.isEmpty,
              let baseURL = URL(string: baseURLString) else { return nil }

        return baseURL.appending(path: "invite")
    }

    func makeTemplate(code: String) -> FeedTemplate? {
        guard let groupCodeWebURL else { return nil }

        let inviteURL = groupCodeWebURL.appending(queryItems: [
            .init(name: "inviteCode", value: code)
        ])
        let link = Link(
            webUrl: inviteURL,
            mobileWebUrl: inviteURL,
            iosExecutionParams: [
                "inviteCode": code
            ]
        )

        return FeedTemplate(
            content: .init(
                title: "모디 그룹에 초대합니다.",
                imageUrl: inviteImageURL,
                imageWidth: 960,
                imageHeight: 832,
                description: "초대 코드: \(code)\n나중에 문구 정하면 수정 필요",
                link: link
            ),
            buttons: [
                .init(
                    title: "바뀔 버튼 타이틀 아직안정함",
                    link: link
                )
            ]
        )
    }

    func makeSharingURL(from template: Templatable) async throws -> URL {
        if ShareApi.isKakaoTalkSharingAvailable() {
            return try await makeKakaoTalkSharingURL(from: template)
        }

        guard let url = ShareApi.shared.makeDefaultUrl(templatable: template) else {
            throw CoreKakaoShareError.failedToMakeSharingURL
        }

        return url
    }

    func makeKakaoTalkSharingURL(from template: Templatable) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            ShareApi.shared.shareDefault(templatable: template) { sharingResult, error in
                if let sharingResult {
                    continuation.resume(returning: sharingResult.url)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: CoreKakaoShareError.missingSharingResult)
                }
            }
        }
    }
}

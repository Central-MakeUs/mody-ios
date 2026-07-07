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
        let template = makeTemplate(code: code)
        let sharingURL = try await makeSharingURL(from: template)
        await UIApplication.shared.open(sharingURL)
    }
}

private enum CoreKakaoShareError: Error {
    case failedToMakeSharingURL
    case missingSharingResult
}

private extension CoreKakaoShareService {
    var groupCodeWebURL: URL {
        URL(string: "https://mody.app/invite")!
    }

    func makeTemplate(code: String) -> TextTemplate {
        let link = Link(
            webUrl: groupCodeWebURL,
            mobileWebUrl: groupCodeWebURL,
            iosExecutionParams: [
                "inviteCode": code
            ]
        )

        return TextTemplate(
            text: "모디 그룹에 초대합니다.\n초대 코드: \(code)",
            link: link,
            buttons: [
                .init(
                    title: "모디 앱 실행",
                    link: link
                )
            ]
        )
    }

    func makeSharingURL(from template: TextTemplate) async throws -> URL {
        if ShareApi.isKakaoTalkSharingAvailable() {
            return try await makeKakaoTalkSharingURL(from: template)
        }

        guard let url = ShareApi.shared.makeDefaultUrl(templatable: template) else {
            throw CoreKakaoShareError.failedToMakeSharingURL
        }

        return url
    }

    func makeKakaoTalkSharingURL(from template: TextTemplate) async throws -> URL {
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

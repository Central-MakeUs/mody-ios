//
//  CoreKakaoShareService.swift
//  CoreKakao
//
//  Created by 김동준 on 7/7/26
//

import CoreKakaoInterface
import KakaoSDKShare
import UIKit

public final class CoreKakaoShareService: CoreKakaoShareInterface {
    public init() {}

    @MainActor
    public func shareCodeToKakao(code: String, groupName: String) async throws {
        guard let customTemplateID else {
            throw CoreKakaoShareError.missingCustomTemplateID
        }

        let sharingURL = try await makeSharingURL(
            templateID: customTemplateID,
            templateArguments: [
                "groupName": groupName,
                "inviteCode": code
            ]
        )
        await UIApplication.shared.open(sharingURL)
    }
}

private enum CoreKakaoShareError: Error {
    case failedToMakeSharingURL
    case missingCustomTemplateID
    case missingSharingResult
}

private extension CoreKakaoShareService {
    var customTemplateID: Int64? {
        guard let value = Bundle.main.object(
            forInfoDictionaryKey: "KAKAO_SHARE_TEMPLATE_ID"
        ) as? String else { return nil }

        return Int64(value)
    }

    func makeSharingURL(
        templateID: Int64,
        templateArguments: [String: String]
    ) async throws -> URL {
        if ShareApi.isKakaoTalkSharingAvailable() {
            return try await makeKakaoTalkSharingURL(
                templateID: templateID,
                templateArguments: templateArguments
            )
        }

        guard let url = ShareApi.shared.makeCustomUrl(
            templateId: templateID,
            templateArgs: templateArguments
        ) else {
            throw CoreKakaoShareError.failedToMakeSharingURL
        }

        return url
    }

    func makeKakaoTalkSharingURL(
        templateID: Int64,
        templateArguments: [String: String]
    ) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            ShareApi.shared.shareCustom(
                templateId: templateID,
                templateArgs: templateArguments
            ) { sharingResult, error in
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

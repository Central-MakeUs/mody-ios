//
//  CoreKakaoShareServiceTests.swift
//  CoreKakaoTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreKakao
import CoreKakaoInterface
import Foundation
import XCTest

final class CoreKakaoShareServiceTests: XCTestCase {
    @MainActor
    func testShareRejectsMissingTemplateConfigurationBeforeCallingSDK() async {
        guard Bundle.main.object(forInfoDictionaryKey: "KAKAO_SHARE_TEMPLATE_ID") == nil else {
            XCTFail("This test requires a test runner without KAKAO_SHARE_TEMPLATE_ID")
            return
        }
        let sut: any CoreKakaoShareInterface = CoreKakaoShareService()

        do {
            try await sut.shareCodeToKakao(code: "ABC123", groupName: "테스트 그룹")
            XCTFail("Expected the missing template configuration error")
        } catch {
            // The implementation's error enum is private; check the thrown case without exposing it.
            XCTAssertEqual(String(describing: error), "missingCustomTemplateID")
        }
    }
}

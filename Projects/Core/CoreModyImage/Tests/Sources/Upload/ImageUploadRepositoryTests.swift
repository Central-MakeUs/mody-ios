//
//  ImageUploadRepositoryTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CommonDomain
import CoreModyImageInterface
import CoreNetworkInterface
import Foundation
import XCTest
@testable import CoreModyImage

final class ImageUploadRepositoryTests: XCTestCase {
    func testPresignedRequestAndResponseMappingForBothDomains() async throws {
        for domain in [ImageUploadDomain.profile, .record] {
            let network = ImageNetworkSpy(responseJSON: #"{"result":{"presignedUrl":"https://upload.invalid/object?signature=abc","imageKey":"object-key","expiresInSeconds":60}}"#)
            let result = try await ImageUploadRepository(network: network).postPresignedURL(
                domain: domain, fileName: "한글 photo.jpg"
            )
            XCTAssertEqual(result, PresignedImageUpload(
                url: URL(string: "https://upload.invalid/object?signature=abc")!, imageKey: "object-key"
            ))
            let endpoint = try XCTUnwrap(network.endpoints.first)
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(endpoint.path, "api/v1/uploads/presigned-url")
            XCTAssertEqual(endpoint.method, .POST)
            XCTAssertEqual(endpoint.queryParameters, ["domain": domain.rawValue, "fileName": "한글 photo.jpg"])
            XCTAssertTrue(endpoint.requiresAuthorization)
            XCTAssertTrue(endpoint.headers.isEmpty)
            XCTAssertNil(endpoint.bodyParameters)
        }
    }

    func testIncompleteOrMalformedPresignedResponseIsRejected() async {
        let responses = [
            "{}", #"{"result":null}"#, #"{"result":{}}"#,
            #"{"result":{"presignedUrl":null,"imageKey":"key"}}"#,
            #"{"result":{"presignedUrl":"","imageKey":"key"}}"#,
            #"{"result":{"presignedUrl":"https://[","imageKey":"key"}}"#,
            #"{"result":{"presignedUrl":"https://upload.invalid"}}"#,
            #"{"result":{"presignedUrl":"https://upload.invalid","imageKey":null}}"#,
            #"{"result":{"presignedUrl":"https://upload.invalid","imageKey":""}}"#
        ]
        for json in responses {
            await assertNetworkError(.invalidResponse) {
                _ = try await ImageUploadRepository(network: ImageNetworkSpy(responseJSON: json))
                    .postPresignedURL(domain: .record, fileName: "image.jpg")
            }
        }
    }

    func testPresignedNetworkErrorPropagates() async {
        let network = ImageNetworkSpy()
        network.error = NetworkError.unauthorized
        await assertNetworkError(.unauthorized) {
            _ = try await ImageUploadRepository(network: network).postPresignedURL(domain: .profile, fileName: "image.jpg")
        }
        XCTAssertEqual(network.endpoints.count, 1)
    }

    func testPresignedDecodingErrorPropagates() async {
        do {
            _ = try await ImageUploadRepository(network: ImageNetworkSpy(responseJSON: "not-json"))
                .postPresignedURL(domain: .record, fileName: "image.jpg")
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testUploadRejectsMissingOrInvalidImageWithoutRequestingPresignedURL() async throws {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let network = ImageNetworkSpy()
        let repository = ImageUploadRepository(network: network)
        let destination = URL(string: "https://upload.invalid/image")!
        for limit: Int? in [nil, 640, 0, -1] {
            await assertNetworkError(.invalidResponse) {
                try await repository.putImage(fileURL: fileURL, to: destination, maximumPixelSize: limit)
            }
        }
        try Data("invalid-image".utf8).write(to: fileURL)
        defer { try? FileManager.default.removeItem(at: fileURL) }
        await assertNetworkError(.invalidResponse) {
            try await repository.putImage(fileURL: fileURL, to: destination, maximumPixelSize: nil)
        }
        XCTAssertTrue(network.endpoints.isEmpty)
        XCTAssertEqual(try Data(contentsOf: fileURL), Data("invalid-image".utf8))
    }
}

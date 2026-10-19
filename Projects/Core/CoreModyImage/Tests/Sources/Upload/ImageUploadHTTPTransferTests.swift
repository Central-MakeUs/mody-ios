//
//  ImageUploadHTTPTransferTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import Alamofire
import CommonDomain
import Foundation
import UIKit
import XCTest
@testable import CoreModyImage

final class ImageUploadHTTPTransferTests: XCTestCase {
    private var session: Session!

    override func setUp() {
        super.setUp()
        ImageUploadURLProtocolStub.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageUploadURLProtocolStub.self]
        session = Session(configuration: configuration)
    }

    override func tearDown() {
        session.session.invalidateAndCancel()
        session = nil
        super.tearDown()
    }

    func testOriginalPNGUploadsWithDetectedMIMEAndPUTAndAcceptsEmpty2xx() async throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source) }
        let original = try Data(contentsOf: source)
        let repository = ImageUploadRepository(network: ImageNetworkSpy(), uploadSession: session)
        for status in [200, 201, 204, 299] {
            try await repository.putImage(fileURL: source, to: destination("status/\(status)"), maximumPixelSize: nil)
        }
        XCTAssertEqual(ImageUploadURLProtocolStub.requests.count, 4)
        for request in ImageUploadURLProtocolStub.requests {
            XCTAssertEqual(request.httpMethod, "PUT")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "image/png")
        }
        XCTAssertEqual(try Data(contentsOf: source), original)
    }

    func testProfileDownsampleUploadsJPEGAndPreservesSource() async throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source) }
        let original = try Data(contentsOf: source)
        try await ImageUploadRepository(network: ImageNetworkSpy(), uploadSession: session).putImage(
            fileURL: source, to: destination("status/204"), maximumPixelSize: 20
        )
        let request = try XCTUnwrap(ImageUploadURLProtocolStub.requests.first)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "image/jpeg")
        XCTAssertEqual(request.httpMethod, "PUT")
        XCTAssertEqual(try Data(contentsOf: source), original)
    }

    func testNon2xxResponsesMapToInvalidResponse() async throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source) }
        for status in [400, 403, 500] {
            await assertNetworkError(.invalidResponse) {
                try await ImageUploadRepository(network: ImageNetworkSpy(), uploadSession: session).putImage(
                    fileURL: source, to: destination("status/\(status)"), maximumPixelSize: nil
                )
            }
        }
        XCTAssertEqual(ImageUploadURLProtocolStub.requests.count, 3)
        XCTAssertTrue(FileManager.default.fileExists(atPath: source.path))
    }

    func testTransportErrorsMapToDomainErrors() async throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source) }
        let cases: [(URLError.Code, NetworkError)] = [
            (.timedOut, .timeout), (.notConnectedToInternet, .networkUnavailable),
            (.networkConnectionLost, .networkUnavailable), (.cannotConnectToHost, .networkUnavailable),
            (.cannotFindHost, .networkUnavailable), (.dnsLookupFailed, .networkUnavailable),
            (.internationalRoamingOff, .networkUnavailable), (.dataNotAllowed, .networkUnavailable),
            (.cancelled, .unknown), (.badURL, .unknown)
        ]
        for (code, expected) in cases {
            await assertNetworkError(expected) {
                try await ImageUploadRepository(network: ImageNetworkSpy(), uploadSession: session).putImage(
                    fileURL: source, to: destination("error/\(code.rawValue)"), maximumPixelSize: nil
                )
            }
        }
        XCTAssertEqual(ImageUploadURLProtocolStub.requests.count, cases.count)
    }

    private func destination(_ path: String) -> URL {
        URL(string: "https://\(ImageUploadURLProtocolStub.host)/\(path)")!
    }

    private func makeSource() throws -> URL {
        let source = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try XCTUnwrap(ImageFixture.make().pngData()).write(to: source)
        return source
    }
}

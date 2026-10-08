//  CameraFileNameTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import Photos
import XCTest

@testable import CoreCamera

final class CameraFileNameTests: XCTestCase {
    func testCameraAndLibraryGeneratedNamesUseTimestampAndUppercaseUUIDSuffix() {
        let id = UUID(uuidString: "abcdef00-0000-0000-0000-000000000000")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let date = calendar.date(from: DateComponents(year: 2026, month: 10, day: 9, hour: 12, minute: 34, second: 56))!
        XCTAssertEqual(
            PhotoFileNameUtil.makeCameraFileName(date: date, identifier: id), "MODY_PHOTO_20261009_123456_ABCDEF.jpg")
        XCTAssertEqual(
            PhotoFileNameUtil.makePhotoLibraryFileName(originalFileName: nil, date: date, identifier: id),
            "MODY_PHOTO_LIBRARY_20261009_123456_ABCDEF.jpg")
    }

    func testOriginalFilenameIsPreservedIncludingExtensionAndUnicode() {
        for name in ["원본 HEIC.heic", "IMG_001.PNG", ""] {
            XCTAssertEqual(PhotoFileNameUtil.makePhotoLibraryFileName(originalFileName: name), name)
        }
    }

    func testResourceSelectionPrefersFirstPhotoOrFullSizePhotoThenFirstResource() {
        XCTAssertNil(PhotoFileNameUtil.preferredFileName(resources: []))
        XCTAssertEqual(
            PhotoFileNameUtil.preferredFileName(resources: [
                (.video, "video"), (.photo, "photo"), (.fullSizePhoto, "full"),
            ]), "photo")
        XCTAssertEqual(
            PhotoFileNameUtil.preferredFileName(resources: [(.fullSizePhoto, "full"), (.photo, "photo")]), "full")
        XCTAssertEqual(
            PhotoFileNameUtil.preferredFileName(resources: [(.video, "first"), (.audio, "second")]), "first")
    }
}

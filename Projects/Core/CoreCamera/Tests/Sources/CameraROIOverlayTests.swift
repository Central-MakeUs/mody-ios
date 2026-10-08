//  CameraROIOverlayTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import UIKit
import XCTest

@testable import CoreCamera

@MainActor
final class CameraROIOverlayTests: XCTestCase {
    func testCustomAspectRatioFitsInsideBorderAndOffsetSelectableFrame() {
        let view = ROIOverlayView(selectionAspectRatio: CGSize(width: 1, height: 1))
        view.bounds = CGRect(x: 0, y: 0, width: 300, height: 600)
        view.resetSelection(in: CGRect(x: 0, y: 200, width: 300, height: 150))
        XCTAssertEqual(view.selectionFrame, CGRect(x: 77, y: 202, width: 146, height: 146))
    }

    func testDefaultAspectRatioAndNilSelectableFrameUseViewBounds() {
        let view = ROIOverlayView(selectionAspectRatio: nil)
        view.bounds = CGRect(x: 0, y: 0, width: 300, height: 600)
        view.resetSelection(in: nil)
        XCTAssertEqual(view.selectionFrame.minX, 2, accuracy: 0.001)
        XCTAssertEqual(view.selectionFrame.width / view.selectionFrame.height, 252.0 / 200.0, accuracy: 0.001)
        XCTAssertEqual(view.selectionFrame.midY, 300, accuracy: 0.001)
    }

    func testInvalidOrNonIntersectingSelectableFrameFallsBackToBounds() {
        let view = ROIOverlayView(selectionAspectRatio: CGSize(width: 1, height: 1))
        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        for selectable in [CGRect.zero, CGRect(x: 200, y: 200, width: 100, height: 100)] {
            view.resetSelection(in: selectable)
            XCTAssertEqual(view.selectionFrame, CGRect(x: 2, y: 2, width: 96, height: 96))
        }
    }

    func testShrinkingSelectableFrameConstrainsExistingSelectionAndResetRecenters() {
        let view = ROIOverlayView(selectionAspectRatio: CGSize(width: 2, height: 1))
        view.bounds = CGRect(x: 0, y: 0, width: 300, height: 600)
        view.updateSelectableFrame(nil)
        let small = CGRect(x: 50, y: 250, width: 100, height: 80)
        view.updateSelectableFrame(small)
        XCTAssertTrue(small.insetBy(dx: 2, dy: 2).contains(view.selectionFrame))
        XCTAssertEqual(view.selectionFrame.size, CGSize(width: 96, height: 76))
        view.resetSelection(in: small)
        XCTAssertEqual(view.selectionFrame, CGRect(x: 52, y: 266, width: 96, height: 48))
    }

    func testLayoutInitializesSelectionAndKeepsItInsideResizedBounds() {
        let view = ROIOverlayView(selectionAspectRatio: CGSize(width: 1, height: 1))
        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.layoutSubviews()
        XCTAssertEqual(view.selectionFrame, CGRect(x: 2, y: 2, width: 96, height: 96))
        view.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        view.layoutSubviews()
        XCTAssertEqual(view.selectionFrame, CGRect(x: 2, y: 2, width: 46, height: 46))
    }

    func testTinyAndEmptyBoundsDoNotProduceNegativeSelection() {
        let view = ROIOverlayView(selectionAspectRatio: nil)
        for size: CGFloat in [0, 1, 4, 20] {
            view.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            view.resetSelection(in: nil)
            XCTAssertEqual(view.selectionFrame, .zero)
        }
    }
}

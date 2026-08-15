//
//  ROISelectionFrameCalculator.swift
//  CoreCamera
//
//  Created by 김동준 on 8/15/26.
//

import Foundation

struct ROISelectionFrameCalculator {
    static func maximumFrame(
        aspectRatio: CGSize,
        in selectableFrame: CGRect
    ) -> CGRect {
        guard aspectRatio.width.isFinite,
              aspectRatio.height.isFinite,
              aspectRatio.width > 0,
              aspectRatio.height > 0,
              selectableFrame.width.isFinite,
              selectableFrame.height.isFinite,
              selectableFrame.width > 0,
              selectableFrame.height > 0 else {
            return .zero
        }

        let scale = min(
            selectableFrame.width / aspectRatio.width,
            selectableFrame.height / aspectRatio.height
        )
        let size = CGSize(
            width: aspectRatio.width * scale,
            height: aspectRatio.height * scale
        )

        return CGRect(
            x: selectableFrame.midX - (size.width / 2),
            y: selectableFrame.midY - (size.height / 2),
            width: size.width,
            height: size.height
        )
    }
}

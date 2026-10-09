//
//  ImageFixture.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import UIKit

/// scale=1로 만들어 시뮬레이터의 화면 배율과 무관한 픽셀 입력을 제공합니다.
enum ImageFixture {
    static func make(size: CGSize = CGSize(width: 80, height: 40)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: size.width / 2, height: size.height))
            UIColor.blue.setFill()
            context.fill(CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
        }
    }
}

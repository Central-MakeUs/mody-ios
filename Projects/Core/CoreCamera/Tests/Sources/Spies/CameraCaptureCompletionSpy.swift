//  CameraCaptureCompletionSpy.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import Foundation

final class CameraCaptureCompletionSpy: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [Data?] = []

    var results: [Data?] { lock.withLock { values } }
    func record(_ data: Data?) { lock.withLock { values.append(data) } }
}

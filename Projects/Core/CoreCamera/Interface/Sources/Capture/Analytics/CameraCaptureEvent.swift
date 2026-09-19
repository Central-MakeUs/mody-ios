//
//  CameraCaptureEvent.swift
//  CoreCameraInterface
//
//  Created by 김동준 on 9/19/26.
//

public enum CameraCaptureEvent: Equatable {
    case buttonClicked(CameraCaptureButton)
}

public enum CameraCaptureButton: String, Equatable {
    case takeAPicture = "take_a_picture"
    case switchCamera = "switch_camera"
    case gallery
    case retake
    case rotateLeft = "rotate_left"
    case rotateRight = "rotate_right"
}

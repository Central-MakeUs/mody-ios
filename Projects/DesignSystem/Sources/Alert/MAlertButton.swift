//
//  MAlertButton.swift
//  DesignSystem
//

public struct MAlertButton {
    public let title: String
    public let style: MButtonStyle

    private let action: () -> Void

    public init(
        _ title: String,
        style: MButtonStyle = .primary,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.style = style
        self.action = action
    }

    public func perform() {
        action()
    }
}

//
//  MUILabel.swift
//  DesignSystem
//
//  Created by 김동준 on 7/1/26
//

import UIKit

public final class MUILabel: UILabel {
    public var style: ModyTypography {
        didSet { applyTypography() }
    }
    
    public var underline: Bool {
        didSet { applyTypography() }
    }
    
    private var isApplyingTypography = false
    
    public override var text: String? {
        didSet { applyTypography() }
    }
    
    public override var textColor: UIColor! {
        didSet { applyTypography() }
    }
    
    public override var textAlignment: NSTextAlignment {
        didSet { applyTypography() }
    }
    
    public override var lineBreakMode: NSLineBreakMode {
        didSet { applyTypography() }
    }
    
    public init(
        text: String? = nil,
        style: ModyTypography,
        color: UIColor = .systemBlack,
        numberOfLines: Int = 1,
        underline: Bool = false,
        alignment: NSTextAlignment = .center,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) {
        self.style = style
        self.underline = underline
        super.init(frame: .zero)
        configure(
            text: text,
            style: style,
            color: color,
            numberOfLines: numberOfLines,
            underline: underline,
            alignment: alignment,
            lineBreakMode: lineBreakMode
        )
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension MUILabel {
    func configure(
        text: String?,
        style: ModyTypography,
        color: UIColor = .systemBlack,
        numberOfLines: Int = 1,
        underline: Bool = false,
        alignment: NSTextAlignment = .center,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) {
        isApplyingTypography = true
        self.style = style
        self.textColor = color
        self.numberOfLines = numberOfLines
        self.underline = underline
        self.textAlignment = alignment
        self.lineBreakMode = lineBreakMode
        self.text = text
        isApplyingTypography = false
        
        applyTypography()
    }
}

private extension MUILabel {
    func applyTypography() {
        guard !isApplyingTypography else { return }
        
        isApplyingTypography = true
        let currentText = text ?? ""
        font = style.token.uiFont
        attributedText = style.token.attributedString(
            currentText,
            color: textColor ?? .systemBlack,
            alignment: textAlignment,
            lineBreakMode: lineBreakMode,
            underline: underline
        )
        isApplyingTypography = false
        
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
}

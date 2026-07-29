//
//  FeedRecordSelectionField.swift
//  Feed
//
//  Created by 김동준 on 7/16/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedRecordSelectionField: UIControl {
    private let titleLabel = MUILabel(
        text: "운동 선택",
        style: .b4,
        color: .gray4,
        alignment: .left
    )
    private let customTextField = UITextField()
    private let arrowImageView = UIImageView()
    private let arrowButton = UIButton(type: .custom)

    var onCustomTextChanged: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        selectedType: FeedExerciseType?,
        customText: String,
        isExpanded: Bool
    ) {
        let isCustom = selectedType == .custom
        let shouldFocusCustomTextField = isCustom && customTextField.isHidden

        titleLabel.text = selectedType?.name ?? "운동 선택"
        titleLabel.textColor = selectedType == nil ? .gray4 : .gray10
        titleLabel.isHidden = isCustom

        customTextField.isHidden = !isCustom
        if customTextField.text != customText {
            customTextField.text = customText
        }

        arrowImageView.image = (isExpanded ? UIImage.icArrowDown : UIImage.icArrowUp)
            .withRenderingMode(.alwaysTemplate)

        if isExpanded {
            customTextField.resignFirstResponder()
        } else if shouldFocusCustomTextField {
            DispatchQueue.main.async { [weak self] in
                self?.customTextField.becomeFirstResponder()
            }
        }

        updateBorderColor()
    }
}

private extension FeedRecordSelectionField {
    func setupUI() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray2.cgColor

        customTextField.font = ModyTypography.b4.token.uiFont
        customTextField.textColor = .gray10
        customTextField.tintColor = .main
        customTextField.attributedPlaceholder = ModyTypography.b4.token.attributedString(
            "직접 입력",
            color: .gray4,
            alignment: .left
        )
        customTextField.isHidden = true
        customTextField.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }

                self.updateBorderColor()
                self.onCustomTextChanged?(self.customTextField.text ?? "")
            },
            for: .editingChanged
        )
        customTextField.addAction(
            UIAction { [weak self] _ in
                self?.updateBorderColor()
            },
            for: [.editingDidBegin, .editingDidEnd]
        )

        arrowImageView.image = UIImage.icArrowUp.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .gray3
        arrowImageView.contentMode = .scaleAspectFit

        arrowButton.addAction(
            UIAction { [weak self] _ in
                self?.sendActions(for: .touchUpInside)
            },
            for: .touchUpInside
        )
    }

    func setupLayout() {
        addSubview(titleLabel)
        addSubview(customTextField)
        addSubview(arrowImageView)
        addSubview(arrowButton)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-8)
        }

        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(24)
        }

        customTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(arrowButton.snp.leading).offset(-8)
        }

        arrowButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
    }

    func updateBorderColor() {
        let hasFocusedText = customTextField.isFirstResponder
            && !(customTextField.text ?? "").isEmpty
        let borderColor: UIColor = hasFocusedText ? .main : .gray2
        layer.borderColor = borderColor.cgColor
    }
}

//
//  FeedRecordView.swift
//  Feed
//
//  Created by 김동준 on 7/15/26.
//

import UIKit
import FeedInterface
import DesignSystem
import SnapKit

final class FeedRecordView: UIView {
    let navigationBarContainerView = UIView()
    let uploadView = FeedRecordUploadView()
    let inputFieldContainerView = UIView()
    let exerciseSelectionField = FeedRecordSelectionField()
    let exerciseMenuView = FeedRecordExerciseMenuView()
    let timePickerContainerView = UIView()
    let finishButtonContainerView = UIView()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let inputSectionStackView = UIStackView()
    private let timeSectionStackView = UIStackView()

    private let recordType: FeedRecordType
    private lazy var inputSectionHeaderView = FeedRecordSectionHeaderView(
        icon: recordType == .meal ? .icCook : .icExercise,
        title: recordType == .meal ? "메뉴" : "운동 종류"
    )
    private lazy var timeSectionHeaderView = FeedRecordSectionHeaderView(
        icon: .icClock,
        title: recordType == .meal ? "식사 시간" : "운동 시간",
        spacing: 6
    )

    init(recordType: FeedRecordType) {
        self.recordType = recordType
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureExerciseInput(_ viewState: FeedRecordExerciseInputViewState) {
        exerciseSelectionField.configure(
            selectedType: viewState.selectedType,
            customText: viewState.customExerciseName,
            isExpanded: viewState.isExpanded
        )
        exerciseMenuView.configure(selectedType: viewState.selectedType)
        exerciseMenuView.isHidden = !viewState.isExpanded

        guard viewState.isExpanded else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.exerciseMenuView.isHidden else { return }

            self.layoutIfNeeded()
            self.scrollExerciseMenuToLastItem()
        }
    }

    func configurePhoto(_ image: UIImage) {
        uploadView.configure(image: image)
    }
}

private extension FeedRecordView {
    func setupUI() {
        backgroundColor = .systemWhite

        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive

        contentStackView.axis = .vertical
        contentStackView.spacing = 0

        inputSectionStackView.axis = .vertical
        inputSectionStackView.spacing = 12

        timeSectionStackView.axis = .vertical
        timeSectionStackView.spacing = 12

        exerciseMenuView.isHidden = true
    }

    func setupLayout() {
        addSubview(navigationBarContainerView)
        addSubview(scrollView)
        addSubview(finishButtonContainerView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        inputSectionStackView.addArrangedSubview(inputSectionHeaderView)
        inputSectionStackView.addArrangedSubview(inputFieldContainerView)
        inputSectionStackView.addArrangedSubview(exerciseMenuView)
        inputSectionStackView.setCustomSpacing(0, after: inputFieldContainerView)

        timeSectionStackView.addArrangedSubview(timeSectionHeaderView)
        timeSectionStackView.addArrangedSubview(timePickerContainerView)

        contentStackView.addArrangedSubview(uploadView)
        contentStackView.setCustomSpacing(32, after: uploadView)
        contentStackView.addArrangedSubview(inputSectionStackView)
        contentStackView.setCustomSpacing(32, after: inputSectionStackView)
        contentStackView.addArrangedSubview(timeSectionStackView)

        if recordType == .exercise {
            inputFieldContainerView.addSubview(exerciseSelectionField)
            exerciseSelectionField.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }

        navigationBarContainerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        finishButtonContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(40)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBarContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(finishButtonContainerView.snp.top).offset(-16)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        uploadView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
    }
}

private extension FeedRecordView {
    func scrollExerciseMenuToLastItem() {
        let menuRect = exerciseMenuView.convert(exerciseMenuView.bounds, to: contentView)
        scrollView.scrollRectToVisible(menuRect.insetBy(dx: 0, dy: -12), animated: true)
    }
}

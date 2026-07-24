//
//  FeedRecordViewController.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import UIKit
import SwiftUI
import Base
import CoreCameraInterface
import FeedInterface
import ReactorKit
import DesignSystem
import RxCocoa

public final class FeedRecordViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()

    private let recordType: FeedRecordType
    private let recordView: FeedRecordView
    let cameraCaptureBuilder: CameraCaptureBuildable

    private var finishButtonHostingController: UIHostingController<FeedRecordFinishButtonView>?
    var photoSourceSheetViewController: UIViewController?
    var cameraContainerViewController: UIViewController?

    public init(
        reactor: FeedRecordReactor,
        cameraCaptureBuilder: CameraCaptureBuildable
    ) {
        let recordType = reactor.initialState.recordType
        self.recordType = recordType
        self.recordView = FeedRecordView(recordType: recordType)
        self.cameraCaptureBuilder = cameraCaptureBuilder
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = recordView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureRecordTypeContent()
    }

    public func bind(reactor: FeedRecordReactor) {
        recordView.uploadView.rx.controlEvent(.touchUpInside)
            .map { FeedRecordReactor.Action.didTapPhotoUpload }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        recordView.exerciseSelectionField.rx.controlEvent(.touchUpInside)
            .map { FeedRecordReactor.Action.didTapExerciseMenu }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        recordView.exerciseMenuView.onSelect = { [weak reactor] type in
            reactor?.action.onNext(.didSelectExerciseType(type))
        }

        recordView.exerciseSelectionField.onCustomTextChanged = { [weak reactor] text in
            reactor?.action.onNext(.didChangeCustomExerciseName(text))
        }

        reactor.state
            .map(\.photoPresentation)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, presentation in
                owner.setPhotoPresentation(presentation)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.selectedPhoto)
            .compactMap { $0?.croppedImage }
            .distinctUntilChanged { $0 === $1 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, image in
                owner.recordView.configurePhoto(image)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isFinishButtonEnabled)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isEnabled in
                owner.configureFinishButton(isEnabled: isEnabled)
            }
            .disposed(by: disposeBag)

        guard recordType == .exercise else { return }

        reactor.state
            .map { state in
                FeedRecordExerciseInputViewState(
                    selectedType: state.selectedExerciseType,
                    customExerciseName: state.customExerciseName,
                    isExpanded: state.isExerciseMenuExpanded
                )
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, viewState in
                owner.recordView.configureExerciseInput(viewState)
            }
            .disposed(by: disposeBag)
    }
}

private extension FeedRecordViewController {
    func configureNavigationBar() {
        let navigationBar = MNavigationBar(
            title: recordType.title,
            onBackTap: { [weak self] in
                self?.reactor?.action.onNext(.didTapBackButton)
            }
        )
        addHostedView(
            navigationBar,
            to: recordView.navigationBarContainerView,
            sizesToContent: true
        )
    }
    
    func configureRecordTypeContent() {
        switch recordType {
        case .meal:
            configureMealTextField()
            configureMealTimePicker()
        case .exercise:
            configureExerciseDurationPicker()
        }
        
        configureFinishButton(isEnabled: false)
    }
}

private extension FeedRecordViewController {
    func configureMealTextField() {
        let textField = FeedRecordMealTextFieldView(
            text: reactor?.currentState.mealMenu ?? "",
            placeholder: "메뉴를 간단하게 입력해주세요",
            onTextChanged: { [weak self] text in
                self?.reactor?.action.onNext(.didChangeMealMenu(text))
            }
        )
        addHostedView(
            textField,
            to: recordView.inputFieldContainerView,
            sizesToContent: true
        )
    }
    
    func configureMealTimePicker() {
        let timePicker = FeedRecordMealTimePickerView(
            date: reactor?.currentState.mealTime ?? Date(),
            onDateChanged: { [weak self] date in
                self?.reactor?.action.onNext(.didChangeMealTime(date))
            }
        )
        addHostedView(
            timePicker,
            to: recordView.timePickerContainerView,
            sizesToContent: true
        )
    }
}

private extension FeedRecordViewController {
    func configureExerciseDurationPicker() {
        let state = reactor?.currentState
        let durationPicker = FeedRecordExerciseDurationPickerView(
            hours: state?.exerciseHours ?? 0,
            minutes: state?.exerciseMinutes ?? 0,
            onDurationChanged: { [weak self] hours, minutes in
                self?.reactor?.action.onNext(
                    .didChangeExerciseDuration(hours: hours, minutes: minutes)
                )
            }
        )
        addHostedView(
            durationPicker,
            to: recordView.timePickerContainerView,
            sizesToContent: true
        )
    }
}

private extension FeedRecordViewController {
    func configureFinishButton(isEnabled: Bool) {
        let rootView = FeedRecordFinishButtonView(
            isEnabled: isEnabled,
            onTap: { [weak self] in
                self?.reactor?.action.onNext(.didTapFinishButton)
            }
        )

        if let finishButtonHostingController {
            finishButtonHostingController.rootView = rootView
            return
        }

        let hostingController = addHostedView(
            rootView,
            to: recordView.finishButtonContainerView,
            sizesToContent: true
        )
        finishButtonHostingController = hostingController
    }
}

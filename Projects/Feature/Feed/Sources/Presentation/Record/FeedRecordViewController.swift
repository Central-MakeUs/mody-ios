//
//  FeedRecordViewController.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import UIKit
import SwiftUI
import Base
import CommonDomain
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
    private var recordFailureAlertHostingController: UIHostingController<MAlertView>?
    private var recordLoadingHostingController: UIHostingController<AnyView>?
    var photoSourceSheetViewController: UIViewController?
    var cameraCaptureViewController: UIViewController?

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
        configureRecordLoadingView()
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
            .observe(on: MainScheduler.instance)
            .map(\.photoPresentation)
            .distinctUntilChanged()
            .bind(with: self) { owner, presentation in
                owner.setPhotoPresentation(presentation)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map(\.selectedPhoto)
            .compactMap { $0?.croppedImage }
            .distinctUntilChanged { $0 === $1 }
            .bind(with: self) { owner, image in
                owner.recordView.configurePhoto(image)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map(\.isFinishButtonEnabled)
            .distinctUntilChanged()
            .bind(with: self) { owner, isEnabled in
                owner.configureFinishButton(isEnabled: isEnabled)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map(\.isSubmittingRecord)
            .distinctUntilChanged()
            .bind(with: self) { owner, isSubmitting in
                owner.setRecordLoadingVisible(isSubmitting)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map(\.recordFailureAlert)
            .distinctUntilChanged()
            .bind(with: self) { owner, error in
                owner.setRecordFailureAlert(error)
            }
            .disposed(by: disposeBag)

        guard recordType == .exercise else { return }

        reactor.state
            .observe(on: MainScheduler.instance)
            .map { state in
                FeedRecordExerciseInputViewState(
                    selectedType: state.selectedExerciseType,
                    customExerciseName: state.customExerciseName,
                    isExpanded: state.isExerciseMenuExpanded
                )
            }
            .distinctUntilChanged()
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
    func configureRecordLoadingView() {
        let loadingView = MLoadingIndicatorView()
            .greedyFrame()
            .background(Color.systemBlack.opacity(0.6))
        let hostingController = UIHostingController(rootView: AnyView(loadingView))

        hostingController.view.backgroundColor = .clear
        hostingController.view.isHidden = true
        recordLoadingHostingController = hostingController

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        hostingController.didMove(toParent: self)
    }

    func setRecordLoadingVisible(_ isVisible: Bool) {
        recordLoadingHostingController?.view.isHidden = !isVisible

        if isVisible,
           let loadingView = recordLoadingHostingController?.view {
            view.bringSubviewToFront(loadingView)
        }
    }

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

    func setRecordFailureAlert(_ error: NetworkError?) {
        guard let error else {
            dismissRecordFailureAlert()
            return
        }

        guard recordFailureAlertHostingController == nil else { return }

        let alertView = MAlertView(
            title: error.title,
            contents: error.message,
            trailingButton: MAlertButton("확인") { [weak self] in
                self?.reactor?.action.onNext(.didDismissRecordFailureAlert)
            },
            onDismiss: { [weak self] in
                self?.reactor?.action.onNext(.didDismissRecordFailureAlert)
            }
        )
        recordFailureAlertHostingController = addHostedView(alertView, to: view)
    }

    func dismissRecordFailureAlert() {
        guard let recordFailureAlertHostingController else { return }

        recordFailureAlertHostingController.willMove(toParent: nil)
        recordFailureAlertHostingController.view.removeFromSuperview()
        recordFailureAlertHostingController.removeFromParent()
        self.recordFailureAlertHostingController = nil
    }
}

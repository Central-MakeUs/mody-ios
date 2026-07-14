//
//  FeedWeekCalendarDayView.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

import UIKit
import CommonDomain
import DesignSystem
import SnapKit
import Util

final class FeedWeekCalendarDayView: UIControl {
    var onTap: ((FeedWeekCalendarModel) -> Void)?

    private let disabledAlpha: CGFloat = 0.4
    private let contentStackView = UIStackView()
    private let dayOfWeekLabel: MUILabel
    private let dateContainerView = UIView()
    private let dateLabel = MUILabel(
        style: .b7,
        color: .gray10
    )
    private let recordDotView = UIView()
    private var model: FeedWeekCalendarModel?

    init(dayOfWeek: DayOfWeek) {
        self.dayOfWeekLabel = MUILabel(
            text: dayOfWeek.title,
            style: .b7,
            color: .gray6
        )
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        model: FeedWeekCalendarModel,
        todayDate: String,
        selectedDate: String
    ) {
        self.model = model

        let calendar = Date.koreanCalendar
        let date = FeedWeekCalendarCalculator.parseDate(model.date)
        let isSelected = model.date == selectedDate
        let isSelectable = FeedWeekCalendarCalculator.isSelectable(
            date: model.date,
            latestSelectableDate: todayDate,
            calendar: calendar
        )

        dateLabel.text = date.map {
            String(calendar.component(.day, from: $0))
        }
        dateContainerView.backgroundColor = isSelected ? .main : .clear
        recordDotView.backgroundColor = model.hasRecord ? .main : .gray2
        isEnabled = isSelectable
        alpha = isSelectable ? 1 : disabledAlpha
    }
}

private extension FeedWeekCalendarDayView {
    func setupUI() {
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 4
        contentStackView.isUserInteractionEnabled = false

        dateContainerView.layer.cornerRadius = 14
        dateContainerView.layer.masksToBounds = true

        recordDotView.layer.cornerRadius = 4
        recordDotView.layer.masksToBounds = true
    }

    func setupLayout() {
        addSubview(contentStackView)
        dateContainerView.addSubview(dateLabel)

        contentStackView.addArrangedSubview(dayOfWeekLabel)
        contentStackView.addArrangedSubview(dateContainerView)
        contentStackView.addArrangedSubview(recordDotView)

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dateContainerView.snp.makeConstraints {
            $0.size.equalTo(28)
        }

        dateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        recordDotView.snp.makeConstraints {
            $0.size.equalTo(8)
        }
    }

    @objc
    func didTap() {
        guard isEnabled, let model else { return }
        onTap?(model)
    }
}

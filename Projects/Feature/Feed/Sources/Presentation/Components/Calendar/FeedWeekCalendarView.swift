//
//  FeedWeekCalendarView.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedWeekCalendarView: UIView {
    var onPreviousWeekTap: (() -> Void)?
    var onNextWeekTap: (() -> Void)?
    var onDateTap: ((FeedWeekCalendarModel) -> Void)?

    private let headerView = FeedWeekCalendarHeaderView()
    private let dayStackView = UIStackView()
    private let separatorView = UIView()
    private let dayViews = FeedWeekCalendarCalculator.weekdays.map {
        FeedWeekCalendarDayView(dayOfWeek: $0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        dates: [FeedWeekCalendarModel],
        canMovePrevious: Bool,
        canMoveNext: Bool,
        todayDate: String,
        selectedDate: String
    ) {
        let sortedDates = dates.sorted { $0.date < $1.date }
        let expectedDays = FeedWeekCalendarCalculator.weekdays
        let hasValidWeek =
            sortedDates.count == expectedDays.count
            && zip(sortedDates, expectedDays).allSatisfy { model, expectedDay in
                model.dayOfWeek == expectedDay
            }

        guard hasValidWeek else { return }

        headerView.configure(
            title: title,
            canMovePrevious: canMovePrevious,
            canMoveNext: canMoveNext
        )

        zip(dayViews, sortedDates).forEach { dayView, model in
            dayView.configure(
                model: model,
                todayDate: todayDate,
                selectedDate: selectedDate
            )
        }
    }
}

private extension FeedWeekCalendarView {
    func setupUI() {
        backgroundColor = .systemWhite

        dayStackView.axis = .horizontal
        dayStackView.alignment = .fill
        dayStackView.distribution = .equalSpacing

        separatorView.backgroundColor = .gray2
    }

    func setupLayout() {
        addSubview(headerView)
        addSubview(dayStackView)
        addSubview(separatorView)

        dayViews.forEach(dayStackView.addArrangedSubview)

        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        dayStackView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.bottom.equalTo(separatorView.snp.top).offset(-16)
        }

        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func setupActions() {
        headerView.onPreviousWeekTap = { [weak self] in
            self?.onPreviousWeekTap?()
        }
        headerView.onNextWeekTap = { [weak self] in
            self?.onNextWeekTap?()
        }

        dayViews.forEach { dayView in
            dayView.onTap = { [weak self] model in
                self?.onDateTap?(model)
            }
        }
    }
}

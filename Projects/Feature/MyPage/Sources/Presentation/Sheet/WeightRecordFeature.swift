//
//  WeightRecordFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import Foundation
import Util

@Reducer
public struct WeightRecordFeature {
    @ObservableState
    public struct State: Equatable {
        var dateText: String
        var currentWeightText: String

        public init(currentWeight: Double) {
            let now = Date()
            let currentWeightText = String(currentWeight)

            self.dateText = now.toString(format: .custom("yyyy.MM.dd"))
            self.currentWeightText = currentWeightText.hasSuffix(".0")
                ? String(currentWeightText.dropLast(2))
                : currentWeightText
        }

        var currentWeight: Double? {
            Double(currentWeightText)
        }

        var recordedOn: String? {
            guard isDateFormatValid else { return nil }

            return dateText.replacingOccurrences(of: ".", with: "-")
        }

        var isRecordButtonDisabled: Bool {
            !isDateFormatValid || currentWeight == nil
        }

        private var isDateFormatValid: Bool {
            let components = dateText.split(
                separator: ".",
                omittingEmptySubsequences: false
            )

            guard components.map(\.count) == [4, 2, 2] else { return false }

            return components.allSatisfy { component in
                component.allSatisfy(\.isNumber)
            }
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case recordButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

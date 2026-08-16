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
        let selectableWeights: ClosedRange<Int>
        var currentWeightKg: Int

        public init(currentWeight: Double) {
            let now = Date()
            let selectableWeights = 20...150

            self.dateText = now.toString(format: .custom("yyyy.MM.dd"))
            self.selectableWeights = selectableWeights
            self.currentWeightKg = min(
                max(Int(currentWeight.rounded()), selectableWeights.lowerBound),
                selectableWeights.upperBound
            )
        }

        var currentWeight: Double {
            Double(currentWeightKg)
        }

        var recordedOn: String? {
            guard isDateFormatValid else { return nil }

            return dateText.replacingOccurrences(of: ".", with: "-")
        }

        var isRecordButtonDisabled: Bool {
            !isDateFormatValid
        }

        var isDateFormatValid: Bool {
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

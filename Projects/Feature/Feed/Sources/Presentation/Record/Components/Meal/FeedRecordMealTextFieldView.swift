//
//  FeedRecordMealTextFieldView.swift
//  Feed
//
//  Created by 김동준 on 7/16/26.
//

import SwiftUI
import DesignSystem

struct FeedRecordMealTextFieldView: View {
    @State private var text: String
    @FocusState private var isFocused: Bool

    private let placeholder: String
    private let onTextChanged: (String) -> Void

    init(
        text: String,
        placeholder: String,
        onTextChanged: @escaping (String) -> Void
    ) {
        self._text = State(initialValue: text)
        self.placeholder = placeholder
        self.onTextChanged = onTextChanged
    }

    var body: some View {
        MTextField(
            $text,
            placeholder: placeholder,
            cursorColor: .main,
            hasStroke: true,
            strokeColor: isFocused && !text.isEmpty ? .main : .gray2,
            focus: $isFocused
        )
        .onChange(of: text) { _, newValue in
            onTextChanged(newValue)
        }
    }
}

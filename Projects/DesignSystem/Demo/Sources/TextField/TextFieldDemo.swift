import SwiftUI
import DesignSystem

struct TextFieldDemo: View {
    @State private var text = "Label"
    @State private var underlineColor: TextFieldDemoColor?
    @State private var textColor: TextFieldDemoColor?
    @State private var placeholderColor: TextFieldDemoColor?
    @State private var cursorColor: TextFieldDemoColor?
    @State private var hasStroke = false
    @State private var strokeColor: TextFieldDemoColor?
    @State private var hasClearButton = false
    @State private var showsErrorMessage = true
    @State private var maxCount: Int? = 14

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TextFieldDemoSection(title: "Preview") {
                    MTextField(
                        $text,
                        placeholder: "Label",
                        textColor: textColor?.color ?? .gray10,
                        placeholderColor: placeholderColor?.color ?? .gray4,
                        cursorColor: cursorColor?.color ?? .main,
                        underlineColor: underlineColor?.color ?? .gray2,
                        focusedUnderlineColor: underlineColor?.color ?? .main,
                        hasStroke: hasStroke,
                        strokeColor: strokeColor?.color ?? .gray2,
                        hasClearButton: hasClearButton,
                        errorMessage: errorMessage,
                        maxCount: maxCount,
                        isValid: isValid
                    )
                }

                TextFieldDemoSection(title: "Text") {
                    TextFieldDemoTextToggle(text: $text)
                }

                TextFieldDemoSection(title: "Style") {
                    Toggle("Stroke", isOn: $hasStroke)
                        .font(.subheadline)

                    Toggle("Clear Button", isOn: $hasClearButton)
                        .font(.subheadline)

                    Toggle(
                        "Error Message",
                        isOn: $showsErrorMessage
                    )
                    .font(.subheadline)

                    Toggle(
                        "Text Count",
                        isOn: Binding(
                            get: { maxCount != nil },
                            set: { maxCount = $0 ? 14 : nil }
                        )
                    )
                    .font(.subheadline)
                }

                TextFieldDemoSection(title: "Colors") {
                    TextFieldDemoColorPicker(
                        title: "Underline",
                        defaultTitle: "없음 (Gray2 / Focus Main)",
                        selection: $underlineColor
                    )

                    TextFieldDemoColorPicker(
                        title: "Text",
                        defaultTitle: "없음 (Gray10)",
                        selection: $textColor
                    )

                    TextFieldDemoColorPicker(
                        title: "Placeholder",
                        defaultTitle: "없음 (Gray4)",
                        selection: $placeholderColor
                    )

                    TextFieldDemoColorPicker(
                        title: "Cursor",
                        defaultTitle: "없음 (Main)",
                        selection: $cursorColor
                    )

                    TextFieldDemoColorPicker(
                        title: "Stroke",
                        defaultTitle: "없음 (Gray2)",
                        selection: $strokeColor
                    )
                }
            }
            .padding(16)
        }
        .navigationTitle("TextField")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var isValid: Bool? {
        if text.isEmpty {
            return nil
        }

        return text.count <= 14
    }

    private var errorMessage: String? {
        guard showsErrorMessage, isValid == false else {
            return nil
        }

        return "14자 이내로 적어주세요"
    }
}

private struct TextFieldDemoTextToggle: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Button("Empty") {
                text = ""
            }
            .buttonStyle(.bordered)

            Button("Filled") {
                text = "Label"
            }
            .buttonStyle(.bordered)

            Button("Typing") {
                text = "Typing"
            }
            .buttonStyle(.bordered)

            Button("Over 14") {
                text = "123456789012345"
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct TextFieldDemoColorPicker: View {
    let title: String
    let defaultTitle: String
    @Binding var selection: TextFieldDemoColor?

    var body: some View {
        HStack(spacing: 12) {
            MText(
                title,
                style: .c1,
                color: .gray10,
                alignment: .leading
            )
            .frame(width: 92, alignment: .leading)

            Menu {
                Button(defaultTitle) {
                    selection = nil
                }

                Divider()

                ForEach(TextFieldDemoColor.allCases) { color in
                    Button {
                        selection = color
                    } label: {
                        Text(color.title)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Circle()
                        .fill((selection?.color ?? .clear))
                        .overlay {
                            Circle()
                                .stroke(Color.gray2, lineWidth: selection == nil ? 1 : 0)
                        }
                        .frame(width: 16, height: 16)

                    Text(selection?.title ?? defaultTitle)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }
}

private enum TextFieldDemoColor: String, CaseIterable, Identifiable {
    case main
    case main2
    case systemError
    case gray2
    case gray4
    case gray7
    case gray10

    var id: String { rawValue }

    var title: String {
        switch self {
        case .main: "Main (#FFE24A)"
        case .main2: "Main2 (#FFEE92)"
        case .systemError: "SystemError (#FC2C30)"
        case .gray2: "Gray2 (#E4E4E4)"
        case .gray4: "Gray4 (#B7B7B7)"
        case .gray7: "Gray7 (#6A6A6A)"
        case .gray10: "Gray10 (#111111)"
        }
    }

    var color: Color {
        switch self {
        case .main: .main
        case .main2: .main2
        case .systemError: .systemError
        case .gray2: .gray2
        case .gray4: .gray4
        case .gray7: .gray7
        case .gray10: .gray10
        }
    }
}

private struct TextFieldDemoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

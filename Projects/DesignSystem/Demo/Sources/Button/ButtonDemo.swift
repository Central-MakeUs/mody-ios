import SwiftUI
import DesignSystem

struct ButtonDemo: View {
    @State private var selectedStyle: MButtonStyle = .primary
    @State private var isDisabled = false
    @State private var showsTrailingIcon = true
    @State private var horizontalPadding: CGFloat = 10
    @State private var verticalPadding: CGFloat = 10
    @State private var tapCount = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ButtonDemoSection(title: "Preview") {
                    VStack(alignment: .leading, spacing: 12) {
                        MButton(
                            "Label",
                            style: selectedStyle,
                            isDisabled: isDisabled,
                            horizontalPadding: horizontalPadding,
                            verticalPadding: verticalPadding,
                            trailingIcon: showsTrailingIcon ? .icAward : nil
                        ) {
                            tapCount += 1
                        }

                        Text("Tap count: \(tapCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                ButtonDemoSection(title: "Controls") {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Style", selection: $selectedStyle) {
                            ForEach(ButtonDemoStyle.allCases) { style in
                                Text(style.title).tag(style.buttonStyle)
                            }
                        }
                        .pickerStyle(.segmented)

                        Toggle("Disabled", isOn: $isDisabled)
                            .font(.subheadline)

                        Toggle("Trailing Icon", isOn: $showsTrailingIcon)
                            .font(.subheadline)

                        ButtonDemoPaddingSlider(
                            title: "Horizontal Padding",
                            value: $horizontalPadding
                        )

                        ButtonDemoPaddingSlider(
                            title: "Vertical Padding",
                            value: $verticalPadding
                        )
                    }
                }

                ButtonDemoSection(title: "Styles") {
                    VStack(spacing: 12) {
                        ForEach(ButtonDemoStyle.allCases) { style in
                            MButton(
                                style.title,
                                style: style.buttonStyle
                            ) { }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                ButtonDemoSection(title: "Trailing Icon") {
                    HStack(spacing: 12) {
                        MButton(
                            "Label",
                            style: .primary,
                            trailingIcon: .icAward
                        ) { }

                        MButton(
                            "Label",
                            style: .black,
                            trailingIcon: .icAward
                        ) { }
                    }
                }

                ButtonDemoSection(title: "Disabled") {
                    VStack(spacing: 12) {
                        ForEach(ButtonDemoStyle.allCases) { style in
                            MButton(
                                style.title,
                                style: style.buttonStyle,
                                isDisabled: true,
                                trailingIcon: .icAward
                            ) { }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Button")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

private enum ButtonDemoStyle: String, CaseIterable, Identifiable {
    case primary
    case gray
    case black

    var id: String { rawValue }

    var title: String {
        switch self {
        case .primary: "Primary"
        case .gray: "Gray"
        case .black: "Black"
        }
    }

    var buttonStyle: MButtonStyle {
        switch self {
        case .primary: .primary
        case .gray: .gray
        case .black: .black
        }
    }
}

private struct ButtonDemoPaddingSlider: View {
    let title: String
    @Binding var value: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)

                Spacer()

                Text("\(Int(value))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: 0...32, step: 1)
        }
    }
}

private struct ButtonDemoSection<Content: View>: View {
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

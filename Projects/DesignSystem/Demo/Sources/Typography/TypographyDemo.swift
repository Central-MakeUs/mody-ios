import SwiftUI
import UIKit
import DesignSystem

struct TypographyDemo: View {
    @State private var selectedStyle: ModyTypography = .b5
    
    private let samples: [TypographyDemoSample] = [
        .init(
            title: "1 line",
            text: "Mody 한글 English 123",
            lineLimit: 1
        ),
        .init(
            title: "2 lines",
            text: "Mody Typography는 한글 English 123이 섞여도 같은 높이로 보여야 합니다.",
            lineLimit: 2
        ),
        .init(
            title: "3 lines",
            text: "Pretendard Bold SemiBold Medium 12345 가나다 ABC를 여러 줄로 배치해 줄간격과 패딩을 확인합니다.",
            lineLimit: 3
        ),
        .init(
            title: "Ellipsis",
            text: "아주 긴 한글 English 123 텍스트가 한 줄 안에서 자연스럽게 말줄임표로 잘리는지 확인합니다.",
            lineLimit: 1
        ),
        .init(
            title: "Underline",
            text: "Underline 테스트 한글 English 123",
            lineLimit: 1,
            underline: true
        )
    ]
    
    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding: CGFloat = 20
            let contentWidth = max(0, proxy.size.width - horizontalPadding * 2)
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    stylePicker
                    allStylesPreview
                    
                    ForEach(samples) { sample in
                        TypographyDemoSampleView(sample: sample, style: selectedStyle)
                    }
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 20)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .navigationTitle("Typography")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    private var stylePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Style")
                .font(.headline)
            
            Picker("Style", selection: $selectedStyle) {
                ForEach(ModyTypography.allCases, id: \.self) { style in
                    Text(style.name).tag(style)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private var allStylesPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("All Styles")
                .font(.headline)
            
            ForEach(ModyTypography.allCases, id: \.self) { style in
                HStack(spacing: 12) {
                    Text(style.name)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .leading)
                    
                    MText("한글 English 123", style: style, lineLimit: 1, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct TypographyDemoSampleView: View {
    let sample: TypographyDemoSample
    let style: ModyTypography
    
    private let comparisonColumns = [
        GridItem(.flexible(minimum: 0), spacing: 12, alignment: .topLeading),
        GridItem(.flexible(minimum: 0), spacing: 0, alignment: .topLeading)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(sample.title)
                    .font(.headline)
                Spacer()
                Text(style.name)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            
            comparisonRows
            
            TypographyComparisonRow(title: "Overlay: SwiftUI red + UIKit blue") {
                ZStack(alignment: .leading) {
                    MText(
                        sample.text,
                        style: style,
                        color: .red.opacity(0.55),
                        lineLimit: sample.lineLimit,
                        underline: sample.underline,
                        alignment: .leading
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    UIKitTypographyLabel(
                        text: sample.text,
                        style: style,
                        color: UIColor.systemBlue.withAlphaComponent(0.55),
                        lineLimit: sample.lineLimit,
                        underline: sample.underline,
                        alignment: .left
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var comparisonRows: some View {
        LazyVGrid(columns: comparisonColumns, alignment: .leading, spacing: 12) {
            TypographyComparisonRow(title: "SwiftUI") {
                swiftUIText
            }
            
            TypographyComparisonRow(title: "UIKit") {
                uiKitText
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var swiftUIText: some View {
        MText(
            sample.text,
            style: style,
            color: .systemBlack,
            lineLimit: sample.lineLimit,
            underline: sample.underline,
            alignment: .leading
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }
    
    private var uiKitText: some View {
        UIKitTypographyLabel(
            text: sample.text,
            style: style,
            color: .systemBlack,
            lineLimit: sample.lineLimit,
            underline: sample.underline,
            alignment: .left
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }
}

private struct TypographyComparisonRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            content
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct UIKitTypographyLabel: UIViewRepresentable {
    let text: String
    let style: ModyTypography
    let color: UIColor
    let lineLimit: Int?
    let underline: Bool
    let alignment: NSTextAlignment
    
    func makeUIView(context: Context) -> MUILabel {
        let label = MUILabel(
            text: text,
            style: style,
            color: color,
            numberOfLines: lineLimit ?? 0,
            underline: underline,
            alignment: alignment
        )
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    func updateUIView(_ uiView: MUILabel, context: Context) {
        uiView.configure(
            text: text,
            style: style,
            color: color,
            numberOfLines: lineLimit ?? 0,
            underline: underline,
            alignment: alignment
        )
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: MUILabel, context: Context) -> CGSize? {
        guard let width = proposal.width else {
            return nil
        }
        
        uiView.preferredMaxLayoutWidth = width
        let fittingSize = uiView.sizeThatFits(
            CGSize(
                width: width,
                height: UIView.layoutFittingExpandedSize.height
            )
        )
        
        return CGSize(width: width, height: fittingSize.height)
    }
}

private struct TypographyDemoSample: Identifiable {
    let id = UUID()
    let title: String
    let text: String
    let lineLimit: Int?
    var underline: Bool = false
}

private extension ModyTypography {
    var name: String {
        switch self {
        case .h1: "h1"
        case .h2: "h2"
        case .h3: "h3"
        case .b1: "b1"
        case .b2: "b2"
        case .b3: "b3"
        case .b4: "b4"
        case .b5: "b5"
        case .b6: "b6"
        case .b7: "b7"
        case .c1: "c1"
        case .c2: "c2"
        case .c3: "c3"
        }
    }
}

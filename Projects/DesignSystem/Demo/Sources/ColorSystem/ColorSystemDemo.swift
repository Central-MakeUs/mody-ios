import SwiftUI
import UIKit
import DesignSystem

struct ColorSystemDemo: View {
    private let sections: [ColorSystemDemoSection] = [
        .init(
            title: "Gray",
            colors: [
                .init(token: "Gray1", color: .gray1, uiColor: .gray1),
                .init(token: "Gray2", color: .gray2, uiColor: .gray2),
                .init(token: "Gray3", color: .gray3, uiColor: .gray3),
                .init(token: "Gray4", color: .gray4, uiColor: .gray4),
                .init(token: "Gray5", color: .gray5, uiColor: .gray5),
                .init(token: "Gray6", color: .gray6, uiColor: .gray6),
                .init(token: "Gray7", color: .gray7, uiColor: .gray7),
                .init(token: "Gray8", color: .gray8, uiColor: .gray8),
                .init(token: "Gray9", color: .gray9, uiColor: .gray9),
                .init(token: "Gray10", color: .gray10, uiColor: .gray10)
            ]
        ),
        .init(
            title: "Primary",
            colors: [
                .init(token: "Main0", color: .main0, uiColor: .main0),
                .init(token: "Main", color: .main, uiColor: .main),
                .init(token: "Main2", color: .main2, uiColor: .main2),
                .init(token: "Main3", color: .main3, uiColor: .main3),
                .init(token: "Main4", color: .main4, uiColor: .main4)
            ]
        ),
        .init(
            title: "Secondary",
            colors: [
                .init(token: "Sub", color: .sub, uiColor: .sub),
                .init(token: "Sub2", color: .sub2, uiColor: .sub2),
                .init(token: "Sub3", color: .sub3, uiColor: .sub3),
                .init(token: "Sub4", color: .sub4, uiColor: .sub4)
            ]
        ),
        .init(
            title: "System",
            colors: [
                .init(token: "SystemBlack", color: .systemBlack, uiColor: .systemBlack),
                .init(token: "SystemWhite", color: .systemWhite, uiColor: .systemWhite),
                .init(token: "SystemError", color: .systemError, uiColor: .systemError)
            ]
        )
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 88), spacing: 8, alignment: .top)
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(sections) { section in
                    ColorSystemDemoSectionView(section: section, columns: columns)
                }
            }
            .padding(16)
        }
        .navigationTitle("Color System")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

private struct ColorSystemDemoSectionView: View {
    let section: ColorSystemDemoSection
    let columns: [GridItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(.subheadline.weight(.semibold))
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(section.colors) { item in
                    ColorSystemDemoSwatch(item: item)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ColorSystemDemoSwatch: View {
    let item: ColorSystemDemoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 6)
                .fill(item.color)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.token)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(item.hex)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ColorSystemDemoSection: Identifiable {
    let id = UUID()
    let title: String
    let colors: [ColorSystemDemoItem]
}

private struct ColorSystemDemoItem: Identifiable {
    let id = UUID()
    let token: String
    let color: Color
    let uiColor: UIColor
    
    var hex: String {
        uiColor.hexString
    }
}

private extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#------"
        }
        
        let rgb = [red, green, blue].map { Int(round($0 * 255)) }
        return String(format: "#%02X%02X%02X", rgb[0], rgb[1], rgb[2])
    }
}

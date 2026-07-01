import SwiftUI

@main
struct DesignSystemDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DesignSystemDemoHomeView()
        }
    }
}

private struct DesignSystemDemoHomeView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Typography") {
                    TypographyDemo()
                }
                
            }
            .navigationTitle("DesignSystem")
        }
    }
}

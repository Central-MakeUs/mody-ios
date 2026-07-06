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
                
                NavigationLink("Color System") {
                    ColorSystemDemo()
                }
                
                NavigationLink("TextField") {
                    TextFieldDemo()
                }

                NavigationLink("Button") {
                    ButtonDemo()
                }

                NavigationLink("NavigationBar") {
                    NavigationBarDemo()
                }
            }
            .navigationTitle("DesignSystem")
        }
    }
}

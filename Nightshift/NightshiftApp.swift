import SwiftUI

@main
struct NightshiftApp: App {
    @State private var store = Store()
    @AppStorage("theme") private var theme = 0
    @AppStorage("fontSize") private var fontSize = 2
    @AppStorage("accent") private var accentHex = ""

    init() {
        UserDefaults.standard.set([UserDefaults.standard.string(forKey: "language") ?? "en"], forKey: "AppleLanguages")
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Calendar", systemImage: "calendar") {
                    CalendarView()
                }
                Tab("Statistics", systemImage: "chart.bar") {
                    StatsView()
                }
                Tab("Settings", systemImage: "gearshape") {
                    SettingsView()
                }
            }
            .environment(store)
            .environment(\.accent, themeColor(accentHex))
            .tint(themeColor(accentHex))
            .fontDesign(.rounded)
            .dynamicTypeSize(fontSizes[fontSize])
            .preferredColorScheme(theme == 1 ? .light : theme == 2 ? .dark : nil)
        }
    }
}

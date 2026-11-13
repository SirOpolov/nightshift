import SwiftUI

@main
struct NightshiftApp: App {
    @State private var store = Store()
    @AppStorage("theme") private var theme = 0
    @AppStorage("fontSize") private var fontSize = 2

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Kalender", systemImage: "calendar") {
                    CalendarView()
                }
                Tab("Auswertung", systemImage: "chart.bar") {
                    StatsView()
                }
                Tab("Einstellungen", systemImage: "gearshape") {
                    SettingsView()
                }
            }
            .environment(store)
            .fontDesign(.rounded)
            .dynamicTypeSize(fontSizes[fontSize])
            .preferredColorScheme(theme == 1 ? .light : theme == 2 ? .dark : nil)
        }
    }
}

import SwiftUI
import QuickLook

let fontSizes: [DynamicTypeSize] = [.small, .medium, .large, .xLarge, .xxLarge]
let fontSizeNames = [String(localized: "Small"), String(localized: "Medium"), String(localized: "Normal"), String(localized: "Large"), String(localized: "Extra Large")]

struct SettingsView: View {
    @Environment(Store.self) private var store
    @AppStorage("theme") private var theme = 0
    @AppStorage("fontSize") private var fontSize = 2
    @AppStorage("accent") private var accent = ""
    @AppStorage("language") private var language = "en"
    @State private var confirmDelete = false
    @State private var exportYear = calendar.component(.year, from: .now)
    @State private var pdf: URL?
    private let swatches = ["", "#007AFF", "#5856D6", "#AF52DE", "#FF2D55", "#FF3B30", "#34C759", "#30B0C7"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Theme", selection: $theme) {
                        Text("Auto").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    .pickerStyle(.segmented)
                    Stepper("Font size: \(fontSizeNames[fontSize])", value: $fontSize, in: 0...4)
                } header: {
                    Text("Appearance")
                }
                Section {
                    Picker("Language", selection: $language) {
                        Text(verbatim: "English").tag("en")
                        Text(verbatim: "Deutsch").tag("de")
                    }
                } footer: {
                    Text("Takes effect after restarting the app.")
                }
                Section {
                    HStack(spacing: 10) {
                        ForEach(swatches, id: \.self) { hex in
                            Button {
                                accent = hex
                            } label: {
                                Circle()
                                    .fill(themeColor(hex))
                                    .frame(width: 28, height: 28)
                                    .overlay {
                                        if accent == hex {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    ColorPicker("Custom Color", selection: Binding(get: { themeColor(accent) }, set: { accent = hexString($0) }), supportsOpacity: false)
                    HStack {
                        Text("Hex")
                        TextField("#RRGGBB", text: $accent)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .font(.body.monospaced())
                            .multilineTextAlignment(.trailing)
                    }
                    if !accent.isEmpty {
                        Button("Restore Default Color") {
                            accent = ""
                        }
                    }
                } header: {
                    Text("Accent Color")
                }
                Section {
                    NavigationLink("Edit Shifts") {
                        ShiftEditor()
                    }
                    ForEach(store.shiftTypes) { shift in
                        HStack {
                            Circle()
                                .fill(shift.tint)
                                .frame(width: 12, height: 12)
                            Text(shift.label)
                            Spacer()
                            Text(shift.time)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Shifts")
                } footer: {
                    Text("A 30 minute break is deducted per work day. Vacation and Day off count 0 hours. Statistics only count days up to today.")
                }
                Section {
                    Picker("Year", selection: $exportYear) {
                        ForEach(years, id: \.self) { value in
                            Text(String(value)).tag(value)
                        }
                    }
                    Button("Export PDF") {
                        pdf = renderReport(YearReport(store: store, year: exportYear))
                    }
                } header: {
                    Text("Export")
                } footer: {
                    Text("Yearly report as PDF to share, save or print.")
                }
                Section {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    LabeledContent("Entries", value: String(store.entries.count))
                } header: {
                    Text("Info")
                }
                Section {
                    Button("Delete All Data", role: .destructive) {
                        confirmDelete = true
                    }
                    .confirmationDialog("Delete all entries?", isPresented: $confirmDelete, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            store.clear()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .quickLookPreview($pdf)
        }
    }

    private var years: [Int] {
        let used = store.entries.keys.compactMap { Int($0.prefix(4)) }
        return Set(used + [calendar.component(.year, from: .now)]).sorted()
    }
}

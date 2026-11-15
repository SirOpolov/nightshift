import SwiftUI
import QuickLook

let fontSizes: [DynamicTypeSize] = [.small, .medium, .large, .xLarge, .xxLarge]
let fontSizeNames = ["Klein", "Mittel", "Normal", "Groß", "Sehr groß"]

struct SettingsView: View {
    @Environment(Store.self) private var store
    @AppStorage("theme") private var theme = 0
    @AppStorage("fontSize") private var fontSize = 2
    @AppStorage("accent") private var accent = ""
    @State private var confirmDelete = false
    @State private var exportYear = calendar.component(.year, from: .now)
    @State private var pdf: URL?
    private let swatches = ["", "#007AFF", "#5856D6", "#AF52DE", "#FF2D55", "#FF3B30", "#34C759", "#30B0C7"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Erscheinungsbild", selection: $theme) {
                        Text("Auto").tag(0)
                        Text("Hell").tag(1)
                        Text("Dunkel").tag(2)
                    }
                    .pickerStyle(.segmented)
                    Stepper("Schriftgröße: " + fontSizeNames[fontSize], value: $fontSize, in: 0...4)
                } header: {
                    Text("Darstellung")
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
                    ColorPicker("Eigene Farbe", selection: Binding(get: { themeColor(accent) }, set: { accent = hexString($0) }), supportsOpacity: false)
                    HStack {
                        Text("Hex")
                        TextField("#RRGGBB", text: $accent)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .font(.body.monospaced())
                            .multilineTextAlignment(.trailing)
                    }
                    if !accent.isEmpty {
                        Button("Standardfarbe wiederherstellen") {
                            accent = ""
                        }
                    }
                } header: {
                    Text("Akzentfarbe")
                }
                Section {
                    NavigationLink("Schichten anpassen") {
                        ShiftEditor()
                    }
                    ForEach(store.shiftTypes) { shift in
                        HStack {
                            Circle()
                                .fill(shift.tint)
                                .frame(width: 12, height: 12)
                            Text(shift.name.isEmpty ? shift.id : shift.id + " (" + shift.name + ")")
                            Spacer()
                            Text(shift.time)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Schichten")
                } footer: {
                    Text("Pro Arbeitstag werden 30 Minuten Pause abgezogen. Urlaub und Frei zählen 0 Stunden. Die Auswertung zählt nur Tage bis heute.")
                }
                Section {
                    Picker("Jahr", selection: $exportYear) {
                        ForEach(years, id: \.self) { value in
                            Text(String(value)).tag(value)
                        }
                    }
                    Button("PDF exportieren") {
                        pdf = renderReport(YearReport(store: store, year: exportYear), accent: themeColor(accent))
                    }
                } header: {
                    Text("Export")
                } footer: {
                    Text("Jahresauswertung als PDF zum Teilen, Speichern oder Drucken.")
                }
                Section {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    LabeledContent("Einträge", value: String(store.entries.count))
                } header: {
                    Text("Info")
                }
                Section {
                    Button("Beispieldaten erzeugen") {
                        store.fillDemo()
                    }
                    NavigationLink("Rohdaten") {
                        ScrollView {
                            Text(raw)
                                .font(.caption.monospaced())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                        }
                        .navigationTitle("Rohdaten")
                    }
                    Button("Alle Daten löschen", role: .destructive) {
                        confirmDelete = true
                    }
                } header: {
                    Text("Entwickler")
                }
            }
            .navigationTitle("Einstellungen")
            .quickLookPreview($pdf)
            .confirmationDialog("Alle Einträge löschen?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    store.clear()
                }
            }
        }
    }

    private var years: [Int] {
        let used = store.entries.keys.compactMap { Int($0.prefix(4)) }
        return Set(used + [calendar.component(.year, from: .now)]).sorted()
    }

    private var raw: String {
        store.entries.sorted { $0.key < $1.key }.map { $0.key + "  " + $0.value }.joined(separator: "\n")
    }
}

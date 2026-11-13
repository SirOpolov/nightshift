import SwiftUI

let fontSizes: [DynamicTypeSize] = [.small, .medium, .large, .xLarge, .xxLarge]
let fontSizeNames = ["Klein", "Mittel", "Normal", "Groß", "Sehr groß"]

struct SettingsView: View {
    @Environment(Store.self) private var store
    @AppStorage("theme") private var theme = 0
    @AppStorage("fontSize") private var fontSize = 2
    @State private var confirmDelete = false

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
            .confirmationDialog("Alle Einträge löschen?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    store.clear()
                }
            }
        }
    }

    private var raw: String {
        store.entries.sorted { $0.key < $1.key }.map { $0.key + "  " + $0.value }.joined(separator: "\n")
    }
}

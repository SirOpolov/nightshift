import SwiftUI

struct ShiftEditor: View {
    @Environment(Store.self) private var store
    @State private var selected: Set<String> = []
    @State private var adding = false
    @State private var confirmDelete = false

    var body: some View {
        List(store.shiftTypes) { shift in
            Button {
                if selected.contains(shift.id) {
                    selected.remove(shift.id)
                } else {
                    selected.insert(shift.id)
                }
            } label: {
                HStack {
                    Circle()
                        .fill(shift.tint)
                        .frame(width: 12, height: 12)
                    Text(shift.name.isEmpty ? shift.id : shift.id + " (" + shift.name + ")")
                    Spacer()
                    Text(shift.time)
                        .foregroundStyle(.secondary)
                    Image(systemName: selected.contains(shift.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(.tint)
                }
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Schichten anpassen")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button("Hinzufügen") {
                    adding = true
                }
                .buttonStyle(.glassProminent)
                .popover(isPresented: $adding) {
                    ShiftForm()
                        .frame(minWidth: 320, minHeight: 360)
                        .presentationCompactAdaptation(.popover)
                }
                Button("Löschen", role: .destructive) {
                    confirmDelete = true
                }
                .buttonStyle(.glass)
                .disabled(selected.isEmpty)
                .confirmationDialog(
                    selected.count == 1 ? "Schicht löschen?" : String(selected.count) + " Schichten löschen?",
                    isPresented: $confirmDelete,
                    titleVisibility: .visible
                ) {
                    Button("Löschen", role: .destructive) {
                        store.remove(selected)
                        selected = []
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct ShiftForm: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var id = ""
    @State private var name = ""
    @State private var start = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: .now)!
    @State private var end = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: .now)!

    private var valid: Bool {
        !id.isEmpty && !store.shiftTypes.contains { $0.id == id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Schichtname (z. B. F15)", text: $id)
                    TextField("Schichtbeschreibung (z. B. früh)", text: $name)
                    DatePicker("Beginn", selection: $start, displayedComponents: .hourAndMinute)
                    DatePicker("Ende", selection: $end, displayedComponents: .hourAndMinute)
                } footer: {
                    if store.shiftTypes.contains(where: { $0.id == id }) {
                        Text("Diesen Schichtnamen gibt es schon.")
                    }
                }
            }
            .navigationTitle("Neue Schicht")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button("Hinzufügen") {
                        store.add(id: id, name: name, start: time(start), end: time(end))
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!valid)
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .buttonStyle(.glass)
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func time(_ date: Date) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", parts.hour!, parts.minute!)
    }
}

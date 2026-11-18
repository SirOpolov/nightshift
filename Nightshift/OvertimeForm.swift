import SwiftUI

struct OvertimeForm: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    let date: Date
    @State private var hours = 0
    @State private var minutes = 0

    private var valid: Bool {
        (0...23).contains(hours) && (0...59).contains(minutes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    field("Stunden", $hours)
                    field("Minuten", $minutes)
                } footer: {
                    if !valid {
                        Text("Höchstens 23 Stunden und 59 Minuten.")
                    }
                }
            }
            .navigationTitle("Überstunden " + date.formatted(.dateTime.day().month(.twoDigits)))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button("Speichern") {
                        store.setOvertime(hours * 60 + minutes, on: date)
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
        .onAppear {
            let total = store.overtimeMinutes(on: date)
            hours = total / 60
            minutes = total % 60
        }
    }

    private func field(_ label: String, _ value: Binding<Int>) -> some View {
        HStack {
            Text(label)
            TextField("0", value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
        }
    }
}

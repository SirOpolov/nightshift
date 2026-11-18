import SwiftUI

struct OvertimeForm: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    let date: Date
    @State private var hours = ""
    @State private var minutes = ""
    @State private var hoursSelection: TextSelection?
    @State private var minutesSelection: TextSelection?

    private var valid: Bool {
        (Int(hours) ?? 0) <= 23 && (Int(minutes) ?? 0) <= 59
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    field("Hours", $hours, $hoursSelection)
                    field("Minutes", $minutes, $minutesSelection)
                } footer: {
                    if !valid {
                        Text("At most 23 hours and 59 minutes.")
                    }
                }
            }
            .navigationTitle(String(localized: "Overtime \(date.formatted(.dateTime.day().month(.twoDigits)))"))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button("Save") {
                        store.setOvertime((Int(hours) ?? 0) * 60 + (Int(minutes) ?? 0), on: date)
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!valid)
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.glass)
                }
                .padding(.vertical, 8)
            }
        }
        .onAppear {
            let total = store.overtimeMinutes(on: date)
            if total > 0 {
                hours = String(total / 60)
                minutes = String(total % 60)
            }
        }
    }

    private func field(_ label: LocalizedStringKey, _ text: Binding<String>, _ selection: Binding<TextSelection?>) -> some View {
        HStack {
            Text(label)
            TextField("0", text: text, selection: selection)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: text.wrappedValue) {
                    let digits = String(text.wrappedValue.filter { ("0"..."9").contains($0) }.prefix(2))
                    if digits != text.wrappedValue {
                        text.wrappedValue = digits
                    }
                }
                .onChange(of: selection.wrappedValue) {
                    let end = TextSelection(insertionPoint: text.wrappedValue.endIndex)
                    if selection.wrappedValue != end {
                        selection.wrappedValue = end
                    }
                }
        }
    }
}

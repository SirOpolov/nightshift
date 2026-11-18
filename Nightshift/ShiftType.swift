import SwiftUI

struct ShiftType: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let start: String?
    let end: String?
    let color: String
    let vacation: Bool

    var minutes: Int {
        guard let start, let end else { return 0 }
        var duration = minutesOfDay(end) - minutesOfDay(start)
        if duration <= 0 {
            duration += 1440
        }
        return duration - 30
    }

    var title: String {
        Bundle.main.localizedString(forKey: id, value: id, table: "Shifts")
    }

    var label: String {
        name.isEmpty ? title : title + " (" + name + ")"
    }

    var time: String {
        guard let start, let end else { return "" }
        return start + " – " + end
    }

    var cellTime: String {
        guard let start, let end else { return "" }
        return start + " –\n" + end
    }

    var tint: Color {
        let value = Int(color.dropFirst(), radix: 16) ?? 0
        let red = Double((value >> 16) & 255) / 255
        let green = Double((value >> 8) & 255) / 255
        let blue = Double(value & 255) / 255
        return Color(red: red, green: green, blue: blue)
    }

    private func minutesOfDay(_ text: String) -> Int {
        let parts = text.split(separator: ":").compactMap { Int($0) }
        return parts[0] * 60 + parts[1]
    }
}

let baseShifts = [
    ShiftType(id: "Urlaub", name: "", start: nil, end: nil, color: "#FFF3A3", vacation: true),
    ShiftType(id: "Frei", name: "", start: nil, end: nil, color: "#D9D9DE", vacation: false)
]

let legacyShifts = [
    ShiftType(id: "F15", name: "früh", start: "06:45", end: "14:57", color: "#F8C8DC", vacation: false),
    ShiftType(id: "S21", name: "spät", start: "13:03", end: "21:15", color: "#A8E6CF", vacation: false),
    ShiftType(id: "N", name: "nacht", start: "21:00", end: "07:00", color: "#FFCBA4", vacation: false),
    ShiftType(id: "T07", name: "früh", start: "07:00", end: "15:12", color: "#D7BDE2", vacation: false)
] + baseShifts

func startShifts(hasEntries: Bool) -> [ShiftType] {
    hasEntries ? legacyShifts : baseShifts
}

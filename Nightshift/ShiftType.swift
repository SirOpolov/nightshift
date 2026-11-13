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

    var time: String {
        guard let start, let end else { return "" }
        return start + " – " + end
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

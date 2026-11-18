import Foundation

struct Stats {
    var minutes = 0
    var overtime = 0
    var vacationDays = 0
    var counts: [String: Int] = [:]

    init(entries: [String: String], overtime overtimeMinutes: [String: Int] = [:], shiftTypes: [ShiftType], from start: Date, to end: Date, today: Date) {
        let last = min(end, calendar.startOfDay(for: today))
        var date = start
        while date <= last {
            let key = dayKey(date)
            let id = entries[key]
            overtime += overtimeMinutes[key] ?? 0
            if let shift = shiftTypes.first(where: { $0.id == id }) {
                minutes += shift.minutes
                counts[shift.id, default: 0] += 1
                if shift.vacation {
                    vacationDays += 1
                }
            }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
    }
}

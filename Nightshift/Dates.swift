import Foundation

let calendar: Calendar = {
    var calendar = Calendar(identifier: .iso8601)
    calendar.locale = Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en")
    return calendar
}()

let weekdays = [String(localized: "Mo"), String(localized: "Tu"), String(localized: "We"), String(localized: "Th"), String(localized: "Fr"), String(localized: "Sa"), String(localized: "Su")]

func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day))!
}

func lastDay(_ year: Int, _ month: Int) -> Date {
    let first = day(year, month, 1)
    return day(year, month, calendar.range(of: .day, in: .month, for: first)!.count)
}

func dayKey(_ date: Date) -> String {
    let parts = calendar.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
}

func weeks(year: Int, month: Int) -> [[Date?]] {
    let first = day(year, month, 1)
    let count = calendar.range(of: .day, in: .month, for: first)!.count
    let offset = (calendar.component(.weekday, from: first) + 5) % 7
    var cells: [Date?] = Array(repeating: nil, count: offset)
    for number in 1...count {
        cells.append(day(year, month, number))
    }
    while cells.count % 7 != 0 {
        cells.append(nil)
    }
    return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
}

func weekNumber(_ week: [Date?]) -> Int {
    calendar.component(.weekOfYear, from: week.compactMap { $0 }[0])
}

func monthName(_ month: Int) -> String {
    calendar.standaloneMonthSymbols[month - 1]
}

func hours(_ minutes: Int) -> String {
    String(format: "%d:%02d h", minutes / 60, minutes % 60)
}

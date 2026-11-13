import Foundation
import Observation

@Observable
class Store {
    var entries: [String: String] = [:]
    let shiftTypes: [ShiftType]
    private let file = URL.documentsDirectory.appending(path: "entries.json")

    init() {
        let url = Bundle.main.url(forResource: "schichttypen", withExtension: "json")!
        shiftTypes = try! JSONDecoder().decode([ShiftType].self, from: Data(contentsOf: url))
        if let data = try? Data(contentsOf: file), let saved = try? JSONDecoder().decode([String: String].self, from: data) {
            entries = saved
        }
    }

    func shift(on date: Date) -> ShiftType? {
        let id = entries[dayKey(date)]
        return shiftTypes.first { $0.id == id }
    }

    func set(_ shift: ShiftType?, from start: Date, to end: Date) {
        var date = start
        while date <= end {
            entries[dayKey(date)] = shift?.id
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        save()
    }

    func stats(from start: Date, to end: Date) -> Stats {
        Stats(entries: entries, shiftTypes: shiftTypes, from: start, to: end, today: .now)
    }

    func fillDemo() {
        let first = calendar.dateInterval(of: .month, for: .now)!.start
        for offset in 0..<28 {
            let date = calendar.date(byAdding: .day, value: offset, to: first)!
            entries[dayKey(date)] = shiftTypes[(offset / 4) % shiftTypes.count].id
        }
        save()
    }

    func clear() {
        entries = [:]
        save()
    }

    private func save() {
        try? JSONEncoder().encode(entries).write(to: file)
    }
}

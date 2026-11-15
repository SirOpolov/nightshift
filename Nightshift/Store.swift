import Foundation
import Observation

@Observable
class Store {
    var entries: [String: String] = [:]
    private(set) var shiftTypes: [ShiftType] = []
    private let file = URL.documentsDirectory.appending(path: "entries.json")
    private let shiftFile = URL.documentsDirectory.appending(path: "schichten.json")
    private let colors = ["#F8C8DC", "#A8E6CF", "#FFCBA4", "#D7BDE2", "#B5D8F7", "#FFF3A3"]

    init() {
        let url = Bundle.main.url(forResource: "schichttypen", withExtension: "json")!
        if let data = try? Data(contentsOf: shiftFile), let saved = try? JSONDecoder().decode([ShiftType].self, from: data) {
            shiftTypes = saved
        } else {
            shiftTypes = try! JSONDecoder().decode([ShiftType].self, from: Data(contentsOf: url))
        }
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

    func add(id: String, name: String, start: String, end: String) {
        let color = colors[shiftTypes.count % colors.count]
        shiftTypes.append(ShiftType(id: id, name: name, start: start, end: end, color: color, vacation: false))
        try? JSONEncoder().encode(shiftTypes).write(to: shiftFile)
    }

    func remove(_ ids: Set<String>) {
        shiftTypes.removeAll { ids.contains($0.id) }
        entries = entries.filter { !ids.contains($0.value) }
        try? JSONEncoder().encode(shiftTypes).write(to: shiftFile)
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

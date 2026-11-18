import Foundation
import Observation

@Observable
class Store {
    var entries: [String: String] = [:]
    private(set) var overtime: [String: Int] = [:]
    private(set) var shiftTypes: [ShiftType] = []
    private let file = URL.documentsDirectory.appending(path: "entries.json")
    private let shiftFile = URL.documentsDirectory.appending(path: "schichten.json")
    private let overtimeFile = URL.documentsDirectory.appending(path: "overtime.json")
    private let colors = ["#F8C8DC", "#A8E6CF", "#FFCBA4", "#D7BDE2", "#B5D8F7", "#FFF3A3"]

    init() {
        if let data = try? Data(contentsOf: file), let saved = try? JSONDecoder().decode([String: String].self, from: data) {
            entries = saved
        }
        if let data = try? Data(contentsOf: overtimeFile), let saved = try? JSONDecoder().decode([String: Int].self, from: data) {
            overtime = saved
        }
        if let data = try? Data(contentsOf: shiftFile), let saved = try? JSONDecoder().decode([ShiftType].self, from: data) {
            shiftTypes = saved
        } else {
            shiftTypes = startShifts(hasEntries: !entries.isEmpty)
            saveShifts()
        }
    }

    func shift(on date: Date) -> ShiftType? {
        let id = entries[dayKey(date)]
        return shiftTypes.first { $0.id == id }
    }

    func overtimeMinutes(on date: Date) -> Int {
        overtime[dayKey(date)] ?? 0
    }

    func set(_ shift: ShiftType?, from start: Date, to end: Date) {
        var date = start
        while date <= end {
            entries[dayKey(date)] = shift?.id
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        save()
    }

    func setOvertime(_ minutes: Int, on date: Date) {
        overtime[dayKey(date)] = minutes > 0 ? minutes : nil
        saveOvertime()
    }

    func stats(from start: Date, to end: Date) -> Stats {
        Stats(entries: entries, overtime: overtime, shiftTypes: shiftTypes, from: start, to: end, today: .now)
    }

    func add(id: String, name: String, start: String, end: String) {
        let color = colors[shiftTypes.count % colors.count]
        shiftTypes.append(ShiftType(id: id, name: name, start: start, end: end, color: color, vacation: false))
        saveShifts()
    }

    func remove(_ ids: Set<String>) {
        shiftTypes.removeAll { ids.contains($0.id) }
        entries = entries.filter { !ids.contains($0.value) }
        saveShifts()
        save()
    }

    func clear() {
        entries = [:]
        overtime = [:]
        save()
        saveOvertime()
    }

    private func save() {
        try? JSONEncoder().encode(entries).write(to: file)
    }

    private func saveOvertime() {
        try? JSONEncoder().encode(overtime).write(to: overtimeFile)
    }

    private func saveShifts() {
        try? JSONEncoder().encode(shiftTypes).write(to: shiftFile)
    }
}
